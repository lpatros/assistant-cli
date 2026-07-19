_run_generic_skill() {
  local skill_name="$1"
  shift

  local md_file="$ASSISTANT_ROOT_DIR/custom/${skill_name}-assistant.md"
  if [[ ! -f "$md_file" ]]; then
    _error "Skill customizada não encontrada: $md_file"
    return 1
  fi

  local md_content
  md_content=$(cat "$md_file")

  _parse_args_for_llm "$@"
  local clean_args=("${LLM_CLEAN_ARGS[@]}")
  local think_flags=("${LLM_THINK_FLAGS[@]}")

  local prompt=""
  if [[ -n "$md_content" ]]; then
    prompt="=== Guidelines ===
$md_content
"
  fi

  if [[ ${#clean_args[@]} -gt 0 ]]; then
    prompt="$prompt

=== User Query ===
${clean_args[*]}"
  fi

  _llm_run_prompt "$prompt" "" "${think_flags[@]}"
}

_cmd_create_skill() {
  local skill_name="${1:-}"
  local skill_md_path="${2:-}"

  if [[ -z "$skill_name" || -z "$skill_md_path" ]]; then
    t_create_skill_usage
    return 1
  fi

  if [[ ! "$skill_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    _error "Invalid skill name. Use only alphanumeric characters, underscores, or hyphens."
    return 1
  fi

  if [[ ! -f "$skill_md_path" ]]; then
    _error "Skill markdown file not found: $skill_md_path"
    return 1
  fi

  local custom_dir="$ASSISTANT_ROOT_DIR/custom"
  mkdir -p "$custom_dir"

  local dest_md="$custom_dir/${skill_name}-assistant.md"
  cp "$skill_md_path" "$dest_md"

  t_create_skill_success "$skill_name" "$dest_md"
}
