_get_model_for_engine() {
  local engine="${1:-}"
  _load_config
  if [[ -z "$engine" ]]; then
    engine="$ASSISTANT_ENGINE"
  fi

  if [[ "$engine" == "opencode" ]]; then
    echo "$ASSISTANT_MODEL_OPENCODE"
    return 0
  fi

  echo "$ASSISTANT_MODEL_OLLAMA"
}

_get_model() { _get_model_for_engine; }

_get_engine() {
  _load_config
  echo "$ASSISTANT_ENGINE"
}

_load_config() {
  ASSISTANT_MODEL_OLLAMA=""
  ASSISTANT_MODEL_OPENCODE=""
  ASSISTANT_ENGINE="$ASSISTANT_DEFAULT_ENGINE"
  ASSISTANT_THINK_FLAG=""
  ASSISTANT_LANG="$ASSISTANT_DEFAULT_LANG"
  ASSISTANT_MODEL=""

  if [[ -f "$ASSISTANT_CONFIG_FILE" ]]; then
    source "$ASSISTANT_CONFIG_FILE"
  fi

  if [[ -n "${ASSISTANT_MODEL:-}" && -z "$ASSISTANT_MODEL_OLLAMA" && -z "$ASSISTANT_MODEL_OPENCODE" && "$ASSISTANT_ENGINE" == "opencode" ]]; then
    ASSISTANT_MODEL_OPENCODE="$ASSISTANT_MODEL"
  fi

  if [[ -n "${ASSISTANT_MODEL:-}" && -z "$ASSISTANT_MODEL_OLLAMA" && -z "$ASSISTANT_MODEL_OPENCODE" && "$ASSISTANT_ENGINE" != "opencode" ]]; then
    ASSISTANT_MODEL_OLLAMA="$ASSISTANT_MODEL"
  fi

  if [[ -z "$ASSISTANT_MODEL_OLLAMA" ]]; then
    ASSISTANT_MODEL_OLLAMA="$ASSISTANT_DEFAULT_MODEL_OLLAMA"
  fi
  
  if [[ -z "$ASSISTANT_MODEL_OPENCODE" ]]; then
    ASSISTANT_MODEL_OPENCODE="$ASSISTANT_DEFAULT_MODEL_OPENCODE"
  fi
}

_write_config() {
  mkdir -p "$ASSISTANT_CONFIG_DIR"
  {
    echo "ASSISTANT_MODEL_OLLAMA=\"$ASSISTANT_MODEL_OLLAMA\""
    echo "ASSISTANT_MODEL_OPENCODE=\"$ASSISTANT_MODEL_OPENCODE\""
    echo "ASSISTANT_ENGINE=\"$ASSISTANT_ENGINE\""
    echo "ASSISTANT_THINK_FLAG=\"$ASSISTANT_THINK_FLAG\""
    echo "ASSISTANT_LANG=\"$ASSISTANT_LANG\""
  } > "$ASSISTANT_CONFIG_FILE"
}

_set_model() {
  _load_config
  local new_model="$1"
  local engine="${2:-$ASSISTANT_ENGINE}"

  if [[ "$engine" == "opencode" ]]; then
    ASSISTANT_MODEL_OPENCODE="$new_model"
  else
    ASSISTANT_MODEL_OLLAMA="$new_model"
  fi
  _write_config
}

_set_engine() {
  _load_config
  ASSISTANT_ENGINE="$1"
  _write_config
}

_save_think_flag() {
  _load_config
  ASSISTANT_THINK_FLAG="$1"
  _write_config
}

_set_lang() {
  _load_config
  ASSISTANT_LANG="$1"
  _write_config
}
