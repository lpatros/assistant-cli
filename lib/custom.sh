_run_generic_skill() {
  local skill_name="$1"
  shift

  local md_file="$ASSISTANT_ROOT_DIR/custom/skills/${skill_name}-assistant.md"
  if [[ ! -f "$md_file" ]]; then
    t_custom_skill_not_found "$md_file"
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
    t_create_skill_invalid_name
    return 1
  fi

  if [[ ! -f "$skill_md_path" ]]; then
    t_create_skill_md_not_found "$skill_md_path"
    return 1
  fi

  if [[ -d "$ASSISTANT_ROOT_DIR/skills/$skill_name" ]]; then
    t_create_skill_warning_default_override "$skill_name"
    local answer
    t_create_skill_prompt_override
    _prompt_read answer
    if [[ ! "$answer" =~ ^[yY](es)?$ ]]; then
      t_create_skill_aborted
      return 1
    fi
  fi

  local custom_dir="$ASSISTANT_ROOT_DIR/custom/skills"
  mkdir -p "$custom_dir"

  local dest_md="$custom_dir/${skill_name}-assistant.md"
  cp "$skill_md_path" "$dest_md"

  t_create_skill_success "$skill_name" "$dest_md"
}

_get_custom_engines() {
  local engines=()
  local file name

  if [[ -d "$ASSISTANT_ROOT_DIR/custom/engines" ]]; then
    for file in "$ASSISTANT_ROOT_DIR/custom/engines"/*.sh; do
      if [[ -f "$file" ]]; then
        name=$(basename "$file" .sh)
        engines+=("$name")
      fi
    done
    for file in "$ASSISTANT_ROOT_DIR/custom/engines"/*/init.sh; do
      if [[ -f "$file" ]]; then
        name=$(basename "$(dirname "$file")")
        engines+=("$name")
      fi
    done
  fi

  if [[ ${#engines[@]} -gt 0 ]]; then
    printf "%s\n" "${engines[@]}" | sort -u
  fi
}

_get_custom_skills() {
  local skills=()
  local file name

  if [[ -d "$ASSISTANT_ROOT_DIR/custom/skills" ]]; then
    for file in "$ASSISTANT_ROOT_DIR/custom/skills"/*-assistant.md; do
      if [[ -f "$file" ]]; then
        name=$(basename "$file")
        name="${name%-assistant.md}"
        skills+=("$name")
      fi
    done
  fi

  if [[ ${#skills[@]} -gt 0 ]]; then
    printf "%s\n" "${skills[@]}" | sort -u
  fi
}

_get_custom_locales() {
  local locales=()
  local file name

  if [[ -d "$ASSISTANT_ROOT_DIR/custom/locales" ]]; then
    for file in "$ASSISTANT_ROOT_DIR/custom/locales"/*.sh; do
      if [[ -f "$file" ]]; then
        name=$(basename "$file" .sh)
        locales+=("$name")
      fi
    done
  fi

  if [[ ${#locales[@]} -gt 0 ]]; then
    printf "%s\n" "${locales[@]}" | sort -u
  fi
}

_cmd_custom_engines_status() {
  t_custom_engines_status_header
  local engines eng
  engines=$(_get_custom_engines)
  if [[ -n "$engines" ]]; then
    while IFS= read -r eng; do
      [[ -n "$eng" ]] && echo "  • $eng"
    done <<< "$engines"
  else
    t_no_custom_engines_found
  fi
}

_cmd_custom_skills_status() {
  t_custom_skills_status_header
  local skills skill
  skills=$(_get_custom_skills)
  if [[ -n "$skills" ]]; then
    while IFS= read -r skill; do
      [[ -n "$skill" ]] && echo "  • $skill"
    done <<< "$skills"
  else
    t_no_custom_skills_found
  fi
}

_cmd_custom_locales_status() {
  t_custom_locales_status_header
  local locales loc
  locales=$(_get_custom_locales)
  if [[ -n "$locales" ]]; then
    while IFS= read -r loc; do
      [[ -n "$loc" ]] && echo "  • $loc"
    done <<< "$locales"
  else
    t_no_custom_locales_found
  fi
}

_cmd_custom_status() {
  t_custom_status_header
  _cmd_custom_engines_status
  _cmd_custom_skills_status
  _cmd_custom_locales_status
}

_cmd_custom() {
  local target="${1:-status}"
  shift 2>/dev/null || true

  case "$target" in
    status|"")
      _cmd_custom_status
      ;;
    engines)
      local subaction="${1:-status}"
      case "$subaction" in
        status|"")
          _cmd_custom_engines_status
          ;;
        *)
          t_custom_engines_usage
          return 1
          ;;
      esac
      ;;
    skills)
      local subaction="${1:-status}"
      case "$subaction" in
        status|"")
          _cmd_custom_skills_status
          ;;
        *)
          t_custom_skills_usage
          return 1
          ;;
      esac
      ;;
    locales)
      local subaction="${1:-status}"
      case "$subaction" in
        status|"")
          _cmd_custom_locales_status
          ;;
        *)
          t_custom_locales_usage
          return 1
          ;;
      esac
      ;;
    *)
      t_custom_usage
      return 1
      ;;
  esac
}

