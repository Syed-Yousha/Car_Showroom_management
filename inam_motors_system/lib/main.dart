import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'core/theme.dart';
import 'features/shared/main_layout.dart';
import 'firebase_options.dart';
import 'models/app_user.dart';
import 'services/auth_service.dart';
import 'services/backup_service.dart';
import 'services/business_profile_service.dart';
import 'services/cars_repo.dart';
import 'services/customer_service.dart';
import 'services/customers_repo.dart';
import 'services/document_service.dart';
import 'services/documents_repo.dart';
import 'services/expenses_repo.dart';
import 'services/firestore_rest.dart';
import 'services/inventory_service.dart';
import 'services/investors_repo.dart';
import 'services/ledger_repo.dart';
import 'services/ledger_service.dart';
import 'services/local_auth_service.dart';
import 'services/notifications_service.dart';
import 'services/seed_service.dart';
import 'services/storage_service.dart';
import 'services/transaction_service.dart';

/// Global service handles. A simple, deliberate alternative to a DI framework
/// for a single-tenant POS — every screen imports these directly.
final AuthService authService = AuthService();
final CarsRepo carsRepo = CarsRepo();
final CustomersRepo customersRepo = CustomersRepo();
final LedgerRepo ledgerRepo = LedgerRepo();
final InvestorsRepo investorsRepo = InvestorsRepo();
final ExpensesRepo expensesRepo = ExpensesRepo();
final DocumentsRepo documentsRepo = DocumentsRepo();
final TransactionService transactionService = TransactionService();
final SeedService seedService = SeedService();
final InventoryService inventoryService = InventoryService();
final CustomerService customerService = CustomerService();
final LedgerService ledgerService = LedgerService();
final DocumentService documentService = DocumentService();
final LocalAuthService localAuthService = LocalAuthService();
final StorageService storageService = StorageService();
final BusinessProfileService businessProfileService = BusinessProfileService();
final NotificationsService notificationsService = NotificationsService(
  inventory: inventoryService,
  customers: customerService,
);
final BackupService backupService = BackupService(
  inventory: inventoryService,
  customers: customerService,
  customersRepo: customersRepo,
  ledger: ledgerService,
  expenses: expensesRepo,
  investors: investorsRepo,
  documents: documentsRepo,
);

/// REST client for Firestore reads — populated in `main()` after Firebase
/// has been initialised (needs `Firebase.app().options.projectId`). The
/// Windows `cloud_firestore` SDK crashes on every read, so all read paths
/// route through this REST client instead.
late final FirestoreRest firestoreRest;

void main() {
  // Single-zone initialisation — binding + Firebase init + runApp must all
  // happen in the same zone, otherwise Flutter throws a zone-mismatch
  // assertion.
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[Init] Firebase initialised');

    // The Windows C++ Firebase SDK chokes on LevelDB persistence — force
    // in-memory cache. Wrapped in try/catch so a settings-API mismatch on
    // a future SDK can't take down the app at boot.
    if (!kIsWeb && Platform.isWindows) {
      try {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: false,
        );
        debugPrint('[Init] Firestore persistence disabled (Windows)');
      } catch (e, s) {
        debugPrint('[Init] Failed to apply Firestore settings: $e\n$s');
      }
    }

    // Catch any uncaught Flutter framework errors and log instead of
    // crashing.
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('[FlutterError] ${details.exceptionAsString()}');
    };

    // REST client for Firestore reads (works around the Windows C++ SDK
    // crash on `.get()` / `.snapshots()`). Inject into every read-using
    // repo — writes still go through the SDK directly.
    firestoreRest = FirestoreRest();
    investorsRepo.rest = firestoreRest;
    inventoryService.rest = firestoreRest;
    customerService.rest = firestoreRest;
    ledgerService.rest = firestoreRest;
    documentsRepo.rest = firestoreRest;
    documentService.rest = firestoreRest;
    expensesRepo.rest = firestoreRest;
    customersRepo.rest = firestoreRest;
    ledgerRepo.rest = firestoreRest;
    businessProfileService.rest = firestoreRest;
    debugPrint('[Init] FirestoreRest configured for project '
        '${Firebase.app().options.projectId}');

    // Force sign-in on every restart by clearing the persistent auth state
    // await authService.signOut();  // REMOVED: keep Firebase session alive for lock screen

    runApp(const InamMotorsApp());
  }, (error, stack) {
    debugPrint('[Zone] Unhandled error: $error\n$stack');
  });
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
      home: const AuthGate(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  AuthGate — listens to Firebase Auth state and shows either the lock screen
//  or the main app. Replaces the old hardcoded-password AppLockWrapper.
// ─────────────────────────────────────────────────────────────────────────────
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  static bool isUnlocked = false;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppUser?>(
      stream: authService.authStateChanges,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }
        final user = snap.data;
        if (user == null) {
          AuthGate.isUnlocked = false;
          return const LoginScreen();
        }
        if (!AuthGate.isUnlocked) {
          return LockScreen(
            username: user.usernameFromEmail,
            onUnlocked: () => setState(() => AuthGate.isUnlocked = true),
          );
        }
        return const MainLayout();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ProgressRing(),
            const SizedBox(height: 16),
            Text(
              'Inam Motors',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  LoginScreen — username + password (mapped to <user>@inammotors.local).
//  Visual style mirrors the original AppLockWrapper card.
// ─────────────────────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _showPassword = false;
  bool _busy = false;
  bool _isSavedUser = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadSavedUsername();
  }

  Future<void> _loadSavedUsername() async {
    try {
      final saved = await localAuthService.storedUsername();
      if (saved != null && saved.isNotEmpty && mounted) {
        setState(() {
          _usernameCtrl.text = saved;
          _isSavedUser = true;
        });
        _passwordFocus.requestFocus();
      }
    } catch (_) {}
  }

  Future<void> _saveUsernameAndPass(String username, String password) async {
    try {
      await localAuthService.remember(username: username, password: password);
    } catch (_) {}
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _attemptUnlock() async {
    if (_busy) return;
    final user = _usernameCtrl.text.trim();
    final pw = _passwordCtrl.text;
    if (user.isEmpty || pw.isEmpty) {
      setState(() => _error = 'Username and password are required.');
      return;
    }
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      await authService.signIn(username: user, password: pw);
      await _saveUsernameAndPass(user, pw);
      AuthGate.isUnlocked = true;
      // AuthGate's StreamBuilder will swap us out automatically.
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AuthService.describeError(e);
        _passwordCtrl.clear();
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(FluentIcons.lock,
                  size: 40, color: AppTheme.primary),
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
              "Sign in to continue",
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            if (_isSavedUser) ...[
              Text(
                "Welcome back, ${_usernameCtrl.text}",
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              HyperlinkButton(
                onPressed: () {
                  setState(() {
                    _isSavedUser = false;
                    _usernameCtrl.clear();
                    _usernameFocus.requestFocus();
                  });
                },
                child: const Text("Not you? Switch user",
                    style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11)),
              ),
              const SizedBox(height: 14),
            ] else ...[
              InfoLabel(
                label: "Username",
                labelStyle: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
                child: TextBox(
                  controller: _usernameCtrl,
                  focusNode: _usernameFocus,
                  autofocus: true,
                  placeholder: "e.g. admin",
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                  onChanged: (_) {
                    if (_error.isNotEmpty) setState(() => _error = '');
                  },
                  onSubmitted: (_) => _passwordFocus.requestFocus(),
                ),
              ),
              const SizedBox(height: 14),
            ],
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
                obscureText: !_showPassword,
                placeholder: "Enter password",
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
                onChanged: (_) {
                  if (_error.isNotEmpty) setState(() => _error = '');
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
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                _error,
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
                onPressed: _busy ? null : _attemptUnlock,
                child: _busy
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: ProgressRing(strokeWidth: 2),
                      )
                    : const Text(
                        "Sign In",
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

// ─────────────────────────────────────────────────────────────────────────────
//  LockScreen — asks for password locally when the app is restarted but
//  the Firebase session is still valid.
// ─────────────────────────────────────────────────────────────────────────────
class LockScreen extends StatefulWidget {
  final String username;
  final VoidCallback onUnlocked;
  const LockScreen({super.key, required this.username, required this.onUnlocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _passwordCtrl = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  bool _showPassword = false;
  String _error = '';

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _attemptUnlock() async {
    final pw = _passwordCtrl.text;
    if (pw.isEmpty) return;

    try {
      final stored = await localAuthService.storedUsername() ?? widget.username;
      final ok = await localAuthService.verify(username: stored, password: pw);
      if (ok) {
        widget.onUnlocked();
        return;
      }
    } catch (_) {}

    setState(() {
      _error = 'Incorrect password.';
      _passwordCtrl.clear();
      _passwordFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
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
              "System Locked",
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Welcome back, ${widget.username.split('@').first}",
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
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
                placeholder: "Enter password to unlock",
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
                suffix: IconButton(
                  icon: Icon(
                    _showPassword ? FluentIcons.hide3 : FluentIcons.red_eye,
                    size: 14,
                    color: AppTheme.textMuted,
                  ),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ).withClickCursor,
                onChanged: (_) {
                  if (_error.isNotEmpty) setState(() => _error = '');
                },
                onSubmitted: (_) => _attemptUnlock(),
              ),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _error,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12,
                  color: AppTheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(AppTheme.primary),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                ),
                onPressed: _attemptUnlock,
                child: const Text(
                  "Unlock System",
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ).withClickCursor,
            ),
            const SizedBox(height: 14),
            HyperlinkButton(
              onPressed: () async {
                await authService.signOut();
                AuthGate.isUnlocked = false;
              },
              child: const Text("Not you? Switch user",
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11)),
            ),
          ]),
        ),
      ),
    );
  }
}
