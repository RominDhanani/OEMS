import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/toast_provider.dart';
import '../../widgets/common/erp_toast.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/premium/premium_button.dart';
import '../../widgets/premium/glass_card.dart';
import '../../widgets/common/shake_widget.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final _emailShakeKey = GlobalKey<ShakeWidgetState>();


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
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      _emailShakeKey.currentState?.shake();
      ref.read(toastProvider.notifier).show(message: "Enter a valid email", type: ToastType.error);
      return;
    }

    try {
      final success = await ref.read(authServiceProvider).requestPasswordReset(email);
      if (success && mounted) {
        ref.read(toastProvider.notifier).show(
          message: "Reset link sent to your email",
          type: ToastType.success,
        );
        context.push('/login');
      }
    } catch (e) {
      if (mounted) {
        ref.read(toastProvider.notifier).show(message: "Failed to send reset link", type: ToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final authState = ref.watch(authProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(theme.brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
            color: theme.primaryColor,
            onPressed: () {
              final currentTheme = ref.read(themeProvider);
              final nextTheme = currentTheme == AppThemeType.light ? AppThemeType.dark : AppThemeType.light;
              ref.read(themeProvider.notifier).setTheme(nextTheme);
            },
          ),
          const SizedBox(width: 16),
        ],
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
                    top: -100,
                    right: -70,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.primaryColor.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    left: -80,
                    child: Container(
                      width: 220,
                      height: 220,
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
                          child: Form(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Icon(Icons.lock_reset_rounded, size: MediaQuery.of(context).size.width < 360 ? 48 : 60, color: theme.primaryColor),
                                const SizedBox(height: 18),
                                Text(
                                  "Reset Password",
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 9),
                                Text(
                                  "Enter your email address and we'll send you a link to reset your password.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 36),
                                ShakeWidget(
                                  key: _emailShakeKey,
                                  child: TextFormField(
                                    controller: _emailController,
                                    decoration: const InputDecoration(
                                      labelText: "Email Address",
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                 PremiumButton(
                                   label: "SEND RESET LINK",
                                   loadingLabel: "SENDING...",
                                   isLoading: authState.status == AuthStatus.loading,
                                   onPressed: _handleSubmit,
                                   borderRadius: 12,
                                   height: 48,
                                 ),
                                const SizedBox(height: 15),
                                TextButton(
                                  onPressed: () => context.pop(),
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
            ),
          ],
        ),
    );
  }
}

