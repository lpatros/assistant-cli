# Modular OpenCode Engine implementation for Assistant CLI

_engine_opencode_binary() {
  echo "opencode"
}

_engine_opencode_is_installed() {
  _is_installed "opencode"
}

_engine_opencode_list_models() {
  opencode models 2>/dev/null | grep -v '^$' | grep '/'
}

_engine_opencode_run_prompt() {
  local prompt="$1"
  local output_file="$2"
  shift 2 || true

  local model
  model=$(_get_model_for_engine "opencode")

  local args=("run")
  [[ -n "$model" ]] && args+=("--model" "$model")
  args+=("--" "$prompt")

  if [[ -n "$output_file" ]]; then
    opencode "${args[@]}" > "$output_file" 2>/dev/null
  else
    opencode "${args[@]}"
  fi
}

_engine_opencode_run_interactive() {
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

_engine_opencode_default_model() {
  echo ""
}
