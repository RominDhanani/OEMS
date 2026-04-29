import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/toast_provider.dart';
import '../../widgets/common/erp_toast.dart';
import '../../widgets/premium/premium_button.dart';
import '../../widgets/premium/glass_card.dart';
import '../../widgets/common/shake_widget.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final _passwordShakeKey = GlobalKey<ShakeWidgetState>();
  final _confirmShakeKey = GlobalKey<ShakeWidgetState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.length < 8) {
      _passwordShakeKey.currentState?.shake();
      ref
          .read(toastProvider.notifier)
          .show(
            message: "Password must be at least 8 characters long",
            type: ToastType.error,
          );
      return;
    }
    if (!RegExp(r'[A-Z]').hasMatch(password) ||
        !RegExp(r'\d').hasMatch(password)) {
      _passwordShakeKey.currentState?.shake();
      ref
          .read(toastProvider.notifier)
          .show(
            message: "Password must contain uppercase and numbers",
            type: ToastType.error,
          );
      return;
    }
    if (password != confirm) {
      _confirmShakeKey.currentState?.shake();
      ref
          .read(toastProvider.notifier)
          .show(message: "Passwords do not match", type: ToastType.error);
      return;
    }

    try {
      final success = await ref
          .read(authServiceProvider)
          .resetPassword(widget.token, password);
      if (success && mounted) {
        ref
            .read(toastProvider.notifier)
            .show(
              message: "Password reset successful. Please login.",
              type: ToastType.success,
            );
        context.push('/login');
      }
    } catch (e) {
      if (mounted) {
        ref
            .read(toastProvider.notifier)
            .show(message: "Failed to reset password", type: ToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final authState = ref.watch(authProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Set New Password"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
          children: [
            // Background Gradient
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
                    top: -80,
                    right: -60,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.primaryColor.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -40,
                    left: -70,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.secondary.withOpacity(0.08),
                      ),
                    ),
                  ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width < 360 ? 12 : 18,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: GlassCard(
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width < 360 ? 15 : 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Icon(
                                Icons.vpn_key_rounded,
                                size: MediaQuery.of(context).size.width < 360 ? 48 : 60,
                                color: theme.primaryColor,
                              ),
                              const SizedBox(height: 18),
                              Text(
                                "Create New Password",
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                "Your identity has been verified. Please set a strong new password for your account.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 36),
                                ShakeWidget(
                                  key: _passwordShakeKey,
                                  child: TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: "New Password",
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscurePassword = !_obscurePassword,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ShakeWidget(
                                  key: _confirmShakeKey,
                                  child: TextFormField(
                                    controller: _confirmController,
                                    obscureText: _obscurePassword,
                                    decoration: const InputDecoration(
                                      labelText: "Confirm Password",
                                      prefixIcon: Icon(Icons.lock_clock_outlined),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 30),
                               PremiumButton(
                                 label: "RESET PASSWORD",
                                 loadingLabel: "UPDATING...",
                                 isLoading: authState.status == AuthStatus.loading,
                                 onPressed: _handleSubmit,
                                 borderRadius: 12,
                                 height: 48,
                               ),
                              const SizedBox(height: 20),
                              TextButton(
                                onPressed: () => context.push('/login'),
                                child: const Text("Return to Login", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}

