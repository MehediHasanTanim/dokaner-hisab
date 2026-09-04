// The bundled faces, as the tests see them.
//
// The tests read the .ttf files straight off disk rather than through
// `rootBundle`, for one reason: when a face is missing the failure has to name
// the file and the script that fetches it. "Asset not found" does not tell a
// contributor that they need to run ./scripts/fetch-fonts.sh.

import 'dart:io';

import 'package:flutter/services.dart';

import 'ttf.dart';

const String kFontDirectory = 'assets/fonts';

/// One declared face. Kept in step with the `fonts:` block of pubspec.yaml —
/// typography_test.dart asserts the two lists agree.
class BundledFont {
  const BundledFont(this.family, this.fileName, this.weight);

  final String family;
  final String fileName;
  final int weight;

  String get path => '$kFontDirectory/$fileName';

  File get file => File(path);

  TtfFace get face => TtfFace.fromFile(file);

  @override
  String toString() => '$family $weight ($fileName)';
}

/// Noto Serif Bengali sets titles and receipts; Hind Siliguri sets everything
/// else including every number. DESIGN.md § Typography.
const List<BundledFont> kBundledFonts = <BundledFont>[
  BundledFont('NotoSerifBengali', 'NotoSerifBengali-SemiBold.ttf', 600),
  BundledFont('NotoSerifBengali', 'NotoSerifBengali-Bold.ttf', 700),
  BundledFont('HindSiliguri', 'HindSiliguri-Regular.ttf', 400),
  BundledFont('HindSiliguri', 'HindSiliguri-Medium.ttf', 500),
  BundledFont('HindSiliguri', 'HindSiliguri-SemiBold.ttf', 600),
  BundledFont('HindSiliguri', 'HindSiliguri-Bold.ttf', 700),
];

/// The message a contributor gets when the faces are not there yet.
const String kMissingFontsHint =
    'Bundled fonts are missing from $kFontDirectory/.\n'
    'Run:  cd apps/mobile && ./scripts/fetch-fonts.sh\n'
    'The app never downloads a face at runtime and never falls back to a system '
    'one (UX-DR3), so the build fails here rather than shipping tofu boxes.';

bool get bundledFontsPresent =>
    kBundledFonts.every((BundledFont f) => f.file.existsSync());

/// Registers the bundled faces with the test font collection so that anything
/// laid out in a test uses the real Bangla faces, not the test placeholder.
Future<void> loadBundledFonts() async {
  if (!bundledFontsPresent) {
    throw StateError(kMissingFontsHint);
  }
  final Set<String> families = kBundledFonts
      .map((BundledFont f) => f.family)
      .toSet();
  for (final String family in families) {
    final FontLoader loader = FontLoader(family);
    for (final BundledFont font in kBundledFonts.where(
      (BundledFont f) => f.family == family,
    )) {
      final bytes = font.file.readAsBytesSync();
      loader.addFont(
        Future.value(
          bytes.buffer.asByteData(bytes.offsetInBytes, bytes.lengthInBytes),
        ),
      );
    }
    await loader.load();
  }
}
