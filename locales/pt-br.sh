# Engine commands
t_engine_changed() {
  _success "Engine alterada para: ${BOLD}$1${RESET}"
}

t_engine_usage() {
  _error "Uso: assistant engine [ollama|opencode|--list|status]"
}

t_engine_status() {
  _info "Engine atual: ${MAGENTA}${BOLD}$1${RESET}"
  _info "Modelo atual: ${GREEN}${BOLD}$2${RESET}"
}

t_model_status_detailed() {
  _info "Engine atual: ${MAGENTA}${BOLD}$1${RESET}"
  _info "Modelo atual: ${GREEN}${BOLD}$2${RESET}"
  _info "Modelo ollama: ${GREEN}${BOLD}$3${RESET}"
  _info "Modelo opencode: ${GREEN}${BOLD}$4${RESET}"
}

t_models_available_header() {
  _header "Modelos disponíveis — engine: $1"
}

t_no_models_found_ollama() {
  _error "Nenhum modelo encontrado. O Ollama está rodando?"
}

t_no_models_found_opencode() {
  _error "Nenhum modelo encontrado. O opencode está instalado e configurado?"
}

t_menu_switch_engine() {
  echo "[ Trocar engine ]"
}

t_menu_cancel() {
  echo "Cancelar"
}

t_current_model_label() {
  echo -e "  Modelo atual: ${GREEN}${BOLD}$1${RESET}\n"
}

t_choose_model_prompt() {
  echo "  Escolha um modelo: "
}

t_choose_engine_prompt() {
  echo "  Escolha a engine: "
}

t_cancelled() {
  _warn "Cancelado."
}

t_model_changed() {
  _success "Modelo alterado para: ${BOLD}$1${RESET}"
}

t_invalid_option() {
  _warn "Opção inválida. Tente novamente."
}

t_invalid_option_simple() {
  _warn "Opção inválida."
}

t_choose_engine_header() {
  _header "Escolha a engine"
}

t_use_model_list_to_choose() {
  _info "Use ${CYAN}assistant model --list${RESET} para escolher um modelo dessa engine."
}

t_current_engine_label() {
  echo -e "  Engine atual: ${MAGENTA}${BOLD}$1${RESET}\n"
}

t_model_usage() {
  _error "Uso: assistant model --list|status"
}

# Think commands
t_think_enabled() {
  _success "Think mode ativado e salvo."
}

t_think_disabled() {
  _success "Think mode desativado e salvo."
}

t_think_hidden() {
  _success "Think mode definido como oculto e salvo."
}

t_think_cleared() {
  _success "Think mode limpo — usando padrão do modelo."
}

t_think_status_default() {
  _info "Think mode: ${DIM}padrão do modelo (nenhuma flag salva)${RESET}"
}

t_think_status_current() {
  _info "Think mode atual: ${YELLOW}${BOLD}$1${RESET}"
}

t_think_usage() {
  _error "Uso: assistant think [on|off|hide|clear|status]"
}

# General / LLM / Helpers
t_engine_display() {
  _info "Engine: ${MAGENTA}${BOLD}$1${RESET}"
}

t_model_display() {
  _info "Modelo: ${GREEN}${BOLD}$1${RESET}"
}

t_think_mode_display() {
  _info "Think mode: ${YELLOW}$1${RESET}"
}

t_think_flag_display() {
  _info "Think flag: ${YELLOW}$1${RESET}"
}

t_default_engine_model() {
  echo "padrao da engine"
}

t_convention_file_not_found() {
  _warn "Arquivo de convenções não encontrado em: $1" >&2
}

t_continuing_without_guidelines() {
  _warn "Continuando sem o guia de convenções..." >&2
}

# Lang commands
t_lang_changed() {
  _success "Idioma alterado para: ${BOLD}$1${RESET}"
}

t_lang_usage() {
  _error "Uso: assistant lang [en|pt-br|es|status]"
}

t_lang_status() {
  _info "Idioma atual: ${CYAN}${BOLD}$1${RESET}"
}

# Commit skill
t_commit_not_git_repo() {
  _error "Não está dentro de um repositório Git."
}

t_commit_analyzing() {
  _header "Analisando repositório com $1 ($2)..."
}

t_commit_no_staged_files() {
  echo "(nenhum arquivo em staging)"
}

t_commit_no_unstaged_files() {
  echo "(nenhum arquivo unstaged)"
}

t_commit_prompt_instructions() {
  echo "Analise as mudanças acima e sugira commits seguindo as guidelines fornecidas."
}

# Resume skill
t_resume_analyzing() {
  _info "Analisando projeto ${BOLD}$1${RESET}..."
}

t_resume_prompt_instructions() {
  echo "Analise o projeto acima e gere o arquivo de resumo seguindo estritamente as guidelines fornecidas."
}

t_resume_failed() {
  _error "Falha ao gerar resumo para ${BOLD}$1${RESET}"
}

t_resume_project_dir_not_found() {
  _error "Diretório do projeto não encontrado: $1"
}

t_resume_success() {
  _success "Resumo gerado para ${BOLD}$1${RESET} em ${GREEN}$2${RESET}"
}

t_resume_starting() {
  _header "Iniciando análise com $1 ($2)..."
}

t_resume_parallel_info() {
  _info "Analisando $1 projetos em paralelo..."
}

t_resume_parallel_done() {
  _success "Análise paralela concluída."
}

# Readme skill
t_readme_missing_args() {
  _warn "Por favor, forneça ambos os parâmetros para continuar:

- --lang — o idioma do conteúdo do README (ex: en, pt-br, es, fr)
- --name — o nome do arquivo de saída sem extensão (ex: README, README-PTBR)

Exemplo: assistant readme --lang en --name README"
}

t_readme_analyzing() {
  _header "Analisando o projeto com $1 ($2)..."
}

t_readme_prompt_instructions() {
  echo "Analise o projeto acima e gere o arquivo README seguindo estritamente as diretrizes fornecidas. O idioma de saída DEVE ser: $1. IMPORTANTE: Retorne APENAS o conteúdo bruto em Markdown do README. NÃO inclua nenhum texto conversacional, confirmações ou formatação de bloco de código markdown (\`\`\`markdown) envolvendo a resposta."
}

t_readme_failed() {
  _error "Falha ao gerar o README."
}

t_readme_success() {
  _success "$1 gerado em $2."
}

# Update command
t_update_starting() {
  _header "Atualizando o assistente..."
}

t_update_success() {
  _success "Assistente atualizado com sucesso!"
}

t_update_failed() {
  _error "Falha ao atualizar o assistente."
}

t_unknown_command() {
  _error "Comando '$1' não existe."
  echo -e "Tente ${GREEN}assistant --help${RESET} para visualizar a lista de comandos."
}

t_message_needs_quotes() {
  _error "A mensagem deve estar entre aspas."
  echo -e "Exemplo: ${GREEN}assistant \"sua mensagem aqui\"${RESET}"
}

t_create_skill_usage() {
  _error "Uso: assistant create skill [nome-da-skill] [caminho-do-arquivo-md]"
}

t_create_skill_success() {
  _success "Skill customizada '${BOLD}$1${RESET}' criada com sucesso!"
  _info "Markdown salvo em: $2"
  _info "Agora você pode executá-la com: ${GREEN}assistant $1${RESET}"
}

t_custom_skill_not_found() {
  _error "Skill customizada não encontrada: $1"
}

t_create_skill_invalid_name() {
  _error "Nome de skill inválido. Use apenas caracteres alfanuméricos, sublinhados (_) ou hífens (-)."
}

t_create_skill_md_not_found() {
  _error "Arquivo markdown original não encontrado em: $1"
}

t_create_skill_warning_default_override() {
  _warn "A skill '${BOLD}$1${RESET}' é uma skill padrão do assistente."
}

t_create_skill_prompt_override() {
  echo -n "Deseja realmente sobrescrevê-la? [y/N]: "
}

t_create_skill_aborted() {
  _warn "Operação cancelada. A skill não foi criada."
}

t_help_output() {
  echo -e "
${BOLD}${BLUE}assistant${RESET} — CLI wrapper para Ollama e OpenCode

${BOLD}Uso:${RESET}
  ${GREEN}assistant${RESET}                                  Chat interativo com o modelo atual
  ${GREEN}assistant${RESET} \"<mensagem>\"                    Envia uma mensagem direta
  ${GREEN}assistant status${RESET}                           Mostra engine, modelos, think mode e idioma
  ${GREEN}assistant update${RESET}                           Atualiza o assistente para a última versão
  ${GREEN}assistant commit${RESET}                           Analisa o repo git e sugere commits
  ${GREEN}assistant resume${RESET} [caminhos...]             Gera resumos de projetos em markdown
  ${GREEN}assistant readme${RESET} --lang <code> --name <nome>  Gera o README do projeto
  ${GREEN}assistant create skill${RESET} <nome> <caminho.md>  Cria uma nova skill customizada
  ${GREEN}assistant <skill-customizada>${RESET} [argumentos]   Executa uma skill customizada
  ${GREEN}assistant model --list${RESET}                     Lista modelos e permite trocar
  ${GREEN}assistant model status${RESET}                     Mostra modelo da engine atual e modelos salvos
  ${GREEN}assistant engine${RESET} [ollama|opencode|--list|status]  Troca a engine ativa
  ${GREEN}assistant engine status${RESET}                    Mostra engine atual e modelo ativo
  ${GREEN}assistant think${RESET} [on|off|hide|clear|status] Gerencia o think mode (ollama)
  ${GREEN}assistant lang${RESET} [en|pt-br|es|status]       Gerencia o idioma do assistente

${BOLD}Notas:${RESET}
  - Modelos sao salvos por engine; trocar a engine nao perde o modelo anterior.
  - Se o modelo do opencode estiver vazio, ele usa o padrao configurado no opencode.

${BOLD}Flags de thinking — apenas Ollama (por sessão ou persistente):${RESET}
  ${YELLOW}--think${RESET}                           Ativa o modo thinking (e salva)
  ${YELLOW}--no-think${RESET}                        Desativa o modo thinking (e salva)
  ${YELLOW}--hide-think${RESET}                      Oculta o thinking (e salva)

${BOLD}Exemplos:${RESET}
  assistant \"Explica o que é um closure em JS\"
  assistant commit
  assistant commit --no-think
  assistant \"Resuma esse texto\" --think
  assistant readme --lang pt-br --name README-PTBR
  assistant create skill deploy ./deploy.md
  assistant deploy \"crie uma configuração do docker\"
  assistant model --list
  assistant model status
  assistant engine opencode
  assistant engine ollama
  assistant engine --list
  assistant engine status
  assistant status
  assistant think off
  assistant think status
  assistant think clear
  assistant lang pt-br
  assistant lang status

${BOLD}Engine atual:${RESET} ${MAGENTA}${BOLD}${1:-}${RESET}
${BOLD}Modelo atual:${RESET} ${GREEN}${BOLD}${2:-}${RESET}
${BOLD}Modelo ollama:${RESET} ${GREEN}${BOLD}${3:-}${RESET}
${BOLD}Modelo opencode:${RESET} ${GREEN}${BOLD}${4:-}${RESET}
${BOLD}Think flag:${RESET}   ${YELLOW}${5:-(padrão do modelo)}${RESET}
${BOLD}Idioma:${RESET}       ${CYAN}${BOLD}${6:-}${RESET}
"
}
