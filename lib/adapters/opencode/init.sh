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
  local prompt="$1" output_file="$2" model temp_dir run_rc
  shift 2 || true
  if ! command -v jq >/dev/null 2>&1; then
    t_harness_dependency opencode jq >&2
    return 1
  fi
  model=$(_get_model_for_engine "opencode")
  local args=(run --format json)
  [[ -z "$model" ]] || args+=(--model "$model")
  temp_dir=$(mktemp -d) || return 1
  opencode "${args[@]}" -- "$prompt" > "$temp_dir/events" 2> "$temp_dir/diagnostic"
  run_rc=$?
  if [[ $run_rc -eq 0 ]]; then
    jq -s -er -f "$ASSISTANT_LIB_DIR/adapters/opencode/result.jq" "$temp_dir/events" > "$temp_dir/result" 2>> "$temp_dir/diagnostic" || run_rc=1
  fi
  _harness_publish opencode "$temp_dir/result" "$temp_dir/diagnostic" "$output_file" "$run_rc"
  run_rc=$?
  rm -rf -- "$temp_dir"
  return "$run_rc"
}

_engine_opencode_run_interactive() {
  local model="$1"
  echo "" >&2
  if [[ ${#LLM_CLEAN_ARGS[@]} -gt 0 ]]; then
    _engine_opencode_run_prompt "${LLM_CLEAN_ARGS[*]}" "" "${LLM_THINK_FLAGS[@]}"
  elif [[ -n "$model" ]]; then
    opencode --model "$model"
  else
    opencode
  fi
}

_engine_opencode_default_model() {
  echo ""
}

_engine_opencode_capabilities() {
  printf '%s\n' prompt interactive workspace_tools model_list final_output
}
