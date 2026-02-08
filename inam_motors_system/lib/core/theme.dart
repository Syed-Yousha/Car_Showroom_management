import 'package:fluent_ui/fluent_ui.dart';
import '../main.dart';

class AppTheme {
  static const String fontFamily = 'Inter';

  static bool get _isDark => InamMotorsApp.isDarkMode.value;

  // ── Dynamic colors that switch with dark mode ──
  static Color get background => _isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FB);
  static Color get cardColor => _isDark ? const Color(0xFF222240) : const Color(0xFFFFFFFF);
  static Color get surfaceColor => _isDark ? const Color(0xFF222240) : const Color(0xFFFFFFFF);
  static Color get divider => _isDark ? const Color(0xFF2E2E4A) : const Color(0xFFEEEFF2);
  static Color get textPrimary => _isDark ? const Color(0xFFE8E8F0) : const Color(0xFF1A1A2E);
  static Color get textSecondary => _isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
  static Color get textMuted => _isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);
  static Color get primaryLight => _isDark ? const Color(0xFF2A2650) : const Color(0xFFEBE8FA);

  // Brand Colors (same in both modes)
  static const Color primary = Color(0xFF6C5DD3);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static FluentThemeData get lightTheme {
    return FluentThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8F9FB),
      cardColor: const Color(0xFFFFFFFF),
      accentColor: primary.toAccentColor(),
      navigationPaneTheme: NavigationPaneThemeData(
        backgroundColor: const Color(0xFFFFFFFF),
        highlightColor: primary,
        selectedIconColor: WidgetStateProperty.all(primary),
        unselectedIconColor: WidgetStateProperty.all(const Color(0xFF6B7280)),
        selectedTextStyle: WidgetStateProperty.all(
          const TextStyle(fontFamily: fontFamily, color: primary, fontWeight: FontWeight.w600),
        ),
        unselectedTextStyle: WidgetStateProperty.all(
          const TextStyle(fontFamily: fontFamily, color: Color(0xFF6B7280)),
        ),
      ),
      typography: Typography.raw(
        body: const TextStyle(fontFamily: fontFamily, color: Color(0xFF1A1A2E), fontSize: 14),
        bodyLarge: const TextStyle(fontFamily: fontFamily, color: Color(0xFF1A1A2E), fontSize: 16),
        bodyStrong: const TextStyle(fontFamily: fontFamily, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600),
        title: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E), fontSize: 28),
        titleLarge: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E), fontSize: 40),
        subtitle: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E), fontSize: 20),
        caption: const TextStyle(fontFamily: fontFamily, color: Color(0xFF6B7280), fontSize: 12),
        display: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E), fontSize: 68),
      ),
    );
  }

  // Keep backward compat
  static FluentThemeData get darkTheme => lightTheme;

  static FluentThemeData get darkModeTheme {
    return FluentThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      cardColor: const Color(0xFF222240),
      accentColor: primary.toAccentColor(),
      navigationPaneTheme: NavigationPaneThemeData(
        backgroundColor: const Color(0xFF222240),
        highlightColor: primary,
        selectedIconColor: WidgetStateProperty.all(primary),
        unselectedIconColor: WidgetStateProperty.all(const Color(0xFF9CA3AF)),
        selectedTextStyle: WidgetStateProperty.all(
          const TextStyle(fontFamily: fontFamily, color: primary, fontWeight: FontWeight.w600),
        ),
        unselectedTextStyle: WidgetStateProperty.all(
          const TextStyle(fontFamily: fontFamily, color: Color(0xFF9CA3AF)),
        ),
      ),
      typography: Typography.raw(
        body: const TextStyle(fontFamily: fontFamily, color: Color(0xFFE8E8F0), fontSize: 14),
        bodyLarge: const TextStyle(fontFamily: fontFamily, color: Color(0xFFE8E8F0), fontSize: 16),
        bodyStrong: const TextStyle(fontFamily: fontFamily, color: Color(0xFFE8E8F0), fontWeight: FontWeight.w600),
        title: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700, color: Color(0xFFE8E8F0), fontSize: 28),
        titleLarge: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700, color: Color(0xFFE8E8F0), fontSize: 40),
        subtitle: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w600, color: Color(0xFFE8E8F0), fontSize: 20),
        caption: const TextStyle(fontFamily: fontFamily, color: Color(0xFF9CA3AF), fontSize: 12),
        display: const TextStyle(fontFamily: fontFamily, fontWeight: FontWeight.w700, color: Color(0xFFE8E8F0), fontSize: 68),
      ),
    );
  }
}