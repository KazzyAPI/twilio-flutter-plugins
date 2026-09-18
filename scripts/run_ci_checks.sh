#!/usr/bin/env bash
# Local mirror of .github/workflows/ci.yml (documentation-sync + analyze-and-test).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BASE="${1:-origin/main}"

echo "== SDD sync =="
scripts/check_sdd_sync.sh "$BASE"

echo "== Documentation sync =="
scripts/check_documentation_sync.sh "$BASE"

echo "== Comment style =="
scripts/check_comment_style.sh

echo "== twilio_flutter_core =="
(cd packages/twilio_flutter_core && dart pub get && dart analyze --fatal-infos && dart test)

echo "== twilio_flutter_conversations =="
(
  cd packages/twilio_flutter_conversations
  flutter pub get
  dart run pigeon --input pigeons/conversations_api.dart
  git diff --exit-code lib/src/pigeon/conversations.pigeon.dart \
    ios/Classes/Pigeon/ConversationsPigeon.swift \
    android/src/main/kotlin/com/twilioflutter/conversations/pigeon/ConversationsPigeon.kt
  flutter analyze --fatal-infos
  flutter test
)

echo "== twilio_flutter_video =="
(
  cd packages/twilio_flutter_video
  flutter pub get
  dart run pigeon --input pigeons/video_api.dart
  git diff --exit-code lib/src/pigeon/video.pigeon.dart \
    ios/Classes/Pigeon/VideoPigeon.swift \
    android/src/main/kotlin/com/twilioflutter/video/pigeon/VideoPigeon.kt
  flutter analyze --fatal-infos
  flutter test
)

echo "All CI checks passed (Dart/analyze/test; run Android/iOS jobs on GitHub for native builds)."
