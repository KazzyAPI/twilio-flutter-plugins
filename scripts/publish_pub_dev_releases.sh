#!/usr/bin/env bash
# Emergency/local manual publish only. CI uses tag-triggered OIDC via publish-pub-dev.yml.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [[ -z "${PUB_TOKEN:-}" ]]; then
  echo "PUB_TOKEN is not set. Add a pub.dev token as the PUB_DEV_TOKEN repository secret." >&2
  exit 1
fi

publish_package() {
  local rel_path="$1"
  local use_flutter="$2"
  cd "$ROOT/$rel_path"

  echo "Publishing $rel_path ..."
  if [[ "$use_flutter" == "true" ]]; then
    flutter pub get
    flutter pub publish --dry-run
    flutter pub publish -f
  else
    dart pub get
    dart pub publish --dry-run
    dart pub publish -f
  fi
}

if [[ "${PUBLISH_TWILIO_FLUTTER_CORE:-false}" == "true" ]]; then
  publish_package "packages/twilio_flutter_core" "false"
fi

if [[ "${PUBLISH_TWILIO_FLUTTER_CONVERSATIONS:-false}" == "true" ]]; then
  publish_package "packages/twilio_flutter_conversations" "true"
fi

if [[ "${PUBLISH_TWILIO_FLUTTER_VIDEO:-false}" == "true" ]]; then
  publish_package "packages/twilio_flutter_video" "true"
fi
