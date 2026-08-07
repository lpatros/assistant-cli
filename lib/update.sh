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

_update_list_versions() {
  if ! _is_installed "git"; then
    t_git_not_installed
    return 1
  fi

  if [[ ! -d "$ASSISTANT_ROOT_DIR/.git" ]]; then
    t_update_failed
    return 1
  fi

  git -C "$ASSISTANT_ROOT_DIR" fetch --tags origin &>/dev/null || true

  local current_version
  current_version="$(_get_assistant_version)"

  local tags
  tags="$(git -C "$ASSISTANT_ROOT_DIR" tag -l | sort -V -r 2>/dev/null || git -C "$ASSISTANT_ROOT_DIR" tag -l)"

  t_update_list_header
  if [[ -z "$tags" ]]; then
    if [[ -n "$current_version" && "$current_version" != "desconhecida" && "$current_version" != "unknown" && "$current_version" != "desconocida" ]]; then
      echo -e "  ${GREEN}* v${current_version}${RESET} (atual)"
    fi
  else
    local tag clean_tag
    while IFS= read -r tag; do
      [[ -z "$tag" ]] && continue
      clean_tag="${tag#v}"
      if [[ "$clean_tag" == "$current_version" || "$tag" == "$current_version" ]]; then
        echo -e "  ${GREEN}* ${tag}${RESET} (atual)"
      else
        echo -e "    ${tag}"
      fi
    done <<< "$tags"
  fi

  echo ""
  t_update_list_tip
}

_update_to_version() {
  local raw_target="$1"
  local clean_target="${raw_target#@}"
  clean_target="${clean_target#v}"

  if ! _is_installed "git"; then
    t_git_not_installed
    t_update_failed
    return 1
  fi

  if [[ ! -d "$ASSISTANT_ROOT_DIR/.git" ]]; then
    t_update_failed
    return 1
  fi

  t_update_version_starting "$clean_target"

  _draw_progress_bar 15
  git -C "$ASSISTANT_ROOT_DIR" fetch --tags origin &>/dev/null || true

  _draw_progress_bar 40

  local matched_tag=""
  if git -C "$ASSISTANT_ROOT_DIR" rev-parse -q --verify "refs/tags/v${clean_target}" &>/dev/null; then
    matched_tag="v${clean_target}"
  elif git -C "$ASSISTANT_ROOT_DIR" rev-parse -q --verify "refs/tags/${clean_target}" &>/dev/null; then
    matched_tag="${clean_target}"
  fi

  if [[ -z "$matched_tag" ]]; then
    _draw_progress_bar 100
    echo ""
    t_update_version_not_found "$raw_target"
    return 1
  fi

  local current_version
  current_version="$(_get_assistant_version)"
  if [[ "$clean_target" == "$current_version" ]]; then
    _draw_progress_bar 100
    echo ""
    t_update_already_on_version "$clean_target"
    return 0
  fi

  _draw_progress_bar 65
  local checkout_output
  checkout_output="$(git -C "$ASSISTANT_ROOT_DIR" checkout "$matched_tag" 2>&1)"
  local checkout_status=$?

  if [[ $checkout_status -eq 0 ]]; then
    case "$clean_target" in
      *-beta*|*-alpha*|*-rc*|*-dev*)
        _set_channel "beta"
        ;;
      *)
        _set_channel "stable"
        ;;
    esac
    _draw_progress_bar 100
    echo ""
    t_update_version_success "$clean_target"
    _ask_and_show_changelog
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
      local force_checkout_output
      force_checkout_output="$(git -C "$ASSISTANT_ROOT_DIR" checkout -f "$matched_tag" 2>&1)"
      local force_checkout_status=$?

      if [[ $force_checkout_status -eq 0 ]]; then
        case "$clean_target" in
          *-beta*|*-alpha*|*-rc*|*-dev*)
            _set_channel "beta"
            ;;
          *)
            _set_channel "stable"
            ;;
        esac
        _draw_progress_bar 100
        echo ""
        t_update_version_success "$clean_target"
        _ask_and_show_changelog
        local assistant_version
        assistant_version="$(_get_assistant_version)"
        t_version "$assistant_version"
        return 0
      else
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

_cmd_update() {
  local arg1="${1:-}"
  local target_ver=""

  case "$arg1" in
    "--list"|"-l")
      _update_list_versions
      return $?
      ;;
    @*)
      target_ver="$arg1"
      _update_to_version "$target_ver"
      return $?
      ;;
    "--version"|"-v")
      if [[ -z "${2:-}" ]]; then
        t_update_usage
        return 1
      fi
      target_ver="$2"
      _update_to_version "$target_ver"
      return $?
      ;;
    --version=*)
      target_ver="${arg1#*=}"
      if [[ -z "$target_ver" ]]; then
        t_update_usage
        return 1
      fi
      _update_to_version "$target_ver"
      return $?
      ;;
    "--help"|"-h")
      t_update_usage
      return 0
      ;;
    "")
      ;;
    *)
      t_update_usage
      return 1
      ;;
  esac

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

  local current_branch=""
  current_branch="$(git -C "$ASSISTANT_ROOT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"

  if [[ "$current_branch" == "HEAD" || -z "$current_branch" ]]; then
    local target_channel target_branch
    target_channel="$(_get_configured_channel)"
    if [[ "$target_channel" == "beta" || "$target_channel" == "dev" ]]; then
      target_branch="dev"
    else
      target_branch="main"
    fi

    t_update_returning_to_channel "$target_channel"
    local switch_output
    switch_output="$(git -C "$ASSISTANT_ROOT_DIR" switch "$target_branch" 2>&1 || git -C "$ASSISTANT_ROOT_DIR" switch -c "$target_branch" "origin/$target_branch" 2>&1)"
    local switch_status=$?

    if [[ $switch_status -ne 0 ]]; then
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
          local force_switch_output
          force_switch_output="$(git -C "$ASSISTANT_ROOT_DIR" checkout -f "$target_branch" 2>&1)"
          if [[ $? -ne 0 ]]; then
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
    fi
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
