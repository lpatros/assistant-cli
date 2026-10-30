_engine_codex_binary() {
  echo "codex"
}

_engine_codex_is_installed() {
  _is_installed "codex"
}

_engine_codex_run_prompt() {
  local prompt="$1"
  local output_file="$2"
  shift 2 || true

  local model
  model=$(_get_model_for_engine "codex")

  local args=()
  [[ -n "$model" ]] && args+=("--model" "$model")
  args+=("exec" "$prompt")

  if [[ -n "$output_file" ]]; then
    local err_file exit_code
    err_file=$(mktemp) || return 1
    codex "${args[@]}" > "$output_file" 2>"$err_file"
    exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
      cat "$err_file" >&2
    fi
    rm -f "$err_file"
    return "$exit_code"
  else
    codex "${args[@]}"
  fi
}

_engine_codex_run_interactive() {
  local model="$1"
  echo ""
  if [[ ${#LLM_CLEAN_ARGS[@]} -gt 0 ]]; then
    local args=()
    [[ -n "$model" ]] && args+=("--model" "$model")
    args+=("exec" "${LLM_CLEAN_ARGS[*]}")
    codex "${args[@]}"
  elif [[ -n "$model" ]]; then
    codex --model "$model"
  else
    codex
  fi
}

_engine_codex_default_model() {
  echo ""
}
