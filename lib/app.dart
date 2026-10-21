import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stencil/core/app_identity.dart';
import 'package:stencil/core/theme/app_theme.dart';
import 'package:stencil/core/theme/theme_mode_notifier.dart';

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppIdentity.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: ThemeHome(
        themeMode: themeMode,
        onThemeModeChanged: (mode) {
          ref.read(themeModeProvider.notifier).setThemeMode(mode);
        },
      ),
    );
  }
}

class ThemeHome extends StatelessWidget {
  const ThemeHome({
    required this.themeMode,
    required this.onThemeModeChanged,
    super.key,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppIdentity.appName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('System'),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selection) {
                    onThemeModeChanged(selection.single);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
