# Engine commands
t_engine_changed() {
  _success "Engine alterada para: ${BOLD}$1${RESET}"
}

t_engine_usage() {
  _error "Uso: assistant engine [<engine>|--list|status]"
}

t_engine_status() {
  _info "Engine atual: ${MAGENTA}${BOLD}$1${RESET}"
  _info "Modelo atual: ${GREEN}${BOLD}$2${RESET}"
}

t_engine_not_installed_warning() {
  _warn "A engine '${BOLD}$1${RESET}' não foi encontrada no PATH do seu sistema."
  _info "É altamente recomendável instalar o CLI do ${BOLD}$1${RESET} ou corrigir a variável de ambiente PATH para que o assistente funcione corretamente."
}

t_engine_not_installed_prompt() {
  echo -n "Deseja realmente continuar com a execução? [y/N]: "
}

t_engine_not_installed_aborted() {
  _warn "Operação cancelada. Instale o ${BOLD}$1${RESET} ou ajuste a variável PATH do seu sistema."
}

t_model_status_detailed() {
  _info "Engine atual: ${MAGENTA}${BOLD}$1${RESET}"
  _info "Modelo atual: ${GREEN}${BOLD}$2${RESET}"
}

t_models_available_header() {
  _header "Modelos disponíveis — engine: $1"
}

t_no_models_found() {
  _error "Nenhum modelo encontrado para a engine '$1'. O CLI está instalado e configurado?"
}

t_engine_no_model_listing() {
  _info "A engine '$1' não suporta listagem de modelos."
  echo -e "  Use ${BOLD}assistant model set <modelo>${RESET} para definir o modelo manualmente."
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
  echo "  Digite o número para selecionar: "
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

t_engines_configured_header() {
  _info "${BOLD}Engines instaladas:${RESET}"
}

t_engines_not_installed_header() {
  _info "${BOLD}Engines não instaladas:${RESET}"
}

t_no_engines_configured() {
  echo -e "  ${DIM}(nenhuma engine instalada)${RESET}"
}

t_no_engines_uninstalled() {
  echo -e "  ${DIM}(nenhuma engine não instalada)${RESET}"
}

t_use_model_list_to_choose() {
  _info "Use ${CYAN}assistant model --list${RESET} ou ${CYAN}assistant model set <modelo>${RESET} para escolher um modelo."
}

t_current_engine_label() {
  echo -e "  Engine atual: ${MAGENTA}${BOLD}$1${RESET}\n"
}

t_model_usage() {
  _error "Uso: assistant model --list|set <modelo>|status"
}

t_model_set_usage() {
  _error "Uso: assistant model set <modelo>"
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
  _info "Ollama think mode atual: ${YELLOW}${BOLD}$1${RESET}"
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
  _error "Uso: assistant lang [<idioma>|--list|status]"
}

t_lang_status() {
  _info "Idioma atual: ${CYAN}${BOLD}$1${RESET}"
}

t_lang_not_found() {
  _error "Locale '$1' não encontrado em locales/ ou custom/locales/."
}

t_lang_list_header() {
  _header "Idiomas disponíveis:"
}

# Commit skill
t_commit_not_git_repo() {
  _error "Não está dentro de um repositório Git."
}

t_git_not_installed() {
  _error "O git não está instalado. Por favor, instale o git primeiro."
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

# Version command
t_version() {
  _info "Assistant CLI v$1"
}

t_version_unknown() {
  echo "desconhecida"
}

# Update command
t_update_starting() {
  _header "Atualizando o assistente..."
}

t_update_success() {
  _success "Assistente atualizado com sucesso!"
}

t_update_already_up_to_date() {
  _info "Você está na versão mais recente."
}

t_update_failed() {
  _error "Falha ao atualizar o assistente."
}

t_update_conflict_warning() {
  _warn "Conflito detectado ao atualizar o assistente."
  _info "Verifique se você fez alguma alteração local nos arquivos que possa estar dando conflito."
  _info "Se você não alterou nada, deve ser seguro forçar a atualização."
}

t_update_conflict_prompt() {
  echo -n "Deseja forçar a atualização? [y/N]: "
}

t_update_changelog_prompt() {
  echo -n "Deseja visualizar o changelog? [y/N]: "
}

t_update_aborted() {
  _warn "Atualização cancelada."
}

t_update_list_header() {
  _header "Versões disponíveis:"
}

t_update_list_tip() {
  _info "Use ${CYAN}assistant update @<versão>${RESET} ou ${CYAN}assistant update --version <versão>${RESET} para trocar de versão."
}

t_update_version_starting() {
  _header "Atualizando o assistente para a versão v$1..."
}

t_update_version_success() {
  _success "Assistente alterado para a versão v$1 com sucesso!"
}

t_update_version_not_found() {
  _error "Versão '$1' não encontrada. Use ${CYAN}assistant update --list${RESET} para ver as versões disponíveis."
}

t_update_already_on_version() {
  _info "Você já está na versão v$1."
}

t_update_usage() {
  _error "Uso: assistant update [@<versão>|--version <versão>|--list]"
}

t_update_returning_to_channel() {
  _info "Saindo da versão específica e retornando para o canal ${CYAN}${BOLD}$1${RESET}..."
}

t_changelog_not_found() {
  _warn "Arquivo $1 não encontrado."
}

t_changelog_web_link() {
  _info "Veja também a release no GitHub: ${CYAN}$1${RESET}"
}

t_changelog_opening_web() {
  _info "Abrindo changelog no navegador: ${CYAN}$1${RESET}"
}

t_changelog_usage() {
  _error "Uso: assistant changelog [--web|-w|--terminal|-t]"
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

# Custom commands
t_custom_engines_status_header() {
  _header "Engines Customizadas:"
}

t_no_custom_engines_found() {
  echo -e "  ${DIM}(nenhuma engine customizada encontrada)${RESET}"
}

t_custom_skills_status_header() {
  _header "Skills Customizadas:"
}

t_no_custom_skills_found() {
  echo -e "  ${DIM}(nenhuma skill customizada encontrada)${RESET}"
}

t_custom_locales_status_header() {
  _header "Locales Customizados:"
}

t_no_custom_locales_found() {
  echo -e "  ${DIM}(nenhum locale customizado encontrado)${RESET}"
}

t_custom_status_header() {
  _header "Status de Customizações:"
}

t_custom_usage() {
  _error "Uso: assistant custom [engines|skills|locales|status] [status]"
}

t_custom_engines_usage() {
  _error "Uso: assistant custom engines [status]"
}

t_custom_skills_usage() {
  _error "Uso: assistant custom skills [status]"
}

t_custom_locales_usage() {
  _error "Uso: assistant custom locales [status]"
}

# Channel commands
t_channel_status() {
  _info "Canal de release atual: ${CYAN}${BOLD}$1${RESET}"
}

t_channel_switching() {
  _info "Alternando para o canal de release: ${CYAN}${BOLD}$1${RESET}..."
}

t_channel_already_active() {
  _info "Você já está utilizando o canal: ${CYAN}${BOLD}$1${RESET}."
  _info "Buscando atualizações mais recentes..."
}

t_channel_switch_failed() {
  _error "Falha ao alternar para o canal '$1'."
  if [[ -n "$2" ]]; then
    echo -e "${RED}$2${RESET}"
  fi
}

t_channel_usage() {
  _error "Uso: assistant channel [stable|beta|status]"
}

t_help_output() {
  echo -e "
${BOLD}${BLUE}assistant${RESET} — CLI wrapper para LLMs e engines modulares

${BOLD}Uso:${RESET}
  ${GREEN}assistant${RESET}                                     Chat interativo com o modelo atual
  ${GREEN}assistant${RESET} \"<mensagem>\"                        Envia uma mensagem direta
  ${GREEN}assistant status${RESET}                              Mostra engine, modelos, think mode e idioma
  ${GREEN}assistant custom${RESET} [engines|skills|locales|status] Mostra componentes customizados identificados
  ${GREEN}assistant channel${RESET} [<stable|beta|status>]      Gerencia o canal de release (estável/beta)
  ${GREEN}assistant changelog${RESET} [--terminal|-t]           Exibe o changelog no navegador (or terminal com -t)
  ${GREEN}assistant update${RESET} [@<ver>|--version <ver>|--list] Atualiza o assistente para a versão mais recente ou específica
  ${GREEN}assistant --version${RESET}                           Mostra a versão atual do assistente
  ${GREEN}assistant commit${RESET}                              Analisa o repo git e sugere commits
  ${GREEN}assistant resume${RESET} [caminhos...]                Gera resumos de projetos em markdown
  ${GREEN}assistant readme${RESET} --lang <code> --name <nome>  Gera o README do projeto
  ${GREEN}assistant create skill${RESET} <nome> <caminho.md>    Cria uma nova skill customizada
  ${GREEN}assistant <skill-customizada>${RESET} [argumentos]    Executa uma skill customizada
  ${GREEN}assistant model${RESET} [--list|set <modelo>|status]  Gerencia os modelos da engine ativa
  ${GREEN}assistant engine${RESET} [<engine>|--list|status]     Troca a engine ativa
  ${GREEN}assistant engine status${RESET}                       Mostra engine atual e modelo ativo
  ${GREEN}assistant think${RESET} [on|off|hide|clear|status]    Gerencia o think mode (ollama)
  ${GREEN}assistant lang${RESET} [<idioma>|--list|status]       Gerencia o idioma do assistente

${BOLD}Notas:${RESET}
  - Crie engines customizadas em custom/engines/<nome>.sh.
  - Modelos são salvos por engine; trocar a engine não perde os modelos anteriores.

${BOLD}Flags de thinking — apenas Ollama (por sessão ou persistente):${RESET}
  ${YELLOW}--think${RESET}                           Ativa o modo thinking (e salva)
  ${YELLOW}--no-think${RESET}                        Desativa o modo thinking (e salva)
  ${YELLOW}--hide-think${RESET}                      Oculta o thinking (e salva)

${BOLD}Exemplos:${RESET}
  assistant \"Explica o que é um closure em JS\"
  assistant commit
  assistant custom status
  assistant custom engines status
  assistant channel beta
  assistant engine agy
  assistant engine opencode
  assistant engine ollama
  assistant engine --list
  assistant engine status
  assistant status
"
}
