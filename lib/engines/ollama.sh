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
  local prompt="$1"
  local output_file="$2"
  shift 2 || true

  local model
  model=$(_get_model_for_engine "ollama")

  local think_flag
  think_flag=$(_get_think_flag "$@")

  local think_args=()
  [[ -n "$think_flag" ]] && think_args+=("$think_flag")

  if [[ -z "$output_file" && -n "$think_flag" ]]; then
    t_think_flag_display "$think_flag"
  fi

  if [[ -n "$output_file" ]]; then
    local err_file status
    err_file=$(mktemp 2>/dev/null || echo "/tmp/assistant_ollama_err_$$")
    echo "$prompt" | ollama run "$model" "${think_args[@]}" --nowordwrap > "$output_file" 2>"$err_file"
    status=$?
    if [[ $status -ne 0 && -f "$err_file" ]]; then
      cat "$err_file" >&2
    fi
    rm -f "$err_file" 2>/dev/null
    return $status
  else
    echo "$prompt" | ollama run "$model" "${think_args[@]}" --nowordwrap
  fi
}

_engine_ollama_run_interactive() {
  local model="$1"
  local think_flag
  think_flag=$(_get_think_flag "${LLM_THINK_FLAGS[@]}")

  local think_args=()
  [[ -n "$think_flag" ]] && think_args+=("$think_flag")

  [[ -n "$think_flag" ]] && t_think_mode_display "$think_flag"
  echo ""

  if [[ ${#LLM_CLEAN_ARGS[@]} -gt 0 ]]; then
    ollama run "$model" "${think_args[@]}" --nowordwrap "${LLM_CLEAN_ARGS[@]}"
  else
    ollama run "$model" "${think_args[@]}"
  fi
}

_engine_ollama_default_model() {
  echo "gemma4:e2b"
}
