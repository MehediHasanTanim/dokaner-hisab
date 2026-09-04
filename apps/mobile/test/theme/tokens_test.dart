// Asserts every token against DESIGN.md.
//
// This test is a transcription check, nothing cleverer. It exists because the
// failure it catches is silent: someone nudges a green, or drops a token they
// think is unused, and the app drifts away from the design document with no
// visible symptom until two screens disagree. The values below were read from
// the frontmatter of
//   _bmad-output/planning-artifacts/ux-designs/ux-hisab-dokan-2026-08-29/DESIGN.md
// and are duplicated here on purpose: a copy that disagrees is the whole point.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisab/theme/tokens.dart';

void main() {
  group('colours', () {
    test('DESIGN.md defines fifteen, and there are fifteen', () {
      // The epic context says "13 colour tokens". That count is stale:
      // DESIGN.md's frontmatter defines fifteen names, two of which share a
      // value by design. Fifteen names is the contract.
      expect(HisabColors.all, hasLength(15));
    });

    test('every value matches DESIGN.md', () {
      expect(HisabColors.all, <String, Color>{
        'paper': const Color(0xFFFAF5EA),
        'paper-sunk': const Color(0xFFF1E7D3),
        'surface': const Color(0xFFFFFDF8),
        'rule': const Color(0xFFE4D9C2),
        'ink': const Color(0xFF2B2419),
        'ink-muted': const Color(0xFF7C6F5B),
        'ink-faint': const Color(0xFFB9AC94),
        'accent': const Color(0xFF1F5D46),
        'money-in': const Color(0xFF1F5D46),
        'money-out': const Color(0xFF9C4221),
        'warn': const Color(0xFF8A6516),
        'warn-surface': const Color(0xFFF6EAD2),
        'warn-rule': const Color(0xFFE3CFA4),
        'ai-surface': const Color(0xFFEBF1EC),
        'ai-rule': const Color(0xFFC9DCCE),
      });
    });

    test('accent and money-in are one colour doing two jobs', () {
      // "one colour doing two jobs that never conflict: primary actions, and
      // money coming in." Two names, so that changing one cannot silently
      // change the other.
      expect(HisabColors.accent, HisabColors.moneyIn);
    });

    test('money-in and money-out are distinguishable from each other', () {
      expect(HisabColors.moneyIn, isNot(HisabColors.moneyOut));
    });

    test('ink is warm near-black, never pure black', () {
      expect(HisabColors.ink, isNot(const Color(0xFF000000)));
    });

    test('there is no third surface', () {
      // paper, paper-sunk and surface are the only grounds in the product.
      const Set<Color> grounds = <Color>{
        HisabColors.paper,
        HisabColors.paperSunk,
        HisabColors.surface,
      };
      expect(grounds, hasLength(3));
    });
  });

  group('typography', () {
    test('the scale is four amount sizes and four text roles', () {
      expect(HisabTypeScale.amounts, hasLength(4));
      expect(HisabTypeScale.text, hasLength(4));
      expect(HisabTypeScale.all, hasLength(8));
    });

    test('the amount ramp matches DESIGN.md', () {
      expect(HisabTypeScale.amountXl.size, 36);
      expect(HisabTypeScale.amountXl.weight, FontWeight.w700);
      // -0.02em at 36px.
      expect(HisabTypeScale.amountXl.letterSpacing, -0.72);

      expect(HisabTypeScale.amountLg.size, 26);
      expect(HisabTypeScale.amountLg.weight, FontWeight.w700);

      expect(HisabTypeScale.amountMd.size, 19);
      expect(HisabTypeScale.amountMd.weight, FontWeight.w700);

      expect(HisabTypeScale.amountSm.size, 15);
      expect(HisabTypeScale.amountSm.weight, FontWeight.w700);
    });

    test('the text roles match DESIGN.md', () {
      expect(HisabTypeScale.title.size, 18);
      expect(HisabTypeScale.title.weight, FontWeight.w600);
      expect(HisabTypeScale.title.family, HisabFonts.display);

      expect(HisabTypeScale.body.size, 15);
      expect(HisabTypeScale.body.weight, FontWeight.w400);

      expect(HisabTypeScale.label.size, 12);
      expect(HisabTypeScale.label.weight, FontWeight.w500);
      expect(HisabTypeScale.label.color, HisabColors.inkMuted);

      expect(HisabTypeScale.meta.size, 12.5);
      expect(HisabTypeScale.meta.weight, FontWeight.w400);
      expect(HisabTypeScale.meta.color, HisabColors.inkMuted);
    });

    test('the amount ramp descends and never repeats a size', () {
      final List<double> sizes = HisabTypeScale.amounts
          .map((HisabTypeRole r) => r.size)
          .toList();
      expect(sizes, <double>[36, 26, 19, 15]);
    });

    test('the serif sets titles and receipts only, never below 17px', () {
      for (final HisabTypeRole role in HisabTypeScale.all.values) {
        if (role.family == HisabFonts.display) {
          expect(
            role.size,
            greaterThanOrEqualTo(HisabFonts.displayMinSize),
            reason: '${role.name} uses the serif below its 17px floor',
          );
        }
      }
    });

    test('every number is set in the UI family', () {
      for (final HisabTypeRole role in HisabTypeScale.amounts) {
        expect(role.family, HisabFonts.ui, reason: '${role.name} sets money');
      }
    });

    test('only one role uses the serif', () {
      final Iterable<HisabTypeRole> serif = HisabTypeScale.all.values.where(
        (HisabTypeRole r) => r.family == HisabFonts.display,
      );
      expect(serif.map((HisabTypeRole r) => r.name), <String>['title']);
    });
  });

  group('radii', () {
    test('there are five', () {
      expect(HisabRadii.all, hasLength(5));
    });

    test('every value matches DESIGN.md', () {
      expect(HisabRadii.all, <String, double>{
        'sm': 6,
        'chip': 999,
        'md': 12,
        'lg': 14,
        'sheet': 20,
      });
    });

    test('the receipt radius is the deliberate outlier', () {
      // "Receipts are the deliberate outlier at 6px — a receipt should read as
      // a printed slip, not as a card."
      expect(HisabRadii.sm, lessThan(HisabRadii.md));
    });
  });

  group('spacing', () {
    test('there are six steps: 4 / 8 / 12 / 16 / 22 / 32', () {
      expect(HisabSpacing.all, hasLength(6));
      expect(HisabSpacing.all.values.toList(), <double>[4, 8, 12, 16, 22, 32]);
    });

    test('screen margin is 16 and stacked cards are 12 apart', () {
      expect(HisabSpacing.screenMargin, 16);
      expect(HisabSpacing.cardGap, 12);
    });
  });

  group('component metrics', () {
    test('buttons are 54px at radius 13', () {
      expect(HisabMetrics.buttonHeight, 54);
      expect(HisabMetrics.buttonRadius, 13);
      expect(HisabMetrics.buttonLabelSize, 16.5);
      expect(HisabMetrics.buttonLabelWeight, FontWeight.w600);
      expect(HisabMetrics.buttonBorderWidth, 1.5);
    });

    test('a primary action clears the 48dp accessibility floor', () {
      expect(HisabMetrics.buttonHeight, greaterThan(HisabMetrics.minHitTarget));
      expect(HisabMetrics.minHitTarget, 48);
    });

    test('quick actions are at least 80px', () {
      expect(HisabMetrics.quickActionMinHeight, 80);
      expect(HisabMetrics.quickActionIconSize, 24);
      expect(HisabMetrics.quickActionLabelSize, 13.5);
    });

    test('cards are radius 14 with 14px inside', () {
      expect(HisabRadii.lg, 14);
      expect(HisabMetrics.cardPadding, 14);
    });

    test('fields are radius 12 with 11/13 padding and a 17px value', () {
      expect(HisabRadii.md, 12);
      expect(HisabMetrics.fieldPaddingVertical, 11);
      expect(HisabMetrics.fieldPaddingHorizontal, 13);
      expect(HisabMetrics.fieldLabelSize, 12);
      expect(HisabMetrics.fieldValueSize, 17);
    });

    test('the app bar is 58px and the bottom nav 66px', () {
      expect(HisabMetrics.appBarHeight, 58);
      expect(HisabMetrics.bottomNavHeight, 66);
      expect(HisabMetrics.bottomNavIconSize, 21);
      expect(HisabMetrics.bottomNavLabelSize, 11);
    });

    test('the ledger row grid is 52 / 1fr / 78 / 82 at 13px', () {
      expect(HisabMetrics.ledgerDateWidth, 52);
      expect(HisabMetrics.ledgerAmountWidth, 78);
      expect(HisabMetrics.ledgerBalanceWidth, 82);
      expect(HisabMetrics.ledgerPaddingVertical, 11);
      expect(HisabMetrics.ledgerPaddingHorizontal, 16);
      expect(HisabMetrics.ledgerTextSize, 13);
    });

    test('there is one line weight in the product', () {
      expect(HisabMetrics.ruleWidth, 1);
    });

    test('nothing is elevated', () {
      // "Cards separate from the ground by tone and by a 1px rule, never by
      // shadow." The two exceptions are a bottom sheet and the centre nav
      // button, and neither exists yet.
      expect(HisabMetrics.flat, 0);
    });
  });
}
