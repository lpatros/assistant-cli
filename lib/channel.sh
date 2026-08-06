_get_current_channel() {
  local branch=""
  if _is_installed "git" && [[ -d "$ASSISTANT_ROOT_DIR/.git" ]]; then
    branch="$(git -C "$ASSISTANT_ROOT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  fi

  case "$branch" in
    "main")
      echo "stable"
      ;;
    "dev")
      echo "beta"
      ;;
    "")
      echo "unknown"
      ;;
    *)
      echo "$branch"
      ;;
  esac
}

_cmd_channel() {
  local target="${1:-}"

  if ! _is_installed "git" || [[ ! -d "$ASSISTANT_ROOT_DIR/.git" ]]; then
    t_git_not_installed
    return 1
  fi

  local current_channel
  current_channel="$(_get_current_channel)"

  case "$target" in
    ""|"status")
      t_channel_status "$current_channel"
      ;;
    "beta"|"dev")
      if [[ "$current_channel" == "beta" ]]; then
        t_channel_already_active "beta"
        _cmd_update
        return $?
      fi

      t_channel_switching "beta"
      local switch_output
      switch_output="$(git -C "$ASSISTANT_ROOT_DIR" switch dev 2>&1 || git -C "$ASSISTANT_ROOT_DIR" switch -c dev origin/dev 2>&1)"
      local switch_status=$?

      if [[ $switch_status -ne 0 ]]; then
        t_channel_switch_failed "beta" "$switch_output"
        return 1
      fi

      _cmd_update
      ;;
    "stable"|"main")
      if [[ "$current_channel" == "stable" ]]; then
        t_channel_already_active "stable"
        _cmd_update
        return $?
      fi

      t_channel_switching "stable"
      local switch_output
      switch_output="$(git -C "$ASSISTANT_ROOT_DIR" switch main 2>&1 || git -C "$ASSISTANT_ROOT_DIR" switch -c main origin/main 2>&1)"
      local switch_status=$?

      if [[ $switch_status -ne 0 ]]; then
        t_channel_switch_failed "stable" "$switch_output"
        return 1
      fi

      _cmd_update
      ;;
    *)
      t_channel_usage
      return 1
      ;;
  esac
}
