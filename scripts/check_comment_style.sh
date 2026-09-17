#!/usr/bin/env bash
# Disallows vague "high level" phrasing in source comments (Dart/Kotlin/Swift).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PATTERN='(///|//|/\*|\*|#).*([Hh]igh[- ]level|[Hh]igh level)'

if rg -n --pcre2 "$PATTERN" \
  packages/twilio_flutter_core/lib \
  packages/twilio_flutter_conversations/lib \
  packages/twilio_flutter_conversations/pigeons \
  packages/twilio_flutter_conversations/android/src/main/kotlin \
  packages/twilio_flutter_conversations/ios/Classes \
  2>/dev/null; then
  echo "Comment style check failed: remove 'high level' phrasing; describe function intent instead."
  exit 1
fi

exit 0
