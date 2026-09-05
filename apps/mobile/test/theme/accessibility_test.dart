// Covers the "Largest system font" row of the story's edge-case matrix, and the
// accessibility acceptance criteria, against the one screen that exists.
//
// The condition every decision is made against: one-handed, at arm's length, in
// daylight, at a counter, with a customer waiting. A 5-inch phone at 720x1280
// with a device pixel ratio of 2 is a 360x640 logical viewport, so that is the
// viewport these tests use — the smallest the product supports.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisab/theme/hisab_theme.dart';
import 'package:hisab/theme/theme_preview.dart';
import 'package:hisab/theme/tokens.dart';

/// A 5-inch screen, logical pixels.
const Size kSmallestPhone = Size(360, 640);

/// The text scales worth testing. 1.0 is the default; 2.0 is Android's
/// accessibility maximum; 3.0 is past iOS's largest accessibility size, kept
/// here as headroom — "full layout integrity at the largest system font size"
/// has no asterisk in UX-DR22.
const List<double> kTextScales = <double>[1.0, 2.0, 3.0];

Widget _app(double textScale) {
  // The preview reads the language from Riverpod (Story 1.3), so it needs the
  // same scope main.dart gives it. Nothing is overridden: the app under test
  // starts in Bangla, which is what an owner who never opens settings gets.
  return ProviderScope(
    child: MaterialApp(
      theme: HisabTheme.light(),
      debugShowCheckedModeBanner: false,
      home: const ThemePreviewScreen(),
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
    ),
  );
}

/// Scrolls the whole screen past the viewport, so an overflow anywhere in the
/// list is exercised and not just the part that happens to be on screen.
Future<void> _scrollToEnd(WidgetTester tester) async {
  final Finder scrollable = find.byType(Scrollable).first;
  for (int i = 0; i < 40; i++) {
    await tester.drag(scrollable, const Offset(0, -500));
    await tester.pump();
    expect(
      tester.takeException(),
      isNull,
      reason: 'something overflowed while scrolling',
    );
  }
  await tester.pumpAndSettle();
}

void main() {
  for (final double scale in kTextScales) {
    group('at text scale ${scale}x on a 5-inch screen', () {
      testWidgets('nothing truncates, overlaps or clips', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = kSmallestPhone;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(_app(scale));
        await tester.pumpAndSettle();
        // A RenderFlex overflow, a clipped box or a failed layout all arrive
        // here as an exception. Silence is the assertion.
        expect(tester.takeException(), isNull);

        await _scrollToEnd(tester);
      });

      testWidgets('every hit target clears 48dp', (WidgetTester tester) async {
        tester.view.physicalSize = kSmallestPhone;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final SemanticsHandle handle = tester.ensureSemantics();
        addTearDown(handle.dispose);

        await tester.pumpWidget(_app(scale));
        await tester.pumpAndSettle();

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      });

      testWidgets('every interactive element carries a Bangla label', (
        WidgetTester tester,
      ) async {
        tester.view.physicalSize = kSmallestPhone;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        final SemanticsHandle handle = tester.ensureSemantics();
        addTearDown(handle.dispose);

        await tester.pumpWidget(_app(scale));
        await tester.pumpAndSettle();

        // Every tappable node has a label at all...
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        // ...and the labels are Bangla, not English. An untranslated
        // user-facing string is a defect (NFR-20).
        for (final Widget widget in tester.allWidgets) {
          if (widget is Text && widget.data != null) {
            expect(
              _isPermitted(widget.data!),
              isTrue,
              reason: '"${widget.data}" is not Bangla',
            );
          }
        }
      });
    });
  }

  group('primary actions', () {
    testWidgets('are 54px tall, above the 48dp floor', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = kSmallestPhone;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(1.0));
      await tester.pumpAndSettle();

      for (final Type type in <Type>[
        FilledButton,
        OutlinedButton,
        TextButton,
      ]) {
        final Finder button = find.byType(type);
        expect(button, findsWidgets, reason: 'no $type on the preview screen');
        for (final Element element in button.evaluate()) {
          final RenderBox box = element.renderObject! as RenderBox;
          expect(
            box.size.height,
            greaterThanOrEqualTo(HisabMetrics.buttonHeight),
            reason: '$type is shorter than ${HisabMetrics.buttonHeight}px',
          );
        }
      }
    });
  });

  group('meaning survives without colour', () {
    testWidgets('money in and out are distinguished by sign and word', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = kSmallestPhone;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(1.0));
      await tester.pumpAndSettle();

      // Colour is never the only carrier of meaning: the sign is in the figure
      // and the word is under it.
      expect(find.textContaining('+'), findsWidgets);
      expect(find.textContaining('−'), findsWidgets);
      expect(find.text('জমা হলো'), findsOneWidget);
      expect(find.text('খরচ হলো'), findsOneWidget);
    });
  });

  group('no animation is load-bearing', () {
    testWidgets('the screen is complete on its first frame', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = kSmallestPhone;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(1.0));
      // One frame, no settling: with reduced motion on, or with animations
      // disabled entirely, the screen still reads.
      expect(find.text('রং'), findsOneWidget);
      expect(find.text('খাতার সারি'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

/// Latin is allowed only where it is a token key, a font family name or a
/// number — the things a developer needs to read on a theme sheet. Everything a
/// shop owner would read is Bangla.
final RegExp _tokenish = RegExp(r'^[a-zA-Z0-9 ·.\-]+$');

bool _isPermitted(String text) {
  if (_tokenish.hasMatch(text)) {
    return true;
  }
  // Anything else must contain Bangla.
  return RegExp(r'[ঀ-৿]').hasMatch(text);
}
