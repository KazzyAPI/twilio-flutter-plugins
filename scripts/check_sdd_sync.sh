#!/usr/bin/env bash
# Spec-Driven Development audit: artifacts exist, spec covers API surface, impl
# changes include updates to the active feature spec directory.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck source=_changed_files.sh
source "$ROOT/scripts/_changed_files.sh"

BASE_ARG="${1:-}"
resolve_base_ref "$BASE_ARG"
list_changed_files

failures=0

feature_dir=""
if [[ -f .specify/feature.json ]]; then
  if command -v jq >/dev/null 2>&1; then
    feature_dir="$(jq -r '.feature_directory // empty' .specify/feature.json)"
  else
    feature_dir="$(python3 -c "import json; print(json.load(open('.specify/feature.json')).get('feature_directory',''))" 2>/dev/null || true)"
  fi
fi

if [[ -z "$feature_dir" ]]; then
  feature_dir="specs/001-twilio-flutter-conversations"
fi

if [[ ! -d "$feature_dir" ]]; then
  echo "SDD sync check failed: feature directory not found: $feature_dir"
  echo "Set .specify/feature.json feature_directory or SPECIFY_FEATURE_DIRECTORY."
  exit 1
fi

constitution=".specify/memory/constitution.md"
spec="$feature_dir/spec.md"
plan="$feature_dir/plan.md"
tasks="$feature_dir/tasks.md"
surface="$feature_dir/sdd-api-surface.txt"

require_file() {
  local path="$1"
  local hint="$2"
  if [[ ! -f "$path" ]]; then
    echo "SDD sync check failed: missing $path ($hint)"
    failures=$((failures + 1))
  fi
}

require_file "$constitution" "run /speckit.constitution"
require_file "$spec" "run /speckit.specify"
require_file "$plan" "run /speckit.plan"
require_file "$tasks" "run /speckit.tasks"
require_file "$surface" "add sdd-api-surface.txt for this feature"

if [[ -f "$spec" && -f "$surface" ]]; then
  while IFS= read -r token || [[ -n "$token" ]]; do
    [[ -z "$token" || "$token" =~ ^# ]] && continue
    if ! grep -Fq "$token" "$spec"; then
      echo "SDD sync check failed: spec.md missing token from sdd-api-surface.txt: $token"
      failures=$((failures + 1))
    fi
  done < "$surface"
fi

if [[ -f "$plan" && -f "$spec" ]]; then
  if ! grep -Fq "$feature_dir" "$plan"; then
    echo "SDD sync check failed: plan.md should reference feature directory $feature_dir"
    failures=$((failures + 1))
  fi
fi

if [[ -f "$tasks" && -f "$spec" ]]; then
  for fr in FR-1 FR-2 FR-3 FR-4; do
    if grep -Fq "$fr" "$spec" && ! grep -Fq "$fr" "$tasks" && ! grep -Fq "$fr" "$plan"; then
      echo "SDD sync check failed: $fr in spec.md but not mentioned in plan.md or tasks.md"
      failures=$((failures + 1))
    fi
  done
fi

impl_changed=false
sdd_changed=false
integrator_doc_changed=false

while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  case "$file" in
    packages/*/lib/*|packages/*/pigeons/*|packages/*/android/src/main/*|packages/*/ios/Classes/*)
      impl_changed=true
      ;;
    "${feature_dir}"/*|.specify/memory/*|.specify/feature.json)
      sdd_changed=true
      ;;
    docs/*)
      integrator_doc_changed=true
      ;;
  esac
done <<< "${CHANGED_FILES:-}"

if [[ "$impl_changed" == true && "$sdd_changed" == false ]]; then
  echo "SDD sync check failed."
  echo "Implementation changed without updating the active SDD feature ($feature_dir/) or constitution."
  echo "Update spec.md, plan.md, tasks.md, and/or sdd-api-surface.txt in the same change set."
  echo ""
  echo "Changed files:"
  echo "${CHANGED_FILES:-}"
  failures=$((failures + 1))
fi

if [[ "$impl_changed" == true && "$integrator_doc_changed" == false ]]; then
  echo "SDD sync check failed."
  echo "Implementation changed without updating docs/ (integrator docs must stay aligned)."
  echo ""
  echo "Changed files:"
  echo "${CHANGED_FILES:-}"
  failures=$((failures + 1))
fi

if [[ "$failures" -gt 0 ]]; then
  exit 1
fi

echo "SDD sync check passed ($feature_dir)."
