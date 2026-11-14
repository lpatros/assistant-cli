_adapter_names() {
  if [[ "$1" == custom ]]; then
    _get_custom_engines
  else
    _get_available_engines
  fi
}

_adapter_list() {
  local names="$1" current name origin available active table
  current=$(_get_engine)
  table=$(
    t_adapters_header
    while IFS= read -r name; do
      [[ -n "$name" ]] || continue
      origin=builtin
      [[ ! -f "$ASSISTANT_ROOT_DIR/custom/adapters/$name/init.sh" ]] || origin=custom
      available=no
      _is_engine_installed "$name" && available=yes
      active=no
      [[ "$name" != "$current" ]] || active=yes
      printf '%s\t%s\t%s\t%s\n' "$name" "$(t_skill_origin "$origin")" "$(t_harness_capability_value "$available")" "$(t_harness_capability_value "$active")"
    done <<< "$names"
  )
  _format_table "$table"
}

_cmd_adapters_for_scope() {
  local scope="$1"
  shift
  local action="${1:-status}" names name capability value table current
  names=$(_adapter_names "$scope") || return 1
  case "$action" in
    --list|list)
      [[ $# -le 1 ]] || { t_adapters_usage >&2; return 1; }
      _adapter_list "$names"
      ;;
    select)
      [[ $# -eq 1 ]] || { t_adapters_usage >&2; return 1; }
      [[ -n "$names" ]] || { t_adapters_empty >&2; return 1; }
      _cmd_engine_switch "$scope"
      ;;
    capabilities)
      [[ $# -le 2 ]] || { t_adapters_usage >&2; return 1; }
      if [[ $# -eq 2 ]]; then
        if ! printf '%s\n' "$names" | grep -Fxq -- "$2"; then
          t_adapters_unknown "$2" >&2
          return 1
        fi
        names="$2"
      fi
      table=$(
        t_harness_capabilities_header
        while IFS= read -r name; do
          [[ -n "$name" ]] || continue
          printf '%s' "$name"
          for capability in prompt interactive workspace_tools model_list final_output native_skills; do
            value=$(_harness_capability "$name" "$capability") || return 1
            printf '\t%s' "$(t_harness_capability_value "$value")"
          done
          printf '\n'
        done <<< "$names"
      ) || return 1
      _format_table "$table"
      ;;
    status|"")
      [[ $# -le 1 ]] || { t_adapters_usage >&2; return 1; }
      current=$(_get_engine)
      if [[ "$scope" == custom ]] && ! printf '%s\n' "$names" | grep -Fxq -- "$current"; then
        t_adapters_no_active_custom
      else
        t_adapters_status "$current" "$(_model_display "$(_get_model)")"
      fi
      ;;
    *)
      [[ $# -eq 1 && "$action" != -* ]] || { t_adapters_usage >&2; return 1; }
      if ! printf '%s\n' "$names" | grep -Fxq -- "$action"; then
        t_adapters_unknown "$action" >&2
        return 1
      fi
      _set_engine "$action" || return 1
      t_adapters_changed "$action"
      ;;
  esac
}

_cmd_adapters() {
  _cmd_adapters_for_scope all "$@"
}
