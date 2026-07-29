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

_ensure_engine_installed() {
  local engine="${1:-$(_get_engine)}"

  if _is_engine_installed "$engine"; then
    return 0
  fi

  t_engine_not_installed_warning "$engine"
  t_engine_not_installed_prompt

  local answer
  if [ -c /dev/tty ]; then
    read -r answer </dev/tty || true
  else
    read -r answer || true
  fi

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
      _ensure_engine_installed "$action"
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

_cmd_engine_switch() {
  t_choose_engine_header
  local current_engine
  current_engine=$(_get_engine)
  t_current_engine_label "$current_engine"

  local available_engines=()
  local eng
  while IFS= read -r eng; do
    [[ -n "$eng" ]] && available_engines+=("$eng")
  done <<< "$(_get_available_engines)"

  local cancel_label
  cancel_label=$(t_menu_cancel)
  available_engines+=("$cancel_label")

  PS3=$'\n'"$(t_choose_engine_prompt)"
  select chosen in "${available_engines[@]}"; do
    if [[ "$chosen" == "$cancel_label" || -z "$chosen" ]]; then
      t_cancelled
      return 0
    fi
    if [[ -n "$chosen" ]]; then
      _set_engine "$chosen"
      t_engine_changed "$chosen"
      _ensure_engine_installed "$chosen"
      t_use_model_list_to_choose
      return 0
    fi
    t_invalid_option_simple
  done
}
