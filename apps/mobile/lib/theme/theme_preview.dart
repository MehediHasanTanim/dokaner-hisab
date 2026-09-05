// A development-only screen that renders the theme so it can be looked at on a
// device and tested by machine.
//
// This is scaffolding, not product. It is NOT হোম, it is not a navigation shell
// and it is not any Epic-1 feature screen — those are other stories, and
// building them here would be building them twice. What it is for:
//
//   * making the tokens visible on a real phone, in daylight, at arm's length,
//     which is the condition every decision in DESIGN.md is made against;
//   * showing one stored integer rendered in both languages, which is the only
//     way to see on a device that a value never changes when its script does;
//   * giving test/theme/accessibility_test.dart something real to render at the
//     largest system font size on a 5-inch viewport.
//
// Every figure on this screen comes from `lib/format/`. There is not one
// hand-written ৳ or Bangla numeral left in it, and
// `tool/check_single_formatter.dart` keeps it that way.
//
// Every string on it is Bangla, because there is no such thing as an
// English-only surface in this product.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../format/format.dart';
import 'hisab_theme.dart';
import 'tokens.dart';

/// Above this text scale a fixed-column layout stops being honest and the row
/// stacks instead. Labels shorten before type does (UX-DR22), and a column that
/// cannot hold its number stacks rather than clipping it.
const double _stackAtScale = 1.35;

/// Above this the two-up swatch grid becomes one column.
const double _singleColumnAtScale = 1.6;

// ── The stored values on this screen ─────────────────────────────────────────
//
// Integers, because that is how money and quantity are stored (AR-1, AR-2) and
// how they arrive at every surface. Nothing on this screen holds a figure as
// text or as a double.

/// ৳1,08,500.00 — the figure DESIGN.md uses to state the grouping rule.
const int _sampleAmountPaisa = 10850000;

/// The same amount with paisa in it, so the two-language section shows the
/// decimal case as well as the grouping.
const int _sampleAmountWithPaisa = 10850050;

const int _sampleCreditPaisa = 1250000;
const int _sampleDebitPaisa = 320000;
const int _ledgerCreditPaisa = 50000;
const int _ledgerBalancePaisa = 436000;

/// 2.5 kg of rice. Milli-units: quantity is not money and carries no ৳.
const int _sampleQuantityMilli = 2500;
const String _sampleQuantityUnit = 'কেজি';

double _textScale(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(100) / 100;

class ThemePreviewScreen extends ConsumerWidget {
  const ThemePreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The language is read, never assumed. Story 1.9 gives it a settings screen
    // and a persistent store; here it starts at Bangla and is remembered by
    // nothing, which is exactly what this story asks for.
    final HisabLanguage language = ref.watch(hisabLanguageProvider);

    return Scaffold(
      appBar: AppBar(
        // The app bar is fixed chrome at 58px, so its title clamps rather than
        // growing the bar. Everything in the scrolling body below scales all
        // the way — that is where layout integrity has to hold (UX-DR22).
        title: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: const Text('হিসাব — থিম'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(HisabSpacing.screenMargin),
          children: <Widget>[
            const _Section(
              heading: 'রং',
              note: 'প্রতিটি রঙের অর্থ একটাই — জমা, খরচ, সতর্কতা, হিসাবের নিজের কথা।',
              child: _Palette(),
            ),
            const SizedBox(height: HisabSpacing.cardGap),
            _Section(
              heading: 'অঙ্ক',
              note:
                  'একই সংখ্যা, দুই ভাষায়। জমা টাকা বদলায় না — শুধু অঙ্ক আর কমার জায়গা বদলায়।',
              child: _Numerals(
                language: language,
                onSelect: (HisabLanguage value) =>
                    ref.read(hisabLanguageProvider.notifier).select(value),
              ),
            ),
            const SizedBox(height: HisabSpacing.cardGap),
            _Section(
              heading: 'লেখার মাপ',
              note: 'টাকার অঙ্ক পর্দার সবচেয়ে বড় জিনিস। অঙ্কের চওড়া সবসময় সমান।',
              child: _TypeScale(language: language),
            ),
            const SizedBox(height: HisabSpacing.cardGap),
            _Section(
              heading: 'টাকার রং',
              note: 'রং একা কিছু বোঝায় না — চিহ্ন আর কথাও সঙ্গে থাকে।',
              child: _MoneyColors(language: language),
            ),
            const SizedBox(height: HisabSpacing.cardGap),
            _Section(
              heading: 'খাতার সারি',
              note: 'ডান পাশের বাকির ঘরটাই সবচেয়ে ভারী — চোখ আগে সেখানে পড়ে।',
              child: _LedgerRow(language: language),
            ),
            const SizedBox(height: HisabSpacing.cardGap),
            const _Section(
              heading: 'বোতাম ও চিপ',
              note: 'সব বোতাম কমপক্ষে ৫৪ পিক্সেল উঁচু, এক হাতে চাপার মতো।',
              child: _Actions(),
            ),
            const SizedBox(height: HisabSpacing.s6),
          ],
        ),
      ),
    );
  }
}

// ── Section shell ────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.heading,
    required this.note,
    required this.child,
  });

  final String heading;
  final String note;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(HisabMetrics.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(heading, style: HisabTextStyles.title),
            const SizedBox(height: HisabSpacing.s1),
            Text(note, style: HisabTextStyles.meta),
            const SizedBox(height: HisabSpacing.s3),
            const Divider(),
            const SizedBox(height: HisabSpacing.s3),
            child,
          ],
        ),
      ),
    );
  }
}

// ── Palette ──────────────────────────────────────────────────────────────────

/// The Bangla name of each token, so the screen reads as Bangla and not as a
/// list of CSS variables. The token key stays visible underneath because this
/// is the screen a developer diffs against DESIGN.md.
const Map<String, String> _colorNamesBn = <String, String>{
  'paper': 'কাগজ',
  'paper-sunk': 'গাঢ় কাগজ',
  'surface': 'পাতা',
  'rule': 'দাগ',
  'ink': 'কালি',
  'ink-muted': 'হালকা কালি',
  'ink-faint': 'ফিকে কালি',
  'accent': 'মূল রং',
  'money-in': 'জমা',
  'money-out': 'খরচ',
  'warn': 'সতর্কতা',
  'warn-surface': 'সতর্ক পাতা',
  'warn-rule': 'সতর্ক দাগ',
  'ai-surface': 'হিসাবের পাতা',
  'ai-rule': 'হিসাবের দাগ',
};

class _Palette extends StatelessWidget {
  const _Palette();

  @override
  Widget build(BuildContext context) {
    final bool singleColumn = _textScale(context) > _singleColumnAtScale;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double columns = singleColumn ? 1 : 2;
        final double width =
            (constraints.maxWidth - (columns - 1) * HisabSpacing.s2) / columns;
        return Wrap(
          spacing: HisabSpacing.s2,
          runSpacing: HisabSpacing.s2,
          children: <Widget>[
            for (final MapEntry<String, Color> entry
                in HisabColors.all.entries)
              SizedBox(
                width: width,
                child: _Swatch(
                  token: entry.key,
                  name: _colorNamesBn[entry.key] ?? entry.key,
                  color: entry.value,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.token,
    required this.name,
    required this.color,
  });

  final String token;
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: HisabMetrics.minHitTarget,
          height: HisabMetrics.minHitTarget,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(
              Radius.circular(HisabRadii.sm),
            ),
            // Every swatch carries the product's one rule, so the near-white
            // tokens are still visible against paper.
            border: Border.all(
              color: HisabColors.rule,
              width: HisabMetrics.ruleWidth,
            ),
          ),
        ),
        const SizedBox(width: HisabSpacing.s2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(name, style: HisabTextStyles.body),
              Text(token, style: HisabTextStyles.label),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Numerals: one stored value, both languages ───────────────────────────────

/// The section that makes Story 1.3 visible on a device.
///
/// One integer — [_sampleAmountWithPaisa] — rendered twice. The digits and the
/// group widths differ; the value does not. Underneath sits the machine-readable
/// form that a CSV or a request body carries, which is the same in both
/// languages by design: a spreadsheet cannot open Bangla digits and lakh commas.
class _Numerals extends StatelessWidget {
  const _Numerals({required this.language, required this.onSelect});

  final HisabLanguage language;
  final ValueChanged<HisabLanguage> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: HisabSpacing.s2,
          runSpacing: HisabSpacing.s2,
          children: <Widget>[
            for (final HisabLanguage value in HisabLanguage.values)
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: HisabMetrics.minHitTarget,
                  minHeight: HisabMetrics.minHitTarget,
                ),
                child: ChoiceChip(
                  label: Text(value.endonym),
                  selected: value == language,
                  onSelected: (_) => onSelect(value),
                ),
              ),
          ],
        ),
        const SizedBox(height: HisabSpacing.s3),
        for (final HisabLanguage value in HisabLanguage.values)
          _Figure(
            label: value.endonym,
            value: MoneyFormat.format(
              _sampleAmountWithPaisa,
              language: value,
            ),
            style: value == language
                ? HisabTextStyles.amountLg
                : HisabTextStyles.amountMd,
          ),
        _Figure(
          label: 'রপ্তানির জন্য',
          value: MoneyFormat.export(_sampleAmountWithPaisa),
          style: HisabTextStyles.body,
        ),
        _Figure(
          label: 'পরিমাণ',
          value: QuantityFormat.format(
            _sampleQuantityMilli,
            language: language,
            unit: _sampleQuantityUnit,
          ),
          style: HisabTextStyles.amountMd,
        ),
      ],
    );
  }
}

/// A labelled figure: the amount first, then what it is. The figure is read
/// before its label (EXPERIENCE.md § Accessibility Floor), and it scales down
/// rather than clipping at the largest system font size.
class _Figure extends StatelessWidget {
  const _Figure({
    required this.label,
    required this.value,
    required this.style,
  });

  final String label;
  final String value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: HisabSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(value, style: style),
            ),
          ),
          Text(label, style: HisabTextStyles.label),
        ],
      ),
    );
  }
}

// ── Type scale ───────────────────────────────────────────────────────────────

class _TypeScale extends StatelessWidget {
  const _TypeScale({required this.language});

  final HisabLanguage language;

  /// Conjuncts on purpose: ক্ত and ঙ্ক are the two that fail first when a face
  /// is missing or a system font is substituted.
  static const String _sample = 'হিসাব · বাকি · সংযুক্ত ক্ত ঙ্ক';

  @override
  Widget build(BuildContext context) {
    final String amount = MoneyFormat.format(
      _sampleAmountPaisa,
      language: language,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final HisabTypeRole role in HisabTypeScale.amounts)
          _TypeRow(role: role, sample: amount),
        for (final HisabTypeRole role in HisabTypeScale.text)
          _TypeRow(role: role, sample: _sample),
      ],
    );
  }
}

class _TypeRow extends StatelessWidget {
  const _TypeRow({required this.role, required this.sample});

  final HisabTypeRole role;
  final String sample;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = HisabTextStyles.forRole(role);
    return Padding(
      padding: const EdgeInsets.only(bottom: HisabSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '${role.name} · ${role.family} · ${role.size}',
            style: HisabTextStyles.label,
          ),
          const SizedBox(height: HisabSpacing.s1),
          // A 36px figure at triple system scale is wider than a 5-inch screen.
          // It scales down to fit rather than clipping: nothing is truncated and
          // nothing overlaps, which is what UX-DR22 asks of the layout.
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(sample, style: style),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Money colours ────────────────────────────────────────────────────────────

class _MoneyColors extends StatelessWidget {
  const _MoneyColors({required this.language});

  final HisabLanguage language;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _MoneyLine(
          word: 'জমা হলো',
          // The direction is in the sign as well as the colour: colour is never
          // the only carrier of meaning.
          amount: MoneyFormat.format(
            _sampleCreditPaisa,
            language: language,
            sign: MoneySign.always,
          ),
          style: HisabTextStyles.amountMd.copyWith(color: HisabColors.moneyIn),
        ),
        const SizedBox(height: HisabSpacing.s2),
        _MoneyLine(
          word: 'খরচ হলো',
          amount: MoneyFormat.format(
            -_sampleDebitPaisa,
            language: language,
            sign: MoneySign.always,
          ),
          style: HisabTextStyles.amountMd.copyWith(color: HisabColors.moneyOut),
        ),
      ],
    );
  }
}

class _MoneyLine extends StatelessWidget {
  const _MoneyLine({
    required this.word,
    required this.amount,
    required this.style,
  });

  final String word;
  final String amount;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    // The amount is read before its label, matching the visual hierarchy
    // (EXPERIENCE.md § Accessibility Floor). The sign and the word carry the
    // meaning on their own, so nothing is lost if the colour is not perceived.
    return Semantics(
      label: '$amount $word',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(amount, style: style),
            ),
          ),
          Text(word, style: HisabTextStyles.label),
        ],
      ),
    );
  }
}

// ── Ledger row ───────────────────────────────────────────────────────────────

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.language});

  final HisabLanguage language;

  // A date, not a figure: dates are formatted by their own utility in a later
  // story and are not this story's business.
  static const String _date = '০৯ সেপ্ট';
  static const String _description = 'রহিম — চাল ৫ কেজি';

  @override
  Widget build(BuildContext context) {
    final bool stacked = _textScale(context) > _stackAtScale;
    final String credit = MoneyFormat.format(
      _ledgerCreditPaisa,
      language: language,
    );
    final String balance = MoneyFormat.format(
      _ledgerBalancePaisa,
      language: language,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (!stacked) ...<Widget>[
          _LedgerGrid(
            date: 'তারিখ',
            description: 'বিবরণ',
            credit: 'জমা',
            balance: 'বাকি',
            style: HisabTextStyles.label,
            balanceStyle: HisabTextStyles.label,
          ),
          const Divider(),
          _LedgerGrid(
            date: _date,
            description: _description,
            credit: credit,
            balance: balance,
            style: HisabTextStyles.ledger,
            creditStyle: HisabTextStyles.ledger.copyWith(
              color: HisabColors.moneyIn,
            ),
            balanceStyle: HisabTextStyles.ledgerBalance,
          ),
        ] else
          _LedgerStacked(
            date: _date,
            description: _description,
            credit: credit,
            balance: balance,
          ),
        const Divider(),
      ],
    );
  }
}

/// `grid 52px 1fr 78px 82px, 11/16px padding, 1px rule below, 13px`.
class _LedgerGrid extends StatelessWidget {
  const _LedgerGrid({
    required this.date,
    required this.description,
    required this.credit,
    required this.balance,
    required this.style,
    required this.balanceStyle,
    this.creditStyle,
  });

  final String date;
  final String description;
  final String credit;
  final String balance;
  final TextStyle style;
  final TextStyle balanceStyle;
  final TextStyle? creditStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: HisabMetrics.ledgerPaddingVertical,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: HisabMetrics.ledgerDateWidth,
            child: Text(date, style: style),
          ),
          Expanded(child: Text(description, style: style)),
          SizedBox(
            width: HisabMetrics.ledgerAmountWidth,
            child: Text(
              credit,
              style: creditStyle ?? style,
              textAlign: TextAlign.end,
            ),
          ),
          SizedBox(
            width: HisabMetrics.ledgerBalanceWidth,
            child: Text(balance, style: balanceStyle, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

/// The same four values at a text scale where four fixed columns would clip.
/// Nothing is dropped — the columns become labelled lines.
class _LedgerStacked extends StatelessWidget {
  const _LedgerStacked({
    required this.date,
    required this.description,
    required this.credit,
    required this.balance,
  });

  final String date;
  final String description;
  final String credit;
  final String balance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: HisabMetrics.ledgerPaddingVertical,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(date, style: HisabTextStyles.label),
          Text(description, style: HisabTextStyles.ledger),
          const SizedBox(height: HisabSpacing.s1),
          _StackedFigure(
            label: 'জমা',
            value: credit,
            style: HisabTextStyles.ledger.copyWith(color: HisabColors.moneyIn),
          ),
          _StackedFigure(
            label: 'বাকি',
            value: balance,
            style: HisabTextStyles.ledgerBalance,
          ),
        ],
      ),
    );
  }
}

class _StackedFigure extends StatelessWidget {
  const _StackedFigure({
    required this.label,
    required this.value,
    required this.style,
  });

  final String label;
  final String value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: Text(label, style: HisabTextStyles.label)),
        const SizedBox(width: HisabSpacing.s2),
        Flexible(child: Text(value, style: style, textAlign: TextAlign.end)),
      ],
    );
  }
}

// ── Actions ──────────────────────────────────────────────────────────────────

class _Actions extends StatefulWidget {
  const _Actions();

  @override
  State<_Actions> createState() => _ActionsState();
}

class _ActionsState extends State<_Actions> {
  static const List<String> _methods = <String>['নগদ', 'বিকাশ', 'বাকি'];
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _PreviewButton(kind: _ButtonKind.primary, label: 'সংরক্ষণ'),
        const SizedBox(height: HisabSpacing.s2),
        const _PreviewButton(kind: _ButtonKind.secondary, label: 'রসিদ'),
        const SizedBox(height: HisabSpacing.s2),
        const _PreviewButton(kind: _ButtonKind.tertiary, label: 'বাতিল'),
        const SizedBox(height: HisabSpacing.s3),
        Wrap(
          spacing: HisabSpacing.s2,
          runSpacing: HisabSpacing.s2,
          children: <Widget>[
            for (int i = 0; i < _methods.length; i++)
              // A chip is a hit target like any other: 48dp minimum, even
              // when its Bangla label is two syllables long.
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: HisabMetrics.minHitTarget,
                  minHeight: HisabMetrics.minHitTarget,
                ),
                child: ChoiceChip(
                  label: Text(_methods[i]),
                  selected: _selected == i,
                  onSelected: (_) => setState(() => _selected = i),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

enum _ButtonKind { primary, secondary, tertiary }

class _PreviewButton extends StatelessWidget {
  const _PreviewButton({required this.kind, required this.label});

  final _ButtonKind kind;
  final String label;

  @override
  Widget build(BuildContext context) {
    // Nothing happens: this screen records no money and never will.
    void noop() {}

    final Widget child = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(label, textAlign: TextAlign.center),
    );

    return SizedBox(
      width: double.infinity,
      child: switch (kind) {
        _ButtonKind.primary => FilledButton(onPressed: noop, child: child),
        _ButtonKind.secondary => OutlinedButton(onPressed: noop, child: child),
        _ButtonKind.tertiary => TextButton(onPressed: noop, child: child),
      },
    );
  }
}
