import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
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
      home: const MainLayout(),
    );
  }
}