// The Hisab theme: Material 3 with only the documented delta overridden.
//
// EXPERIENCE.md § Foundation is explicit about the contract: "Components inherit
// M3 anatomy, states and accessibility behaviour; this document specifies only
// the delta. Where M3 and this document disagree on a detail neither specifies,
// take the M3 default rather than inventing one."
//
// So this file sets colour, type and the component metrics DESIGN.md fixes, and
// nothing else. It does not restate M3's state layers, ripples, focus rings,
// tap-target padding or motion curves — those keep working, which is the point
// of theming M3 rather than replacing it.
//
// M3 is the default in this Flutter SDK; there is no `useMaterial3` flag to set.

// Prefixed so the import is unambiguous regardless of what `material.dart`
// happens to re-export from `dart:ui` in a given SDK.
import 'dart:ui' as ui show FontFeature;

import 'package:flutter/material.dart';

import 'tokens.dart';

/// Tabular figures, globally, without exception.
///
/// DESIGN.md § Typography: "a ledger where the digits wander is a ledger the
/// owner will not trust." Applied to every style in the theme, including the
/// serif ones, because receipts carry numbers too.
const List<ui.FontFeature> kTabularFigures = <ui.FontFeature>[
  ui.FontFeature.tabularFigures(),
];

TextStyle _role(HisabTypeRole role) => TextStyle(
  fontFamily: role.family,
  fontFamilyFallback: role.family == HisabFonts.display
      ? HisabFonts.displayFallback
      : HisabFonts.uiFallback,
  fontSize: role.size,
  fontWeight: role.weight,
  letterSpacing: role.letterSpacing,
  color: role.color ?? HisabColors.ink,
  fontFeatures: kTabularFigures,
);

TextStyle _ui(double size, FontWeight weight, {Color color = HisabColors.ink}) =>
    TextStyle(
      fontFamily: HisabFonts.ui,
      fontFamilyFallback: HisabFonts.uiFallback,
      fontSize: size,
      fontWeight: weight,
      color: color,
      fontFeatures: kTabularFigures,
    );

/// The named text styles.
///
/// The eight DESIGN.md roles, plus the handful of component-specific sizes the
/// component specs fix. Widgets outside `lib/theme/` reference these by name (or
/// read `Theme.of(context).textTheme`) instead of writing a `fontSize:`, which
/// is what `tool/check_theme_tokens.dart` enforces.
abstract final class HisabTextStyles {
  // The amount ramp. Money is the largest thing on any screen it appears on.
  static final TextStyle amountXl = _role(HisabTypeScale.amountXl);
  static final TextStyle amountLg = _role(HisabTypeScale.amountLg);
  static final TextStyle amountMd = _role(HisabTypeScale.amountMd);
  static final TextStyle amountSm = _role(HisabTypeScale.amountSm);

  // The four text roles.
  static final TextStyle title = _role(HisabTypeScale.title);
  static final TextStyle body = _role(HisabTypeScale.body);
  static final TextStyle label = _role(HisabTypeScale.label);
  static final TextStyle meta = _role(HisabTypeScale.meta);

  /// The eight roles keyed by their DESIGN.md name. Iterated by
  /// test/theme/typography_test.dart, which asserts that every one of them
  /// carries tabular figures and resolves to a bundled family.
  static final Map<String, TextStyle> byRole = <String, TextStyle>{
    'amount-xl': amountXl,
    'amount-lg': amountLg,
    'amount-md': amountMd,
    'amount-sm': amountSm,
    'title': title,
    'body': body,
    'label': label,
    'meta': meta,
  };

  /// The style for a token role, so a widget names the role rather than a size.
  static TextStyle forRole(HisabTypeRole role) =>
      byRole[role.name] ?? _role(role);

  /// Money arriving. Colour is never the only carrier of meaning — the sign and
  /// the column position carry it too (EXPERIENCE.md § Accessibility Floor).
  static final TextStyle amountIn = amountSm.copyWith(color: HisabColors.moneyIn);

  /// Money leaving, and dues owed.
  static final TextStyle amountOut = amountSm.copyWith(
    color: HisabColors.moneyOut,
  );

  /// 16.5px / 600 on all three button levels.
  static final TextStyle buttonLabel = _ui(
    HisabMetrics.buttonLabelSize,
    HisabMetrics.buttonLabelWeight,
  );

  /// A field's label sits above its value at 12px.
  static final TextStyle fieldLabel = label;

  /// A field's value is 17px/600 — large, because a shop owner checks the
  /// number they just typed while a customer watches.
  static final TextStyle fieldValue = _ui(
    HisabMetrics.fieldValueSize,
    HisabMetrics.fieldValueWeight,
  );

  /// Placeholder text is the only use of ink-faint.
  static final TextStyle fieldHint = _ui(
    HisabMetrics.fieldValueSize,
    HisabMetrics.fieldValueWeight,
    color: HisabColors.inkFaint,
  );

  /// 13.5px / 600, and it never truncates: the constraint is on the wording.
  static final TextStyle quickActionLabel = _ui(
    HisabMetrics.quickActionLabelSize,
    HisabMetrics.quickActionLabelWeight,
  );

  /// 12px / 600 on a chip.
  static final TextStyle chipLabel = _ui(
    HisabMetrics.chipLabelSize,
    HisabMetrics.chipLabelWeight,
  );

  static final TextStyle chipLabelSelected = chipLabel.copyWith(
    color: HisabColors.paper,
  );

  /// The ledger row: 13px, the component everything else serves.
  static final TextStyle ledger = _ui(
    HisabMetrics.ledgerTextSize,
    FontWeight.w400,
  );

  /// The running-balance column is heavier than the rest.
  static final TextStyle ledgerBalance = _ui(
    HisabMetrics.ledgerTextSize,
    FontWeight.w600,
  );

  /// 11px under a 21px icon.
  static final TextStyle bottomNavLabel = _ui(
    HisabMetrics.bottomNavLabelSize,
    FontWeight.w500,
  );

  /// Disclosure banners: the sentences the product is obliged to say.
  static final TextStyle banner = _ui(
    HisabMetrics.bannerTextSize,
    FontWeight.w400,
    color: HisabColors.warn,
  );

  /// Text on an AI surface. Always labelled, never mistakable for a record.
  static final TextStyle aiBody = _ui(
    HisabMetrics.bannerTextSize,
    FontWeight.w400,
  );
}

/// The Hisab theme.
abstract final class HisabTheme {
  /// There is one theme. DESIGN.md describes a paper ledger in daylight; a dark
  /// variant is not specified and is not invented here.
  static ThemeData light() {
    return ThemeData(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: HisabColors.paper,
      canvasColor: HisabColors.paper,
      splashColor: HisabColors.paperSunk,
      // "Effectively none. Cards separate from the ground by tone and by a 1px
      // rule, never by shadow." The two exceptions in the whole product are a
      // bottom sheet and the raised centre nav button; neither exists yet.
      shadowColor: Colors.transparent,
      // M3 tints surfaces with the primary colour as they elevate. On paper
      // that reads as a green cast, so the tint is off everywhere.
      applyElevationOverlayColor: false,
      // 48dp minimum hit target throughout (UX-DR21). M3 already pads tap
      // targets on mobile; pinning it here means a desktop or test host
      // cannot quietly drop below the floor.
      materialTapTargetSize: MaterialTapTargetSize.padded,
      iconTheme: const IconThemeData(
        color: HisabColors.ink,
        size: HisabMetrics.iconSize,
      ),
      dividerTheme: dividerTheme,
      appBarTheme: appBarTheme,
      cardTheme: cardTheme,
      chipTheme: chipTheme,
      inputDecorationTheme: inputDecorationTheme,
      filledButtonTheme: filledButtonTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      outlinedButtonTheme: outlinedButtonTheme,
      textButtonTheme: textButtonTheme,
      navigationBarTheme: navigationBarTheme,
      bottomSheetTheme: bottomSheetTheme,
      listTileTheme: listTileTheme,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: HisabColors.accent,
        selectionHandleColor: HisabColors.accent,
      ),
    );
  }

  // ── Colour ─────────────────────────────────────────────────────────────────
  //
  // M3's roles are filled from the fifteen tokens. Where a role has no token
  // behind it, it is derived from one rather than introduced: there is no
  // sixteenth colour in the product.

  static const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,

    // Primary actions, and money arriving — one colour, two jobs.
    primary: HisabColors.accent,
    onPrimary: HisabColors.paper,
    primaryContainer: HisabColors.aiSurface,
    onPrimaryContainer: HisabColors.accent,

    // Money leaving, and destructive actions. There is no red button in the
    // product: a destructive action is a tertiary button with money-out text.
    secondary: HisabColors.moneyOut,
    onSecondary: HisabColors.paper,
    secondaryContainer: HisabColors.paperSunk,
    onSecondaryContainer: HisabColors.ink,

    // Warning. Reserved almost entirely for stock and for disclosures.
    tertiary: HisabColors.warn,
    onTertiary: HisabColors.paper,
    tertiaryContainer: HisabColors.warnSurface,
    onTertiaryContainer: HisabColors.warn,

    // "Avoid red error fills — money-out is the strongest red the product owns."
    error: HisabColors.moneyOut,
    onError: HisabColors.paper,
    errorContainer: HisabColors.warnSurface,
    onErrorContainer: HisabColors.moneyOut,

    // The ground is paper; cards and rows sit on surface, one shade lighter.
    surface: HisabColors.paper,
    onSurface: HisabColors.ink,
    surfaceDim: HisabColors.paperSunk,
    surfaceBright: HisabColors.surface,
    surfaceContainerLowest: HisabColors.surface,
    surfaceContainerLow: HisabColors.surface,
    surfaceContainer: HisabColors.paper,
    surfaceContainerHigh: HisabColors.paperSunk,
    surfaceContainerHighest: HisabColors.paperSunk,
    onSurfaceVariant: HisabColors.inkMuted,

    // One line colour for every rule in the product.
    outline: HisabColors.rule,
    outlineVariant: HisabColors.rule,

    shadow: Colors.transparent,
    scrim: HisabColors.ink,
    inverseSurface: HisabColors.ink,
    onInverseSurface: HisabColors.paper,
    inversePrimary: HisabColors.aiRule,
    surfaceTint: Colors.transparent,
  );

  // ── Type ───────────────────────────────────────────────────────────────────
  //
  // M3 has fifteen text slots; DESIGN.md has eight roles. Every slot is filled
  // from one of the eight — none is left to fall through to a system font,
  // because a system font is exactly the Bangla conjunct failure UX-DR3 exists
  // to prevent.

  static TextTheme get textTheme => TextTheme(
    // The amount ramp owns the display slots: money is the content.
    displayLarge: HisabTextStyles.amountXl,
    displayMedium: HisabTextStyles.amountLg,
    displaySmall: HisabTextStyles.amountMd,

    headlineLarge: HisabTextStyles.amountLg,
    headlineMedium: HisabTextStyles.amountMd,
    headlineSmall: HisabTextStyles.amountSm,

    // The serif sets titles and nothing smaller than 17px.
    titleLarge: HisabTextStyles.title,
    titleMedium: HisabTextStyles.title,
    titleSmall: HisabTextStyles.title,

    bodyLarge: HisabTextStyles.body,
    bodyMedium: HisabTextStyles.body,
    bodySmall: HisabTextStyles.meta,

    labelLarge: HisabTextStyles.label,
    labelMedium: HisabTextStyles.label,
    labelSmall: HisabTextStyles.label,
  );

  // ── Components ─────────────────────────────────────────────────────────────

  /// One line weight, one line colour, everywhere.
  static const DividerThemeData dividerTheme = DividerThemeData(
    color: HisabColors.rule,
    thickness: HisabMetrics.ruleWidth,
    space: HisabMetrics.ruleWidth,
  );

  /// `height 58px, paper fill, 1px rule below, title 18px/600 display`.
  ///
  /// NOTE for a future SDK bump: this is `AppBarThemeData`, the normalised name
  /// Flutter moved to. On an older SDK the class is `AppBarTheme`.
  static AppBarThemeData get appBarTheme => AppBarThemeData(
    toolbarHeight: HisabMetrics.appBarHeight,
    backgroundColor: HisabColors.paper,
    foregroundColor: HisabColors.ink,
    surfaceTintColor: Colors.transparent,
    elevation: HisabMetrics.flat,
    scrolledUnderElevation: HisabMetrics.flat,
    centerTitle: false,
    titleTextStyle: HisabTextStyles.title,
    iconTheme: const IconThemeData(
      color: HisabColors.ink,
      size: HisabMetrics.iconSize,
    ),
    // The rule under the app bar is the same 1px line as every other rule.
    shape: const Border(
      bottom: BorderSide(
        color: HisabColors.rule,
        width: HisabMetrics.ruleWidth,
      ),
    ),
  );

  /// `radius 14, surface fill, 1px rule, 14px padding`.
  ///
  /// NOTE for a future SDK bump: `CardThemeData` is the normalised name; older
  /// SDKs call it `CardTheme`.
  static const CardThemeData cardTheme = CardThemeData(
    color: HisabColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: HisabMetrics.flat,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(HisabRadii.lg)),
      side: BorderSide(
        color: HisabColors.rule,
        width: HisabMetrics.ruleWidth,
      ),
    ),
  );

  /// `radius 999, paper-sunk fill, 12px/600, 5/11px padding; selected = accent fill`.
  ///
  /// Selected state is a fill change, never a border change, because a border
  /// change is invisible at arm's length.
  static ChipThemeData get chipTheme => ChipThemeData(
    backgroundColor: HisabColors.paperSunk,
    selectedColor: HisabColors.accent,
    secondarySelectedColor: HisabColors.accent,
    disabledColor: HisabColors.paperSunk,
    surfaceTintColor: Colors.transparent,
    elevation: HisabMetrics.flat,
    pressElevation: HisabMetrics.flat,
    showCheckmark: false,
    side: BorderSide.none,
    shape: const StadiumBorder(),
    labelStyle: HisabTextStyles.chipLabel,
    secondaryLabelStyle: HisabTextStyles.chipLabelSelected,
    padding: const EdgeInsets.symmetric(
      vertical: HisabMetrics.chipPaddingVertical,
      horizontal: HisabMetrics.chipPaddingHorizontal,
    ),
  );

  /// `radius 12, surface fill, 1px rule, 11/13px padding, label 12px over value 17px/600`.
  ///
  /// The value style itself is [HisabTextStyles.fieldValue] — `InputDecoration`
  /// does not carry the input's own text style, so a field passes it explicitly.
  ///
  /// NOTE for a future SDK bump: `InputDecorationThemeData` is the normalised
  /// name; older SDKs call it `InputDecorationTheme`.
  static InputDecorationThemeData get inputDecorationTheme =>
      InputDecorationThemeData(
        filled: true,
        fillColor: HisabColors.surface,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          vertical: HisabMetrics.fieldPaddingVertical,
          horizontal: HisabMetrics.fieldPaddingHorizontal,
        ),
        labelStyle: HisabTextStyles.fieldLabel,
        floatingLabelStyle: HisabTextStyles.fieldLabel,
        hintStyle: HisabTextStyles.fieldHint,
        helperStyle: HisabTextStyles.meta,
        errorStyle: HisabTextStyles.meta.copyWith(color: HisabColors.moneyOut),
        border: _fieldBorder(HisabColors.rule),
        enabledBorder: _fieldBorder(HisabColors.rule),
        disabledBorder: _fieldBorder(HisabColors.rule),
        // Focus is the one place a field takes the accent, matching the amount
        // field rising to accent while it is being entered.
        focusedBorder: _fieldBorder(
          HisabColors.accent,
          width: HisabMetrics.buttonBorderWidth,
        ),
        errorBorder: _fieldBorder(HisabColors.moneyOut),
        focusedErrorBorder: _fieldBorder(
          HisabColors.moneyOut,
          width: HisabMetrics.buttonBorderWidth,
        ),
      );

  static OutlineInputBorder _fieldBorder(
    Color color, {
    double width = HisabMetrics.ruleWidth,
  }) => OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(HisabRadii.md)),
    borderSide: BorderSide(color: color, width: width),
  );

  /// Primary: `height 54px, radius 13px, accent fill, 16.5px/600`.
  ///
  /// 54px is the floor for a primary action, above the 48dp minimum, because
  /// these are pressed one-handed at speed.
  static FilledButtonThemeData get filledButtonTheme =>
      FilledButtonThemeData(style: primaryButtonStyle);

  /// `ElevatedButton` is themed to the same flat primary so a screen that
  /// reaches for it does not quietly reintroduce a shadow.
  static ElevatedButtonThemeData get elevatedButtonTheme =>
      ElevatedButtonThemeData(style: primaryButtonStyle);

  static ButtonStyle get primaryButtonStyle => _buttonBase().copyWith(
    backgroundColor: const WidgetStatePropertyAll<Color>(HisabColors.accent),
    foregroundColor: const WidgetStatePropertyAll<Color>(HisabColors.paper),
  );

  /// Secondary: `height 54px, radius 13px, 1.5px accent border, transparent fill`.
  static OutlinedButtonThemeData get outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: _buttonBase().copyWith(
          backgroundColor: const WidgetStatePropertyAll<Color>(
            Colors.transparent,
          ),
          foregroundColor: const WidgetStatePropertyAll<Color>(
            HisabColors.accent,
          ),
          side: const WidgetStatePropertyAll<BorderSide>(
            BorderSide(
              color: HisabColors.accent,
              width: HisabMetrics.buttonBorderWidth,
            ),
          ),
        ),
      );

  /// Tertiary: `height 54px, radius 13px, paper-sunk fill, ink text`.
  ///
  /// Destructive actions are this button with `money-out` text. There is no red
  /// button in the product.
  static TextButtonThemeData get textButtonTheme => TextButtonThemeData(
    style: _buttonBase().copyWith(
      backgroundColor: const WidgetStatePropertyAll<Color>(
        HisabColors.paperSunk,
      ),
      foregroundColor: const WidgetStatePropertyAll<Color>(HisabColors.ink),
    ),
  );

  static ButtonStyle _buttonBase() => ButtonStyle(
    minimumSize: const WidgetStatePropertyAll<Size>(
      Size(HisabMetrics.minHitTarget, HisabMetrics.buttonHeight),
    ),
    // Below this a button cannot be hit reliably one-handed at a counter.
    tapTargetSize: MaterialTapTargetSize.padded,
    padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
      EdgeInsets.symmetric(horizontal: HisabSpacing.s4),
    ),
    textStyle: WidgetStatePropertyAll<TextStyle>(HisabTextStyles.buttonLabel),
    elevation: const WidgetStatePropertyAll<double>(HisabMetrics.flat),
    shadowColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
    surfaceTintColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
    shape: const WidgetStatePropertyAll<OutlinedBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(HisabMetrics.buttonRadius),
        ),
      ),
    ),
  );

  /// `height 66px, surface fill, 1px rule above, icon 21px over 11px label`.
  ///
  /// The rule above the bar is drawn by the shell widget — `NavigationBar` has
  /// no border slot — and uses the same 1px `rule` as everything else.
  static NavigationBarThemeData get navigationBarTheme =>
      NavigationBarThemeData(
        height: HisabMetrics.bottomNavHeight,
        backgroundColor: HisabColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: HisabColors.paperSunk,
        elevation: HisabMetrics.flat,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll<TextStyle>(
          HisabTextStyles.bottomNavLabel,
        ),
        iconTheme: const WidgetStatePropertyAll<IconThemeData>(
          IconThemeData(
            color: HisabColors.ink,
            size: HisabMetrics.bottomNavIconSize,
          ),
        ),
      );

  /// `radius 20` on the top corners. A bottom sheet is one of the two things in
  /// the product that casts a shadow, because it genuinely sits over the page.
  static BottomSheetThemeData get bottomSheetTheme => const BottomSheetThemeData(
    backgroundColor: HisabColors.surface,
    surfaceTintColor: Colors.transparent,
    showDragHandle: true,
    dragHandleColor: HisabColors.rule,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(HisabRadii.sheet),
      ),
    ),
  );

  static ListTileThemeData get listTileTheme => ListTileThemeData(
    minVerticalPadding: HisabSpacing.s3,
    // Every row is at least a 48dp target even before its content grows it.
    minTileHeight: HisabMetrics.minHitTarget,
    iconColor: HisabColors.ink,
    textColor: HisabColors.ink,
    titleTextStyle: HisabTextStyles.body,
    subtitleTextStyle: HisabTextStyles.meta,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: HisabSpacing.s4,
      vertical: HisabSpacing.s1,
    ),
  );
}
