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
  echo "  Choose the engine: "
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

t_choose_engine_header() {
  _header "Choose the engine"
}

t_use_model_list_to_choose() {
  _info "Use ${CYAN}assistant model --list${RESET} to choose a model for this engine."
}

t_current_engine_label() {
  echo -e "  Current engine: ${MAGENTA}${BOLD}$1${RESET}\n"
}

t_model_usage() {
  _error "Usage: assistant model --list|status"
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

# Resume skill
t_resume_analyzing() {
  _info "Analyzing project ${BOLD}$1${RESET}..."
}

t_resume_prompt_instructions() {
  echo "Analyze the project above and generate the resume file strictly following the provided guidelines."
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

# Update command
t_update_starting() {
  _header "Updating the assistant..."
}

t_update_success() {
  _success "Assistant updated successfully!"
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

t_changelog_not_found() {
  _warn "CHANGELOG.md file not found at: $1"
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
  _error "Invalid skill name. Use only alphanumeric characters, underscores, or hyphens."
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

t_help_output() {
  echo -e "
${BOLD}${BLUE}assistant${RESET} — CLI wrapper for LLMs and modular engines (Ollama, OpenCode, Antigravity (AGY), and custom)

${BOLD}Usage:${RESET}
  ${GREEN}assistant${RESET}                                  Interactive chat with current model
  ${GREEN}assistant${RESET} \"<message>\"                    Send a direct message
  ${GREEN}assistant status${RESET}                           Show engine, models, think mode, and language
  ${GREEN}assistant update${RESET}                           Update the assistant to the latest version
  ${GREEN}assistant --version${RESET}                        Show current assistant version
  ${GREEN}assistant commit${RESET}                           Analyze git repo and suggest commits
  ${GREEN}assistant resume${RESET} [paths...]                 Generate project resumes in markdown
  ${GREEN}assistant readme${RESET} --lang <code> --name <name>  Generate project README file
  ${GREEN}assistant create skill${RESET} <name> <path.md>     Create a new custom skill
  ${GREEN}assistant <custom-skill>${RESET} [arguments]        Execute a custom skill
  ${GREEN}assistant model --list${RESET}                     List models and allow switching
  ${GREEN}assistant model status${RESET}                     Show current engine's model and saved models
  ${GREEN}assistant engine${RESET} [<engine>|--list|status]  Switch the active engine
  ${GREEN}assistant engine status${RESET}                    Show current engine and active model
  ${GREEN}assistant think${RESET} [on|off|hide|clear|status] Manage think mode (ollama)
  ${GREEN}assistant lang${RESET} [en|pt-br|es|status]       Manage assistant language

${BOLD}Notes:${RESET}
  - Built-in engines: ollama, opencode, agy.
  - Create custom engines in custom/engines/<name>.sh.
  - Models are saved per engine; switching engines does not lose previous model selections.

${BOLD}Thinking flags — Ollama only (per session or persistent):${RESET}
  ${YELLOW}--think${RESET}                           Enable thinking mode (and save)
  ${YELLOW}--no-think${RESET}                        Disable thinking mode (and save)
  ${YELLOW}--hide-think${RESET}                      Hide thinking (and save)

${BOLD}Examples:${RESET}
  assistant \"Explain what a closure is in JS\"
  assistant commit
  assistant engine agy
  assistant engine opencode
  assistant engine ollama
  assistant engine --list
  assistant engine status
  assistant status
"
}
