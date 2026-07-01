_cmd_help() {
  _load_config
  local current_model current_model_display
  current_model=$(_get_model)
  current_model_display=$(_model_display "$current_model")

  t_help_output \
    "${ASSISTANT_ENGINE:-$ASSISTANT_DEFAULT_ENGINE}" \
    "$current_model_display" \
    "$(_model_display "$ASSISTANT_MODEL_OLLAMA")" \
    "$(_model_display "$ASSISTANT_MODEL_OPENCODE")" \
    "$ASSISTANT_THINK_FLAG" \
    "${ASSISTANT_LANG:-$ASSISTANT_DEFAULT_LANG}" \
}

_cmd_status() {
  _header "Status"
  _cmd_model_status
  _cmd_think status
  _cmd_lang status
}
