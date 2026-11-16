_engine_codex_binary() {
  echo "codex"
}

_engine_codex_is_installed() {
  _is_installed "codex"
}

_engine_codex_run_prompt() {
  local prompt="$1" output_file="$2" model temp_dir run_rc
  shift 2 || true
  model=$(_get_model_for_engine "codex")
  temp_dir=$(mktemp -d) || return 1
  local args=(exec --color never --output-last-message "$temp_dir/result")
  [[ -z "$model" ]] || args+=(--model "$model")
  codex "${args[@]}" -- "$prompt" > /dev/null 2> "$temp_dir/diagnostic"
  run_rc=$?
  _harness_publish codex "$temp_dir/result" "$temp_dir/diagnostic" "$output_file" "$run_rc"
  run_rc=$?
  rm -rf -- "$temp_dir"
  return "$run_rc"
}

_engine_codex_run_interactive() {
  local model="$1"
  echo "" >&2
  if [[ ${#LLM_CLEAN_ARGS[@]} -gt 0 ]]; then
    _engine_codex_run_prompt "${LLM_CLEAN_ARGS[*]}" "" "${LLM_THINK_FLAGS[@]}"
  elif [[ -n "$model" ]]; then
    codex --model "$model"
  else
    codex
  fi
}

_engine_codex_default_model() {
  echo ""
}

_engine_codex_capabilities() {
  printf '%s\n' prompt interactive workspace_tools final_output native_skills
}

_engine_codex_skill_root() {
  case "$1" in
    project) printf '%s/.agents/skills\n' "$2" ;;
    user)
      local user_root
      user_root=$(cd -- "$HOME" && pwd -P) || return 1
      printf '%s/.agents/skills\n' "$user_root"
      ;;
    *) return 1 ;;
  esac
}

_engine_codex_render_skill() {
  local source_file="$2"
  cat "$source_file"
}

_engine_codex_skill_roots() {
  local cursor="$1" boundary scope=project root
  boundary=$(git -C "$cursor" rev-parse --show-toplevel 2>/dev/null) || boundary="$cursor"
  boundary=$(cd -- "$boundary" && pwd -P) || return 1
  while true; do
    root=$(_engine_codex_skill_root project "$cursor") || return 1
    printf '%s\t%s\n' "$scope" "$root"
    [[ "$cursor" != "$boundary" && "$cursor" != / ]] || break
    cursor=$(dirname -- "$cursor")
    scope=ancestor
  done
  root=$(_engine_codex_skill_root user '') || return 1
  printf 'user\t%s\n' "$root"
}
