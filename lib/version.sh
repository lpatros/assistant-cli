_get_assistant_version() {
  local version=""

  if _is_installed "git" && [[ -d "$ASSISTANT_ROOT_DIR/.git" ]]; then
    version="$(git -C "$ASSISTANT_ROOT_DIR" describe --tags --abbrev=0 2>/dev/null || true)"
  fi

  if [[ -z "$version" ]] && [[ -f "$ASSISTANT_ROOT_DIR/CHANGELOG.md" ]]; then
    version="$(grep -m1 -E '^## \[?[0-9]+\.[0-9]+\.[0-9]+' "$ASSISTANT_ROOT_DIR/CHANGELOG.md" 2>/dev/null | sed -E 's/^## \[?([0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?).*/\1/' || true)"
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
