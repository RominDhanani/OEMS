import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/toast_provider.dart';
import '../../widgets/common/erp_toast.dart';
import '../../core/utils/path_utils.dart';
import 'active_sessions_screen.dart';
import '../../widgets/premium/premium_button.dart';
import '../../widgets/premium/glass_card.dart';
import '../../widgets/common/shake_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  File? _imageFile;

  final _nameShakeKey = GlobalKey<ShakeWidgetState>();
  final _mobileShakeKey = GlobalKey<ShakeWidgetState>();
  final _passwordShakeKey = GlobalKey<ShakeWidgetState>();
  final _confirmShakeKey = GlobalKey<ShakeWidgetState>();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.fullName);
    _emailController = TextEditingController(text: user?.email);
    _mobileController = TextEditingController(text: user?.mobileNumber);
    
    // Add listeners to detect dirty state
    _nameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _mobileController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {});
  }

  bool get _isDirty {
    final user = ref.read(authProvider).user;
    if (user == null) return false;
    
    return _nameController.text.trim() != user.fullName ||
           _emailController.text.trim() != user.email ||
           _mobileController.text.trim() != (user.mobileNumber ?? "") ||
           _passwordController.text.isNotEmpty ||
           _imageFile != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _handleUpdate() async {
    bool isValid = _formKey.currentState!.validate();
    
    if (_nameController.text.trim().isEmpty) _nameShakeKey.currentState?.shake();
    if (_mobileController.text.trim().isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(_mobileController.text.trim())) _mobileShakeKey.currentState?.shake();

    if (_passwordController.text.isNotEmpty) {
      if (_passwordController.text.length < 8 ||
          !RegExp(r'[A-Z]').hasMatch(_passwordController.text) ||
          !RegExp(r'\d').hasMatch(_passwordController.text)) {
        _passwordShakeKey.currentState?.shake();
        ref.read(toastProvider.notifier).show(message: "Password must be at least 8 chars long with uppercase and number", type: ToastType.error);
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        _confirmShakeKey.currentState?.shake();
        ref.read(toastProvider.notifier).show(message: "Passwords do not match", type: ToastType.error);
        return;
      }
    }

    if (!isValid) return;

    setState(() => _isLoading = true);
    try {
      final data = {
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'mobile_number': _mobileController.text.trim(),
      };
      
      if (_passwordController.text.isNotEmpty) {
        data['password'] = _passwordController.text;
      }

      final success = await ref.read(authServiceProvider).updateProfile(
        data,
        imagePath: _imageFile?.path,
      );

      if (success && mounted) {
        await ref.read(authProvider.notifier).checkAuthStatus();
        ref.read(toastProvider.notifier).show(
          message: "Profile updated successfully",
          type: ToastType.success,
        );
        setState(() {
          _isEditing = false;
          _passwordController.clear();
          _confirmPasswordController.clear();
          _imageFile = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ref.read(toastProvider.notifier).show(
          message: "Failed to update profile",
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDeleteImage() async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Photo?"),
        content: const Text("Are you sure you want to remove your profile picture?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("DELETE", style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final success = await ref.read(authServiceProvider).deleteProfileImage();
      if (success && mounted) {
        await ref.read(authProvider.notifier).checkAuthStatus();
        ref.read(toastProvider.notifier).show(
          message: "Profile photo removed",
          type: ToastType.success,
        );
        setState(() => _imageFile = null);
      }
    } catch (e) {
      if (mounted) {
        ref.read(toastProvider.notifier).show(
          message: "Failed to delete photo",
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Profile Settings",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.1)),
                ),
                child: Icon(Icons.edit_note_rounded, size: 20, color: theme.colorScheme.onSurface),
              ),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.1)),
                ),
                child: Icon(Icons.close_rounded, size: 20, color: theme.colorScheme.onSurface),
              ),
              onPressed: () => setState(() {
                _isEditing = false;
                _nameController.text = user?.fullName ?? "";
                _mobileController.text = user?.mobileNumber ?? "";
                _passwordController.clear();
                _confirmPasswordController.clear();
                _imageFile = null;
              }),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
          child: Column(
            children: [
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _isEditing ? _pickImage : null,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.secondary.withOpacity(0.1),
                            theme.colorScheme.secondary.withOpacity(0.01),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.secondary.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: theme.colorScheme.onSurface.withOpacity(0.05),
                        backgroundImage: _imageFile != null 
                          ? FileImage(_imageFile!) 
                          : (user?.profileImage != null ? NetworkImage(PathUtils.normalizeImageUrl(user!.profileImage)) : null) as ImageProvider?,
                        child: _imageFile == null && user?.profileImage == null
                          ? Icon(Icons.person_rounded, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3))
                          : null,
                      ),
                    ),
                    if (_isEditing) ...[
                      if (user?.profileImage != null || _imageFile != null)
                        Positioned(
                          bottom: 5,
                          left: 5,
                          child: GestureDetector(
                            onTap: _handleDeleteImage,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.scaffoldBackgroundColor, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.error.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.scaffoldBackgroundColor, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.secondary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (!_isEditing) ...[
                Text(
                  user?.fullName ?? "Fintech User",
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    user?.role ?? "USER",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.secondary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),

              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildSectionHeader(context, "Account Basics", Icons.person_outline_rounded),
                      const SizedBox(height: 20),
                      
                      if (_isEditing) ...[
                        ShakeWidget(
                          key: _nameShakeKey,
                          child: TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration(context, "Full Name", Icons.person_outline),
                            validator: (val) => val == null || val.trim().isEmpty ? "Required" : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          enabled: false,
                          decoration: _inputDecoration(context, "Email", Icons.email_outlined),
                        ),
                        const SizedBox(height: 16),
                        ShakeWidget(
                          key: _mobileShakeKey,
                          child: TextFormField(
                            controller: _mobileController,
                            decoration: _inputDecoration(context, "Mobile", Icons.phone_outlined),
                            validator: (val) {
                              if (val != null && val.trim().isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(val.trim())) {
                                return "Enter 10 digits";
                              }
                              return null;
                            },
                          ),
                        ),
                      ] else ...[
                        _buildReadOnlyField(context, "Full Name", user?.fullName ?? "", Icons.person_outline),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(context, "Email Address", user?.email ?? "", Icons.email_outlined),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(context, "Mobile Number", user?.mobileNumber ?? "Not provided", Icons.phone_android_outlined),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(context, "Employee ID", "#EMP-${user?.id.toString().padLeft(4, '0') ?? '0000'}", Icons.badge_outlined),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(context, "Designation / Role", (user?.role ?? "USER").toUpperCase(), Icons.stars_rounded),
                      ],
                      
                      const SizedBox(height: 32),
                      _buildSectionHeader(context, "Security Settings", Icons.lock_outline_rounded),
                      const SizedBox(height: 20),
                      
                      if (_isEditing) ...[
                        ShakeWidget(
                          key: _passwordShakeKey,
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: _inputDecoration(context, "New Password", Icons.lock_outline_rounded).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ShakeWidget(
                          key: _confirmShakeKey,
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscurePassword,
                            decoration: _inputDecoration(context, "Confirm Password", Icons.verified_user_outlined),
                            validator: (v) => _passwordController.text.isNotEmpty && v != _passwordController.text ? "Passwords do not match" : null,
                          ),
                        ),
                      ] else ...[
                        _buildReadOnlyField(context, "Password", "••••••••••••", Icons.lock_outline_rounded),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              if (!_isEditing)
                InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveSessionsScreen())),
                  borderRadius: BorderRadius.circular(24),
                  child: GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.security_rounded, color: theme.colorScheme.secondary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Active Sessions", style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                              const SizedBox(height: 2),
                              Text("Manage authorized devices", style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.65))),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurface.withOpacity(0.2)),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 48),
              if (!_isEditing)
                PremiumButton(
                  label: "SIGN OUT OF ACCOUNT",
                  icon: Icons.logout_rounded,
                  color: theme.colorScheme.error,
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Sign Out"),
                        content: const Text("Are you sure you want to exit the application?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL")),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.error,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("SIGN OUT", style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirmed == true) {
                      await ref.read(authProvider.notifier).logout();
                    }
                  },
                ),
            ],
          ),
        ),
      bottomNavigationBar: _isEditing 
        ? Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
            ),
            child: PremiumButton(
              label: "SAVE CHANGES",
              loadingLabel: "UPDATING...",
              isLoading: _isLoading,
              onPressed: _isDirty ? _handleUpdate : null,
              color: theme.colorScheme.secondary,
            ),
          )
        : null,
    );
  }

  Widget _buildReadOnlyField(BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.onSurface.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.secondary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label, IconData icon) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label.toUpperCase(),
      labelStyle: TextStyle(
        color: theme.colorScheme.onSurface.withOpacity(0.7),
        fontWeight: FontWeight.w900,
        fontSize: 10,
        letterSpacing: 1.2,
      ),
      prefixIcon: Icon(icon, color: theme.colorScheme.secondary, size: 20),
      filled: true,
      fillColor: theme.colorScheme.onSurface.withOpacity(0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.08)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.secondary),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.secondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: theme.colorScheme.secondary.withOpacity(0.12))),
      ],
    );
  }
}
