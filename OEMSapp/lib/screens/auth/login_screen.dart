import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/auth_provider.dart';
import '../../providers/toast_provider.dart';
import '../../widgets/common/erp_toast.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/premium/glass_card.dart';
import '../../widgets/premium/premium_button.dart';
import '../../widgets/common/shake_widget.dart';


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animationController;
  final _emailShakeKey = GlobalKey<ShakeWidgetState>();
  final _passwordShakeKey = GlobalKey<ShakeWidgetState>();
  bool _isLoginLoading = false;
  bool _isOtpLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _animationController.forward();

    // Parity: Auto-logout if visiting Login while already authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.status == AuthStatus.authenticated) {
        ref.read(authProvider.notifier).logout();
        // Parity: Show success toast for session closure
        ref.read(toastProvider.notifier).show(
          message: "Your session has been securely closed.",
          type: ToastType.success,
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    HapticFeedback.mediumImpact();
    bool isValid = _formKey.currentState!.validate();
    if (!isValid) {
      if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
        _emailShakeKey.currentState?.shake();
      }
      if (_passwordController.text.isEmpty) {
        _passwordShakeKey.currentState?.shake();
      }
      return;
    }
    
    setState(() => _isLoginLoading = true);
    try {
      await ref.read(authProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } finally {
      if (mounted) setState(() => _isLoginLoading = false);
    }
  }

  Future<void> _handleOtpLogin() async {
    HapticFeedback.lightImpact();
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      _emailShakeKey.currentState?.shake();
      ref.read(toastProvider.notifier).show(message: "Enter a valid email address", type: ToastType.error);
      return;
    }

    setState(() => _isOtpLoading = true);
    try {
      final success = await ref.read(authProvider.notifier).requestLoginOtp(email);
      if (success && mounted) {
        context.push('/verify-otp', extra: {'email': email, 'flow': 'LOGIN'});
      } else if (mounted) {
        ref.read(toastProvider.notifier).show(message: "Failed to send OTP", type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isOtpLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Listen for errors
    ref.listen(authProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        ref.read(toastProvider.notifier).show(
          message: next.errorMessage ?? "Login failed",
          type: ToastType.error,
        );
      }
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: () {
              final currentTheme = ref.read(themeProvider);
              final nextTheme = currentTheme == AppThemeType.light ? AppThemeType.dark : AppThemeType.light;
              ref.read(themeProvider.notifier).setTheme(nextTheme);
            },
          ),
          const SizedBox(width: 8),
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
                    theme.primaryColor.withOpacity(isDark ? 0.2 : 0.1),
                    theme.scaffoldBackgroundColor,
                    theme.colorScheme.secondary.withOpacity(isDark ? 0.1 : 0.05),
                  ],
                ),
              ),
            ),
            // Animated Background Circles
            Positioned(
              top: -100,
              right: -100,
              child: IgnorePointer(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.primaryColor.withOpacity(0.1),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: IgnorePointer(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                  ),
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width < 360 ? 12 : 18,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Section with Entrance Animation
                        _buildAnimatedLogo(theme, isDark),
                        const SizedBox(height: 36),
                        // Glass Login Card with Staggered Elements
                        _buildStaggeredForm(theme, authState),
                        const SizedBox(height: 24),
                        _buildStaggeredFooter(theme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildAnimatedLogo(ThemeData theme, bool isDark) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.5)),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'app_logo',
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SvgPicture.string(
                  '<svg viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg"><path d="M320 336c0 8.84-7.16 16-16 16h-96c-8.84 0-16-7.16-16-16v-48H0v144c0 25.6 22.4 48 48 48h416c25.6 0 48-22.4 48-48V288H320v48zm144-208h-80V80c0-25.6-22.4-48-48-48H176c-25.6 0-48 22.4-48 48v48H48c-25.6 0-48 22.4-48 48v80h512v-80c0-25.6-22.4-48-48-48zm-144 0H192V96h128v32z" fill="white"></path></svg>',
                  width: 26,
                  height: 26,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "OFFICE EXPENSE",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        fontSize: 17,
                        color: isDark ? Colors.white : theme.primaryColor,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  Text(
                    "MANAGEMENT",
                    style: theme.textTheme.labelMedium?.copyWith(
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold,
                      color: (isDark ? Colors.white : theme.primaryColor).withOpacity(0.6),
                      fontSize: 9,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaggeredForm(ThemeData theme, AuthState authState) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _animationController, curve: const Interval(0.3, 0.7)),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
            .animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic))),
        child: GlassCard(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width < 360 ? 15 : 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Welcome Back",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Sign in to access your administrative tools and manage expenses securely.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ShakeWidget(
                  key: _emailShakeKey,
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email Address",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Please enter email";
                      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) return "Enter valid email";
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),
                ShakeWidget(
                  key: _passwordShakeKey,
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Please enter password";
                      return null;
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: Text("Forgot Password?", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 18),
                PremiumButton(
                  label: "LOGIN",
                  loadingLabel: "LOGGING IN...",
                  isLoading: _isLoginLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "OR",
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 18),
                PremiumButton(
                  label: "CONTINUE WITH OTP",
                  loadingLabel: "SENDING OTP...",
                  isLoading: _isOtpLoading,
                  onPressed: _handleOtpLogin,
                  isOutlined: true,
                  icon: Icons.phonelink_ring_rounded,
                  height: 45,
                  borderRadius: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaggeredFooter(ThemeData theme) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _animationController, curve: const Interval(0.6, 1.0)),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
            .animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut))),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text("Don't have an account? ", style: theme.textTheme.bodyMedium),
            TextButton(
              onPressed: () => context.push('/register'),
              child: Text("Register here", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

