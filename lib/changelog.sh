_view_changelog_terminal() {
  local changelog_file
  changelog_file="$(_get_changelog_file)"

  if [[ -f "$changelog_file" ]]; then
    if _is_installed "less"; then
      less -FRX "$changelog_file"
    else
      cat "$changelog_file"
    fi
  else
    t_changelog_not_found "$(basename "$changelog_file")"
  fi

  local release_url
  release_url="$(_get_release_url)"
  t_changelog_web_link "$release_url"
}

_view_changelog_web() {
  local release_url
  release_url="$(_get_release_url)"
  t_changelog_opening_web "$release_url"
  if ! _open_url "$release_url"; then
    t_changelog_web_link "$release_url"
  fi
}

_view_changelog() {
  local mode="${1:-web}"
  case "$mode" in
    "terminal"|"--terminal"|"-t")
      _view_changelog_terminal
      ;;
    *)
      _view_changelog_web
      ;;
  esac
}

_cmd_changelog() {
  local arg="${1:-}"

  case "$arg" in
    "--terminal"|"-t"|"terminal")
      _view_changelog_terminal
      ;;
    "--web"|"-w"|"web"|"")
      _view_changelog_web
      ;;
    "--help"|"-h"|"help")
      t_changelog_usage
      ;;
    *)
      t_changelog_usage
      return 1
      ;;
  esac
}
