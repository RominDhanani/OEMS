import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/theme/app_theme.dart';
import 'auth_provider.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeType>((ref) {
  final authState = ref.watch(authProvider);
  return ThemeNotifier(authState.user?.id);
});

class ThemeNotifier extends StateNotifier<AppThemeType> {
  final int? _userId;
  final _storage = const FlutterSecureStorage();
  
  ThemeNotifier(this._userId) : super(AppThemeType.light) {
    _loadTheme();
  }

  String get _themeKey => _userId != null ? 'theme_$_userId' : 'theme';

  Future<void> _loadTheme() async {
    try {
      final savedTheme = await _storage.read(key: _themeKey);
      if (!mounted) return;
      if (savedTheme != null) {
        state = AppThemeType.values.firstWhere(
          (t) => t.name == savedTheme,
          orElse: () => AppThemeType.light,
        );
      }
    } catch (e) {
      if (!mounted) return;
      state = AppThemeType.light;
    }
  }

  Future<void> setTheme(AppThemeType type) async {
    if (!mounted) return;
    state = type;
    await _storage.write(key: _themeKey, value: type.name);
  }

  Future<void> toggleTheme() async {
    if (!mounted) return;
    final nextIndex = (state.index + 1) % AppThemeType.values.length;
    final nextTheme = AppThemeType.values[nextIndex];
    await setTheme(nextTheme);
  }
}
