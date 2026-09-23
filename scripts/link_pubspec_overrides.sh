#!/usr/bin/env bash
# Use path deps locally while pubspec.yaml declares pub.dev-compatible version constraints.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

copy_override() {
  local src="$1"
  local dest="$2"
  if [[ ! -f "$src" ]]; then
    echo "Missing $src" >&2
    exit 1
  fi
  cp "$src" "$dest"
}

for pkg in twilio_flutter_conversations twilio_flutter_video; do
  copy_override \
    "$ROOT/packages/$pkg/pubspec_overrides.yaml.example" \
    "$ROOT/packages/$pkg/pubspec_overrides.yaml"
done

copy_override \
  "$ROOT/packages/twilio_flutter_conversations/example/pubspec_overrides.yaml.example" \
  "$ROOT/packages/twilio_flutter_conversations/example/pubspec_overrides.yaml"
