_llm_run_prompt() {
  local prompt="$1"
  local output_file="${2:-}"
  shift 2 || true

  local current_engine current_model clean_eng func_name
  current_engine=$(_get_engine)
  current_model=$(_get_model)
  clean_eng=$(_sanitize_engine_name "$current_engine")
  func_name="_engine_${clean_eng}_run_prompt"

  _ensure_engine_installed "$current_engine" || return 1

  if command -v "$func_name" &>/dev/null; then
    "$func_name" "$prompt" "$output_file" "$@"
    return $?
  fi

  # Generic fallback execution if engine module function doesn't exist
  local binary="$current_engine"
  if command -v "_engine_${clean_eng}_binary" &>/dev/null; then
    binary=$("_engine_${clean_eng}_binary")
  fi

  local args=()
  [[ -n "$current_model" ]] && args+=("--model" "$current_model")
  args+=("--" "$prompt")

  if [[ -n "$output_file" ]]; then
    "$binary" "${args[@]}" > "$output_file" 2>/dev/null
  else
    "$binary" "${args[@]}"
  fi
}

_llm_run_interactive() {
  local current_engine current_model current_model_display clean_eng func_name
  current_engine=$(_get_engine)
  current_model=$(_get_model)
  current_model_display=$(_model_display "$current_model")
  clean_eng=$(_sanitize_engine_name "$current_engine")
  func_name="_engine_${clean_eng}_run_interactive"

  _ensure_engine_installed "$current_engine" || return 1

  t_engine_display "$current_engine"
  t_model_display "$current_model_display"

  _parse_args_for_llm "$@"

  if command -v "$func_name" &>/dev/null; then
    "$func_name" "$current_model"
    return $?
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
}
