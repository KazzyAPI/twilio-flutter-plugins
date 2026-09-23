#!/usr/bin/env bash
# Local/CI: path-override twilio_flutter_core while pubspec.yaml declares hosted constraints for pub.dev.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

copy_override() {
  cp "$1" "$2"
}

for pkg in twilio_flutter_conversations twilio_flutter_video; do
  copy_override \
    "$ROOT/packages/$pkg/pubspec_overrides.yaml.example" \
    "$ROOT/packages/$pkg/pubspec_overrides.yaml"
done

copy_override \
  "$ROOT/packages/twilio_flutter_conversations/example/pubspec_overrides.yaml.example" \
  "$ROOT/packages/twilio_flutter_conversations/example/pubspec_overrides.yaml"
