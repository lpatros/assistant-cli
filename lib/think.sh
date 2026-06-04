_get_think_flag() {
  local think_flag=""

  for arg in "$@"; do
    case "$arg" in
      --think)       think_flag="--think" ;;
      --no-think)    think_flag="--think=false" ;;
      --hide-think)  think_flag="--hidethinking" ;;
    esac
  done

  if [[ -z "$think_flag" && -f "$ASSISTANT_CONFIG_FILE" ]]; then
    source "$ASSISTANT_CONFIG_FILE"
    think_flag="${ASSISTANT_THINK_FLAG:-}"
  fi

  if [[ -n "$think_flag" ]]; then
    _save_think_flag "$think_flag"
  fi

  echo "$think_flag"
}

_cmd_think() {
  local action="${1:-status}"

  case "$action" in
    on)
      _save_think_flag "--think"
      t_think_enabled
      ;;
    off)
      _save_think_flag "--think=false"
      t_think_disabled
      ;;
    hide)
      _save_think_flag "--hidethinking"
      t_think_hidden
      ;;
    clear)
      _save_think_flag ""
      t_think_cleared
      ;;
    status|"")
      local current_flag=""
      if [[ -f "$ASSISTANT_CONFIG_FILE" ]]; then
        source "$ASSISTANT_CONFIG_FILE"
        current_flag="${ASSISTANT_THINK_FLAG:-}"
      fi
      if [[ -z "$current_flag" ]]; then
        t_think_status_default
        return 0
      fi
      t_think_status_current "$current_flag"
      ;;
    *)
      t_think_usage
      return 1
      ;;
  esac
}
