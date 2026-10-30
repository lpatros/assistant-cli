_engine_agy_binary() {
  echo "agy"
}

_engine_agy_is_installed() {
  _is_installed "agy"
}

_engine_agy_list_models() {
  agy models 2>/dev/null | grep -v '^$' | awk '{print $1}'
}

_engine_agy_run_prompt() {
  local prompt="$1" output_file="$2" model
  shift 2 || true
  model=$(_get_model_for_engine "agy")
  local args=(--print --output-format text --dangerously-skip-permissions)
  [[ -z "$model" ]] || args+=(--model "$model")
  _harness_capture_text agy "$output_file" agy "${args[@]}" <<< "$prompt"
}

_engine_agy_run_interactive() {
  local model="$1"
  local bin
  bin=$(_engine_agy_binary)
  echo "" >&2
  if [[ ${#LLM_CLEAN_ARGS[@]} -gt 0 ]]; then
    _engine_agy_run_prompt "${LLM_CLEAN_ARGS[*]}" "" "${LLM_THINK_FLAGS[@]}"
  elif [[ -n "$model" ]]; then
    "$bin" --model "$model"
  else
    "$bin"
  fi
}

_engine_agy_default_model() {
  echo ""
}

_engine_agy_capabilities() {
  printf '%s\n' prompt interactive workspace_tools model_list final_output
}
