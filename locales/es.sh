# Engine commands
t_engine_changed() {
  _success "Motor cambiado a: ${BOLD}$1${RESET}"
}

t_engine_usage() {
  _error "Uso: assistant engine [ollama|opencode|--list|status]"
}

t_engine_status() {
  _info "Motor actual: ${MAGENTA}${BOLD}$1${RESET}"
  _info "Modelo actual: ${GREEN}${BOLD}$2${RESET}"
}

t_model_status_detailed() {
  _info "Motor actual: ${MAGENTA}${BOLD}$1${RESET}"
  _info "Modelo actual: ${GREEN}${BOLD}$2${RESET}"
  _info "Modelo de Ollama: ${GREEN}${BOLD}$3${RESET}"
  _info "Modelo de OpenCode: ${GREEN}${BOLD}$4${RESET}"
}

t_models_available_header() {
  _header "Modelos disponibles — motor: $1"
}

t_no_models_found_ollama() {
  _error "No se encontraron modelos. ¿Está ejecutándose Ollama?"
}

t_no_models_found_opencode() {
  _error "No se encontraron modelos. ¿Está OpenCode instalado y configurado?"
}

t_menu_switch_engine() {
  echo "[ Cambiar motor ]"
}

t_menu_cancel() {
  echo "Cancelar"
}

t_current_model_label() {
  echo -e "  Modelo actual: ${GREEN}${BOLD}$1${RESET}\n"
}

t_choose_model_prompt() {
  echo "  Elige un modelo: "
}

t_choose_engine_prompt() {
  echo "  Elige el motor: "
}

t_cancelled() {
  _warn "Cancelado."
}

t_model_changed() {
  _success "Modelo cambiado a: ${BOLD}$1${RESET}"
}

t_invalid_option() {
  _warn "Opción inválida. Por favor, inténtalo de nuevo."
}

t_invalid_option_simple() {
  _warn "Opción inválida."
}

t_choose_engine_header() {
  _header "Elige el motor"
}

t_use_model_list_to_choose() {
  _info "Usa ${CYAN}assistant model --list${RESET} para elegir un modelo para este motor."
}

t_current_engine_label() {
  echo -e "  Motor actual: ${MAGENTA}${BOLD}$1${RESET}\n"
}

t_model_usage() {
  _error "Uso: assistant model --list|status"
}

# Think commands
t_think_enabled() {
  _success "Modo pensamiento habilitado y guardado."
}

t_think_disabled() {
  _success "Modo pensamiento deshabilitado y guardado."
}

t_think_hidden() {
  _success "Modo pensamiento configurado como oculto y guardado."
}

t_think_cleared() {
  _success "Modo pensamiento restablecido — usando el valor predeterminado del modelo."
}

t_think_status_default() {
  _info "Modo pensamiento: ${DIM}predeterminado del modelo (sin flag guardado)${RESET}"
}

t_think_status_current() {
  _info "Modo pensamiento actual: ${YELLOW}${BOLD}$1${RESET}"
}

t_think_usage() {
  _error "Uso: assistant think [on|off|hide|clear|status]"
}

# General / LLM / Helpers
t_engine_display() {
  _info "Motor: ${MAGENTA}${BOLD}$1${RESET}"
}

t_model_display() {
  _info "Modelo: ${GREEN}${BOLD}$1${RESET}"
}

t_think_mode_display() {
  _info "Modo pensamiento: ${YELLOW}$1${RESET}"
}

t_think_flag_display() {
  _info "Flag de pensamiento: ${YELLOW}$1${RESET}"
}

t_default_engine_model() {
  echo "motor predeterminado"
}

t_convention_file_not_found() {
  _warn "Archivo de convenciones no encontrado en: $1" >&2
}

t_continuing_without_guidelines() {
  _warn "Continuando sin la guía de convenciones..." >&2
}

# Lang commands
t_lang_changed() {
  _success "Idioma cambiado a: ${BOLD}$1${RESET}"
}

t_lang_usage() {
  _error "Uso: assistant lang [en|pt-br|es|status]"
}

t_lang_status() {
  _info "Idioma actual: ${CYAN}${BOLD}$1${RESET}"
}

# Commit skill
t_commit_not_git_repo() {
  _error "No estás dentro de un repositorio Git."
}

t_commit_analyzing() {
  _header "Analizando repositorio con $1 ($2)..."
}

t_commit_no_staged_files() {
  echo "(no hay archivos en el área de preparación)"
}

t_commit_no_unstaged_files() {
  echo "(no hay archivos sin preparar)"
}

t_commit_prompt_instructions() {
  echo "Analiza los cambios anteriores y sugiere commits siguiendo las pautas proporcionadas."
}

# Resume skill
t_resume_analyzing() {
  _info "Analizando proyecto ${BOLD}$1${RESET}..."
}

t_resume_prompt_instructions() {
  echo "Analiza el proyecto anterior y genera el archivo de resumen siguiendo estrictamente las pautas proporcionadas."
}

t_resume_failed() {
  _error "No se pudo generar el resumen para ${BOLD}$1${RESET}"
}

t_resume_project_dir_not_found() {
  _error "Directorio del proyecto no encontrado: $1"
}

t_resume_success() {
  _success "Resumen generado para ${BOLD}$1${RESET} en ${GREEN}$2${RESET}"
}

t_resume_starting() {
  _header "Iniciando análisis con $1 ($2)..."
}

t_resume_parallel_info() {
  _info "Analizando $1 proyectos en paralelo..."
}

t_resume_parallel_done() {
  _success "Análisis en paralelo completado."
}

# Readme skill
t_readme_missing_args() {
  _warn "Por favor, proporciona ambos parámetros para continuar:

- --lang — el idioma para el contenido del README (ej. en, pt-br, es, fr)
- --name — el nombre del archivo de salida sin extensión (ej. README, README-PTBR, README-ES)

Ejemplo: assistant readme --lang es --name README-ES"
}

t_readme_analyzing() {
  _header "Analizando proyecto con $1 ($2)..."
}

t_readme_prompt_instructions() {
  echo "Analiza el proyecto anterior y genera el archivo README siguiendo estrictamente las pautas proporcionadas. El idioma de salida DEBE ser: $1. IMPORTANTE: Genera ÚNICAMENTE el contenido Markdown bruto para el README. NO incluyas ningún texto conversacional, confirmaciones o bloques de código markdown (\`\`\`markdown) envolviendo la respuesta."
}

t_readme_failed() {
  _error "No se pudo generar el README."
}

t_readme_success() {
  _success "$1 generado en $2."
}

# Update command
t_update_starting() {
  _header "Actualizando el asistente..."
}

t_update_success() {
  _success "¡Asistente actualizado con éxito!"
}

t_update_failed() {
  _error "No se pudo actualizar el asistente."
}

t_unknown_command() {
  _error "El comando '$1' no existe."
  echo -e "Prueba ${GREEN}assistant --help${RESET} para ver la lista de comandos."
}

t_message_needs_quotes() {
  _error "El mensaje debe estar entre comillas."
  echo -e "Ejemplo: ${GREEN}assistant \"tu mensaje aquí\"${RESET}"
}

t_create_skill_usage() {
  _error "Uso: assistant create skill [nombre-habilidad] [ruta-archivo-md]"
}

t_create_skill_success() {
  _success "¡Habilidad personalizada '${BOLD}$1${RESET}' creada con éxito!"
  _info "Markdown guardado en: $2"
  _info "Ahora puedes ejecutarla usando: ${GREEN}assistant $1${RESET}"
}

t_custom_skill_not_found() {
  _error "Habilidad personalizada no encontrada: $1"
}

t_create_skill_invalid_name() {
  _error "Nombre de habilidad inválido. Usa solo caracteres alfanuméricos, guiones bajos o guiones."
}

t_create_skill_md_not_found() {
  _error "Archivo markdown de habilidad no encontrado: $1"
}

t_create_skill_warning_default_override() {
  _warn "La habilidad '${BOLD}$1${RESET}' es una habilidad predeterminada del asistente."
}

t_create_skill_prompt_override() {
  echo -n "¿Realmente deseas sobrescribirla? [y/N]: "
}

t_create_skill_aborted() {
  _warn "Operación abortada. La habilidad no fue creada."
}

t_help_output() {
  echo -e "
${BOLD}${BLUE}assistant${RESET} — Envoltura CLI para Ollama y OpenCode

${BOLD}Uso:${RESET}
  ${GREEN}assistant${RESET}                                  Chat interactivo con el modelo actual
  ${GREEN}assistant${RESET} \"<mensaje>\"                    Enviar un mensaje directo
  ${GREEN}assistant status${RESET}                           Mostrar motor, modelos, modo pensamiento e idioma
  ${GREEN}assistant update${RESET}                           Actualizar el asistente a la última versión
  ${GREEN}assistant commit${RESET}                           Analizar repositorio git y sugerir commits
  ${GREEN}assistant resume${RESET} [rutas...]                 Generar resúmenes de proyectos en markdown
  ${GREEN}assistant readme${RESET} --lang <código> --name <nom> Generar archivo README del proyecto
  ${GREEN}assistant create skill${RESET} <nom> <ruta.md>     Crear una nueva habilidad personalizada
  ${GREEN}assistant <habilidad-personalizada>${RESET} [args]  Ejecutar una habilidad personalizada
  ${GREEN}assistant model --list${RESET}                     Listar modelos y permitir cambiar de modelo
  ${GREEN}assistant model status${RESET}                     Mostrar el modelo del motor actual y guardados
  ${GREEN}assistant engine${RESET} [ollama|opencode|--list|status]  Cambiar el motor activo
  ${GREEN}assistant engine status${RESET}                    Mostrar motor actual y modelo activo
  ${GREEN}assistant think${RESET} [on|off|hide|clear|status] Gestionar modo pensamiento (ollama)
  ${GREEN}assistant lang${RESET} [en|pt-br|es|status]       Gestionar el idioma del asistente

${BOLD}Notas:${RESET}
  - Los modelos se guardan por motor; cambiar el motor no hace perder el modelo anterior.
  - Si el modelo de opencode está vacío, se utiliza el configurado por defecto en opencode.

${BOLD}Flags de pensamiento — Solo Ollama (por sesión o persistente):${RESET}
  ${YELLOW}--think${RESET}                           Habilitar modo pensamiento (y guardar)
  ${YELLOW}--no-think${RESET}                        Deshabilitar modo pensamiento (y guardar)
  ${YELLOW}--hide-think${RESET}                      Ocultar pensamiento (y guardar)

${BOLD}Ejemplos:${RESET}
  assistant \"Explica qué es un closure en JS\"
  assistant commit
  assistant commit --no-think
  assistant \"Resume este texto\" --think
  assistant readme --lang es --name README-ES
  assistant create skill deploy ./deploy.md
  assistant deploy \"crear una configuración de docker\"
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
  assistant lang es
  assistant lang status

${BOLD}Motor actual:${RESET} ${MAGENTA}${BOLD}${1:-}${RESET}
${BOLD}Modelo actual:${RESET} ${GREEN}${BOLD}${2:-}${RESET}
${BOLD}Modelo de Ollama:${RESET} ${GREEN}${BOLD}${3:-}${RESET}
${BOLD}Modelo de OpenCode:${RESET} ${GREEN}${BOLD}${4:-}${RESET}
${BOLD}Flag de pensamiento:${RESET} ${YELLOW}${5:-(predeterminado del modelo)}${RESET}
${BOLD}Idioma:${RESET}       ${CYAN}${BOLD}${6:-}${RESET}
"
}
