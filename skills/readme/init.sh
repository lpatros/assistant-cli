_gather_readme_context() {
  local project_path="$1"
  local project_name

  project_name=$(basename "$(cd "$project_path" && pwd)")

  echo "=== Project Name: $project_name ==="
  echo "=== Location: $project_path ==="
  echo ""

  echo "=== Directory Structure (Top Level) ==="
  if command -v tree &>/dev/null; then
    tree -L 3 --noreport "$project_path" | grep -Ev '(node_modules|\.git|dist|build|__pycache__|\.next|\.turbo|coverage)'
  else
    find "$project_path" -maxdepth 3 -not -path '*/.*' -not -path '*/node_modules/*' -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/__pycache__/*' 2>/dev/null
  fi
  echo ""

  local files_to_read=(
    "package.json"
    "requirements.txt"
    "Cargo.toml"
    "go.mod"
    "pom.xml"
    "build.gradle"
    "composer.json"
    "pyproject.toml"
    "setup.py"
    "Makefile"
  )

  for file in "${files_to_read[@]}"; do
    if [[ -f "$project_path/$file" ]]; then
      echo "=== Content of: $file ==="
      head -n 150 "$project_path/$file"
      echo ""
    fi
  done
}

_cmd_readme() {
  local lang=""
  local name=""
  local llm_args=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --lang)
        lang="$2"
        shift 2
        ;;
      --name)
        name="$2"
        shift 2
        ;;
      *)
        llm_args+=("$1")
        shift
        ;;
    esac
  done

  if [[ -z "$lang" || -z "$name" ]]; then
    t_readme_missing_args
    return 1
  fi

  local current_engine current_model_display
  current_engine=$(_get_engine)
  current_model_display=$(_model_display "$(_get_model)")

  t_readme_analyzing "$current_model_display" "$current_engine"

  local md_file md_content
  md_file=$(_get_skill_md_path "readme")
  md_content=$(_read_guidelines "$md_file")

  local project_context
  project_context=$(_gather_readme_context ".")

  local prompt_instructions
  prompt_instructions=$(t_readme_prompt_instructions "$lang")

  local prompt
  prompt="$(
    [[ -n "$md_content" ]] && echo "=== Guidelines ===
$md_content

"
    echo "=== Project Context ===
$project_context

$prompt_instructions"
  )"

  local output_file="${name}.md"

  _parse_args_for_llm "${llm_args[@]}"
  _llm_run_prompt "$prompt" "$output_file" "${LLM_THINK_FLAGS[@]}"
  
  local run_status=$?
  if [[ $run_status -ne 0 ]]; then
    t_readme_failed
    return 1
  fi

  t_readme_success "$output_file" "$lang"
}
