// A very small TrueType reader, used by the Bangla rendering tests.
//
// Why parse the font instead of trusting a golden image: a golden proves that
// what rendered today matches what rendered when the golden was taken. It does
// not prove the *face* can draw a Bangla conjunct — swap in a Latin-only font
// and re-record the golden and it passes, showing tofu boxes. Reading the
// font's own `cmap` and `GSUB` tables answers the real question: are the
// codepoints there, and does the face carry the Bengali shaping features that
// turn ক + ্ + ত into ক্ত?
//
// Only the two tables the tests need are parsed. This is not a font library.

import 'dart:io';
import 'dart:typed_data';

class TtfTableMissing implements Exception {
  TtfTableMissing(this.path, this.table);

  final String path;
  final String table;

  @override
  String toString() => 'TtfTableMissing: $path has no "$table" table';
}

class TtfFace {
  TtfFace._(this.path, this._bytes, this._data, this._tables);

  final String path;
  final Uint8List _bytes;
  final ByteData _data;
  final Map<String, int> _tables;

  static TtfFace fromFile(File file) {
    if (!file.existsSync()) {
      throw FileSystemException(
        'Bundled font is missing. Run ./scripts/fetch-fonts.sh — the app must '
        'never fall back to a system face (UX-DR3).',
        file.path,
      );
    }
    final Uint8List bytes = file.readAsBytesSync();
    final ByteData data = ByteData.sublistView(bytes);
    final int sfnt = data.getUint32(0);
    // 0x00010000 = TrueType outlines, 'true' = an older Apple variant.
    if (sfnt != 0x00010000 && sfnt != 0x74727565) {
      throw FormatException(
        '${file.path} is not a TrueType font (sfnt tag '
        '0x${sfnt.toRadixString(16)}). A download that silently returned an '
        'HTML error page looks exactly like this.',
      );
    }
    final int numTables = data.getUint16(4);
    // Not `final`: it is filled below, and an empty typed literal would be a
    // constant if it were.
    Map<String, int> tables = <String, int>{};
    for (int i = 0; i < numTables; i++) {
      final int record = 12 + i * 16;
      tables[String.fromCharCodes(bytes, record, record + 4)] = data.getUint32(
        record + 8,
      );
    }
    return TtfFace._(file.path, bytes, data, tables);
  }

  bool hasTable(String tag) => _tables.containsKey(tag);

  /// The glyph id for a code point, or 0 when the face cannot draw it.
  int glyphFor(int codePoint) {
    final int? cmap = _tables['cmap'];
    if (cmap == null) {
      throw TtfTableMissing(path, 'cmap');
    }
    final int subtable = _bestCmapSubtable(cmap);
    final int format = _data.getUint16(subtable);
    return switch (format) {
      4 => _lookupFormat4(subtable, codePoint),
      12 => _lookupFormat12(subtable, codePoint),
      _ => throw FormatException(
        '$path: unsupported cmap subtable format $format',
      ),
    };
  }

  bool covers(int codePoint) => glyphFor(codePoint) != 0;

  /// The OpenType feature tags in `GSUB`. Bengali conjuncts are produced by
  /// these: without them the shaper has nothing to work with.
  Set<String> get gsubFeatureTags {
    final int? gsub = _tables['GSUB'];
    if (gsub == null) {
      return const <String>{};
    }
    final int featureList = gsub + _data.getUint16(gsub + 6);
    final int count = _data.getUint16(featureList);
    Set<String> tags = <String>{};
    for (int i = 0; i < count; i++) {
      final int record = featureList + 2 + i * 6;
      tags.add(String.fromCharCodes(_bytes, record, record + 4));
    }
    return tags;
  }

  int _bestCmapSubtable(int cmap) {
    final int count = _data.getUint16(cmap + 2);
    int bestScore = -1;
    int? best;
    for (int i = 0; i < count; i++) {
      final int record = cmap + 4 + i * 8;
      final int platform = _data.getUint16(record);
      final int encoding = _data.getUint16(record + 2);
      final int offset = cmap + _data.getUint32(record + 4);
      final int format = _data.getUint16(offset);
      final int score = switch ((platform, encoding, format)) {
        (3, 10, 12) => 4,
        (0, _, 12) => 3,
        (3, 1, 4) => 2,
        (0, _, 4) => 1,
        _ => 0,
      };
      if (score > bestScore) {
        bestScore = score;
        best = offset;
      }
    }
    if (best == null || bestScore == 0) {
      throw FormatException('$path: no usable Unicode cmap subtable');
    }
    return best;
  }

  int _lookupFormat4(int subtable, int codePoint) {
    if (codePoint > 0xFFFF) {
      return 0;
    }
    final int segCount = _data.getUint16(subtable + 6) ~/ 2;
    final int endCodes = subtable + 14;
    final int startCodes = endCodes + segCount * 2 + 2;
    final int idDeltas = startCodes + segCount * 2;
    final int idRangeOffsets = idDeltas + segCount * 2;

    for (int seg = 0; seg < segCount; seg++) {
      final int end = _data.getUint16(endCodes + seg * 2);
      if (codePoint > end) {
        continue;
      }
      final int start = _data.getUint16(startCodes + seg * 2);
      if (codePoint < start) {
        return 0;
      }
      final int idDelta = _data.getInt16(idDeltas + seg * 2);
      final int idRangeOffsetAt = idRangeOffsets + seg * 2;
      final int idRangeOffset = _data.getUint16(idRangeOffsetAt);
      if (idRangeOffset == 0) {
        return (codePoint + idDelta) & 0xFFFF;
      }
      final int glyphAt =
          idRangeOffsetAt + idRangeOffset + (codePoint - start) * 2;
      final int glyph = _data.getUint16(glyphAt);
      return glyph == 0 ? 0 : (glyph + idDelta) & 0xFFFF;
    }
    return 0;
  }

  int _lookupFormat12(int subtable, int codePoint) {
    final int groups = _data.getUint32(subtable + 12);
    int low = 0;
    int high = groups - 1;
    while (low <= high) {
      final int mid = (low + high) ~/ 2;
      final int group = subtable + 16 + mid * 12;
      final int start = _data.getUint32(group);
      final int end = _data.getUint32(group + 4);
      if (codePoint < start) {
        high = mid - 1;
      } else if (codePoint > end) {
        low = mid + 1;
      } else {
        return _data.getUint32(group + 8) + (codePoint - start);
      }
    }
    return 0;
  }
}
