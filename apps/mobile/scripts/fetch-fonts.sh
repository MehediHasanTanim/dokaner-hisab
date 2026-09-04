#!/usr/bin/env bash
# Fetch the two bundled Bangla faces into apps/mobile/assets/fonts/.
#
# UX-DR3 / DESIGN.md § Typography: Bangla conjuncts do not render reliably from
# system fonts on either platform, and the same faces have to render inside a
# generated PDF receipt. So the faces ship as bundled assets and are never
# downloaded at runtime — no google_fonts, no network dependency, ever.
#
# Run this ONCE on a machine with a network connection, eyeball the result, and
# COMMIT the six .ttf files, the two OFL.txt licences and MANIFEST.txt. CI has
# no network and fails loudly if the files are absent (.github/workflows/ci.yml).
#
#   cd apps/mobile && ./scripts/fetch-fonts.sh
#
# Requires: curl, python3 with fonttools (`pip3 install fonttools`), and either
# sha256sum or shasum on PATH.
#
# PORTABILITY: this script must run on stock macOS, whose /bin/bash is 3.2 from
# 2007. No associative arrays, no `declare -A`, no `mapfile`, no `${x^^}`. If you
# edit it, keep it inside that dialect — a script that only runs on the author's
# Homebrew bash is a script that fails on the machine that actually needs it.
set -euo pipefail
cd "$(dirname "$0")/.."

DEST="assets/fonts"
REF="${GOOGLE_FONTS_REF:-main}"
BASE="https://raw.githubusercontent.com/google/fonts/${REF}"

HIND_DIR="ofl/hindsiliguri"
NOTO_DIR="ofl/notoserifbengali"
NOTO_VF="NotoSerifBengali[wdth,wght].ttf"

# Filenames are FIXED. pubspec.yaml declares them literally; a renamed file is a
# silently missing face, and a missing face is a tofu box in a shop owner's hand.
HIND_FILES="HindSiliguri-Regular.ttf HindSiliguri-Medium.ttf HindSiliguri-SemiBold.ttf HindSiliguri-Bold.ttf"
NOTO_FILES="NotoSerifBengali-SemiBold.ttf NotoSerifBengali-Bold.ttf"

mkdir -p "$DEST"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
# filename<TAB>source, appended as each file lands. Replaces an associative
# array, which bash 3.2 does not have.
SOURCES="$WORK/sources.tsv"
: > "$SOURCES"

need() { command -v "$1" >/dev/null 2>&1 || { echo "error: '$1' not found on PATH" >&2; exit 1; }; }
need curl
need python3

if command -v sha256sum >/dev/null 2>&1; then
  sha256() { sha256sum "$1" | cut -d' ' -f1; }
elif command -v shasum >/dev/null 2>&1; then
  sha256() { shasum -a 256 "$1" | cut -d' ' -f1; }
else
  echo "error: neither sha256sum nor shasum found on PATH" >&2; exit 1
fi

python3 -c 'import fontTools' 2>/dev/null || {
  echo "error: fonttools is not installed." >&2
  echo "       Noto Serif Bengali ships from google/fonts as a variable font only," >&2
  echo "       so it has to be instanced to static 600 and 700 weights here." >&2
  echo "       Install it with:  pip3 install fonttools" >&2
  exit 1
}

# fetch <url> <path> -- fail on 404 rather than writing an HTML error page as a font.
fetch() {
  echo "  GET $1"
  curl -fsSL --retry 3 --retry-delay 2 -o "$2" "$1" || {
    echo "error: could not fetch $1" >&2
    echo "       If google/fonts moved the file, fix the path in this script." >&2
    echo "       Never substitute a different face — the metrics are part of the design." >&2
    exit 1
  }
}

record_source() { printf '%s\t%s\n' "$1" "$2" >> "$SOURCES"; }
source_of() { grep "^$1	" "$SOURCES" | head -1 | cut -f2-; }

# --- Licences -----------------------------------------------------------------
# The OFL requires the licence to travel with the binaries, so they ship too.
echo "Licences:"
fetch "$BASE/$HIND_DIR/OFL.txt" "$DEST/OFL-HindSiliguri.txt"
fetch "$BASE/$NOTO_DIR/OFL.txt" "$DEST/OFL-NotoSerifBengali.txt"

# --- Hind Siliguri: statics exist upstream ------------------------------------
echo "Hind Siliguri (400 / 500 / 600 / 700):"
for f in $HIND_FILES; do
  fetch "$BASE/$HIND_DIR/$f" "$DEST/$f"
  record_source "$f" "$BASE/$HIND_DIR/$f"
done

# --- Noto Serif Bengali: variable upstream, instanced to statics here ---------
echo "Noto Serif Bengali (600 / 700):"
noto_statics_found=1
for f in $NOTO_FILES; do
  if curl -fsSL --retry 2 -o "$DEST/$f" "$BASE/$NOTO_DIR/static/$f" 2>/dev/null; then
    echo "  GET $BASE/$NOTO_DIR/static/$f"
    record_source "$f" "$BASE/$NOTO_DIR/static/$f"
  else
    rm -f "$DEST/$f"
    noto_statics_found=0
    break
  fi
done

if [ "$noto_statics_found" -eq 0 ]; then
  echo "  upstream ships no statics — instancing the variable face"
  : > "$SOURCES.noto"
  VF_TMP="$WORK/NotoSerifBengali-VF.ttf"
  fetch "$BASE/$NOTO_DIR/$NOTO_VF" "$VF_TMP"
  for f in $NOTO_FILES; do
    case "$f" in
      *SemiBold*) w=600 ;;
      *Bold*)     w=700 ;;
      *) echo "error: no weight known for $f" >&2; exit 1 ;;
    esac
    echo "  instancing wght=$w wdth=100 -> $f"
    # --update-name-table rewrites family/subfamily from STAT so the instance
    # identifies itself honestly; fall back if the upstream STAT is thin.
    python3 -m fontTools.varLib.instancer --update-name-table \
      -o "$DEST/$f" "$VF_TMP" "wght=$w" "wdth=100" >/dev/null 2>&1 \
      || python3 -m fontTools.varLib.instancer \
           -o "$DEST/$f" "$VF_TMP" "wght=$w" "wdth=100" >/dev/null
    record_source "$f" "$BASE/$NOTO_DIR/$NOTO_VF (instanced: wght=$w, wdth=100)"
  done
fi

# --- Sanity: a face that cannot draw a Bangla conjunct is the wrong face ------
echo "Verifying Bangla coverage:"
python3 - "$DEST" <<'PY'
import sys, pathlib
from fontTools.ttLib import TTFont

dest = pathlib.Path(sys.argv[1])
# ক  ্  ত  ঙ  হ  ি  স  া  ব  ০  ৯  ৳
required = [0x0995, 0x09CD, 0x09A4, 0x0999, 0x09B9, 0x09BF,
            0x09B8, 0x09BE, 0x09AC, 0x09E6, 0x09EF, 0x09F3]
required += [ord(c) for c in "0123456789"]
bad = False
for ttf in sorted(dest.glob("*.ttf")):
    font = TTFont(ttf, lazy=True)
    cmap = font.getBestCmap()
    missing = [f"U+{cp:04X}" for cp in required if cp not in cmap]
    gsub = font.get("GSUB")
    has_conjunct_shaping = False
    if gsub is not None:
        feats = {r.FeatureTag for r in gsub.table.FeatureList.FeatureRecord}
        # Bengali conjuncts are built by these; without them the face cannot shape.
        has_conjunct_shaping = bool(feats & {"akhn", "rphf", "blwf", "half", "pstf", "vatu", "cjct"})
    status = "ok"
    if missing:
        status = "MISSING " + " ".join(missing)
        bad = True
    elif not has_conjunct_shaping:
        status = "NO CONJUNCT FEATURES (akhn/half/blwf/rphf/pstf/vatu/cjct)"
        bad = True
    print(f"  {ttf.name}: {status}")
if bad:
    print("error: a bundled face cannot render Bangla. Do not commit this.", file=sys.stderr)
    sys.exit(1)
PY

# --- MANIFEST -----------------------------------------------------------------
# Bundled binaries need provenance: where each byte came from and what it is.
MANIFEST="$DEST/MANIFEST.txt"
{
  echo "Hisab — bundled font provenance"
  echo "Generated by scripts/fetch-fonts.sh. Do not edit by hand."
  echo
  echo "google/fonts ref : $REF"
  echo "fetched (UTC)    : $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  echo
  echo "Both families are licensed under the SIL Open Font License 1.1."
  echo "The licence texts ship beside the faces as OFL-HindSiliguri.txt and"
  echo "OFL-NotoSerifBengali.txt, as the OFL requires."
  echo
  for f in $HIND_FILES $NOTO_FILES; do
    echo "file    : $f"
    echo "source  : $(source_of "$f")"
    echo "sha256  : $(sha256 "$DEST/$f")"
    echo "bytes   : $(wc -c < "$DEST/$f" | tr -d ' ')"
    echo "licence : SIL Open Font License 1.1 (OFL.txt)"
    echo
  done
  for f in OFL-HindSiliguri.txt OFL-NotoSerifBengali.txt; do
    echo "file    : $f"
    echo "sha256  : $(sha256 "$DEST/$f")"
    echo
  done
} > "$MANIFEST"

echo
echo "Wrote $MANIFEST"
echo "Six .ttf files are in $DEST. Commit them, the two OFL texts and the manifest."
echo "Then, once, to record the golden:"
echo "  flutter test --update-goldens test/theme/bangla_rendering_test.dart"
echo "Look at test/theme/goldens/bangla_conjuncts.png before committing it:"
echo "conjuncts must be joined and there must be no dotted circles or empty boxes."
