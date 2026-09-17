#!/usr/bin/env bash
# Fails when implementation files change without integrator documentation updates.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck source=_changed_files.sh
source "$ROOT/scripts/_changed_files.sh"

BASE_ARG="${1:-}"
resolve_base_ref "$BASE_ARG"
list_changed_files

if [[ -z "${CHANGED_FILES:-}" ]]; then
  exit 0
fi

impl_changed=false
doc_changed=false

while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  case "$file" in
    packages/*/lib/*|packages/*/pigeons/*|packages/*/android/src/main/*|packages/*/ios/Classes/*)
      impl_changed=true
      ;;
    docs/*|README.md|CONTRIBUTING.md|CHANGELOG.md|packages/*/README.md|packages/*/CHANGELOG.md)
      doc_changed=true
      ;;
  esac
done <<< "$CHANGED_FILES"

if [[ "$impl_changed" == true && "$doc_changed" == false ]]; then
  echo "Documentation sync check failed."
  echo "Implementation files changed without updating integrator docs."
  echo "Update at least one of: docs/, README.md, CONTRIBUTING.md, CHANGELOG.md, package README/CHANGELOG."
  echo "For Spec Kit artifacts use scripts/check_sdd_sync.sh (specs/ + constitution)."
  echo ""
  echo "Changed files:"
  echo "$CHANGED_FILES"
  exit 1
fi

exit 0
