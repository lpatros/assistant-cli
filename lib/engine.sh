_cmd_engine() {
  local action="${1:-status}"

  case "$action" in
    ollama)
      _set_engine "ollama"
      t_engine_changed "ollama"
      ;;
    opencode)
      _set_engine "opencode"
      t_engine_changed "opencode"
      ;;
    status|"")
      _cmd_engine_status
      ;;
    --list)
      _cmd_model_list
      ;;
    *)
      t_engine_usage
      return 1
      ;;
  esac
}

_cmd_engine_status() {
  t_engine_status "$(_get_engine)" "$(_model_display "$(_get_model)")"
}

_get_available_models() {
  local engine="$1"
  if [[ "$engine" == "ollama" ]]; then
    ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'
  elif [[ "$engine" == "opencode" ]]; then
    opencode models 2>/dev/null | grep -v '^$' | grep '/'
  fi
}

_cmd_model_list() {
  local current_engine current_model current_model_display
  current_engine=$(_get_engine)
  current_model=$(_get_model)
  current_model_display=$(_model_display "$current_model")

  t_models_available_header "$current_engine"

  local model_array=()
  local models
  models=$(_get_available_models "$current_engine")

  if [[ -z "$models" ]]; then
    if [[ "$current_engine" == "ollama" ]]; then
      t_no_models_found_ollama
    else
      t_no_models_found_opencode
    fi
    return 1
  fi

  while IFS= read -r line; do
    model_array+=("$line")
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
  t_model_status_detailed \
    "$ASSISTANT_ENGINE" \
    "$(_model_display "$(_get_model)")" \
    "$(_model_display "$ASSISTANT_MODEL_OLLAMA")" \
    "$(_model_display "$ASSISTANT_MODEL_OPENCODE")"
}

_cmd_engine_switch() {
  t_choose_engine_header
  local current_engine
  current_engine=$(_get_engine)
  t_current_engine_label "$current_engine"

  local cancel_label
  cancel_label=$(t_menu_cancel)

  PS3=$'\n'"$(t_choose_engine_prompt)"
  select chosen in "ollama" "opencode" "$cancel_label"; do
    if [[ "$chosen" == "$cancel_label" ]]; then
      t_cancelled
      return 0
    fi
    if [[ -n "$chosen" ]]; then
      _set_engine "$chosen"
      t_engine_changed "$chosen"
      t_use_model_list_to_choose
      return 0
    fi
    t_invalid_option_simple
  done
}
