_get_assistant_version() {
  local version=""

  if _is_installed "git" && [[ -d "$ASSISTANT_ROOT_DIR/.git" ]]; then
    version="$(git -C "$ASSISTANT_ROOT_DIR" describe --tags --abbrev=0 2>/dev/null || true)"
  fi

  local changelog_file
  changelog_file="$(_get_changelog_file)"
  if [[ -z "$version" ]] && [[ -f "$changelog_file" ]]; then
    version="$(grep -m1 -E '^## \[?[0-9]+\.[0-9]+\.[0-9]+' "$changelog_file" 2>/dev/null | sed -E 's/^## \[?([0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?).*/\1/' || true)"
  fi

  if [[ -n "$version" ]]; then
    version="${version#v}"
    echo "$version"
  else
    t_version_unknown
  fi
}

_cmd_version() {
  local version
  version="$(_get_assistant_version)"
  t_version "$version"
}
