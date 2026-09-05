// The number layer, in one import.
//
//   import 'package:hisab/format/format.dart';
//
// Every surface in the product — screens, receipts, reports, CSV export,
// notifications and the AI draft parser — renders and reads figures through
// this one library (UX-DR4). There is no second formatter and no second parser
// anywhere: `tool/check_single_formatter.dart` fails the build when one
// appears, because the moment a second implementation exists the two drift and
// a receipt disagrees with a screen.
//
// What lives behind this barrel:
//
//   language.dart  the HisabLanguage enum and its provider (Bangla by default)
//   digits.dart    digit scripts and the two grouping rules
//   money.dart     integer paisa      → the string the owner reads, and export
//   quantity.dart  integer milli-units → the same, without the currency mark
//   parse.dart     what the owner typed → the stored integer, or a reason
//
// The stored value never changes shape here: money is integer paisa (AR-1),
// quantity is integer milli-units (AR-2), and no `double` crosses this boundary
// in either direction.

export 'digits.dart';
export 'language.dart';
export 'money.dart';
export 'parse.dart';
export 'quantity.dart';
