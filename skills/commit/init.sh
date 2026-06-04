_cmd_commit() {
  local current_engine current_model_display
  current_engine=$(_get_engine)
  current_model_display=$(_model_display "$(_get_model)")

  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    t_commit_not_git_repo
    return 1
  fi

  local md_file md_content
  md_file=$(_get_skill_md_path "commit")
  md_content=$(_read_guidelines "$md_file")

  local git_status git_diff_staged git_diff_unstaged
  git_status=$(git status 2>&1)
  git_diff_staged=$(git diff --cached 2>&1)
  git_diff_unstaged=$(git diff --stat 2>&1)

  t_commit_analyzing "$current_model_display" "$current_engine"

  local prompt_instructions prompt_staged_label prompt_unstaged_label
  prompt_instructions=$(t_commit_prompt_instructions)
  prompt_staged_label=$(t_commit_no_staged_files)
  prompt_unstaged_label=$(t_commit_no_unstaged_files)

  local prompt
  prompt="$(
    [[ -n "$md_content" ]] && echo "=== Commit Guidelines ===
$md_content

"
    echo "=== git status ===
$git_status

=== git diff (staged) ===
${git_diff_staged:-"$prompt_staged_label"}

=== git diff --stat (unstaged) ===
${git_diff_unstaged:-"$prompt_unstaged_label"}

$prompt_instructions"
  )"

  _parse_args_for_llm "$@"
  _llm_run_prompt "$prompt" "" "${LLM_THINK_FLAGS[@]}"
}
