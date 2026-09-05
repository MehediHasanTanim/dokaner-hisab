// Which script the owner reads numbers in.
//
// The stored value is script-independent (money is integer paisa, quantity is
// integer milli-units); only the rendering changes. So the language is a
// *parameter* of every format call rather than a global the formatter reaches
// for, and there is exactly one enum for the whole product.
//
// SCOPE: this file exposes the language. It does NOT build the language
// setting — choosing and persisting a language is Story 1.9. The provider here
// defaults to Bangla, ignores the device locale (FR-8: "Bangla by default
// regardless of device locale") and persists nothing at all. Story 1.9 replaces
// the notifier's backing store; every other file in the product depends on the
// enum and the provider name, not on where the value is kept, so that swap
// touches this file only.

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The two languages the product renders numbers in.
///
/// Bangla is first in the declaration on purpose: it is the default, and the
/// default is the one a shop owner never has to find.
enum HisabLanguage {
  /// Bangla digits (০-৯) with lakh grouping — ৳১,০৮,৫০০.
  bangla,

  /// Western digits (0-9) with Western grouping — ৳108,500.
  english;

  /// The default, everywhere, regardless of the device locale (FR-8).
  static const HisabLanguage fallback = HisabLanguage.bangla;

  bool get isBangla => this == HisabLanguage.bangla;

  bool get isEnglish => this == HisabLanguage.english;

  /// The language's own name, in its own script. Used by any surface that
  /// offers the choice; never translated, because a language name a reader
  /// cannot read is useless to them.
  String get endonym => switch (this) {
    HisabLanguage.bangla => 'বাংলা',
    HisabLanguage.english => 'English',
  };
}

/// Holds the language for the running app.
///
/// Story 1.9 gives this a persistent backing store and a settings screen. Until
/// then it starts at Bangla on every launch and remembers nothing — which is
/// correct behaviour for this story, not a stub: an owner who never opens
/// settings must get Bangla forever.
class HisabLanguageNotifier extends Notifier<HisabLanguage> {
  @override
  HisabLanguage build() => HisabLanguage.fallback;

  /// Switches the language for this session.
  ///
  /// Nothing stored changes — a figure is re-rendered from the same integer,
  /// which is the whole reason the formatter takes the language as an argument.
  void select(HisabLanguage language) => state = language;
}

/// The language every surface reads before formatting a figure.
final NotifierProvider<HisabLanguageNotifier, HisabLanguage>
hisabLanguageProvider =
    NotifierProvider<HisabLanguageNotifier, HisabLanguage>(
      HisabLanguageNotifier.new,
    );
