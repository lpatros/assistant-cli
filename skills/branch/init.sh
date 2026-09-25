_branch_base_ref() {
  local current_branch="$1"
  local candidate

  for candidate in main master develop dev; do
    [[ "$candidate" == "$current_branch" ]] && continue
    if git show-ref --verify --quiet "refs/heads/$candidate" ||
      git show-ref --verify --quiet "refs/remotes/origin/$candidate"; then
      echo "$candidate"
      return 0
    fi
  done

  echo "$current_branch"
}

_cmd_branch() {
  local current_engine current_model_display
  current_engine=$(_get_engine)
  current_model_display=$(_model_display "$(_get_model)")

  if ! _is_installed "git"; then
    t_git_not_installed
    return 1
  fi

  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    t_commit_not_git_repo
    return 1
  fi

  local md_file md_content
  md_file=$(_get_skill_md_path "branch")
  md_content=$(_read_guidelines "$md_file")

  local current_branch base_branch
  current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo "(unknown)")
  base_branch=$(_branch_base_ref "$current_branch")

  local git_status git_branches git_log git_diff_staged git_diff_unstaged git_diff_stat
  git_status=$(git status 2>&1)
  git_branches=$(git branch --format='%(refname:short)' 2>&1)
  git_log=$(git log --oneline -15 2>&1)
  git_diff_staged=$(git diff --cached 2>&1)
  git_diff_unstaged=$(git diff 2>&1)
  git_diff_stat=$(git diff --stat 2>&1)

  t_branch_analyzing "$current_engine" "$current_model_display"

  local prompt_instructions prompt_staged_label prompt_unstaged_label prompt_no_branches
  prompt_instructions=$(t_branch_prompt_instructions)
  prompt_staged_label=$(t_commit_no_staged_files)
  prompt_unstaged_label=$(t_commit_no_unstaged_files)
  prompt_no_branches=$(t_branch_no_branches)

  _parse_args_for_llm "$@"

  local prompt
  prompt="$(
    [[ -n "$md_content" ]] && echo "=== Branch Guidelines ===
$md_content

"
    echo "=== Current branch ===
$current_branch

=== Base branch (reference for new branches) ===
$base_branch

=== Existing local branches ===
${git_branches:-"$prompt_no_branches"}

=== git status ===
$git_status

=== git diff (staged) ===
${git_diff_staged:-"$prompt_staged_label"}

=== git diff (unstaged) ===
${git_diff_unstaged:-"$prompt_unstaged_label"}

=== git diff --stat (unstaged) ===
${git_diff_stat:-"$prompt_unstaged_label"}

=== git log --oneline -15 ===
$git_log

$prompt_instructions"
    if [[ ${#LLM_CLEAN_ARGS[@]} -gt 0 ]]; then
      echo "
=== Additional context from user ===
${LLM_CLEAN_ARGS[*]}"
    fi
  )"

  _llm_run_prompt "$prompt" "" "${LLM_THINK_FLAGS[@]}"
}
