_llm_run_prompt() {
  local prompt="$1"
  local output_file="${2:-}"
  shift 2 || true

  local current_engine current_model
  current_engine=$(_get_engine)
  current_model=$(_get_model)

  if [[ "$current_engine" == "opencode" ]]; then
    _llm_run_prompt_opencode "$prompt" "$current_model" "$output_file"
  else
    _llm_run_prompt_ollama "$prompt" "$current_model" "$output_file" "$@"
  fi
}

_llm_run_prompt_opencode() {
  local prompt="$1"
  local model="$2"
  local output_file="$3"

  local args=("run")
  [[ -n "$model" ]] && args+=("--model" "$model")
  args+=("--" "$prompt")

  if [[ -n "$output_file" ]]; then
    opencode "${args[@]}" > "$output_file" 2>/dev/null
  else
    opencode "${args[@]}"
  fi
}

_llm_run_prompt_ollama() {
  local prompt="$1"
  local model="$2"
  local output_file="$3"
  shift 3 || true

  local think_flag
  think_flag=$(_get_think_flag "$@")

  if [[ -z "$output_file" && -n "$think_flag" ]]; then
    t_think_flag_display "$think_flag"
  fi

  if [[ -n "$output_file" ]]; then
    echo "$prompt" | ollama run "$model" $think_flag --nowordwrap > "$output_file" 2>/dev/null
  else
    echo "$prompt" | ollama run "$model" $think_flag --nowordwrap
  fi
}

_llm_run_interactive() {
  local current_engine current_model current_model_display
  current_engine=$(_get_engine)
  current_model=$(_get_model)
  current_model_display=$(_model_display "$current_model")

  t_engine_display "$current_engine"
  t_model_display "$current_model_display"

  _parse_args_for_llm "$@"

  if [[ "$current_engine" == "opencode" ]]; then
    _llm_run_interactive_opencode "$current_model"
  else
    _llm_run_interactive_ollama "$current_model"
  fi
}

_llm_run_interactive_opencode() {
  local model="$1"
  echo ""
  if [[ ${#LLM_CLEAN_ARGS[@]} -gt 0 ]]; then
    local args=("run")
    [[ -n "$model" ]] && args+=("--model" "$model")
    args+=("--" "${LLM_CLEAN_ARGS[@]}")
    opencode "${args[@]}"
  elif [[ -n "$model" ]]; then
    opencode --model "$model"
  else
    opencode
  fi
}

_llm_run_interactive_ollama() {
  local model="$1"
  local think_flag
  think_flag=$(_get_think_flag "${LLM_THINK_FLAGS[@]}")

  [[ -n "$think_flag" ]] && t_think_mode_display "$think_flag"
  echo ""

  if [[ ${#LLM_CLEAN_ARGS[@]} -gt 0 ]]; then
    ollama run "$model" $think_flag --nowordwrap "${LLM_CLEAN_ARGS[@]}"
  else
    ollama run "$model" $think_flag
  fi
}
