_cmd_create_skill() {
  local skill_name="${1:-}"
  local skill_md_path="${2:-}"

  if [[ $# -ne 2 || -z "$skill_name" || -z "$skill_md_path" ]]; then
    t_create_skill_usage
    return 1
  fi

  if [[ ! "$skill_name" =~ ^[a-z0-9][a-z0-9_-]*$ ]]; then
    t_create_skill_invalid_name
    return 1
  fi

  if [[ ! -f "$skill_md_path" ]]; then
    t_create_skill_md_not_found "$skill_md_path"
    return 1
  fi

  if _skill_is_reserved "$skill_name"; then
    t_skill_error "$skill_name" "$(t_skill_state reserved)" >&2
    return 1
  fi
  local metadata
  metadata=$(_skill_metadata "$skill_md_path")
  if [[ $? -ne 0 || "${metadata%%$'\t'*}" != "$skill_name" ]]; then
    t_skill_error "$skill_md_path" "$(t_skill_state invalid)" >&2
    return 1
  fi
  local existing
  existing=$(_skill_registry | awk -F '\t' -v name="$skill_name" '$2 == "custom" && ($1 == name || $6 == name) { print $3 }')
  if [[ -e "$ASSISTANT_ROOT_DIR/custom/skills/$skill_name" || -n "$existing" ]]; then
    t_skill_error "$skill_name" "$(t_skill_state conflict)" >&2
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

  local custom_dir="$ASSISTANT_ROOT_DIR/custom/skills/$skill_name"
  mkdir -p "$custom_dir" || return 1

  local dest_md="$custom_dir/SKILL.md"
  cp "$skill_md_path" "$dest_md" || return 1

  t_create_skill_success "$skill_name" "$dest_md"
}

_get_custom_engines() {
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    setopt localoptions nonomatch
  fi
  local engines=()
  local file name

  if [[ -d "$ASSISTANT_ROOT_DIR/custom/adapters" ]]; then
    for file in "$ASSISTANT_ROOT_DIR/custom/adapters"/*/init.sh; do
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
  _skill_registry | awk -F '\t' '$2 == "custom" { print $1 }' | sort -u
}

_get_custom_locales() {
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    setopt localoptions nonomatch
  fi
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
    adapters|engine|engines|harness)
      _cmd_adapters_for_scope custom "$@"
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

