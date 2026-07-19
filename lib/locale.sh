_load_locale() {
  _load_config
  local lang="${ASSISTANT_LANG:-$ASSISTANT_DEFAULT_LANG}"
  if [[ "$lang" != "en" && "$lang" != "pt-br" && "$lang" != "es" ]]; then
    lang="$ASSISTANT_DEFAULT_LANG"
  fi

  local locale_file="$ASSISTANT_ROOT_DIR/locales/$lang.sh"
  if [[ -f "$locale_file" ]]; then
    source "$locale_file"
  else
    _error "Locale file not found: $locale_file"
  fi
}

_cmd_lang() {
  local action="${1:-status}"

  case "$action" in
    en)
      _set_lang "en"
      _load_locale
      t_lang_changed "en"
      ;;
    pt-br)
      _set_lang "pt-br"
      _load_locale
      t_lang_changed "pt-br"
      ;;
    es)
      _set_lang "es"
      _load_locale
      t_lang_changed "es"
      ;;
    status|"")
      _load_config
      t_lang_status "${ASSISTANT_LANG:-$ASSISTANT_DEFAULT_LANG}"
      ;;
    *)
      t_lang_usage
      return 1
      ;;
  esac
}
