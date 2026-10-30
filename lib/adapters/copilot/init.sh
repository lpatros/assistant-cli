_engine_copilot_binary() {
  echo "copilot"
}

_engine_copilot_is_installed() {
  _is_installed "copilot"
}

_engine_copilot_run_prompt() {
  local prompt="$1" output_file="$2" model
  shift 2 || true
  model=$(_get_model_for_engine "copilot")
  local args=(-p "$prompt" --silent)
  [[ -z "$model" ]] || args+=(--model "$model")
  _harness_capture_text copilot "$output_file" copilot "${args[@]}"
}

_engine_copilot_run_interactive() {
  local model="$1"
  echo "" >&2
  if [[ ${#LLM_CLEAN_ARGS[@]} -gt 0 ]]; then
    _engine_copilot_run_prompt "${LLM_CLEAN_ARGS[*]}" "" "${LLM_THINK_FLAGS[@]}"
  elif [[ -n "$model" ]]; then
    copilot --model "$model"
  else
    copilot
  fi
}

_engine_copilot_default_model() {
  echo ""
}

_engine_copilot_capabilities() {
  printf '%s\n' prompt interactive workspace_tools final_output
}
