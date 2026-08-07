_sanitize_engine_name() {
  echo "$1" | tr '-' '_' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_]//g'
}

_get_model_var_name() {
  local engine="$1"
  local clean_name
  clean_name=$(echo "$engine" | tr '-' '_' | tr '[:lower:]' '[:upper:]' | sed 's/[^A-Z0-9_]//g')
  echo "ASSISTANT_MODEL_${clean_name}"
}

_get_model_for_engine() {
  local engine="${1:-}"
  _load_config
  if [[ -z "$engine" ]]; then
    engine="$ASSISTANT_ENGINE"
  fi

  local var_name
  var_name=$(_get_model_var_name "$engine")
  local val
  eval "val=\"\${${var_name}:-}\""

  if [[ -z "$val" ]]; then
    local func_name="_engine_$(_sanitize_engine_name "$engine")_default_model"
    if command -v "$func_name" &>/dev/null; then
      val=$("$func_name")
    elif [[ "$engine" == "ollama" ]]; then
      val="${ASSISTANT_DEFAULT_MODEL_OLLAMA:-gemma4:e2b}"
    elif [[ "$engine" == "opencode" ]]; then
      val="${ASSISTANT_DEFAULT_MODEL_OPENCODE:-}"
    fi
  fi

  echo "$val"
}

_get_model() { _get_model_for_engine; }

_get_engine() {
  _load_config
  echo "$ASSISTANT_ENGINE"
}

_load_config() {
  ASSISTANT_ENGINE="$ASSISTANT_DEFAULT_ENGINE"
  ASSISTANT_MODEL_OLLAMA_THINK_FLAG=""
  ASSISTANT_LANG="$ASSISTANT_DEFAULT_LANG"
  ASSISTANT_CHANNEL="${ASSISTANT_CHANNEL:-}"
  ASSISTANT_MODEL=""

  if [[ -f "$ASSISTANT_CONFIG_FILE" ]]; then
    source "$ASSISTANT_CONFIG_FILE"
  fi

  # Legacy fallback for old config format using ASSISTANT_MODEL
  if [[ -n "${ASSISTANT_MODEL:-}" ]]; then
    local legacy_var
    legacy_var=$(_get_model_var_name "$ASSISTANT_ENGINE")
    eval "if [[ -z \"\${${legacy_var}:-}\" ]]; then ${legacy_var}=\"\$ASSISTANT_MODEL\"; fi"
  fi
}

_write_config() {
  mkdir -p "$ASSISTANT_CONFIG_DIR"
  {
    echo "ASSISTANT_ENGINE=\"$ASSISTANT_ENGINE\""
    echo "ASSISTANT_MODEL_OLLAMA_THINK_FLAG=\"$ASSISTANT_MODEL_OLLAMA_THINK_FLAG\""
    echo "ASSISTANT_LANG=\"$ASSISTANT_LANG\""
    echo "ASSISTANT_CHANNEL=\"$ASSISTANT_CHANNEL\""

    local vars=()
    local eng var_name
    if command -v _get_available_engines &>/dev/null; then
      while IFS= read -r eng || [[ -n "$eng" ]]; do
        [[ -n "$eng" ]] && vars+=("$(_get_model_var_name "$eng")")
      done <<< "$(_get_available_engines)"
    fi

    if [[ -f "$ASSISTANT_CONFIG_FILE" ]]; then
      while IFS= read -r line; do
        if [[ "$line" == ASSISTANT_MODEL_* ]]; then
          vars+=("${line%%=*}")
        fi
      done < "$ASSISTANT_CONFIG_FILE"
    fi

    local unique_vars
    unique_vars=$(printf "%s\n" "${vars[@]}" | sort -u)

    local var val
    while IFS= read -r var || [[ -n "$var" ]]; do
      [[ -z "$var" ]] && continue
      eval "val=\"\${${var}:-}\""
      echo "${var}=\"${val}\""
    done <<< "$unique_vars"
  } > "$ASSISTANT_CONFIG_FILE"
}

_set_model() {
  _load_config
  local new_model="$1"
  local engine="${2:-$ASSISTANT_ENGINE}"
  local var_name
  var_name=$(_get_model_var_name "$engine")
  eval "${var_name}=\"\$new_model\""
  _write_config
}

_set_engine() {
  _load_config
  ASSISTANT_ENGINE="$1"
  _write_config
}

_save_think_flag() {
  _load_config
  ASSISTANT_MODEL_OLLAMA_THINK_FLAG="$1"
  _write_config
}

_set_lang() {
  _load_config
  ASSISTANT_LANG="$1"
  _write_config
}

_set_channel() {
  _load_config
  ASSISTANT_CHANNEL="$1"
  _write_config
}

_get_configured_channel() {
  _load_config
  if [[ -n "${ASSISTANT_CHANNEL:-}" ]]; then
    echo "$ASSISTANT_CHANNEL"
    return 0
  fi

  local current_version
  current_version="$(_get_assistant_version 2>/dev/null || true)"
  case "$current_version" in
    *-beta*|*-alpha*|*-rc*|*-dev*)
      echo "beta"
      ;;
    *)
      echo "stable"
      ;;
  esac
}
