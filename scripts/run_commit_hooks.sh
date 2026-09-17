#!/usr/bin/env bash
# Run the same checks as pre-commit without requiring `pre-commit install`.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BASE_REF="${1:-}"

run() {
  echo ""
  echo "==> $1"
  shift
  "$@"
}

run "SDD sync audit" "$ROOT/scripts/check_sdd_sync.sh" ${BASE_REF:+"$BASE_REF"}
run "Documentation sync" "$ROOT/scripts/check_documentation_sync.sh" ${BASE_REF:+"$BASE_REF"}
run "Comment style" "$ROOT/scripts/check_comment_style.sh"
run "Pigeon drift" bash -c 'cd packages/twilio_flutter_conversations && dart run pigeon --input pigeons/conversations_api.dart && git diff --exit-code lib/src/pigeon/conversations.pigeon.dart ios/Classes/Pigeon/ConversationsPigeon.swift android/src/main/kotlin/com/twilioflutter/conversations/pigeon/ConversationsPigeon.kt'
run "dart analyze core" bash -c 'cd packages/twilio_flutter_core && dart analyze --fatal-infos'
run "flutter analyze conversations" bash -c 'cd packages/twilio_flutter_conversations && flutter analyze --fatal-infos'

echo ""
echo "All commit hook checks passed."
