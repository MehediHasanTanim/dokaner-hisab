// Hisab — Bangla-first business management for Bangladesh's small shops.
//
// The app entry point. Two things happen here and nothing else:
//
//   1. A `ProviderScope` wraps the whole app. Riverpod is the state layer for
//      every later story (AR-29: notifiers are the only state mutators), so the
//      scope goes in now rather than being retrofitted around a running app.
//   2. `MaterialApp` takes the Hisab theme. Every screen from here on reads its
//      colour, type, radius and spacing from it — no widget declares a literal,
//      and `tool/check_theme_tokens.dart` fails the build when one does.
//
// The home screen is the theme preview: scaffolding for this story, replaced by
// the real routing shell when the navigation story lands. There is no হোম here,
// and building one early would only mean building it twice.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/hisab_theme.dart';
import 'theme/theme_preview.dart';

void main() {
  runApp(const ProviderScope(child: HisabApp()));
}

class HisabApp extends StatelessWidget {
  const HisabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Shown in the Android task switcher, so it is Bangla like everything
      // else the owner sees.
      title: 'হিসাব',
      debugShowCheckedModeBanner: false,
      theme: HisabTheme.light(),
      // DESIGN.md describes one product: a paper ledger read in daylight. A
      // dark variant is not specified, so the light theme is pinned rather than
      // letting the platform substitute a Material default at night.
      darkTheme: HisabTheme.light(),
      themeMode: ThemeMode.light,
      home: const ThemePreviewScreen(),
    );
  }
}
