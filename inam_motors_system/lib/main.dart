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
  String _pinInput = '';
  String _pinError = '';
  static const String _correctPin = '1234';

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
          width: 400,
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
              "Enter your PIN to continue",
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            // PIN dot indicators
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (int i = 0; i < 4; i++)
                Container(
                  width: 48,
                  height: 56,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _pinError.isNotEmpty
                          ? AppTheme.error
                          : (i < _pinInput.length
                              ? AppTheme.primary
                              : AppTheme.divider),
                      width: i < _pinInput.length ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      i < _pinInput.length ? "\u2022" : "",
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
            ]),
            if (_pinError.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _pinError,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12,
                  color: AppTheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 24),
            // PIN numpad
            SizedBox(
              width: 260,
              child: Column(children: [
                for (int row = 0; row < 4; row++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int col = 0; col < 3; col++)
                          () {
                            final nums = [
                              ['1', '2', '3'],
                              ['4', '5', '6'],
                              ['7', '8', '9'],
                              ['C', '0', '\u2713']
                            ];
                            final val = nums[row][col];
                            final isAction = val == 'C' || val == '\u2713';
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: SizedBox(
                                width: 64,
                                height: 48,
                                child: Button(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                      val == '\u2713'
                                          ? AppTheme.primary
                                          : AppTheme.cardColor,
                                    ),
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _pinError = '';
                                      if (val == 'C') {
                                        if (_pinInput.isNotEmpty) {
                                          _pinInput = _pinInput.substring(
                                              0, _pinInput.length - 1);
                                        }
                                      } else if (val == '\u2713') {
                                        if (_pinInput == _correctPin) {
                                          _isUnlocked = true;
                                        } else {
                                          _pinError = 'Incorrect PIN. Try again.';
                                          _pinInput = '';
                                        }
                                      } else if (_pinInput.length < 4) {
                                        _pinInput += val;
                                      }
                                    });
                                  },
                                  child: Text(
                                    val,
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontFamily,
                                      fontSize: isAction ? 16 : 18,
                                      fontWeight: FontWeight.w600,
                                      color: val == '\u2713'
                                          ? Colors.white
                                          : AppTheme.textPrimary,
                                    ),
                                  ),
                                ).withClickCursor,
                              ),
                            );
                          }(),
                      ],
                    ),
                  ),
              ]),
            ),
            const SizedBox(height: 16),
            Text(
              "Default PIN: 1234",
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}