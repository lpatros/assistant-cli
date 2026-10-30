_skill_is_reserved() {
  case "$1" in
    create|skills|model|engine|think|lang|custom|status|update|channel|changelog|version|--version|-v|help|--help|-h|--think|--no-think|--hide-think) return 0 ;;
    *) return 1 ;;
  esac
}

# Parse a flat, single-line frontmatter subset as data, never as shell code.
_skill_metadata() {
  [[ -f "$1" ]] || return 1
  awk '
    function scalar(s, first, last) {
      sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s)
      first = substr(s, 1, 1); last = substr(s, length(s), 1)
      if (first == "\"" || first == sprintf("%c", 39)) {
        if (length(s) < 2 || last != first) { bad = 1; return "" }
        s = substr(s, 2, length(s) - 2)
        if (index(s, first) || index(s, "\\")) bad = 1
      } else if (s ~ /^[>|\[\]{}&*!#]/ || s ~ /[ \t]#/ || s ~ /: /) bad = 1
      return s
    }
    { sub(/\r$/, "") }
    NR == 1 { if ($0 != "---") bad = 1; next }
    !closed && $0 == "---" { closed = 1; next }
    !closed {
      if ($0 ~ /^[ \t]*$/ || $0 ~ /^#/) next
      if ($0 !~ /^(name|description):[ \t]+/) { bad = 1; next }
      key = $0; sub(/:.*/, "", key)
      value = $0; sub(/^[^:]+:/, "", value)
      if (seen[key]++) bad = 1
      values[key] = scalar(value)
      next
    }
    END {
      if (bad || !closed || values["name"] !~ /^[a-z0-9][a-z0-9_-]*$/ || values["description"] !~ /[^ \t]/ || values["description"] ~ /\t/) exit 1
      printf "%s\t%s\n", values["name"], values["description"]
    }
  ' "$1"
}

# Columns: name, origin, path, state, description, folder.
_skill_registry() {
  local origin directory file folder metadata name description state
  for origin in builtin custom; do
    directory="$ASSISTANT_ROOT_DIR/skills"
    [[ "$origin" == custom ]] && directory="$ASSISTANT_ROOT_DIR/custom/skills"
    [[ -d "$directory" ]] || continue
    while IFS= read -r file; do
      folder=$(basename "$(dirname "$file")")
      state=ready
      metadata=$(_skill_metadata "$file")
      if [[ $? -ne 0 ]]; then
        name="$folder"
        description="-"
        state=invalid
      else
        name="${metadata%%$'\t'*}"
        description="${metadata#*$'\t'}"
        [[ "$name" == "$folder" ]] || state=invalid
      fi
      _skill_is_reserved "$name" && state=reserved
      printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$name" "$origin" "$file" "$state" "$description" "$folder"
    done < <(find "$directory" -mindepth 2 -maxdepth 2 -name SKILL.md -type f | LC_ALL=C sort)
  done | awk -F '\t' 'BEGIN { OFS = FS }
    { rows[NR] = $0; count[$2 SUBSEP $1]++; custom[$1] += ($2 == "custom") }
    END {
      for (i = 1; i <= NR; i++) {
        split(rows[i], row, FS)
        if (count[row[2] SUBSEP row[1]] > 1) row[4] = "conflict"
        else if (row[4] == "ready" && row[2] == "builtin" && custom[row[1]]) row[4] = "overridden"
        print row[1], row[2], row[3], row[4], row[5], row[6]
      }
    }'
}

# Return 2 only when no definition exists; invalid definitions must not fall through.
_resolve_skill() {
  local requested="$1" name origin file state description folder selected="" failed=0
  while IFS=$'\t' read -r name origin file state description folder; do
    [[ "$name" == "$requested" || "$folder" == "$requested" ]] || continue
    case "$state" in
      ready|overridden)
        if [[ -z "$selected" || "$origin" == custom ]]; then
          selected="$file"
        fi
        ;;
      *)
        t_skill_error "$file" "$(t_skill_state "$state")" >&2
        failed=1
        ;;
    esac
  done < <(_skill_registry)
  [[ $failed -eq 0 ]] || return 1
  [[ -n "$selected" ]] || return 2
  printf '%s\n' "$selected"
}

_run_skill() {
  local skill_name="$1" md_file="$2"
  shift 2
  # Built-in handlers remain trusted bootstrap code; custom packages provide data only.
  if [[ -f "$ASSISTANT_ROOT_DIR/skills/$skill_name/init.sh" ]] && command -v "_cmd_${skill_name}" >/dev/null 2>&1; then
    "_cmd_${skill_name}" "$@"
    return $?
  fi
  local md_content prompt
  md_content=$(_read_guidelines "$md_file") || return 1
  _parse_args_for_llm "$@"
  prompt="=== Guidelines ===
$md_content"
  if [[ ${#LLM_CLEAN_ARGS[@]} -gt 0 ]]; then
    prompt="$prompt

=== Additional context from user ===
${LLM_CLEAN_ARGS[*]}"
  fi
  _llm_run_prompt "$prompt" "" "${LLM_THINK_FLAGS[@]}"
}

_cmd_skills() {
  if [[ "${1:-list}" != list || $# -gt 1 ]]; then
    t_skills_usage
    return 1
  fi
  local name origin file state description folder result=0
  t_skills_header
  while IFS=$'\t' read -r name origin file state description folder; do
    printf '%s\t%s\tSKILL.md\t%s\t%s\t%s\n' "$name" "$(t_skill_origin "$origin")" "$(t_skill_state "$state")" "$file" "$description"
    case "$state" in ready|overridden) ;; *) result=1 ;; esac
  done < <(_skill_registry)
  return "$result"
}
