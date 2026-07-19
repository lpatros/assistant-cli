_gather_project_context() {
  local project_path="$1"
  local project_name="$2"

  echo "=== Project Name: $project_name ==="
  echo "=== Location: $project_path ==="
  echo ""

  echo "=== Directory Structure (Top Level) ==="
  if command -v tree &>/dev/null; then
    tree -L 2 --noreport "$project_path"
  fi
  if ! command -v tree &>/dev/null; then
    find "$project_path" -maxdepth 2 -not -path '*/.*' 2>/dev/null
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
    "README.md"
    "readme.md"
    "README.txt"
  )

  for file in "${files_to_read[@]}"; do
    if [[ -f "$project_path/$file" ]]; then
      echo "=== Content of: $file ==="
      head -n 150 "$project_path/$file"
      echo ""
    fi
  done
}

_analyze_single_project() {
  local proj="$1"
  local output_dir="$2"
  local md_content="$3"
  shift 3
  local think_flags=("$@")

  if [[ ! -d "$proj" ]]; then
    t_resume_project_dir_not_found "$proj"
    return 1
  fi

  local project_name
  project_name=$(basename "$(cd "$proj" && pwd)")

  t_resume_analyzing "$project_name"

  local project_context
  project_context=$(_gather_project_context "$proj" "$project_name")

  local prompt_instructions
  prompt_instructions=$(t_resume_prompt_instructions)

  local prompt
  prompt="$(
    [[ -n "$md_content" ]] && echo "=== Guidelines ===
$md_content

"
    echo "=== Project Context ===
$project_context

$prompt_instructions"
  )"

  local output_file="$output_dir/$project_name.md"

  _llm_run_prompt "$prompt" "$output_file" "${think_flags[@]}"
  local status=$?

  if [[ $status -ne 0 ]]; then
    t_resume_failed "$project_name"
    return 1
  fi

  t_resume_success "$project_name" "$output_file"
}

_cmd_resume() {
  local current_engine current_model_display
  current_engine=$(_get_engine)
  current_model_display=$(_model_display "$(_get_model)")

  local md_file md_content
  md_file=$(_get_skill_md_path "resume")
  md_content=$(_read_guidelines "$md_file")

  _parse_args_for_llm "$@"
  local projects=("${LLM_CLEAN_ARGS[@]}")
  local think_flags=("${LLM_THINK_FLAGS[@]}")

  if [[ ${#projects[@]} -eq 0 ]]; then
    projects+=(".")
  fi

  local output_dir="./projects-resumes"
  mkdir -p "$output_dir"

  t_resume_starting "$current_model_display" "$current_engine"

  if [[ ${#projects[@]} -gt 1 ]]; then
    t_resume_parallel_info "${#projects[@]}"
    for proj in "${projects[@]}"; do
      _analyze_single_project "$proj" "$output_dir" "$md_content" "${think_flags[@]}" &
    done
    wait
    t_resume_parallel_done
    return 0
  fi

  local first_project
  for p in "${projects[@]}"; do
    first_project="$p"
    break
  done
  _analyze_single_project "$first_project" "$output_dir" "$md_content" "${think_flags[@]}"
}
