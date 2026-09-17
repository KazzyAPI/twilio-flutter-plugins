#!/usr/bin/env bash
# Shared git change detection for hook scripts (works before first commit).
# Usage: source scripts/_changed_files.sh && resolve_base_ref [optional_ref] && list_changed_files

resolve_base_ref() {
  local explicit="${1:-}"
  if [[ -n "$explicit" ]]; then
    BASE_REF="$explicit"
    return 0
  fi
  if git rev-parse --verify origin/main >/dev/null 2>&1; then
    BASE_REF="origin/main"
  elif git rev-parse --verify main >/dev/null 2>&1; then
    BASE_REF="main"
  elif git rev-parse --verify HEAD >/dev/null 2>&1; then
    BASE_REF="HEAD"
  else
    BASE_REF="$(git hash-object -t tree /dev/null)"
  fi
}

list_changed_files() {
  local collected=""
  if git rev-parse --verify HEAD >/dev/null 2>&1; then
    if [[ "$BASE_REF" != "HEAD" ]] && git rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
      collected="$(git diff --name-only "$BASE_REF" -- 2>/dev/null || true)"
    fi
    if [[ -z "$collected" ]]; then
      collected="$(git diff --name-only HEAD -- 2>/dev/null || true)"
    fi
    local staged
    staged="$(git diff --name-only --cached HEAD -- 2>/dev/null || true)"
    if [[ -n "$staged" ]]; then
      collected="$(printf '%s\n%s' "$collected" "$staged" | sort -u)"
    fi
  else
    collected="$(git diff --name-only "$BASE_REF" -- 2>/dev/null || true)"
    local untracked
    untracked="$(git ls-files --others --exclude-standard 2>/dev/null || true)"
    if [[ -n "$untracked" ]]; then
      collected="$(printf '%s\n%s' "$collected" "$untracked" | sort -u)"
    fi
  fi
  # shellcheck disable=SC2034
  CHANGED_FILES="$(echo "$collected" | sed '/^$/d')"
}
