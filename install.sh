set -e

REPO_URL="https://github.com/lpatros/assistant-cli.git"

get_default_install_dir() {
  local os_name="$(uname -s)"
  case "$os_name" in
    CYGWIN*|MINGW*|MSYS*)
      echo "$HOME/AppData/Local/assistant-cli"
      ;;
    *)
      echo "$HOME/.config/assistant-cli"
      ;;
  esac
}

INSTALL_DIR="$(get_default_install_dir)"

BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

info()    { printf "${CYAN}  %s${RESET}\n" "$1"; }
success() { printf "${GREEN} %s${RESET}\n" "$1"; }
warn()    { printf "${YELLOW}  %s${RESET}\n" "$1"; }
error()   { printf "${RED} %s${RESET}\n" "$1"; }

prompt_read() {
  local var_name="$1"
  if [ -c /dev/tty ]; then
    read -r "$var_name" </dev/tty || true
  else
    read -r "$var_name" || true
  fi
}

detect_shell() {
  case "$SHELL" in
    */zsh)  echo "zsh"  ;;
    */bash) echo "bash" ;;
    */fish) echo "fish" ;;
    *)      echo "unknown" ;;
  esac
}

get_rc_file() {
  case "$1" in
    zsh)  echo "$HOME/.zshrc" ;;
    bash) echo "$HOME/.bashrc" ;;
    fish) echo "$HOME/.config/fish/config.fish" ;;
  esac
}

shell_label() {
  case "$1" in
    zsh)  echo "zsh   (~/.zshrc)" ;;
    bash) echo "bash  (~/.bashrc)" ;;
    fish) echo "fish  (~/.config/fish/config.fish)" ;;
  esac
}

echo ""
printf "${BOLD}${CYAN}"
echo "  ┌──────────────────────────────────────┐"
echo "  │       @ Assistant CLI Installer      │"
echo "  └──────────────────────────────────────┘"
printf "${RESET}\n"

echo ""
printf "  Use default installation path (${BOLD}%s${RESET})? [Y/n]: " "$INSTALL_DIR"
prompt_read USE_DEFAULT_DIR

case "$USE_DEFAULT_DIR" in
  [nN]|[nN][oO])
    printf "  Enter custom installation path: "
    prompt_read CUSTOM_DIR
    if [ -n "$CUSTOM_DIR" ]; then
      INSTALL_DIR="${CUSTOM_DIR/#\~/$HOME}"
    fi
    ;;
esac

printf "  -> Installing to: ${BOLD}%s${RESET}\n\n" "$INSTALL_DIR"

if ! command -v git >/dev/null 2>&1; then
  error "git is not installed. Please install git first."
  exit 1
fi

DETECTED_SHELL=$(detect_shell)

echo ""
if [ "$DETECTED_SHELL" != "unknown" ]; then
  printf "  Detected shell: ${BOLD}%s${RESET}\n" "$DETECTED_SHELL"
else
  warn "Could not auto-detect your shell."
fi

echo ""
echo "  Which shell config should be modified?"
echo ""
printf "    ${BOLD}1)${RESET} zsh   ${DIM}(~/.zshrc)${RESET}\n"
printf "    ${BOLD}2)${RESET} bash  ${DIM}(~/.bashrc)${RESET}\n"
printf "    ${BOLD}3)${RESET} fish  ${DIM}(~/.config/fish/config.fish)${RESET}\n"
printf "    ${BOLD}4)${RESET} None  ${DIM}(I'll configure manually)${RESET}\n"
echo ""

if [ "$DETECTED_SHELL" != "unknown" ]; then
  PROMPT_DEFAULT="auto-detect: $DETECTED_SHELL"
else
  PROMPT_DEFAULT="no default"
fi

printf "  Choice [1-4, default: %s]: " "$PROMPT_DEFAULT"
prompt_read CHOICE

case "$CHOICE" in
  1) SHELL_NAME="zsh"  ;;
  2) SHELL_NAME="bash" ;;
  3) SHELL_NAME="fish" ;;
  4) SHELL_NAME="none" ;;
  "")
    if [ "$DETECTED_SHELL" != "unknown" ]; then
      SHELL_NAME="$DETECTED_SHELL"
    else
      error "No shell selected and auto-detection failed. Exiting."
      exit 1
    fi
    ;;
  *)
    error "Invalid choice: '$CHOICE'. Exiting."
    exit 1
    ;;
esac

if [ "$SHELL_NAME" != "none" ]; then
  printf "\n  Using shell: ${BOLD}%s${RESET}\n" "$(shell_label "$SHELL_NAME")"
fi

echo ""
if [ -d "$INSTALL_DIR/.git" ]; then
  info "Installation directory already exists: $INSTALL_DIR"
  printf "  Do you want to update it? [y/N]: "
  prompt_read UPDATE_CHOICE

  case "$UPDATE_CHOICE" in
    [yY]|[yY][eE][sS])
      info "Updating existing installation..."
      git -C "$INSTALL_DIR" pull --ff-only
      success "Updated successfully."
      ;;
    *)
      info "Skipping clone — using existing installation."
      ;;
  esac
elif [ -d "$INSTALL_DIR" ]; then
  warn "Directory $INSTALL_DIR exists but is not a git repository."
  printf "  Do you want to remove it and reinstall? [y/N]: "
  prompt_read REINSTALL_CHOICE

  case "$REINSTALL_CHOICE" in
    [yY]|[yY][eE][sS])
      rm -rf "$INSTALL_DIR"
      info "Cloning repository..."
      git clone "$REPO_URL" "$INSTALL_DIR"
      success "Cloned to $INSTALL_DIR"
      ;;
    *)
      info "Keeping existing directory. Proceeding with configuration..."
      ;;
  esac
else
  info "Cloning repository..."
  mkdir -p "$(dirname "$INSTALL_DIR")"
  git clone "$REPO_URL" "$INSTALL_DIR"
  success "Cloned to $INSTALL_DIR"
fi

echo ""

if [ "$SHELL_NAME" = "none" ]; then
  echo ""
  info "Skipping shell configuration."
  echo ""
  printf "  To configure manually, add this to your shell config:\n\n"
  printf "    ${BOLD}source \"%s/init.sh\"${RESET}\n\n" "$INSTALL_DIR"
else
  RC_FILE=$(get_rc_file "$SHELL_NAME")

  if [ "$SHELL_NAME" = "fish" ]; then
    SOURCE_LINE="source \"$INSTALL_DIR/init.sh\""
    GREP_PATTERN="^[^#]*$INSTALL_DIR/init\.sh"

    mkdir -p "$(dirname "$RC_FILE")"

    if [ -f "$RC_FILE" ] && grep -q "$GREP_PATTERN" "$RC_FILE"; then
      info "Already configured in $RC_FILE"
    else
      {
        echo ""
        echo "# Assistant CLI"
        echo "$SOURCE_LINE"
      } >> "$RC_FILE"
      success "Added to $RC_FILE"
      warn "Fish shell compatibility depends on init.sh being POSIX-friendly."
      echo "  If you encounter issues, you may need a dedicated init.fish wrapper."
    fi
  else
    SOURCE_LINE="source \"$INSTALL_DIR/init.sh\""
    GREP_PATTERN="^[^#]*$INSTALL_DIR/init\.sh"

    if [ -f "$RC_FILE" ] && grep -q "$GREP_PATTERN" "$RC_FILE"; then
      info "Already configured in $RC_FILE"
    else
      {
        echo ""
        echo "# Assistant CLI"
        echo "$SOURCE_LINE"
      } >> "$RC_FILE"
      success "Added to $RC_FILE"
    fi
  fi
fi

echo ""
printf "${BOLD}${GREEN}"
echo "  ┌──────────────────────────────────────┐"
echo "  │    @ Installation complete!          │"
echo "  └──────────────────────────────────────┘"
printf "${RESET}\n"

if [ "$SHELL_NAME" != "none" ]; then
  RC_FILE=$(get_rc_file "$SHELL_NAME")
  printf "  Restart your shell or run:\n\n"
  printf "    ${BOLD}source %s${RESET}\n\n" "$RC_FILE"
fi

printf "  Then try: ${BOLD}assistant --help${RESET}\n\n"
