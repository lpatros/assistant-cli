_engine_ollama_binary() {
  echo "ollama"
}

_engine_ollama_is_installed() {
  _is_installed "ollama"
}

_engine_ollama_list_models() {
  ollama list 2>/dev/null | tail -n +2 | awk '{print $1}'
}

_engine_ollama_run_prompt() {
  local prompt="$1" output_file="$2" model think_flag
  shift 2 || true
  model=$(_get_model_for_engine "ollama")
  think_flag=$(_get_think_flag "$@")
  local args=(run "$model" --nowordwrap --hidethinking)
  [[ -z "$think_flag" || "$think_flag" == --hidethinking ]] || args+=("$think_flag")
  _harness_capture_text ollama "$output_file" ollama "${args[@]}" <<< "$prompt"
}

_engine_ollama_run_interactive() {
  local model="$1"
  local think_flag
  think_flag=$(_get_think_flag "${LLM_THINK_FLAGS[@]}")

  local think_args=()
  [[ -n "$think_flag" ]] && think_args+=("$think_flag")

  [[ -n "$think_flag" ]] && t_think_mode_display "$think_flag" >&2
  echo "" >&2

  if [[ ${#LLM_CLEAN_ARGS[@]} -gt 0 ]]; then
    _engine_ollama_run_prompt "${LLM_CLEAN_ARGS[*]}" "" "${LLM_THINK_FLAGS[@]}"
  else
    ollama run "$model" "${think_args[@]}"
  fi
}

_engine_ollama_default_model() {
  echo "gemma4:e2b"
}

_engine_ollama_capabilities() {
  printf '%s\n' prompt interactive model_list final_output
}
