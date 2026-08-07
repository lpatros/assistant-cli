_draw_progress_bar() {
  local percent="${1:-0}"
  local width=20
  local filled=$(( (percent * width) / 100 ))
  local empty=$(( width - filled ))

  local filled_bar=""
  local empty_bar=""

  if [[ $filled -gt 0 ]]; then
    printf -v filled_bar '%*s' "$filled" ''
    filled_bar="${filled_bar// /=}"
  fi

  if [[ $empty -gt 0 ]]; then
    printf -v empty_bar '%*s' "$empty" ''
  fi

  printf "\r[%s%s] %3d%%" "$filled_bar" "$empty_bar" "$percent"
}

_ask_and_show_changelog() {
  local confirm=""
  t_update_changelog_prompt
  if [ -c /dev/tty ]; then
    read -r confirm </dev/tty || true
  else
    read -r confirm || true
  fi

  case "$confirm" in
    "-t"|"--terminal"|[tT]|[tT][eE][rR][mM][iI][nN][aA][lL])
      echo ""
      _view_changelog "terminal"
      ;;
    [yY]|[sS]|[yY][eE][sS]|[sS][iI][mM]|"-w"|"--web"|[wW]|[wW][eE][bB])
      echo ""
      _view_changelog "web"
      ;;
  esac
}

_cmd_update() {
  t_update_starting

  if ! _is_installed "git"; then
    t_git_not_installed
    t_update_failed
    return 1
  fi

  if [[ ! -d "$ASSISTANT_ROOT_DIR/.git" ]]; then
    t_update_failed
    return 1
  fi

  _draw_progress_bar 15
  local fetch_output
  fetch_output="$(git -C "$ASSISTANT_ROOT_DIR" fetch origin 2>&1)"

  _draw_progress_bar 40

  _draw_progress_bar 65
  local pull_output
  pull_output="$(git -C "$ASSISTANT_ROOT_DIR" pull 2>&1)"
  local pull_status=$?

  if [[ $pull_status -eq 0 ]]; then
    _draw_progress_bar 100
    echo ""
    case "$pull_output" in
      *[Aa]lready*up*to*date*|*[Aa]lready*up-to-date*)
        t_update_already_up_to_date
        ;;
      *)
        t_update_success
        _ask_and_show_changelog
        ;;
    esac

    local assistant_version
    assistant_version="$(_get_assistant_version)"
    t_version "$assistant_version"
    return 0
  fi

  echo ""
  t_update_conflict_warning

  local confirm=""
  t_update_conflict_prompt
  if [ -c /dev/tty ]; then
    read -r confirm </dev/tty || true
  else
    read -r confirm || true
  fi

  case "$confirm" in
    [yY]|[sS]|[yY][eE][sS]|[sS][iI][mM])
      _draw_progress_bar 50
      local rebase_output
      rebase_output="$(git -C "$ASSISTANT_ROOT_DIR" pull --rebase 2>&1)"
      local rebase_status=$?

      if [[ $rebase_status -eq 0 ]]; then
        _draw_progress_bar 100
        echo ""
        case "$rebase_output" in
          *[Aa]lready*up*to*date*|*[Aa]lready*up-to-date*)
            t_update_already_up_to_date
            ;;
          *)
            t_update_success
            _ask_and_show_changelog
            ;;
        esac

        local assistant_version
        assistant_version="$(_get_assistant_version)"
        t_version "$assistant_version"
        return 0
      else
        git -C "$ASSISTANT_ROOT_DIR" rebase --abort &>/dev/null || true
        echo ""
        t_update_failed
        return 1
      fi
      ;;
    *)
      t_update_aborted
      return 1
      ;;
  esac
}
