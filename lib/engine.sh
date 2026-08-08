_get_available_engines() {
  local engines=()
  local file name

  if [[ -d "$ASSISTANT_LIB_DIR/engines" ]]; then
    for file in "$ASSISTANT_LIB_DIR/engines"/*.sh; do
      if [[ -f "$file" ]]; then
        name=$(basename "$file" .sh)
        engines+=("$name")
      fi
    done
  fi

  if [[ -d "$ASSISTANT_ROOT_DIR/custom/engines" ]]; then
    for file in "$ASSISTANT_ROOT_DIR/custom/engines"/*.sh; do
      if [[ -f "$file" ]]; then
        name=$(basename "$file" .sh)
        engines+=("$name")
      fi
    done
    for file in "$ASSISTANT_ROOT_DIR/custom/engines"/*/init.sh; do
      if [[ -f "$file" ]]; then
        name=$(basename "$(dirname "$file")")
        engines+=("$name")
      fi
    done
  fi

  printf "%s\n" "${engines[@]}" | sort -u | grep -Ev '^\*$'
}

_is_engine_installed() {
  local engine="${1:-$(_get_engine)}"
  local clean_eng
  clean_eng=$(_sanitize_engine_name "$engine")

  if command -v "_engine_${clean_eng}_is_installed" &>/dev/null; then
    "_engine_${clean_eng}_is_installed"
    return $?
  fi

  local binary="$engine"
  if command -v "_engine_${clean_eng}_binary" &>/dev/null; then
    binary=$("_engine_${clean_eng}_binary")
  fi

  _is_installed "$binary"
}

_get_engine_binary_path() {
  local engine="${1:-$(_get_engine)}"
  local clean_eng
  clean_eng=$(_sanitize_engine_name "$engine")

  local binary="$engine"
  if command -v "_engine_${clean_eng}_binary" &>/dev/null; then
    binary=$("_engine_${clean_eng}_binary")
  fi

  if command -v "$binary" &>/dev/null; then
    command -v "$binary"
  elif command -v "$engine" &>/dev/null; then
    command -v "$engine"
  else
    echo ""
  fi
}

_ensure_engine_installed() {
  local engine="${1:-$(_get_engine)}"

  if _is_engine_installed "$engine"; then
    return 0
  fi

  t_engine_not_installed_warning "$engine"
  t_engine_not_installed_prompt

  local answer
  _prompt_read answer

  case "$answer" in
    [yY]|[yY][eE][sS])
      return 0
      ;;
    *)
      t_engine_not_installed_aborted "$engine"
      return 1
      ;;
  esac
}

_cmd_engine() {
  local action="${1:-status}"

  case "$action" in
    status|"")
      _cmd_engine_status
      ;;
    --list|list)
      _cmd_engine_switch
      ;;
    *)
      _set_engine "$action"
      t_engine_changed "$action"
      ;;
  esac
}

_cmd_engine_status() {
  t_engine_status "$(_get_engine)" "$(_model_display "$(_get_model)")"
}

_get_available_models() {
  local engine="$1"
  local clean_eng
  clean_eng=$(_sanitize_engine_name "$engine")

  if command -v "_engine_${clean_eng}_list_models" &>/dev/null; then
    "_engine_${clean_eng}_list_models"
    return 0
  fi
}

_cmd_model_list() {
  local current_engine current_model current_model_display
  current_engine=$(_get_engine)
  current_model=$(_get_model)
  current_model_display=$(_model_display "$current_model")

  _ensure_engine_installed "$current_engine" || return 1

  t_models_available_header "$current_engine"

  local model_array=()
  local models
  models=$(_get_available_models "$current_engine")

  if [[ -z "$models" ]]; then
    if command -v t_no_models_found &>/dev/null; then
      t_no_models_found "$current_engine"
    fi
    return 1
  fi

  while IFS= read -r line; do
    [[ -n "$line" ]] && model_array+=("$line")
  done <<< "$models"

  local switch_label cancel_label
  switch_label=$(t_menu_switch_engine)
  cancel_label=$(t_menu_cancel)
  model_array+=("$switch_label" "$cancel_label")

  t_current_model_label "$current_model_display"

  PS3=$'\n'"$(t_choose_model_prompt)"
  select chosen in "${model_array[@]}"; do
    if [[ "$chosen" == "$cancel_label" ]]; then
      t_cancelled
      return 0
    fi
    if [[ "$chosen" == "$switch_label" ]]; then
      _cmd_engine_switch
      return 0
    fi
    if [[ -n "$chosen" ]]; then
      _set_model "$chosen"
      t_model_changed "$chosen"
      return 0
    fi
    t_invalid_option
  done
}

_cmd_model_status() {
  _load_config
  t_model_status_detailed "$ASSISTANT_ENGINE" "$(_model_display "$(_get_model)")"
}

_get_nth() {
  local target_n="$1"
  shift
  if [[ "$target_n" =~ ^[0-9]+$ ]] && [ "$target_n" -ge 1 ] && [ "$target_n" -le "$#" ]; then
    shift $((target_n - 1))
    echo "$1"
  fi
}

_engine_menu_item() {
  local num="$1"
  local eng="$2"
  echo -e "  ${CYAN}${num})${RESET} ${BOLD}${eng}${RESET}"
}

_cmd_engine_switch() {
  local configured_engines=()
  local uninstalled_engines=()
  local all_engines=()

  local eng bin_path
  while IFS= read -r eng; do
    [[ -z "$eng" ]] && continue
    if _is_engine_installed "$eng"; then
      configured_engines+=("$eng")
    else
      uninstalled_engines+=("$eng")
    fi
  done <<< "$(_get_available_engines)"

  local idx=1

  t_engines_configured_header
  if [[ ${#configured_engines[@]} -gt 0 ]]; then
    for eng in "${configured_engines[@]}"; do
      _engine_menu_item "$idx" "$eng"
      all_engines+=("$eng")
      ((idx++))
    done
  else
    t_no_engines_configured
  fi
  echo ""

  t_engines_not_installed_header
  if [[ ${#uninstalled_engines[@]} -gt 0 ]]; then
    for eng in "${uninstalled_engines[@]}"; do
      _engine_menu_item "$idx" "$eng"
      all_engines+=("$eng")
      ((idx++))
    done
  else
    t_no_engines_uninstalled
  fi
  echo ""

  local cancel_num=$idx
  local cancel_label
  cancel_label=$(t_menu_cancel)
  echo -e "  ${YELLOW}${cancel_num})${RESET} ${cancel_label}"
  echo ""

  local current_engine
  current_engine=$(_get_engine)
  t_current_engine_label "$current_engine"

  local answer chosen=""
  while true; do
    echo -n "$(t_choose_engine_prompt)"
    _prompt_read answer

    answer="$(echo "$answer" | xargs 2>/dev/null || echo "$answer" | tr -d '[:space:]')"

    if [[ -z "$answer" || "$answer" == "$cancel_num" || "$answer" == "$cancel_label" ]]; then
      t_cancelled
      return 0
    fi

    if [[ "$answer" =~ ^[0-9]+$ ]]; then
      chosen=$(_get_nth "$answer" "${all_engines[@]}")
      if [[ -n "$chosen" ]]; then
        break
      fi
    else
      for eng in "${all_engines[@]}"; do
        if [[ "$answer" == "$eng" ]]; then
          chosen="$eng"
          break 2
        fi
      done
    fi

    t_invalid_option_simple
  done

  if [[ -n "$chosen" ]]; then
    _set_engine "$chosen"
    t_engine_changed "$chosen"
    t_use_model_list_to_choose
    return 0
  fi
}
