_engine_copilot_binary() {
  echo "copilot"
}

_engine_copilot_is_installed() {
  _is_installed "copilot"
}

_engine_copilot_run_prompt() {
  local prompt="$1"
  local output_file="$2"
  shift 2 || true

  local model
  model=$(_get_model_for_engine "copilot")

  local args=("-p" "$prompt")
  [[ -n "$model" ]] && args+=("--model" "$model")

  if [[ -n "$output_file" ]]; then
    copilot "${args[@]}" > "$output_file" 2>/dev/null
  else
    copilot "${args[@]}"
  fi
}

_engine_copilot_run_interactive() {
  local model="$1"
  echo ""
  if [[ ${#LLM_CLEAN_ARGS[@]} -gt 0 ]]; then
    local args=("-p" "${LLM_CLEAN_ARGS[*]}")
    [[ -n "$model" ]] && args+=("--model" "$model")
    copilot "${args[@]}"
  elif [[ -n "$model" ]]; then
    copilot --model "$model"
  else
    copilot
  fi
}

_engine_copilot_default_model() {
  echo ""
}
