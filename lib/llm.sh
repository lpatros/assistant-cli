_llm_run_prompt() {
  local prompt="$1"
  local output_file="${2:-}"
  shift 2 || true

  local current_engine current_model clean_eng func_name
  current_engine=$(_get_engine)
  current_model=$(_get_model)
  clean_eng=$(_sanitize_engine_name "$current_engine")
  func_name="_engine_${clean_eng}_run_prompt"

  _harness_require "$current_engine" prompt || return 1
  if ! _is_engine_installed "$current_engine"; then
    t_engine_not_installed_warning "$current_engine" >&2
    return 127
  fi
  _update_check_start

  if command -v "$func_name" &>/dev/null; then
    "$func_name" "$prompt" "$output_file" "$@"
    local rc=$?
    _update_check_notify >&2
    return $rc
  fi

  # Generic fallback execution if engine module function doesn't exist
  local binary="$current_engine"
  if command -v "_engine_${clean_eng}_binary" &>/dev/null; then
    binary=$("_engine_${clean_eng}_binary")
  fi

  local args=()
  [[ -n "$current_model" ]] && args+=("--model" "$current_model")
  args+=("--" "$prompt")

  _harness_capture_text "$current_engine" "$output_file" "$binary" "${args[@]}"
  local prompt_rc=$?
  _update_check_notify >&2
  return "$prompt_rc"
}

_llm_run_interactive() {
  local current_engine current_model current_model_display clean_eng func_name
  current_engine=$(_get_engine)
  current_model=$(_get_model)
  current_model_display=$(_model_display "$current_model")
  clean_eng=$(_sanitize_engine_name "$current_engine")
  func_name="_engine_${clean_eng}_run_interactive"

  _parse_args_for_llm "$@"
  if [[ ${#LLM_CLEAN_ARGS[@]} -gt 0 ]]; then
    _llm_run_prompt "${LLM_CLEAN_ARGS[*]}" "" "${LLM_THINK_FLAGS[@]}"
    return $?
  fi
  _harness_require "$current_engine" interactive || return 1
  _ensure_engine_installed "$current_engine" >&2 || return 1
  _update_check_start

  t_engine_display "$current_engine" >&2
  t_model_display "$current_model_display" >&2

  if command -v "$func_name" &>/dev/null; then
    "$func_name" "$current_model"
    local rc=$?
    _update_check_notify >&2
    return $rc
  fi

  # Generic fallback execution if engine module function doesn't exist
  local binary="$current_engine"
  if command -v "_engine_${clean_eng}_binary" &>/dev/null; then
    binary=$("_engine_${clean_eng}_binary")
  fi

  echo ""
  if [[ ${#LLM_CLEAN_ARGS[@]} -gt 0 ]]; then
    local args=()
    [[ -n "$current_model" ]] && args+=("--model" "$current_model")
    args+=("--" "${LLM_CLEAN_ARGS[@]}")
    "$binary" "${args[@]}"
  elif [[ -n "$current_model" ]]; then
    "$binary" --model "$current_model"
  else
    "$binary"
  fi
  local interactive_rc=$?
  _update_check_notify >&2
  return $interactive_rc
}
