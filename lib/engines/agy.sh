_engine_agy_binary() {
  echo "agy"
}

_engine_agy_is_installed() {
  _is_installed "agy"
}

_engine_agy_list_models() {
  agy models 2>/dev/null | grep -v '^$' || grep '/'
}

_engine_agy_run_prompt() {
  local prompt="$1"
  local output_file="$2"
  shift 2 || true

  local bin model
  bin=$(_engine_agy_binary)
  model=$(_get_model_for_engine "agy")

  local args=("--dangerously-skip-permissions")
  [[ -n "$model" ]] && args+=("--model" "$model")

  if [[ -n "$output_file" ]]; then
    local err_file status
    err_file=$(mktemp 2>/dev/null || echo "/tmp/assistant_agy_err_$$")
    echo "$prompt" | "$bin" "${args[@]}" > "$output_file" 2>"$err_file"
    status=$?
    if [[ $status -ne 0 && -f "$err_file" ]]; then
      cat "$err_file" >&2
    fi
    rm -f "$err_file" 2>/dev/null
    return $status
  else
    echo "$prompt" | "$bin" "${args[@]}"
  fi
}

_engine_agy_run_interactive() {
  local model="$1"
  local bin
  bin=$(_engine_agy_binary)
  echo ""
  if [[ ${#LLM_CLEAN_ARGS[@]} -gt 0 ]]; then
    local args=("--dangerously-skip-permissions")
    [[ -n "$model" ]] && args+=("--model" "$model")
    echo "${LLM_CLEAN_ARGS[*]}" | "$bin" "${args[@]}"
  elif [[ -n "$model" ]]; then
    "$bin" --model "$model"
  else
    "$bin"
  fi
}

_engine_agy_default_model() {
  echo ""
}
