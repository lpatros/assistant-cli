# Capabilities describe this adapter, not every feature of its underlying CLI.
_harness_capability() {
  local harness="$1" capability="$2" func capabilities
  func="_engine_$(_sanitize_engine_name "$harness")_capabilities"
  if command -v "$func" >/dev/null 2>&1; then
    capabilities=$("$func") || return 1
    if printf '%s\n' "$capabilities" | grep -Fxq -- "$capability"; then
      printf '%s\n' yes
    else
      printf '%s\n' no
    fi
  else
    # Preserve the execution fallback for existing custom engines.
    case "$capability" in
      prompt|interactive) printf '%s\n' yes ;;
      native_skills) printf '%s\n' no ;;
      *) printf '%s\n' unknown ;;
    esac
  fi
}

_harness_require() {
  local supported
  supported=$(_harness_capability "$1" "$2") || return 1
  if [[ "$supported" == no ]]; then
    t_harness_unsupported "$1" "$2" >&2
    return 1
  fi
}

_cmd_harness() {
  _cmd_adapters "$@"
}

# Publish only a validated final response; a failed executor never truncates the destination.
_harness_publish() {
  local harness="$1" result_file="$2" diagnostic_file="$3" output_file="$4" run_rc="$5"
  [[ ! -s "$diagnostic_file" ]] || cat "$diagnostic_file" >&2
  if [[ $run_rc -ne 0 ]]; then
    t_harness_failed "$harness" "$run_rc" >&2
    return "$run_rc"
  fi
  if [[ ! -s "$result_file" ]] || ! grep -q '[^[:space:]]' "$result_file"; then
    t_harness_empty "$harness" >&2
    return 1
  fi
  if [[ -n "$output_file" ]]; then
    cat "$result_file" > "$output_file"
  else
    cat "$result_file"
  fi
}

_harness_capture_text() {
  local harness="$1" output_file="$2" temp_dir run_rc
  shift 2
  temp_dir=$(mktemp -d) || return 1
  "$@" > "$temp_dir/result" 2> "$temp_dir/diagnostic"
  run_rc=$?
  _harness_publish "$harness" "$temp_dir/result" "$temp_dir/diagnostic" "$output_file" "$run_rc"
  run_rc=$?
  rm -rf -- "$temp_dir"
  return "$run_rc"
}
