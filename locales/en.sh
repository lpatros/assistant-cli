# locales/en.sh

# Engine commands
t_engine_changed() {
  _success "Engine changed to: ${BOLD}$1${RESET}"
}

t_engine_usage() {
  _error "Usage: @assistant engine [ollama|opencode|--list|status]"
}

t_engine_status() {
  _info "Current engine: ${MAGENTA}${BOLD}$1${RESET}"
  _info "Current model: ${GREEN}${BOLD}$2${RESET}"
}

t_model_status_detailed() {
  _info "Current engine: ${MAGENTA}${BOLD}$1${RESET}"
  _info "Current model: ${GREEN}${BOLD}$2${RESET}"
  _info "Ollama model: ${GREEN}${BOLD}$3${RESET}"
  _info "OpenCode model: ${GREEN}${BOLD}$4${RESET}"
}

t_models_available_header() {
  _header "Available models — engine: $1"
}

t_no_models_found_ollama() {
  _error "No models found. Is Ollama running?"
}

t_no_models_found_opencode() {
  _error "No models found. Is OpenCode installed and configured?"
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
  _info "Use ${CYAN}@assistant model --list${RESET} to choose a model for this engine."
}

t_current_engine_label() {
  echo -e "  Current engine: ${MAGENTA}${BOLD}$1${RESET}\n"
}

t_model_usage() {
  _error "Usage: @assistant model --list|status"
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
  _info "Think mode current: ${YELLOW}${BOLD}$1${RESET}"
}

t_think_usage() {
  _error "Usage: @assistant think [on|off|hide|clear|status]"
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
  _error "Usage: @assistant lang [en|pt-br|status]"
}

t_lang_status() {
  _info "Current language: ${CYAN}${BOLD}$1${RESET}"
}

# Commit skill
t_commit_not_git_repo() {
  _error "Not inside a Git repository."
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

Example: @assistant readme --lang en --name README"
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


t_help_output() {
  echo -e "
${BOLD}${BLUE}@assistant${RESET} — CLI wrapper for Ollama and OpenCode

${BOLD}Usage:${RESET}
  ${GREEN}@assistant${RESET}                                  Interactive chat with current model
  ${GREEN}@assistant${RESET} \"<message>\"                    Send a direct message
  ${GREEN}@assistant status${RESET}                           Show engine, models, think mode, and language
  ${GREEN}@assistant commit${RESET}                           Analyze git repo and suggest commits
  ${GREEN}@assistant resume${RESET} [paths...]                 Generate project resumes in markdown
  ${GREEN}@assistant readme${RESET} --lang <code> --name <name>  Generate project README file
  ${GREEN}@assistant model --list${RESET}                     List models and allow switching
  ${GREEN}@assistant model status${RESET}                     Show current engine's model and saved models
  ${GREEN}@assistant engine${RESET} [ollama|opencode|--list|status]  Switch the active engine
  ${GREEN}@assistant engine status${RESET}                    Show current engine and active model
  ${GREEN}@assistant think${RESET} [on|off|hide|clear|status] Manage think mode (ollama)
  ${GREEN}@assistant lang${RESET} [en|pt-br|status]          Manage assistant language

${BOLD}Notes:${RESET}
  - Models are saved per engine; switching the engine doesn't lose the previous model.
  - If the opencode model is empty, it uses the default configured in opencode.

${BOLD}Thinking flags — Ollama only (per session or persistent):${RESET}
  ${YELLOW}--think${RESET}                           Enable thinking mode (and save)
  ${YELLOW}--no-think${RESET}                        Disable thinking mode (and save)
  ${YELLOW}--hide-think${RESET}                      Hide thinking (and save)

${BOLD}Examples:${RESET}
  @assistant \"Explain what a closure is in JS\"
  @assistant commit
  @assistant commit --no-think
  @assistant \"Summarize this text\" --think
  @assistant readme --lang en --name README
  @assistant model --list
  @assistant model status
  @assistant engine opencode
  @assistant engine ollama
  @assistant engine --list
  @assistant engine status
  @assistant status
  @assistant think off
  @assistant think status
  @assistant think clear
  @assistant lang en
  @assistant lang status

${BOLD}Current engine:${RESET} ${MAGENTA}${BOLD}${1:-}${RESET}
${BOLD}Current model:${RESET} ${GREEN}${BOLD}${2:-}${RESET}
${BOLD}Ollama model:${RESET} ${GREEN}${BOLD}${3:-}${RESET}
${BOLD}OpenCode model:${RESET} ${GREEN}${BOLD}${4:-}${RESET}
${BOLD}Think flag:${RESET}   ${YELLOW}${5:-(model default)}${RESET}
${BOLD}Language:${RESET}     ${CYAN}${BOLD}${6:-}${RESET}
${BOLD}Config in:${RESET}    $7
${BOLD}Skill Commit MD in:${RESET}        $8
${BOLD}Skill Resume MD in:${RESET}        $9
"
}
