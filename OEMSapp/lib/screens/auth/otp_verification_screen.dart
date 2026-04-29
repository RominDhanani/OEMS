import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/toast_provider.dart';
import '../../widgets/common/erp_toast.dart';
import '../../widgets/premium/premium_button.dart';
import '../../widgets/common/shake_widget.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  final String flow; // 'LOGIN' or 'REGISTER'

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.flow,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  String? _errorMessage;

  late AnimationController _bgAnimationController;
  late AnimationController _entranceController;
  late List<Animation<double>> _otpAnimations;
  final _otpShakeKey = GlobalKey<ShakeWidgetState>();

  @override
  void initState() {
    super.initState();
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _otpAnimations = List.generate(
      6,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceController,
        curve: Interval(
          0.3 + (index * 0.05),
          0.7 + (index * 0.05),
          curve: Curves.easeOutBack,
        ),
        ),
      ),
    );

    _entranceController.forward();

    // Add listeners to rebuild when focus changes (for border highlighting)
    for (var node in _focusNodes) {
      node.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    _entranceController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }


  Future<void> _checkAndSubmit() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) {
      _otpShakeKey.currentState?.shake();
      setState(() => _errorMessage = "Please enter all 6 digits");
      return;
    }
    if (otp.length == 6) {
      if (widget.flow == 'LOGIN') {
        await ref.read(authProvider.notifier).loginWithOtp(widget.email, otp);
        if (mounted) {
          final state = ref.read(authProvider);
          if (state.status == AuthStatus.authenticated) {
            ref.read(toastProvider.notifier).show(
              message: "OTP Verified Successfully!",
              type: ToastType.success,
            );
            context.go('/login');
          } else if (state.status == AuthStatus.error) {
            setState(() => _errorMessage = state.errorMessage);
          }
        }
      } else {
        final token = await ref
            .read(authProvider.notifier)
            .verifyRegistrationOtp(widget.email, otp);
        if (mounted) {
          if (token != null) {
            ref.read(toastProvider.notifier).show(
              message: "Email verified successfully!",
              type: ToastType.success,
            );
            context.pop(token); // Return token to register screen
          } else {
            final state = ref.read(authProvider);
            setState(() {
               _errorMessage = state.errorMessage ?? "Invalid OTP";
               _otpShakeKey.currentState?.shake();
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    // Listen for authentication errors
    ref.listen(authProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ref.read(toastProvider.notifier).show(
              message: next.errorMessage!,
              type: ToastType.error,
            );
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
          children: [
            // Premium Background
            AnimatedBuilder(
            animation: _bgAnimationController,
            builder: (context, child) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.primaryColor.withOpacity(theme.brightness == Brightness.dark ? 0.15 : 0.05),
                          theme.scaffoldBackgroundColor,
                          theme.colorScheme.secondary.withOpacity(theme.brightness == Brightness.dark ? 0.1 : 0.05),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -100 + (30 * _bgAnimationController.value),
                    right: -70 + (20 * _bgAnimationController.value),
                    child: _buildAnimatedCircle(300, theme.primaryColor.withOpacity(0.1)),
                  ),
                  Positioned(
                    bottom: -50 + (40 * _bgAnimationController.value),
                    left: -100 + (20 * _bgAnimationController.value),
                    child: _buildAnimatedCircle(250, theme.colorScheme.secondary.withOpacity(0.1)),
                  ),
                ],
              );
            },
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: const BackButton(),
                  title: const Text("OTP Verification", style: TextStyle(fontWeight: FontWeight.bold)),
                  centerTitle: true,
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width < 360 ? 12 : 18,
                        vertical: 30,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.5)),
                            child: Container(
                              padding: EdgeInsets.all(MediaQuery.of(context).size.width < 360 ? 12 : 18),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.mark_email_read_rounded,
                                size: MediaQuery.of(context).size.width < 360 ? 42 : 60,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          FadeTransition(
                            opacity: CurvedAnimation(parent: _entranceController, curve: const Interval(0.2, 0.6)),
                            child: Column(
                              children: [
                                Text(
                                  "Check Your Email",
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: theme.primaryColor,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 9),
                                Text(
                                  "We've sent a 6-digit verification code to",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  widget.email,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 36),
                          
                          // OTP Input Section
                          ShakeWidget(
                            key: _otpShakeKey,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                6,
                                (index) {
                                  final child = ScaleTransition(
                                    scale: _otpAnimations[index],
                                    child: FadeTransition(
                                      opacity: _otpAnimations[index],
                                      child: _buildOtpSquare(index),
                                    ),
                                  );
                                  if (index == 0) return Expanded(child: child);
                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: child,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          if (_errorMessage != null) ...[
                            const SizedBox(height: 18),
                            SlideTransition(
                              position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
                                  .animate(CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut)),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],

                          const SizedBox(height: 36),
                          
                          FadeTransition(
                            opacity: CurvedAnimation(parent: _entranceController, curve: const Interval(0.7, 1.0)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                  PremiumButton(
                                    label: "VERIFY ACCOUNT",
                                    loadingLabel: "VERIFYING...",
                                    isLoading: authState.status == AuthStatus.loading,
                                    onPressed: _checkAndSubmit,
                                    borderRadius: 12,
                                    height: 48,
                                  ),
                                const SizedBox(height: 24),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      "Didn't receive the code? ",
                                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Handle resend
                                      },
                                      child: const Text(
                                        "Resend",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildOtpSquare(int index) {
    final theme = Theme.of(context);
    return Container(
      height: 45,
      constraints: const BoxConstraints(maxWidth: 42),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark 
            ? Colors.white.withOpacity(0.05) 
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focusNodes[index].hasFocus 
              ? theme.primaryColor 
              : theme.colorScheme.onSurface.withOpacity(0.08),
          width: 2,
        ),
        boxShadow: _focusNodes[index].hasFocus ? [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          showCursor: false, // Hide cursor to prevent artifacts
          style: TextStyle(
            fontSize: 21, 
            fontWeight: FontWeight.w900,
            color: theme.primaryColor,
            height: 1.2, // Fix vertical centering
          ),
          decoration: const InputDecoration(
            counterText: "",
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              if (index < 5) {
                _focusNodes[index + 1].requestFocus();
              }
              _checkAndSubmit();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          },
        ),
      ),
    );
  }
}

