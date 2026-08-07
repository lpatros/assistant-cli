_is_installed() {
  local cmd="${1:-}"
  [[ -n "$cmd" ]] && command -v "$cmd" &>/dev/null
}

_info()    { echo -e "${CYAN}ℹ${RESET}  $*"; }
_success() { echo -e "${GREEN}✓${RESET}  $*"; }
_warn()    { echo -e "${YELLOW}⚠${RESET}  $*"; }
_error()   { echo -e "${RED}✗${RESET}  $*"; }
_header()  { echo -e "\n${BOLD}${BLUE}$*${RESET}\n"; }

_model_display() {
  if [[ -z "$1" ]]; then
    t_default_engine_model
    return 0
  fi
  echo "$1"
}

_read_guidelines() {
  local filepath="$1"
  if [[ ! -f "$filepath" ]]; then
    t_convention_file_not_found "$filepath"
    t_continuing_without_guidelines
    echo ""
    return 0
  fi
  cat "$filepath"
}

_get_skill_md_path() {
  echo "$ASSISTANT_ROOT_DIR/skills/$1/$1-assistant.md"
}

_get_changelog_file() {
  local channel=""
  if command -v "_get_current_channel" &>/dev/null; then
    channel="$(_get_current_channel)"
  fi

  if [[ "$channel" == "beta" ]]; then
    if [[ -f "$ASSISTANT_ROOT_DIR/CHANGELOG-beta.md" ]]; then
      echo "$ASSISTANT_ROOT_DIR/CHANGELOG-beta.md"
      return 0
    fi
  fi

  if [[ -f "$ASSISTANT_ROOT_DIR/CHANGELOG.md" ]]; then
    echo "$ASSISTANT_ROOT_DIR/CHANGELOG.md"
    return 0
  fi
}

_get_repo_url() {
  local remote_url=""
  if _is_installed "git" && [[ -d "$ASSISTANT_ROOT_DIR/.git" ]]; then
    remote_url="$(git -C "$ASSISTANT_ROOT_DIR" remote get-url origin 2>/dev/null || true)"
  fi
  if [[ -n "$remote_url" ]]; then
    remote_url="$(echo "$remote_url" | sed -E 's|^git@github\.com:|https://github.com/|; s|\.git$||')"
    echo "$remote_url"
  else
    echo "https://github.com/lpatros/assistant-cli"
  fi
}

_get_release_url() {
  local repo_url version tag_url
  repo_url="$(_get_repo_url)"
  if command -v "_get_assistant_version" &>/dev/null; then
    version="$(_get_assistant_version 2>/dev/null || true)"
  fi

  if [[ -n "$version" && "$version" != "unknown" ]]; then
    tag_url="${repo_url}/releases/tag/v${version#v}"
    echo "$tag_url"
  else
    echo "${repo_url}/releases"
  fi
}

_open_url() {
  local url="${1:-}"
  [[ -z "$url" ]] && return 1

  if _is_installed "xdg-open"; then
    ( xdg-open "$url" &>/dev/null & ) &>/dev/null
  elif _is_installed "open"; then
    ( open "$url" &>/dev/null & ) &>/dev/null
  elif _is_installed "wslview"; then
    ( wslview "$url" &>/dev/null & ) &>/dev/null
  elif _is_installed "cmd.exe"; then
    ( cmd.exe /c start "$url" &>/dev/null & ) &>/dev/null
  else
    return 1
  fi
  return 0
}

