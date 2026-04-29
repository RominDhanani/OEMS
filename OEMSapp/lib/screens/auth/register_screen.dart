import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/toast_provider.dart';
import '../../widgets/common/erp_toast.dart';
import '../../providers/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/premium/glass_card.dart';
import '../../widgets/premium/premium_dropdown.dart';
import '../../widgets/premium/premium_button.dart';
import '../../widgets/common/shake_widget.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  String _selectedRole = 'USER';
  bool _otpSent = false;
  bool _verifying = false;
  bool _obscurePassword = true;
  String? _verificationToken;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _nameShakeKey = GlobalKey<ShakeWidgetState>();
  final _emailShakeKey = GlobalKey<ShakeWidgetState>();
  final _mobileShakeKey = GlobalKey<ShakeWidgetState>();
  final _passwordShakeKey = GlobalKey<ShakeWidgetState>();
  final _otpShakeKey = GlobalKey<ShakeWidgetState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      _emailShakeKey.currentState?.shake();
      ref.read(toastProvider.notifier).show(
        message: "Enter a valid email address",
        type: ToastType.error,
      );
      return;
    }

    setState(() => _verifying = true);
    final success = await ref.read(authProvider.notifier).requestRegistrationOtp(email);
    setState(() => _verifying = false);

    if (success && mounted) {
      setState(() => _otpSent = true);
      ref.read(toastProvider.notifier).show(
        message: "Verification code sent to your email",
        type: ToastType.success,
      );
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _otpShakeKey.currentState?.shake();
      ref.read(toastProvider.notifier).show(
        message: "Enter 6-digit verification code",
        type: ToastType.error,
      );
      return;
    }

    setState(() => _verifying = true);
    final token = await ref.read(authProvider.notifier).verifyRegistrationOtp(
      _emailController.text.trim(),
      otp,
    );
    setState(() => _verifying = false);

    if (token != null && mounted) {
      setState(() {
        _verificationToken = token;
        _otpSent = false;
      });
      ref.read(toastProvider.notifier).show(
        message: "Email verified successfully!",
        type: ToastType.success,
      );
    }
  }

  Future<void> _handleRegister() async {
    bool isValid = _formKey.currentState!.validate();
    if (!isValid) {
      if (_nameController.text.trim().length < 3) _nameShakeKey.currentState?.shake();
      if (!RegExp(r'^\d{10}$').hasMatch(_mobileController.text.trim())) _mobileShakeKey.currentState?.shake();
      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_emailController.text.trim())) _emailShakeKey.currentState?.shake();
      if (_passwordController.text.length < 8 || !RegExp(r'[A-Z]').hasMatch(_passwordController.text) || !RegExp(r'\d').hasMatch(_passwordController.text)) _passwordShakeKey.currentState?.shake();

      return;
    }

    if (_verificationToken == null) {
      _emailShakeKey.currentState?.shake();
      ref.read(toastProvider.notifier).show(
        message: "Please verify your email first",
        type: ToastType.error,
      );
      return;
    }

      try {
        final Map<String, dynamic> registrationData = {
          'full_name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'mobile_number': _mobileController.text.trim(),
          'password': _passwordController.text,
          'role': _selectedRole,
          'verificationToken': _verificationToken,
        };
        await ref.read(authProvider.notifier).register(registrationData);

        if (mounted) {
          ref.read(toastProvider.notifier).show(
            message: "Registration successful! Please wait for approval.",
            type: ToastType.success,
          );
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          ref.read(toastProvider.notifier).show(
            message: e.toString(),
            type: ToastType.error,
          );
        }
      }
    }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Register", style: TextStyle(fontSize:22 , fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
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
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primaryColor.withOpacity(isDark ? 0.15 : 0.05),
                    theme.scaffoldBackgroundColor,
                    theme.colorScheme.secondary.withOpacity(isDark ? 0.1 : 0.05),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      children: [
                        _buildStaggeredForm(theme, authState),
                        const SizedBox(height: 14),
                        _buildFooter(theme),
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

  Widget _buildStaggeredForm(ThemeData theme, AuthState authState) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GlassCard(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Register",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Provide your details to register as a ${_selectedRole.toLowerCase()}",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 26),
                ShakeWidget(
                  key: _nameShakeKey,
                  child: TextFormField(
                    style: const TextStyle(fontSize: 16.5),
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      labelStyle: TextStyle(fontSize: 16.5),
                      prefixIcon: Icon(Icons.person_outline_rounded, size: 26),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 3) return "Min 3 chars";
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 26),
                ShakeWidget(
                  key: _mobileShakeKey,
                  child: TextFormField(
                    style: const TextStyle(fontSize: 16.5),
                    controller: _mobileController,
                    decoration: const InputDecoration(
                      labelText: "Mobile Number",
                      labelStyle: TextStyle(fontSize: 16.5),
                      prefixIcon: Icon(Icons.phone_android_rounded, size: 26),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Required";
                      if (!RegExp(r'^\d{10}$').hasMatch(value)) return "10 digits";
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 26),
                ShakeWidget(
                  key: _emailShakeKey,
                  child: TextFormField(
                    style: const TextStyle(fontSize: 16.5),
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                      labelStyle: const TextStyle(fontSize: 16.5),
                      prefixIcon: const Icon(Icons.email_outlined, size: 26),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _buildEmailAction(theme),
                      ),
                    ),
                    readOnly: _verificationToken != null || _otpSent,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                       if (value == null || value.isEmpty) return "Please enter email";
                       if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) return "Enter valid email";
                       return null;
                    },
                  ),
                ),
                if (_otpSent && _verificationToken == null) ...[
                  const SizedBox(height: 26),
                  ShakeWidget(
                    key: _otpShakeKey,
                    child: TextFormField(
                      style: const TextStyle(fontSize: 16.5),
                      controller: _otpController,
                      decoration: InputDecoration(
                        labelText: "Verification Code",
                        labelStyle: const TextStyle(fontSize: 16.5),
                        prefixIcon: const Icon(Icons.key_rounded, size: 26),
                        suffixIcon: TextButton(
                          onPressed: _verifying ? null : _handleVerifyOtp,
                          child: _verifying 
                            ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5))
                            : const Text("Verify", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _verifying ? null : _handleSendOtp,
                      child: const Text("Resend Code", style: TextStyle(fontSize: 13.5)),
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                ShakeWidget(
                  key: _passwordShakeKey,
                  child: TextFormField(
                    style: const TextStyle(fontSize: 16.5),
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(fontSize: 16.5),
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 26),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 26),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Password is required";
                      if (value.length < 8) return "Min 8 chars";
                      if (!RegExp(r'[A-Z]').hasMatch(value)) return "Include an uppercase letter";
                      if (!RegExp(r'\d').hasMatch(value)) return "Include at least one number";
                      return null;
                    },

                  ),
                ),
                const SizedBox(height: 26),
                PremiumDropdown<String>(
                  label: "Select Role",
                  initialValue: _selectedRole,
                  prefixIcon: Icons.badge_outlined,
                  items: [
                    PremiumDropdownItem(value: 'MANAGER', label: "Manager", icon: Icons.admin_panel_settings_rounded),
                    PremiumDropdownItem(value: 'USER', label: "General User", icon: Icons.person_rounded),
                  ],
                  onChanged: _verificationToken != null ? null : (val) => setState(() => _selectedRole = val!),
                ),
                const SizedBox(height: 26),
                PremiumButton(
                  label: "REGISTER",
                  loadingLabel: "REGISTERING...",
                  isLoading: authState.status == AuthStatus.loading,
                  onPressed: _verificationToken == null ? null : _handleRegister,
                  borderRadius: 12,
                  height: 48,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailAction(ThemeData theme) {
    if (_verificationToken != null) {
      return const Icon(Icons.check_circle_rounded, color: Colors.green);
    }
    if (_otpSent) {
      return TextButton(
        onPressed: () => setState(() => _otpSent = false),
        child: const Text("Change", style: TextStyle(fontWeight: FontWeight.bold)),
      );
    }
    return TextButton(
      onPressed: _verifying ? null : _handleSendOtp,
      child: _verifying 
        ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5))
        : const Text("Send OTP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text("Already have an account? "),
        TextButton(
          onPressed: () => context.pop(),
          child: const Text("Login here", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
