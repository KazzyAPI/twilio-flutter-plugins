#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

cd "$ROOT/packages/twilio_flutter_core" && dart pub get && dart test
cd "$ROOT/packages/twilio_flutter_conversations" && flutter pub get && dart run pigeon --input pigeons/conversations_api.dart
flutter test
flutter analyze --fatal-infos

if command -v pre-commit >/dev/null 2>&1; then
  pre-commit install
fi

echo "Bootstrap complete."
