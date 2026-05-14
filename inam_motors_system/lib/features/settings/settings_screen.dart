import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../../main.dart';
import '../../models/business_profile.dart';
import '../../services/auth_service.dart';
import '../../services/backup_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Business profile (loaded from Firestore on init). Only [_businessName]
  // is mirrored to state so the header label updates without re-querying the
  // controller; the remaining fields live in their TextEditingControllers.
  String _businessName = '';
  bool _profileLoading = true;
  bool _profileSaving = false;

  // Persistent controllers for editable fields
  late final TextEditingController _businessNameCtrl;
  late final TextEditingController _ownerNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _logoUrlCtrl;

  // Preferences
  bool get _darkMode => InamMotorsApp.isDarkMode.value;
  bool _notifications = true;
  bool _autoBackup = true;

  // Notification prefs (persisted in shared_preferences)
  bool _notifySale = true;
  bool _notifyExpense = true;
  bool _notifyInvestor = true;
  bool _notifyLowStock = true;

  static const _prefsNotifications = 'pref_notifications';
  static const _prefsAutoBackup = 'pref_auto_backup';
  static const _prefsNotifySale = 'pref_notify_sale';
  static const _prefsNotifyExpense = 'pref_notify_expense';
  static const _prefsNotifyInvestor = 'pref_notify_investor';
  static const _prefsNotifyLowStock = 'pref_notify_low_stock';

  // Security
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  bool _showCurrentPw = false;
  bool _showNewPw = false;
  bool _showConfirmPw = false;
  bool _busyPassword = false;
  bool _seeding = false;

  int _selectedSection = 0;

  @override
  void initState() {
    super.initState();
    _businessNameCtrl = TextEditingController();
    _ownerNameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _logoUrlCtrl = TextEditingController();
    _loadProfile();
    _loadPreferences();
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    _logoUrlCtrl.dispose();
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    _seedStatus.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final p = await businessProfileService.fetchSafe();
      if (!mounted) return;
      setState(() {
        _businessName = p.businessName;
        _businessNameCtrl.text = p.businessName;
        _ownerNameCtrl.text = p.ownerName;
        _phoneCtrl.text = p.phone;
        _emailCtrl.text = p.email;
        _addressCtrl.text = p.address;
        _logoUrlCtrl.text = p.logoUrl;
        _profileLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _profileLoading = false);
      _showError('Failed to load business profile: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (_profileSaving) return;
    setState(() => _profileSaving = true);
    try {
      final p = BusinessProfile(
        businessName: _businessNameCtrl.text.trim().isEmpty
            ? 'Inam Motors'
            : _businessNameCtrl.text.trim(),
        ownerName: _ownerNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        logoUrl: _logoUrlCtrl.text.trim(),
      );
      await businessProfileService.save(p);
      if (!mounted) return;
      setState(() {
        _businessName = p.businessName;
      });
      _showSnack('Profile saved');
    } catch (e) {
      if (mounted) _showError('Failed to save: $e');
    } finally {
      if (mounted) setState(() => _profileSaving = false);
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notifications = prefs.getBool(_prefsNotifications) ?? true;
      _autoBackup = prefs.getBool(_prefsAutoBackup) ?? true;
      _notifySale = prefs.getBool(_prefsNotifySale) ?? true;
      _notifyExpense = prefs.getBool(_prefsNotifyExpense) ?? true;
      _notifyInvestor = prefs.getBool(_prefsNotifyInvestor) ?? true;
      _notifyLowStock = prefs.getBool(_prefsNotifyLowStock) ?? true;
    });
  }

  Future<void> _setPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  final _sections = const [
    'Business Profile',
    'Preferences',
    'Notifications',
    'Security',
    'Data & Backup',
    'About',
  ];

  final _sectionIcons = const [
    FluentIcons.build_definition,
    FluentIcons.color,
    FluentIcons.ringer,
    FluentIcons.lock,
    FluentIcons.database,
    FluentIcons.info,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 700;

      if (isNarrow) {
        return ScaffoldPage.scrollable(
          padding: const EdgeInsets.all(16),
          children: [
            Text("Settings", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text("Manage your showroom settings", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            // Section selector as horizontal chips
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _sections.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => _buildSectionChip(i),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionContent(),
          ],
        );
      }

      return ScaffoldPage(
        padding: EdgeInsets.zero,
        content: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Settings", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text("Manage your showroom settings and preferences", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, color: AppTheme.textSecondary)),
            const SizedBox(height: 24),
            Expanded(
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Left nav
                SizedBox(
                  width: 220,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(_sections.length, (i) => _buildNavItem(i)),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildSectionContent(),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      );
    });
  }

  Widget _buildSectionChip(int i) {
    final sel = _selectedSection == i;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _selectedSection = i),
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? AppTheme.primary : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? AppTheme.primary : AppTheme.divider),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(_sectionIcons[i], size: 13, color: sel ? Colors.white : AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(_sections[i], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppTheme.textPrimary)),
        ]),
      ),
      ),
    );
  }

  Widget _buildNavItem(int i) {
    final sel = _selectedSection == i;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile.selectable(
        selected: sel,
        onSelectionChange: (_) => setState(() => _selectedSection = i),
        leading: Icon(_sectionIcons[i], size: 16, color: sel ? AppTheme.primary : AppTheme.textMuted),
        title: Text(_sections[i], style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.w500, color: sel ? AppTheme.primary : AppTheme.textPrimary)),
      ),
    );
  }

  Widget _buildSectionContent() {
    switch (_selectedSection) {
      case 0: return _buildProfileSection();
      case 1: return _buildPreferencesSection();
      case 2: return _buildNotificationsSection();
      case 3: return _buildSecuritySection();
      case 4: return _buildDataSection();
      case 5: return _buildAboutSection();
      default: return const SizedBox();
    }
  }

  // ═══════════════════════════════════════════════════
  // SECTION 1: Business Profile
  // ═══════════════════════════════════════════════════
  Widget _buildProfileSection() {
    if (_profileLoading) {
      return _card(
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: ProgressRing()),
        ),
      );
    }
    final headerName =
        _businessName.trim().isEmpty ? 'Inam Motors' : _businessName;
    final initials = BusinessProfile(businessName: headerName).initials;
    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader("Business Profile", "Your showroom details and contact information"),
        const SizedBox(height: 24),
        // Logo area
        Row(children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(initials, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primary))),
          ),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(headerName, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text("Car Showroom", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textMuted)),
          ]),
        ]),
        const SizedBox(height: 28),
        _editableFieldCtrl("Business Name", _businessNameCtrl, (v) => setState(() => _businessName = v)),
        _editableFieldCtrl("Owner Name", _ownerNameCtrl, (_) {}),
        _editableFieldCtrl("Phone Number", _phoneCtrl, (_) {}),
        _editableFieldCtrl("Email Address", _emailCtrl, (_) {}),
        _editableFieldCtrl("Address", _addressCtrl, (_) {}),
        _editableFieldCtrl("Logo URL (optional)", _logoUrlCtrl, (_) {}),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(AppTheme.primary),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 24, vertical: 10)),
            ),
            onPressed: _profileSaving ? null : _saveProfile,
            child: _profileSaving
                ? const SizedBox(width: 16, height: 16, child: ProgressRing(strokeWidth: 2))
                : const Text("Save Changes", style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w600, color: Colors.white)),
          ).withClickCursor,
        ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════
  // SECTION 2: Preferences
  // ═══════════════════════════════════════════════════
  Widget _buildPreferencesSection() {
    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader("Appearance", "Customize how the app looks"),
        const SizedBox(height: 20),
        _toggleRow("Dark Mode", "Switch between light and dark theme", _darkMode, (v) {
          InamMotorsApp.isDarkMode.value = v;
          setState(() {});
        }),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════
  // SECTION 3: Notifications
  // ═══════════════════════════════════════════════════
  Widget _buildNotificationsSection() {
    return Column(children: [
      _card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionHeader("General Notifications", "Choose what updates you receive"),
          const SizedBox(height: 20),
          _toggleRow("Push Notifications", "Receive in-app notifications", _notifications, (v) {
            setState(() => _notifications = v);
            _setPref(_prefsNotifications, v);
          }),
        ]),
      ),
      const SizedBox(height: 20),
      _card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionHeader("Event Notifications", "Get notified for specific events"),
          const SizedBox(height: 20),
          _toggleRow("New Sale", "When a car is sold or booked", _notifySale, (v) {
            setState(() => _notifySale = v);
            _setPref(_prefsNotifySale, v);
          }),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
          _toggleRow("New Expense", "When an expense is added", _notifyExpense, (v) {
            setState(() => _notifyExpense = v);
            _setPref(_prefsNotifyExpense, v);
          }),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
          _toggleRow("Investor Activity", "Investments and distributions", _notifyInvestor, (v) {
            setState(() => _notifyInvestor = v);
            _setPref(_prefsNotifyInvestor, v);
          }),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
          _toggleRow("Low Stock Alert", "When inventory drops below 5 cars", _notifyLowStock, (v) {
            setState(() => _notifyLowStock = v);
            _setPref(_prefsNotifyLowStock, v);
          }),
        ]),
      ),
    ]);
  }

  // ═══════════════════════════════════════════════════
  // SECTION 4: Security (Change Password)
  // ═══════════════════════════════════════════════════
  Widget _buildSecuritySection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Change Password", "Update the password used to access this account"),
          const SizedBox(height: 24),
          _passwordField(
            "Current Password",
            _currentPwCtrl,
            _showCurrentPw,
            () => setState(() => _showCurrentPw = !_showCurrentPw),
          ),
          _passwordField(
            "New Password",
            _newPwCtrl,
            _showNewPw,
            () => setState(() => _showNewPw = !_showNewPw),
          ),
          _passwordField(
            "Confirm New Password",
            _confirmPwCtrl,
            _showConfirmPw,
            () => setState(() => _showConfirmPw = !_showConfirmPw),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.18)),
            ),
            child: Row(children: [
              Icon(FluentIcons.info, size: 14, color: AppTheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Use at least 6 characters. Avoid reusing old passwords.",
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textSecondary),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(AppTheme.primary),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 24, vertical: 10)),
              ),
              onPressed: _busyPassword ? null : _submitPasswordChange,
              child: _busyPassword
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: ProgressRing(strokeWidth: 2),
                    )
                  : const Text("Update Password",
                      style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
            ).withClickCursor,
          ),
          const SizedBox(height: 24),
          Container(height: 1, color: AppTheme.divider),
          const SizedBox(height: 24),
          _sectionHeader("Sign Out", "Sign out of this device. You'll need your password to sign back in."),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Button(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
              ),
              onPressed: _confirmSignOut,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(FluentIcons.sign_out, size: 14, color: AppTheme.error),
                const SizedBox(width: 8),
                Text(
                  "Sign Out",
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.error,
                  ),
                ),
              ]),
            ).withClickCursor,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ContentDialog(
        title: const Text('Sign Out',
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(fontFamily: AppTheme.fontFamily),
        ),
        actions: [
          Button(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(fontFamily: AppTheme.fontFamily)),
          ).withClickCursor,
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppTheme.error)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out',
                style: TextStyle(fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ).withClickCursor,
        ],
      ),
    );
    if (confirmed == true) {
      // Force-clear the lock state too — AuthGate.isUnlocked is a static
      // bool that survives sign-out otherwise, which would skip the lock
      // screen on next sign-in.
      AuthGate.isUnlocked = false;
      await authService.signOut();
      // AuthGate's StreamBuilder will route back to LoginScreen.
    }
  }

  // Live progress message shown inside the seeding modal.
  final ValueNotifier<String> _seedStatus =
      ValueNotifier<String>('Preparing...');

  Future<void> _runSeed() async {
    if (_seeding) return;
    print('[Seed] Button pressed — starting seed');
    setState(() => _seeding = true);
    _seedStatus.value = 'Preparing...';

    // Show a non-dismissible modal so the user can see progress and the UI
    // can't be re-entered during the seed.
    final dialogFuture = showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ContentDialog(
        title: Text(
          'Seeding Sample Data',
          style: TextStyle(fontFamily: AppTheme.fontFamily),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: [
            const ProgressRing(strokeWidth: 3),
            const SizedBox(width: 16),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _seedStatus,
                builder: (_, msg, _) => Text(
                  msg,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ]),
        ),
        actions: const [],
      ),
    );

    try {
      print('[Seed] Calling seedService.seedAll()');
      final result = await seedService.seedAll(
        onProgress: (msg) {
          if (mounted) _seedStatus.value = msg;
        },
      );
      print('[Seed] seedAll() returned: ${result.describe()}');
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      await dialogFuture;
      if (!mounted) return;
      _showSnack(result.describe());
    } catch (e, stack) {
      print('[Seed] ERROR: $e');
      print('[Seed] Stack: $stack');
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        await dialogFuture;
      }
      if (!mounted) return;
      _showError('Seed failed: $e');
    } finally {
      print('[Seed] _runSeed() finally block');
      if (mounted) setState(() => _seeding = false);
    }
  }

  Widget _passwordField(String label, TextEditingController ctrl, bool show, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InfoLabel(
        label: label,
        labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
        child: TextBox(
          controller: ctrl,
          obscureText: !show,
          placeholder: label,
          placeholderStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted),
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textPrimary),
          decoration: WidgetStateProperty.all(BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.divider),
          )),
          suffix: IconButton(
            icon: Icon(
              show ? FluentIcons.hide3 : FluentIcons.red_eye,
              size: 14,
              color: AppTheme.textMuted,
            ),
            onPressed: onToggle,
          ).withClickCursor,
        ),
      ),
    );
  }

  Future<void> _submitPasswordChange() async {
    if (_busyPassword) return;
    final current = _currentPwCtrl.text;
    final newPw = _newPwCtrl.text;
    final confirm = _confirmPwCtrl.text;

    if (current.isEmpty || newPw.isEmpty || confirm.isEmpty) {
      _showError("All password fields are required.");
      return;
    }
    if (newPw.length < 6) {
      _showError("New password must be at least 6 characters.");
      return;
    }
    if (newPw != confirm) {
      _showError("New password and confirmation do not match.");
      return;
    }
    if (newPw == current) {
      _showError("New password must be different from the current one.");
      return;
    }

    setState(() => _busyPassword = true);
    try {
      await authService.changePassword(
        currentPassword: current,
        newPassword: newPw,
      );
      if (!mounted) return;
      _currentPwCtrl.clear();
      _newPwCtrl.clear();
      _confirmPwCtrl.clear();
      _showSnack("Password updated successfully");
    } catch (e) {
      if (!mounted) return;
      _showError(AuthService.describeError(e));
    } finally {
      if (mounted) setState(() => _busyPassword = false);
    }
  }

  void _showError(String msg) {
    displayInfoBar(context, builder: (context, close) {
      return InfoBar(
        title: Text(msg, style: const TextStyle(fontFamily: AppTheme.fontFamily)),
        severity: InfoBarSeverity.error,
      );
    });
  }

  // ═══════════════════════════════════════════════════
  // SECTION 5: Data & Backup
  // ═══════════════════════════════════════════════════
  Widget _buildDataSection() {
    return Column(children: [
      _card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionHeader("Backup", "Manage your data backups"),
          const SizedBox(height: 20),
          _toggleRow("Auto Backup", "Automatically back up data daily", _autoBackup, (v) {
            setState(() => _autoBackup = v);
            _setPref(_prefsAutoBackup, v);
          }),
          const SizedBox(height: 20),
          Row(children: [
            _actionBtn(
              _backingUp ? "Backing up..." : "Backup Now",
              FluentIcons.cloud_upload,
              AppTheme.primary,
              _backingUp ? () {} : _runBackup,
            ),
          ]),
        ]),
      ),
      const SizedBox(height: 20),
      _card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionHeader("Sample Data", "Populate Firestore with demo records (skips collections that already have data)"),
          const SizedBox(height: 20),
          Row(children: [
            _actionBtn(
              _seeding ? "Seeding..." : "Seed Sample Data",
              FluentIcons.database_source,
              AppTheme.primary,
              _seeding ? () {} : _runSeed,
            ),
          ]),
        ]),
      ),
      const SizedBox(height: 20),
      _card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionHeader("Export", "Export a section to a .csv file"),
          const SizedBox(height: 20),
          Row(children: [
            _actionBtn(
              _exporting ? "Exporting..." : "Export CSV",
              FluentIcons.table,
              AppTheme.success,
              _exporting ? () {} : _showExportCsvDialog,
            ),
          ]),
        ]),
      ),
      const SizedBox(height: 20),
      _card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionHeader("Danger Zone", "Irreversible actions"),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Reset All Data", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.error)),
                Text("This will permanently delete all showroom data", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
              ])),
              Button(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(AppTheme.error),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: AppTheme.error.withValues(alpha: 0.4)))),
                ),
                onPressed: _resetting ? null : _confirmResetAllData,
                child: _resetting
                    ? const SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2))
                    : const Text("Reset", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600)),
              ).withClickCursor,
            ]),
          ),
        ]),
      ),
    ]);
  }

  // ── BACKUP / EXPORT / RESET HANDLERS ────────────────────────────────────

  bool _backingUp = false;
  bool _exporting = false;
  bool _resetting = false;

  Future<void> _runBackup() async {
    if (_backingUp) return;
    setState(() => _backingUp = true);
    final statusNotifier = ValueNotifier<String>('Preparing...');
    final dialogFuture = showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ContentDialog(
        title: const Text('Backing up data',
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: [
            const ProgressRing(strokeWidth: 3),
            const SizedBox(width: 16),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: statusNotifier,
                builder: (_, msg, _) => Text(msg,
                    style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        color: AppTheme.textSecondary)),
              ),
            ),
          ]),
        ),
        actions: const [],
      ),
    );

    try {
      final result = await backupService.backupAllToJson(
        onProgress: (step) {
          if (mounted) statusNotifier.value = step;
        },
      );
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      await dialogFuture;
      if (!mounted) return;
      if (result.ok) {
        _showSnack(result.message);
      } else {
        _showError(result.message);
      }
    } finally {
      statusNotifier.dispose();
      if (mounted) setState(() => _backingUp = false);
    }
  }

  Future<void> _showExportCsvDialog() async {
    final selected = await showDialog<BackupSection>(
      context: context,
      builder: (ctx) => ContentDialog(
        title: const Text('Export CSV',
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        constraints: const BoxConstraints(maxWidth: 380),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pick a section to export to .csv.',
                style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            for (final s in BackupSection.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: SizedBox(
                  width: double.infinity,
                  child: Button(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 10, horizontal: 14)),
                    ),
                    onPressed: () => Navigator.pop(ctx, s),
                    child: Row(children: [
                      Icon(_csvSectionIcon(s), size: 14, color: AppTheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(s.label,
                            style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary)),
                      ),
                    ]),
                  ).withClickCursor,
                ),
              ),
          ],
        ),
        actions: [
          Button(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(fontFamily: AppTheme.fontFamily))).withClickCursor,
        ],
      ),
    );
    if (selected == null || !mounted) return;
    await _runCsvExport(selected);
  }

  IconData _csvSectionIcon(BackupSection s) {
    switch (s) {
      case BackupSection.inventory:
        return FluentIcons.car;
      case BackupSection.customers:
        return FluentIcons.people;
      case BackupSection.expenses:
        return FluentIcons.calculator_addition;
      case BackupSection.ledger:
        return FluentIcons.financial;
      case BackupSection.investors:
        return FluentIcons.money;
      case BackupSection.salesmen:
        return FluentIcons.contact;
    }
  }

  Future<void> _runCsvExport(BackupSection section) async {
    setState(() => _exporting = true);
    try {
      final result = await backupService.exportSectionToCsv(section);
      if (!mounted) return;
      if (result.ok) {
        _showSnack(result.message);
      } else {
        _showError(result.message);
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _confirmResetAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ContentDialog(
        title: Row(children: [
          Icon(FluentIcons.warning, size: 18, color: AppTheme.error),
          const SizedBox(width: 8),
          const Text('Reset All Data',
              style: TextStyle(
                  fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        ]),
        constraints: const BoxConstraints(maxWidth: 460),
        content: Text(
          'Are you absolutely sure you want to permanently delete all data? '
          'This action cannot be undone.',
          style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              color: AppTheme.textPrimary,
              height: 1.5),
        ),
        actions: [
          Button(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(fontFamily: AppTheme.fontFamily))).withClickCursor,
          FilledButton(
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(AppTheme.error)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, wipe everything',
                style: TextStyle(
                    fontFamily: AppTheme.fontFamily, color: Colors.white)),
          ).withClickCursor,
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _runReset();
  }

  Future<void> _runReset() async {
    setState(() => _resetting = true);
    final statusNotifier = ValueNotifier<String>('Counting records...');
    final dialogFuture = showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ContentDialog(
        title: const Text('Resetting data',
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: [
            const ProgressRing(strokeWidth: 3),
            const SizedBox(width: 16),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: statusNotifier,
                builder: (_, msg, _) => Text(msg,
                    style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        color: AppTheme.textSecondary)),
              ),
            ),
          ]),
        ),
        actions: const [],
      ),
    );

    try {
      final result = await backupService.resetAllData(
        onProgress: (label, done, total) {
          if (mounted) statusNotifier.value = label;
        },
      );
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      await dialogFuture;
      if (!mounted) return;
      if (result.ok) {
        _showSnack(result.message);
        // Refresh the live notifications since the cars/customers list is empty.
        notificationsService.refresh().ignore();
      } else {
        _showError(result.message);
      }
    } finally {
      statusNotifier.dispose();
      if (mounted) setState(() => _resetting = false);
    }
  }

  // ═══════════════════════════════════════════════════
  // SECTION 5: About
  // ═══════════════════════════════════════════════════
  Widget _buildAboutSection() {
    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader("About Inam Motors System", "Application information"),
        const SizedBox(height: 24),
        Center(child: Column(children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(16)),
            child: const Icon(FluentIcons.car, size: 36, color: AppTheme.primary),
          ),
          const SizedBox(height: 16),
          Text("Inam Motors", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text("Car Showroom Management System", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textMuted)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(20)),
            child: const Text("Version 1.0.0", style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
          ),
        ])),
        const SizedBox(height: 28),
        _aboutRow("Platform", "Windows Desktop"),
        _aboutRow("Framework", "Flutter"),
        _aboutRow("UI Library", "Fluent UI"),
        _aboutRow("Build", "Debug"),
        _aboutRow("Developer", "Yousha Mehdi"),
        const SizedBox(height: 20),
        Center(
          child: Text(
            "2024-2026 Inam Motors. All rights reserved.",
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: AppTheme.textMuted),
          ),
        ),
      ]),
    );
  }

  // ── Helpers ──

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.divider)),
      child: child,
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
      const SizedBox(height: 4),
      Text(subtitle, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textMuted)),
    ]);
  }

  Widget _editableFieldCtrl(String label, TextEditingController ctrl, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InfoLabel(
        label: label,
        labelStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
        child: TextBox(
          controller: ctrl,
          placeholder: label,
          placeholderStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted),
          onChanged: onChanged,
          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textPrimary),
          decoration: WidgetStateProperty.all(BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.divider),
          )),
        ),
      ),
    );
  }

  Widget _toggleRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: AppTheme.textMuted)),
      ])),
      ToggleSwitch(
        checked: value,
        onChanged: onChanged,
      ),
    ]);
  }

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Expanded(
      child: Button(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12, horizontal: 8)),
        ),
        onPressed: onPressed,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(child: Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: color), overflow: TextOverflow.ellipsis)),
        ]),
      ).withClickCursor,
    );
  }

  Widget _aboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        SizedBox(width: 120, child: Text(label, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: AppTheme.textMuted))),
        Expanded(child: Text(value, style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
      ]),
    );
  }

  void _showSnack(String msg) {
    displayInfoBar(context, builder: (context, close) {
      return InfoBar(
        title: Text(msg, style: const TextStyle(fontFamily: AppTheme.fontFamily)),
        severity: InfoBarSeverity.success,
      );
    });
  }
}
