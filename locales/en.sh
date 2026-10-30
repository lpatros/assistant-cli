# Engine commands
t_engine_changed() {
  _success "Engine changed to: ${BOLD}$1${RESET}"
}

t_engine_usage() {
  _error "Usage: assistant engine [<engine>|--list|status]"
}

t_engine_status() {
  _info "Current engine: ${MAGENTA}${BOLD}$1${RESET}"
  _info "Current model: ${GREEN}${BOLD}$2${RESET}"
}

t_engine_not_installed_warning() {
  _warn "The engine '${BOLD}$1${RESET}' was not found in your system's PATH."
  _info "It is highly recommended to install the ${BOLD}$1${RESET} CLI or fix your PATH environment variable for the assistant to work properly."
}

t_engine_not_installed_prompt() {
  echo -n "Do you really want to continue with execution? [y/N]: "
}

t_engine_not_installed_aborted() {
  _warn "Operation cancelled. Please install ${BOLD}$1${RESET} or fix your system PATH variable."
}

t_model_status_detailed() {
  _info "Current engine: ${MAGENTA}${BOLD}$1${RESET}"
  _info "Current model: ${GREEN}${BOLD}$2${RESET}"
}

t_models_available_header() {
  _header "Available models — engine: $1"
}

t_no_models_found() {
  _error "No models found for engine '$1'. Is the CLI installed and configured?"
}

t_engine_no_model_listing() {
  _info "Engine '$1' does not support model listing."
  echo -e "  Use ${BOLD}assistant model set <model>${RESET} to set the model manually."
}

t_menu_switch_engine() {
  echo "[ Switch engine ]"
}

t_menu_cancel() {
  echo "Cancel"
}

t_current_model_label() {
  echo -e "  Current model: ${GREEN}${BOLD}$1${RESET}\n"
}

t_choose_model_prompt() {
  echo "  Choose a model: "
}

t_choose_engine_prompt() {
  echo "  Enter number to select: "
}

t_cancelled() {
  _warn "Cancelled."
}

t_model_changed() {
  _success "Model changed to: ${BOLD}$1${RESET}"
}

t_invalid_option() {
  _warn "Invalid option. Please try again."
}

t_invalid_option_simple() {
  _warn "Invalid option."
}

t_engines_configured_header() {
  _info "${BOLD}Installed engines:${RESET}"
}

t_engines_not_installed_header() {
  _info "${BOLD}Not installed engines:${RESET}"
}

t_no_engines_configured() {
  echo -e "  ${DIM}(no installed engines)${RESET}"
}

t_no_engines_uninstalled() {
  echo -e "  ${DIM}(none)${RESET}"
}

t_use_model_list_to_choose() {
  _info "Use ${CYAN}assistant model --list${RESET} or ${CYAN}assistant model set <model>${RESET} to choose a model."
}

t_current_engine_label() {
  echo -e "  Current engine: ${MAGENTA}${BOLD}$1${RESET}\n"
}

t_model_usage() {
  _error "Usage: assistant model --list|set <model>|status"
}

t_model_set_usage() {
  _error "Usage: assistant model set <model>"
}

# Think commands
t_think_enabled() {
  _success "Think mode enabled and saved."
}

t_think_disabled() {
  _success "Think mode disabled and saved."
}

t_think_hidden() {
  _success "Think mode set to hidden and saved."
}

t_think_cleared() {
  _success "Think mode cleared — using model default."
}

t_think_status_default() {
  _info "Think mode: ${DIM}model default (no flag saved)${RESET}"
}

t_think_status_current() {
  _info "Ollama think mode current: ${YELLOW}${BOLD}$1${RESET}"
}

t_think_usage() {
  _error "Usage: assistant think [on|off|hide|clear|status]"
}

# General / LLM / Helpers
t_engine_display() {
  _info "Engine: ${MAGENTA}${BOLD}$1${RESET}"
}

t_model_display() {
  _info "Model: ${GREEN}${BOLD}$1${RESET}"
}

t_think_mode_display() {
  _info "Think mode: ${YELLOW}$1${RESET}"
}

t_think_flag_display() {
  _info "Think flag: ${YELLOW}$1${RESET}"
}

t_default_engine_model() {
  echo "engine default"
}

t_convention_file_not_found() {
  _warn "Convention file not found at: $1" >&2
}

t_continuing_without_guidelines() {
  _warn "Continuing without convention guide..." >&2
}

# Lang commands
t_lang_changed() {
  _success "Language changed to: ${BOLD}$1${RESET}"
}

t_lang_usage() {
  _error "Usage: assistant lang [<language>|--list|status]"
}

t_lang_status() {
  _info "Current language: ${CYAN}${BOLD}$1${RESET}"
}

t_lang_not_found() {
  _error "Locale '$1' not found in locales/ or custom/locales/."
}

t_lang_list_header() {
  _header "Available languages:"
}

# Commit skill
t_commit_not_git_repo() {
  _error "Not inside a Git repository."
}

t_git_not_installed() {
  _error "git is not installed. Please install git first."
}

t_commit_analyzing() {
  _header "Analyzing repository with $1 ($2)..."
}

t_commit_no_staged_files() {
  echo "(no files in staging)"
}

t_commit_no_unstaged_files() {
  echo "(no unstaged files)"
}

t_commit_prompt_instructions() {
  echo "Analyze the changes above and suggest commits following the provided guidelines."
}

# Branch skill
t_branch_analyzing() {
  _header "Analyzing branch separation with $1 ($2)..."
}

t_branch_no_branches() {
  echo "(no local branches)"
}

t_branch_prompt_instructions() {
  echo "Analyze the changes above and propose a multi-branch separation plan strictly following the provided guidelines: identify every distinct scope, suggest one dedicated branch per scope with its atomic commits, Conventional Commit messages, and the exact safe Git commands. Display the commands only for the user to review and run manually; never execute any Git command."
}

# Resume skill
t_resume_analyzing() {
  _info "Analyzing project ${BOLD}$1${RESET}..."
}

t_resume_prompt_instructions() {
  echo "Analyze the project above and generate the resume file strictly following the provided guidelines. Return ONLY the raw Markdown for this project. The caller saves your response to its output file; do not create files or include confirmations or outer code fences."
}

t_resume_failed() {
  _error "Failed to generate resume for ${BOLD}$1${RESET}"
}

t_resume_project_dir_not_found() {
  _error "Project directory not found: $1"
}

t_resume_success() {
  _success "Resume generated for ${BOLD}$1${RESET} in ${GREEN}$2${RESET}"
}

t_resume_starting() {
  _header "Starting analysis with $1 ($2)..."
}

t_resume_parallel_info() {
  _info "Analyzing $1 projects in parallel..."
}

t_resume_parallel_done() {
  _success "Parallel analysis completed."
}

# Readme skill
t_readme_missing_args() {
  _warn "Please provide both parameters to continue:

- --lang — the language for the README content (e.g., en, pt-br, es, fr)
- --name — the output filename without extension (e.g., README, README-PTBR)

Example: assistant readme --lang en --name README"
}

t_readme_analyzing() {
  _header "Analyzing project with $1 ($2)..."
}

t_readme_prompt_instructions() {
  echo "Analyze the project above and generate the README file strictly following the provided guidelines. The output language MUST be: $1. IMPORTANT: Output ONLY the raw Markdown content for the README. Do NOT include any conversational text, confirmations, or markdown codeblocks formatting (\`\`\`markdown) wrapping the response."
}

t_readme_failed() {
  _error "Failed to generate README."
}

t_readme_success() {
  _success "$1 generated in $2."
}

# Version command
t_version() {
  _info "Assistant CLI v$1"
}

t_version_unknown() {
  echo "unknown"
}

# Update check (automatic)
t_update_available() {
  _info "New version available: v$1 (current: v$2)."
  _info "Run ${CYAN}assistant update${RESET} to upgrade."
}

# Update command
t_update_starting() {
  _header "Updating the assistant..."
}

t_update_success() {
  _success "Assistant updated successfully!"
}

t_update_already_up_to_date() {
  _info "You are on the latest version."
}

t_update_failed() {
  _error "Failed to update the assistant."
}

t_update_conflict_warning() {
  _warn "Conflict detected while updating the assistant."
  _info "Please check if you made any local changes that might be causing a conflict."
  _info "If you haven't changed anything, it should be safe to force the update."
}

t_update_conflict_prompt() {
  echo -n "Do you want to force the update? [y/N]: "
}

t_update_changelog_prompt() {
  echo -n "Would you like to view the changelog? [y/N]: "
}

t_update_aborted() {
  _warn "Update cancelled."
}

t_update_list_header() {
  _header "Available versions:"
}

t_update_list_tip() {
  _info "Use ${CYAN}assistant update @<version>${RESET} or ${CYAN}assistant update --version <version>${RESET} to change version."
}

t_update_version_starting() {
  _header "Updating assistant to version v$1..."
}

t_update_version_success() {
  _success "Assistant successfully changed to version v$1!"
}

t_update_version_not_found() {
  _error "Version '$1' not found. Use ${CYAN}assistant update --list${RESET} to view available versions."
}

t_update_already_on_version() {
  _info "You are already on version v$1."
}

t_update_usage() {
  _error "Usage: assistant update [@<version>|--version <version>|--list]"
}

t_update_returning_to_channel() {
  _info "Leaving specific version and returning to ${CYAN}${BOLD}$1${RESET} channel..."
}

t_changelog_not_found() {
  _warn "$1 file not found."
}

t_changelog_web_link() {
  _info "View release on GitHub: ${CYAN}$1${RESET}"
}

t_changelog_opening_web() {
  _info "Opening changelog in browser: ${CYAN}$1${RESET}"
}

t_changelog_usage() {
  _error "Usage: assistant changelog [--web|-w|--terminal|-t]"
}

t_unknown_command() {
  _error "Command '$1' does not exist."
  echo -e "Try ${GREEN}assistant --help${RESET} to see the list of commands."
}

t_message_needs_quotes() {
  _error "Message must be enclosed in quotes."
  echo -e "Example: ${GREEN}assistant \"your message here\"${RESET}"
}

t_create_skill_usage() {
  _error "Usage: assistant create skill [skill-name] [path-to-md-file]"
}

t_create_skill_success() {
  _success "Custom skill '${BOLD}$1${RESET}' successfully created!"
  _info "Markdown saved to: $2"
  _info "You can now run it using: ${GREEN}assistant $1${RESET}"
}

t_custom_skill_not_found() {
  _error "Custom skill not found: $1"
}

t_create_skill_invalid_name() {
  _error "Invalid skill name. Use lowercase letters, digits, underscores or hyphens, starting with a letter or digit."
}

t_create_skill_md_not_found() {
  _error "Skill markdown file not found: $1"
}

t_create_skill_warning_default_override() {
  _warn "The skill '${BOLD}$1${RESET}' is a default assistant skill."
}

t_create_skill_prompt_override() {
  echo -n "Do you really want to overwrite it? [y/N]: "
}

t_create_skill_aborted() {
  _warn "Operation aborted. The skill was not created."
}

# Custom commands
t_custom_engines_status_header() {
  _header "Custom Adapters:"
}

t_no_custom_engines_found() {
  echo -e "  ${DIM}(no custom adapters found)${RESET}"
}

t_custom_skills_status_header() {
  _header "Custom Skills:"
}

t_no_custom_skills_found() {
  echo -e "  ${DIM}(no custom skills found)${RESET}"
}

t_custom_locales_status_header() {
  _header "Custom Locales:"
}

t_no_custom_locales_found() {
  echo -e "  ${DIM}(no custom locales found)${RESET}"
}

t_custom_status_header() {
  _header "Custom Component Status:"
}

t_custom_usage() {
  _error "Usage: assistant custom [adapters|skills|locales|status] [status]"
}

t_custom_engines_usage() {
  _error "Usage: assistant custom adapters [status]"
}

t_custom_skills_usage() {
  _error "Usage: assistant custom skills [status]"
}

t_custom_locales_usage() {
  _error "Usage: assistant custom locales [status]"
}

# Channel commands
t_channel_status() {
  _info "Current release channel: ${CYAN}${BOLD}$1${RESET}"
}

t_channel_switching() {
  _info "Switching to release channel: ${CYAN}${BOLD}$1${RESET}..."
}

t_channel_already_active() {
  _info "You are already on channel: ${CYAN}${BOLD}$1${RESET}."
  _info "Checking for latest updates..."
}

t_channel_switch_failed() {
  _error "Failed to switch to channel '$1'."
  if [[ -n "$2" ]]; then
    echo -e "${RED}$2${RESET}"
  fi
}

t_channel_usage() {
  _error "Usage: assistant channel [stable|beta|status]"
}

t_help_output() {
  echo -e "
${BOLD}${BLUE}assistant${RESET} — CLI wrapper for LLMs and modular engines

${BOLD}Usage:${RESET}
  ${GREEN}assistant${RESET}                                     Interactive chat with current model
  ${GREEN}assistant${RESET} \"<message>\"                         Send a direct message
  ${GREEN}assistant status${RESET}                              Show engine, models, think mode, and language
  ${GREEN}assistant custom${RESET} [adapters|skills|locales|status] Show identified custom components
  ${GREEN}assistant channel${RESET} [<stable|beta|status>]      Manage release channel (stable/beta)
  ${GREEN}assistant changelog${RESET} [--terminal|-t]           View changelog in browser (or terminal with -t)
  ${GREEN}assistant update${RESET} [@<ver>|--version <ver>|--list] Update assistant to latest or specific version
  ${GREEN}assistant --version${RESET}                           Show current assistant version
  ${GREEN}assistant commit${RESET}                              Analyze git repo and suggest commits
  ${GREEN}assistant branch${RESET}                              Analyze git changes and suggest separate branches
  ${GREEN}assistant resume${RESET} [paths...]                   Generate project resumes in markdown
  ${GREEN}assistant readme${RESET} --lang <code> --name <name>  Generate project README file
  ${GREEN}assistant skills list${RESET}                          List skills, origins, and conflicts
  ${GREEN}assistant create skill${RESET} <name> <path.md>       Create a new custom skill
  ${GREEN}assistant <custom-skill>${RESET} [arguments]          Execute a custom skill
  ${GREEN}assistant model${RESET} [--list|set <model>|status]   Manage models for the active engine
  ${GREEN}assistant harness${RESET} [<name>|--list|status]   Manage harnesses (engine is a compatible alias)
  ${GREEN}assistant harness capabilities${RESET} [name]       Show supported operations
  ${GREEN}assistant skills install|verify|remove${RESET} <name>  Install, verify or remove a Codex skill; requires --scope
  ${GREEN}assistant engine${RESET} [<engine>|--list|status]     Switch the active engine
  ${GREEN}assistant engine status${RESET}                       Show current engine and active model
  ${GREEN}assistant think${RESET} [on|off|hide|clear|status]    Manage think mode (ollama)
  ${GREEN}assistant lang${RESET} [<lang>|--list|status]         Manage assistant language

${BOLD}Notes:${RESET}
  - Create custom adapters in custom/adapters/<name>/init.sh.
  - Models are saved per engine; switching engines does not lose previous model selections.

${BOLD}Thinking flags — Ollama only (per session or persistent):${RESET}
  ${YELLOW}--think${RESET}                           Enable thinking mode (and save)
  ${YELLOW}--no-think${RESET}                        Disable thinking mode (and save)
  ${YELLOW}--hide-think${RESET}                      Hide thinking (and save)

${BOLD}Examples:${RESET}
  assistant \"Explain what a closure is in JS\"
  assistant commit
  assistant branch
  assistant custom status
  assistant custom adapters status
  assistant channel beta
  assistant engine agy
  assistant engine opencode
  assistant engine ollama
  assistant engine --list
  assistant engine status
  assistant status
"
}

# Skill discovery
t_skills_usage() { _error "Usage: assistant skills [list|install|verify|remove]"; }
t_skills_header() { printf 'Name\tOrigin\tFormat\tState\tPath\tDescription\n'; }
t_skill_error() { _error "Invalid skill: $1 ($2)."; }
t_skill_origin() {
  case "$1" in
    builtin) printf '%s' 'built-in' ;;
    custom) printf '%s' 'custom' ;;
  esac
}
t_skill_state() {
  case "$1" in
    ready) printf '%s' 'ready' ;;
    overridden) printf '%s' 'overridden' ;;
    invalid) printf '%s' 'invalid metadata or folder name' ;;
    reserved) printf '%s' 'reserved command name' ;;
    conflict) printf '%s' 'duplicate name' ;;
  esac
}

# Harness capabilities and native skills
t_harness_usage() { _error "Usage: assistant harness [<name>|--list|status|capabilities [name]]"; }
t_harness_unknown() { _error "Unknown harness: $1."; }
t_harness_unsupported() { _error "Harness $1 does not support $2."; }
t_harness_status() { _info "Harness: $1 | Model: $2"; }
t_harness_failed() { _error "Harness $1 failed (exit $2)."; }
t_harness_empty() { _error "Harness $1 returned no final response."; }
t_harness_dependency() { _error "Harness $1 requires $2 for this operation."; }
t_native_usage() { _error "Usage: assistant skills <install|verify|remove> <name> --harness codex --scope <project|user> [--project <directory>] [--dry-run]"; }
t_native_error() { _error "Skill operation failed: $1 ($2)."; }
t_harness_capabilities_header() { printf 'Harness\tPrompt\tInteractive\tProject tools\tModel list\tFinal response\tNative install\n'; }
t_harness_capability_value() {
  case "$1" in
    yes) printf '%s' 'yes' ;;
    no) printf '%s' 'no' ;;
    unknown) printf '%s' 'unknown' ;;
  esac
}
t_native_reason() {
  case "$1" in
    checksum) printf '%s' 'SHA-256 requires sha256sum or shasum' ;;
    symlink) printf '%s' 'symbolic links are not allowed in the managed destination' ;;
    unmanaged) printf '%s' 'missing or invalid installation record' ;;
    edited) printf '%s' 'installed content or provenance has been edited' ;;
    invalid) printf '%s' 'invalid skill or path' ;;
    extra) printf '%s' 'destination contains additional files' ;;
    conflict) printf '%s' 'destination or skill name already exists' ;;
    failed) printf '%s' 'file operation failed; inspect the destination' ;;
    unsupported) printf '%s' 'native installation is unavailable for this harness' ;;
    reserved) printf '%s' 'administrative command name is reserved' ;;
  esac
}
t_native_action() {
  case "$1" in
    install) printf '%s' 'install' ;;
    verify) printf '%s' 'verify' ;;
    remove) printf '%s' 'remove' ;;
  esac
}
t_native_plan() {
  printf 'Preview: %s\nDestination: %s\nSource: %s\nVersion: %s\nSHA-256: %s\nFiles: SKILL.md, .assistant-install.tsv, .assistant-install.sha256\n' "$(t_native_action "$1")" "$2" "$3" "$4" "$5"
}
t_native_done() { _success "$(t_native_action "$1"): $2"; }
