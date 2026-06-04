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
