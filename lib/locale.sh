_find_locale_file() {
  local lang="${1:-}"
  if [[ -z "$lang" ]]; then
    return 1
  fi

  if [[ -f "$ASSISTANT_ROOT_DIR/custom/locales/${lang}.sh" ]]; then
    echo "$ASSISTANT_ROOT_DIR/custom/locales/${lang}.sh"
    return 0
  elif [[ -f "$ASSISTANT_ROOT_DIR/locales/${lang}.sh" ]]; then
    echo "$ASSISTANT_ROOT_DIR/locales/${lang}.sh"
    return 0
  fi

  return 1
}

_load_locale() {
  _load_config
  local fallback_lang="${ASSISTANT_DEFAULT_LANG:-en}"
  local fallback_file
  fallback_file="$(_find_locale_file "$fallback_lang")"
  if [[ -z "$fallback_file" ]]; then
    fallback_file="$ASSISTANT_ROOT_DIR/locales/en.sh"
  fi

  if [[ -f "$fallback_file" ]]; then
    source "$fallback_file"
  fi

  local lang="${ASSISTANT_LANG:-$fallback_lang}"
  local target_file
  target_file="$(_find_locale_file "$lang")"

  if [[ -n "$target_file" && -f "$target_file" && "$target_file" != "$fallback_file" ]]; then
    source "$target_file"
  fi
}

_cmd_lang_list() {
  if command -v t_lang_list_header &>/dev/null; then
    t_lang_list_header
  else
    _header "Available languages:"
  fi

  local loc
  local lang_name

  if [[ -d "$ASSISTANT_ROOT_DIR/locales" ]]; then
    for loc in "$ASSISTANT_ROOT_DIR/locales"/*.sh; do
      if [[ -f "$loc" ]]; then
        lang_name="$(basename "$loc" .sh)"
        echo "  • $lang_name"
      fi
    done
  fi

  if [[ -d "$ASSISTANT_ROOT_DIR/custom/locales" ]]; then
    for loc in "$ASSISTANT_ROOT_DIR/custom/locales"/*.sh; do
      if [[ -f "$loc" ]]; then
        lang_name="$(basename "$loc" .sh)"
        echo "  • $lang_name (custom)"
      fi
    done
  fi
}

_cmd_lang() {
  local action="${1:-status}"

  case "$action" in
    status|"")
      _load_config
      t_lang_status "${ASSISTANT_LANG:-$ASSISTANT_DEFAULT_LANG}"
      ;;
    --list|list)
      _cmd_lang_list
      ;;
    *)
      local locale_file
      locale_file="$(_find_locale_file "$action")"
      if [[ -n "$locale_file" ]]; then
        _set_lang "$action"
        _load_locale
        t_lang_changed "$action"
      else
        if command -v t_lang_not_found &>/dev/null; then
          t_lang_not_found "$action"
        else
          _error "Locale file not found for: $action"
        fi
        t_lang_usage
        return 1
      fi
      ;;
  esac
}
