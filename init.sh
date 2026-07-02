if [ -z "${ASSISTANT_ROOT_DIR:-}" ]; then
  ASSISTANT_ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
fi

ASSISTANT_LIB_DIR="${ASSISTANT_LIB_DIR:-$ASSISTANT_ROOT_DIR/lib}"
ASSISTANT_UTILS_DIR="${ASSISTANT_UTILS_DIR:-$ASSISTANT_ROOT_DIR/utils}"

source "$ASSISTANT_UTILS_DIR/colors.sh"
source "$ASSISTANT_UTILS_DIR/helpers.sh"
source "$ASSISTANT_UTILS_DIR/args.sh"

source "$ASSISTANT_LIB_DIR/config.sh"
source "$ASSISTANT_LIB_DIR/persistence.sh"
source "$ASSISTANT_LIB_DIR/locale.sh"
source "$ASSISTANT_LIB_DIR/think.sh"
source "$ASSISTANT_LIB_DIR/engine.sh"
source "$ASSISTANT_LIB_DIR/llm.sh"
source "$ASSISTANT_LIB_DIR/help.sh"
source "$ASSISTANT_LIB_DIR/update.sh"

_load_locale

source "$ASSISTANT_ROOT_DIR/skills/commit/init.sh"
source "$ASSISTANT_ROOT_DIR/skills/resume/init.sh"
source "$ASSISTANT_ROOT_DIR/skills/readme/init.sh"

function assistant() {
  local subcmd="${1:-}"

  case "$subcmd" in
    "")
      _llm_run_interactive
      ;;
    "commit")
      shift
      _cmd_commit "$@"
      ;;
    "resume")
      shift
      _cmd_resume "$@"
      ;;
    "readme")
      shift
      _cmd_readme "$@"
      ;;
    "model")
      shift
      case "${1:-}" in
        "--list")
          _cmd_model_list
          ;;
        "status"|"")
          _cmd_model_status
          ;;
        *)
          t_model_usage
          return 1
          ;;
      esac
      ;;
    "engine")
      shift
      _cmd_engine "$@"
      ;;
    "think")
      shift
      _cmd_think "$@"
      ;;
    "lang")
      shift
      _cmd_lang "$@"
      ;;
    "status")
      _cmd_status
      ;;
    "update")
      _cmd_update
      ;;
    "--help"|"-h"|"help")
      _cmd_help
      ;;
    "--think"|"--no-think"|"--hide-think")
      _llm_run_interactive "$@"
      ;;
    *)
      if [[ "$#" -gt 1 ]]; then
        t_message_needs_quotes
        return 1
      fi

      if [[ -n "$1" && ! "$1" =~ [[:space:]] ]]; then
        t_unknown_command "$1"
        return 1
      fi

      _llm_run_interactive "$@"
      ;;
  esac
}