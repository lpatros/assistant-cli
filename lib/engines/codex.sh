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
    codex "${args[@]}" > "$output_file" 2>/dev/null
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
