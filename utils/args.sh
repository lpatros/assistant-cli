_parse_args_for_llm() {
  LLM_CLEAN_ARGS=()
  LLM_THINK_FLAGS=()
  for arg in "$@"; do
    case "$arg" in
      --think|--no-think|--hide-think)
        LLM_THINK_FLAGS+=("$arg")
        ;;
      *)
        LLM_CLEAN_ARGS+=("$arg")
        ;;
    esac
  done
}
