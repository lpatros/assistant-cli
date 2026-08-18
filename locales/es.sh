# Engine commands
t_engine_changed() {
  _success "Motor cambiado a: ${BOLD}$1${RESET}"
}

t_engine_usage() {
  _error "Uso: assistant engine [<motor>|--list|status]"
}

t_engine_status() {
  _info "Motor actual: ${MAGENTA}${BOLD}$1${RESET}"
  _info "Modelo actual: ${GREEN}${BOLD}$2${RESET}"
}

t_engine_not_installed_warning() {
  _warn "El motor '${BOLD}$1${RESET}' no se encontró en el PATH de tu sistema."
  _info "Es altamente recomendable instalar la CLI de ${BOLD}$1${RESET} o corregir la variable de entorno PATH para que el asistente funcione correctamente."
}

t_engine_not_installed_prompt() {
  echo -n "¿Realmente deseas continuar con la ejecución? [y/N]: "
}

t_engine_not_installed_aborted() {
  _warn "Operación cancelada. Por favor instala ${BOLD}$1${RESET} o corrige el PATH de tu sistema."
}

t_model_status_detailed() {
  _info "Motor actual: ${MAGENTA}${BOLD}$1${RESET}"
  _info "Modelo actual: ${GREEN}${BOLD}$2${RESET}"
}

t_models_available_header() {
  _header "Modelos disponibles — motor: $1"
}

t_no_models_found() {
  _error "No se encontraron modelos para el motor '$1'. ¿Está la CLI instalada y configurada?"
}

t_engine_no_model_listing() {
  _info "El motor '$1' no soporta listado de modelos."
  echo -e "  Use ${BOLD}assistant model set <modelo>${RESET} para definir el modelo manualmente."
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
  echo "  Ingresa el número para seleccionar: "
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

t_engines_configured_header() {
  _info "${BOLD}Motores instalados:${RESET}"
}

t_engines_not_installed_header() {
  _info "${BOLD}Motores no instalados:${RESET}"
}

t_no_engines_configured() {
  echo -e "  ${DIM}(ningún motor instalado)${RESET}"
}

t_no_engines_uninstalled() {
  echo -e "  ${DIM}(ninguno)${RESET}"
}

t_use_model_list_to_choose() {
  _info "Usa ${CYAN}assistant model --list${RESET} o ${CYAN}assistant model set <modelo>${RESET} para elegir un modelo."
}

t_current_engine_label() {
  echo -e "  Motor actual: ${MAGENTA}${BOLD}$1${RESET}\n"
}

t_model_usage() {
  _error "Uso: assistant model --list|set <modelo>|status"
}

t_model_set_usage() {
  _error "Uso: assistant model set <modelo>"
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
  _info "Ollama modo pensamiento actual: ${YELLOW}${BOLD}$1${RESET}"
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
  _error "Uso: assistant lang [<idioma>|--list|status]"
}

t_lang_status() {
  _info "Idioma actual: ${CYAN}${BOLD}$1${RESET}"
}

t_lang_not_found() {
  _error "Locale '$1' no encontrado en locales/ o custom/locales/."
}

t_lang_list_header() {
  _header "Idiomas disponibles:"
}

# Commit skill
t_commit_not_git_repo() {
  _error "No estás dentro de un repositorio Git."
}

t_git_not_installed() {
  _error "git no está instalado. Por favor instala git primero."
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

# Version command
t_version() {
  _info "Assistant CLI v$1"
}

t_version_unknown() {
  echo "desconocida"
}

# Update command
t_update_starting() {
  _header "Actualizando el asistente..."
}

t_update_success() {
  _success "¡Asistente actualizado con éxito!"
}

t_update_already_up_to_date() {
  _info "Estás en la versión más reciente."
}

t_update_failed() {
  _error "No se pudo actualizar el asistente."
}

t_update_conflict_warning() {
  _warn "Conflicto detectado al actualizar el asistente."
  _info "Verifica si realizaste cambios locales que puedan estar generando conflicto."
  _info "Si no has cambiado nada, debería ser seguro forzar la actualización."
}

t_update_conflict_prompt() {
  echo -n "¿Deseas forzar la actualización? [y/N]: "
}

t_update_changelog_prompt() {
  echo -n "¿Deseas ver el registro de cambios (changelog)? [y/N]: "
}

t_update_aborted() {
  _warn "Actualización cancelada."
}

t_update_list_header() {
  _header "Versiones disponibles:"
}

t_update_list_tip() {
  _info "Usa ${CYAN}assistant update @<versión>${RESET} o ${CYAN}assistant update --version <versión>${RESET} para cambiar de versión."
}

t_update_version_starting() {
  _header "Actualizando el asistente a la versión v$1..."
}

t_update_version_success() {
  _success "¡Asistente cambiado a la versión v$1 con éxito!"
}

t_update_version_not_found() {
  _error "Versión '$1' no encontrada. Usa ${CYAN}assistant update --list${RESET} para ver las versiones disponibles."
}

t_update_already_on_version() {
  _info "Ya estás en la versión v$1."
}

t_update_usage() {
  _error "Uso: assistant update [@<versión>|--version <versión>|--list]"
}

t_update_returning_to_channel() {
  _info "Saliendo de la versión específica y regresando al canal ${CYAN}${BOLD}$1${RESET}..."
}

t_changelog_not_found() {
  _warn "Archivo $1 no encontrado."
}

t_changelog_web_link() {
  _info "Ver release en GitHub: ${CYAN}$1${RESET}"
}

t_changelog_opening_web() {
  _info "Abriendo registro de cambios en el navegador: ${CYAN}$1${RESET}"
}

t_changelog_usage() {
  _error "Uso: assistant changelog [--web|-w|--terminal|-t]"
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

# Custom commands
t_custom_engines_status_header() {
  _header "Motores Personalizados:"
}

t_no_custom_engines_found() {
  echo -e "  ${DIM}(ningún motor personalizado encontrado)${RESET}"
}

t_custom_skills_status_header() {
  _header "Habilidades Personalizadas:"
}

t_no_custom_skills_found() {
  echo -e "  ${DIM}(ninguna habilidad personalizada encontrada)${RESET}"
}

t_custom_locales_status_header() {
  _header "Idiomas Personalizados:"
}

t_no_custom_locales_found() {
  echo -e "  ${DIM}(ningún idioma personalizado encontrado)${RESET}"
}

t_custom_status_header() {
  _header "Estado de Personalizaciones:"
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
  _info "Canal de lanzamiento actual: ${CYAN}${BOLD}$1${RESET}"
}

t_channel_switching() {
  _info "Cambiando al canal de lanzamiento: ${CYAN}${BOLD}$1${RESET}..."
}

t_channel_already_active() {
  _info "Ya estás utilizando el canal: ${CYAN}${BOLD}$1${RESET}."
  _info "Buscando actualizaciones más recientes..."
}

t_channel_switch_failed() {
  _error "Error al cambiar al canal '$1'."
  if [[ -n "$2" ]]; then
    echo -e "${RED}$2${RESET}"
  fi
}

t_channel_usage() {
  _error "Uso: assistant channel [stable|beta|status]"
}

t_help_output() {
  echo -e "
${BOLD}${BLUE}assistant${RESET} — Envoltura CLI para LLMs y motores modulares

${BOLD}Uso:${RESET}
  ${GREEN}assistant${RESET}                                     Chat interactivo con el modelo actual
  ${GREEN}assistant${RESET} \"<mensaje>\"                         Enviar un mensaje directo
  ${GREEN}assistant status${RESET}                              Mostrar motor, modelos, modo pensamiento e idioma
  ${GREEN}assistant custom${RESET} [engines|skills|locales|status] Mostrar componentes personalizados identificados
  ${GREEN}assistant channel${RESET} [<stable|beta|status>]      Gestionar el canal de lanzamiento (estable/beta)
  ${GREEN}assistant changelog${RESET} [--terminal|-t]           Muestra el registro de cambios en el navegador (o terminal con -t)
  ${GREEN}assistant update${RESET} [@<ver>|--version <ver>|--list] Actualizar el asistente a la última versión o a una específica
  ${GREEN}assistant --version${RESET}                           Mostrar la versión actual del asistente
  ${GREEN}assistant commit${RESET}                              Analizar repositorio git y sugerir commits
  ${GREEN}assistant resume${RESET} [rutas...]                   Generar resúmenes de proyectos en markdown
  ${GREEN}assistant readme${RESET} --lang <código> --name <nom> Generar archivo README del proyecto
  ${GREEN}assistant create skill${RESET} <nom> <ruta.md>        Crear una nueva habilidad personalizada
  ${GREEN}assistant <habilidad-personalizada>${RESET} [args]    Ejecutar una habilidad personalizada
  ${GREEN}assistant model${RESET} [--list|set <modelo>|status]  Gestionar los modelos del motor activo
  ${GREEN}assistant engine${RESET} [<motor>|--list|status]      Cambiar el motor activo
  ${GREEN}assistant engine status${RESET}                       Mostrar motor actual y modelo activo
  ${GREEN}assistant think${RESET} [on|off|hide|clear|status]    Gestionar modo pensamiento (ollama)
  ${GREEN}assistant lang${RESET} [<idioma>|--list|status]       Gestionar el idioma del asistente

${BOLD}Notas:${RESET}
  - Crea motores personalizados en custom/engines/<nombre>.sh.
  - Los modelos se guardan por motor; cambiar el motor no hace perder los modelos anteriores.

${BOLD}Flags de pensamiento — Solo Ollama (por sesión o persistente):${RESET}
  ${YELLOW}--think${RESET}                           Habilitar modo pensamiento (y guardar)
  ${YELLOW}--no-think${RESET}                        Deshabilitar modo pensamiento (y guardar)
  ${YELLOW}--hide-think${RESET}                      Ocultar pensamiento (y guardar)

${BOLD}Ejemplos:${RESET}
  assistant \"Explica qué es un closure in JS\"
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
