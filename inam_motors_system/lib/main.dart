import 'package:fluent_ui/fluent_ui.dart';
import 'core/theme.dart';
import 'features/shared/main_layout.dart';

void main() {
  runApp(const InamMotorsApp());
}

class InamMotorsApp extends StatefulWidget {
  const InamMotorsApp({super.key});

  static final ValueNotifier<bool> isDarkMode = ValueNotifier(false);

  @override
  State<InamMotorsApp> createState() => _InamMotorsAppState();
}

class _InamMotorsAppState extends State<InamMotorsApp> {
  @override
  void initState() {
    super.initState();
    InamMotorsApp.isDarkMode.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    InamMotorsApp.isDarkMode.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isDark = InamMotorsApp.isDarkMode.value;
    return FluentApp(
      title: 'Inam Motors',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkModeTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const AppLockWrapper(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Global App Lock — wraps the entire app behind a PIN screen on launch
// ─────────────────────────────────────────────────────────────────────────────
class AppLockWrapper extends StatefulWidget {
  const AppLockWrapper({super.key});

  @override
  State<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<AppLockWrapper> {
  bool _isUnlocked = false;
  bool _showPassword = false;
  String _passwordError = '';
  final TextEditingController _passwordCtrl = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  static const String _correctPassword = 'hello1234';

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _attemptUnlock() {
    setState(() {
      if (_passwordCtrl.text == _correctPassword) {
        _isUnlocked = true;
        _passwordError = '';
      } else {
        _passwordError = 'Incorrect password. Try again.';
        _passwordCtrl.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUnlocked) return _buildLockScreen();
    return const MainLayout();
  }

  Widget _buildLockScreen() {
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(FluentIcons.lock, size: 40, color: AppTheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              "Inam Motors",
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Car Showroom Management System",
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Enter your password to continue",
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            InfoLabel(
              label: "Password",
              labelStyle: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
              child: TextBox(
                controller: _passwordCtrl,
                focusNode: _passwordFocus,
                autofocus: true,
                obscureText: !_showPassword,
                placeholder: "Enter password",
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
                onChanged: (_) {
                  if (_passwordError.isNotEmpty) {
                    setState(() => _passwordError = '');
                  }
                },
                onSubmitted: (_) => _attemptUnlock(),
                suffix: IconButton(
                  icon: Icon(
                    _showPassword ? FluentIcons.hide3 : FluentIcons.red_eye,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
              ),
            ),
            if (_passwordError.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                _passwordError,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12,
                  color: AppTheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(AppTheme.primary),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 14),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                onPressed: _attemptUnlock,
                child: const Text(
                  "Unlock",
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ).withClickCursor,
            ),
          ]),
        ),
      ),
    );
  }
}