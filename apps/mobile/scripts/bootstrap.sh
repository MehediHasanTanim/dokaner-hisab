#!/usr/bin/env bash
# Completes Story 1.1 for apps/mobile on a machine that has Flutter installed.
#
# `flutter pub add` resolves each package against pub.dev and writes the exact
# resolved version into pubspec.yaml and pubspec.lock. That is what satisfies
# the story's acceptance criterion — versions pinned by the tool against the
# live registry, not typed from memory.
set -euo pipefail
cd "$(dirname "$0")/.."

command -v flutter >/dev/null || { echo "flutter not found on PATH"; exit 1; }

echo "Flutter version in use:"
flutter --version

# Runtime dependencies — the stack fixed by the architecture spine.
flutter pub add \
  flutter_riverpod riverpod_annotation \
  go_router \
  dio \
  freezed_annotation json_annotation \
  drift sqlite3_flutter_libs path_provider path \
  sqlcipher_flutter_libs \
  flutter_secure_storage \
  connectivity_plus \
  firebase_core firebase_messaging flutter_local_notifications \
  intl \
  uuid \
  share_plus \
  pdf printing

# Build-time only.
flutter pub add --dev \
  build_runner \
  riverpod_generator \
  freezed json_serializable \
  drift_dev \
  flutter_lints \
  mocktail

flutter pub get

echo
echo "Done. pubspec.yaml and pubspec.lock now carry exact resolved versions."
echo "Commit BOTH files — the lockfile is the authority from here on."
