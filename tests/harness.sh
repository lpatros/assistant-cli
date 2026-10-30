# Exercise capabilities, final responses and native installation without model calls.
PROJECT_ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/assistant harness.XXXXXX") || exit 1
trap 'rm -rf "$TEST_ROOT"' EXIT
cp -R "$PROJECT_ROOT/lib" "$PROJECT_ROOT/utils" "$PROJECT_ROOT/locales" "$PROJECT_ROOT/skills" "$PROJECT_ROOT/init.sh" "$TEST_ROOT/" || exit 1
export ASSISTANT_ROOT_DIR="$TEST_ROOT" ASSISTANT_NO_UPDATE_CHECK=1
unset ASSISTANT_LIB_DIR ASSISTANT_UTILS_DIR
source "$TEST_ROOT/init.sh" || exit 1
CHECKS=0
check() {
  local label="$1"
  shift
  if "$@"; then CHECKS=$((CHECKS + 1)); else printf 'FAIL: %s\n' "$label" >&2; exit 1; fi
}
fails() { "$@" >/dev/null 2>&1; [[ $? -ne 0 ]]; }
has() { [[ "$1" == *"$2"* ]]; }
check 'all adapters declare prompt support' test "$(_harness_capability codex prompt)$(_harness_capability copilot prompt)$(_harness_capability opencode prompt)$(_harness_capability agy prompt)$(_harness_capability ollama prompt)" = yesyesyesyesyes
check 'ollama does not use project tools in this adapter' test "$(_harness_capability ollama workspace_tools)" = no
check 'only codex supports installation' test "$(_harness_capability codex native_skills)$(_harness_capability opencode native_skills)$(_harness_capability copilot native_skills)$(_harness_capability ollama native_skills)$(_harness_capability agy native_skills)" = yesnononono
check 'legacy custom engine still runs prompts' test "$(_harness_capability legacy prompt)" = yes
check 'legacy custom capabilities remain unknown' test "$(_harness_capability legacy workspace_tools)" = unknown
check 'capability listing' assistant harness capabilities >/dev/null
check 'engine alias capability listing' assistant engine capabilities codex >/dev/null
check 'unknown harness rejected' fails assistant harness capabilities absent
check 'harness selection' assistant harness codex >/dev/null
check 'same persisted engine setting' has "$(cat "$ASSISTANT_CONFIG_FILE")" 'ASSISTANT_ENGINE="codex"'
check 'engine alias selection' assistant engine ollama >/dev/null
check 'alias changes same configuration' test "$(_get_engine)" = ollama
check 'reserved harness name' _skill_is_reserved harness

mkdir -p "$TEST_ROOT/project" "$TEST_ROOT/user" "$TEST_ROOT/source-project"
git init -q "$TEST_ROOT/project" || exit 1
cd "$TEST_ROOT/project" || exit 1
check 'missing explicit scope' fails assistant skills install commit --harness codex
check 'missing explicit target' fails assistant skills install commit --scope project
check 'unsupported installation' fails assistant skills install commit --harness ollama --scope project
check 'invalid option value' fails assistant skills install commit --harness codex --scope
check 'user scope cannot take project directory' fails assistant skills install commit --harness codex --scope user --project "$TEST_ROOT/project"
check 'official user lookup path' test "$(_engine_codex_skill_root user '')" = "$(cd -- "$HOME" && pwd -P)/.agents/skills"
# Redirect user-scope writes only in the fixture, without changing HOME.
_engine_codex_skill_root() {
  if [[ "$1" == user ]]; then printf '%s/user/.agents/skills\n' "$TEST_ROOT"; else printf '%s/.agents/skills\n' "$2"; fi
}
check 'project preview' assistant skills install commit --harness codex --scope project --dry-run > "$TEST_ROOT/preview"
check 'preview contains destination' has "$(cat "$TEST_ROOT/preview")" "$TEST_ROOT/project/.agents/skills/commit"
check 'preview does not create directories' test ! -e .agents
assistant skills install commit --harness codex --scope project --dry-run > "$TEST_ROOT/preview-again"
check 'rendering and provenance preview are deterministic' test "$(cat "$TEST_ROOT/preview")" = "$(cat "$TEST_ROOT/preview-again")"
check 'install native commit' assistant skills install commit --harness codex --scope project >/dev/null
check 'native skill is exported unchanged' cmp -s "$TEST_ROOT/skills/commit/SKILL.md" .agents/skills/commit/SKILL.md
check 'no shell handler is installed' test ! -e .agents/skills/commit/init.sh
check 'native format remains valid' _skill_metadata .agents/skills/commit/SKILL.md >/dev/null
check 'provenance records source hash' test "$(_native_record_value .agents/skills/commit/.assistant-install.tsv source_hash)" = "$(_native_digest "$TEST_ROOT/skills/commit/SKILL.md")"
check 'verify native installation' assistant skills verify commit --harness codex --scope project >/dev/null
check 'existing installation not overwritten' fails assistant skills install commit --harness codex --scope project
check 'removal preview' assistant skills remove commit --harness codex --scope project --dry-run >/dev/null
check 'preview preserves installation' test -f .agents/skills/commit/SKILL.md
printf '\nLocal edit.\n' >> .agents/skills/commit/SKILL.md
check 'edited file cannot be removed' fails assistant skills remove commit --harness codex --scope project
check 'edited file remains' has "$(cat .agents/skills/commit/SKILL.md)" 'Local edit.'
check 'edited file fails verification' fails assistant skills verify commit --harness codex --scope project
check 'user preview' assistant skills install readme --harness codex --scope user --dry-run >/dev/null
check 'user preview creates no destination' test ! -e "$TEST_ROOT/user/.agents"
check 'user installation' assistant skills install readme --harness codex --scope user >/dev/null
check 'user verification' assistant skills verify readme --harness codex --scope user >/dev/null
check 'readme is exported unchanged' cmp -s "$TEST_ROOT/skills/readme/SKILL.md" "$TEST_ROOT/user/.agents/skills/readme/SKILL.md"
check 'safe user removal' assistant skills remove readme --harness codex --scope user >/dev/null
check 'removed skill directory' test ! -e "$TEST_ROOT/user/.agents/skills/readme"
check 'missing record cannot be removed' fails assistant skills remove commit --harness codex --scope user
check 'install branch for provenance check' assistant skills install branch --harness codex --scope project >/dev/null
printf 'edited\n' >> .agents/skills/branch/.assistant-install.tsv
check 'edited manifest is preserved' fails assistant skills remove branch --harness codex --scope project
check 'install resume for additional file check' assistant skills install resume --harness codex --scope project >/dev/null
printf local > .agents/skills/resume/local.txt
check 'additional files prevent removal' fails assistant skills remove resume --harness codex --scope project
check 'additional files preserved' test -f .agents/skills/resume/local.txt
mkdir -p "$TEST_ROOT/linked-project" "$TEST_ROOT/elsewhere"
ln -s "$TEST_ROOT/elsewhere" "$TEST_ROOT/linked-project/.agents"
check 'symlink destination rejected' fails assistant skills install commit --harness codex --scope project --project "$TEST_ROOT/linked-project"
check 'symlink target untouched' test ! -e "$TEST_ROOT/elsewhere/skills"
mkdir -p "$TEST_ROOT/source-project/.agents/skills/other-folder"
cp "$TEST_ROOT/skills/commit/SKILL.md" "$TEST_ROOT/source-project/.agents/skills/other-folder/SKILL.md"
check 'duplicate native identity rejected' fails assistant skills install commit --harness codex --scope project --project "$TEST_ROOT/source-project"
mkdir -p "$TEST_ROOT/custom/skills/custom-test"
printf '%s\n' '---' 'name: custom-test' 'description: Custom instructions.' '---' 'Custom body.' > "$TEST_ROOT/custom/skills/custom-test/SKILL.md"
check 'custom instructions installation' assistant skills install custom-test --harness codex --scope user >/dev/null
check 'custom body preserved' has "$(cat "$TEST_ROOT/user/.agents/skills/custom-test/SKILL.md")" 'Custom body.'
check 'custom installation removable after source disappears' test -f "$TEST_ROOT/custom/skills/custom-test/SKILL.md"
mv "$TEST_ROOT/custom/skills/custom-test/SKILL.md" "$TEST_ROOT/custom-source-moved.md"
check 'removal does not depend on source' assistant skills remove custom-test --harness codex --scope user >/dev/null

mkdir -p "$TEST_ROOT/custom/skills/commit"
cp "$TEST_ROOT/skills/commit/SKILL.md" "$TEST_ROOT/custom/skills/commit/SKILL.md"
printf '\nCustom commit marker.\n' >> "$TEST_ROOT/custom/skills/commit/SKILL.md"
check 'native installation uses effective custom instructions' assistant skills install commit --harness codex --scope user >/dev/null
check 'custom override exported' has "$(cat "$TEST_ROOT/user/.agents/skills/commit/SKILL.md")" 'Custom commit marker.'
check 'custom override receives no hidden instructions' cmp -s "$TEST_ROOT/custom/skills/commit/SKILL.md" "$TEST_ROOT/user/.agents/skills/commit/SKILL.md"
check 'custom override remains removable' assistant skills remove commit --harness codex --scope user >/dev/null

# Exercise production adapters using local CLI doubles.
_get_model_for_engine() { printf test; }
_get_think_flag() { printf '%s' --think; }
MODE=success
codex() {
  local output='' arg
  while [[ $# -gt 0 ]]; do
    arg="$1"; shift
    if [[ "$arg" == --output-last-message ]]; then output="$1"; shift; fi
  done
  printf 'trace on stdout\n'
  printf 'codex diagnostic\n' >&2
  [[ "$MODE" != fail ]] || return 7
  [[ "$MODE" != empty ]] || return 0
  printf '# Final document\n' > "$output"
}
check 'codex clean response' _engine_codex_run_prompt prompt "$TEST_ROOT/output" 2> "$TEST_ROOT/error"
check 'codex final only' test "$(cat "$TEST_ROOT/output")" = '# Final document'
check 'codex stdout is final response only' test "$(_engine_codex_run_prompt prompt '' 2> "$TEST_ROOT/error")" = '# Final document'
MODE=fail
_engine_codex_run_prompt prompt "$TEST_ROOT/output" 2> "$TEST_ROOT/error"
check 'codex preserves exit code' test "$?" -eq 7
check 'failed call preserves document' test "$(cat "$TEST_ROOT/output")" = '# Final document'
check 'diagnostic stays on stderr' has "$(cat "$TEST_ROOT/error")" 'codex diagnostic'
MODE=empty
check 'empty final response rejected' fails _engine_codex_run_prompt prompt "$TEST_ROOT/output"
MODE=success
copilot() {
  [[ "$*" == *--silent* ]] || return 4
  [[ "$MODE" != fail ]] || return 10
  printf 'Copilot final\n'
}
check 'copilot requests response only' _engine_copilot_run_prompt prompt "$TEST_ROOT/output"
check 'copilot final response' test "$(cat "$TEST_ROOT/output")" = 'Copilot final'
agy() {
  [[ "$*" == *--print* && "$*" == *'--output-format text'* ]] || return 4
  [[ "$MODE" != fail ]] || return 11
  printf 'AGY final\n'
}
check 'agy print mode' _engine_agy_run_prompt prompt "$TEST_ROOT/output"
ollama() {
  [[ "$*" == *--hidethinking* ]] || return 4
  [[ "$MODE" != fail ]] || return 12
  printf 'Ollama final\n'
}
check 'ollama hides reasoning in documents' _engine_ollama_run_prompt prompt "$TEST_ROOT/output"
if command -v jq >/dev/null 2>&1; then
  opencode() {
    [[ "$*" == *'--format json'* ]] || return 4
    [[ "$MODE" != fail ]] || return 13
    if [[ "$MODE" == malformed ]]; then printf 'not json\n'; return 0; fi
    if [[ "$MODE" == event_error ]]; then printf '%s\n' '{"type":"error","error":{"message":"failed upstream"}}'; return 0; fi
    printf '%s\n' '{"type":"step_start"}' '{"type":"text","part":{"messageID":"old","text":"intermediate commentary"}}' '{"type":"tool_use","part":{"text":"tool output"}}' '{"type":"step_start"}' '{"type":"reasoning","part":{"text":"reasoning"}}' '{"type":"text","part":{"messageID":"final","text":"Final OpenCode"}}'
  }
  check 'opencode parses final step' _engine_opencode_run_prompt prompt "$TEST_ROOT/output"
  check 'opencode excludes commentary tools and reasoning' test "$(cat "$TEST_ROOT/output")" = 'Final OpenCode'
  MODE=malformed
  check 'malformed stream rejected' fails _engine_opencode_run_prompt prompt "$TEST_ROOT/output"
  MODE=event_error
  check 'upstream error event rejected' fails _engine_opencode_run_prompt prompt "$TEST_ROOT/output"
else
  check 'missing jq reports failure before execution' fails _engine_opencode_run_prompt prompt "$TEST_ROOT/output"
fi
MODE=fail
_engine_copilot_run_prompt prompt "$TEST_ROOT/output" 2> "$TEST_ROOT/error"
check 'copilot preserves executor failure code' test "$?" -eq 10
_engine_agy_run_prompt prompt "$TEST_ROOT/output" 2> "$TEST_ROOT/error"
check 'agy preserves executor failure code' test "$?" -eq 11
_engine_ollama_run_prompt prompt "$TEST_ROOT/output" 2> "$TEST_ROOT/error"
check 'ollama preserves executor failure code' test "$?" -eq 12
if command -v jq >/dev/null 2>&1; then
  _engine_opencode_run_prompt prompt "$TEST_ROOT/output" 2> "$TEST_ROOT/error"
  check 'opencode preserves executor failure code' test "$?" -eq 13
fi
MODE=success
whitespace_only() { printf ' \n\t\n'; }
check 'whitespace-only final response is rejected' fails _harness_capture_text test "$TEST_ROOT/output" whitespace_only

without_jq() (
  command() {
    if [[ "$1" == -v && "$2" == jq ]]; then return 1; fi
    builtin command "$@"
  }
  _engine_opencode_run_prompt prompt "$TEST_ROOT/output"
)
check 'missing jq fails without invoking opencode' fails without_jq
without_checksum() (
  command() {
    if [[ "$1" == -v && ( "$2" == sha256sum || "$2" == shasum ) ]]; then return 1; fi
    builtin command "$@"
  }
  _native_digest "$TEST_ROOT/init.sh"
)
check 'missing checksum implementation fails clearly' fails without_checksum

# A prompt-only custom adapter is usable through the legacy command contract.
_engine_batchonly_capabilities() { printf '%s\n' prompt; }
_engine_batchonly_run_prompt() { printf '%s\n' 'Custom final response'; }
_engine_batchonly_is_installed() { return 0; }
_get_engine() { printf batchonly; }
_get_model() { printf model; }
_update_check_start() { :; }
_update_check_notify() { printf 'Update notice\n'; }
check 'explicit messages use prompt capability' _llm_run_interactive 'request' > "$TEST_ROOT/custom-output" 2> "$TEST_ROOT/custom-error"
check 'notices do not pollute stdout' test "$(cat "$TEST_ROOT/custom-output")" = 'Custom final response'
check 'notices use stderr' has "$(cat "$TEST_ROOT/custom-error")" 'Update notice'
check 'unsupported interactive mode fails clearly' fails _llm_run_interactive
_get_engine() { printf missingcustom; }
_engine_missingcustom_is_installed() { return 1; }
_llm_run_prompt prompt '' > "$TEST_ROOT/custom-output" 2> "$TEST_ROOT/custom-error"
check 'missing CLI exits without prompting' test "$?" -eq 127
check 'missing CLI diagnostic is on stderr' test -s "$TEST_ROOT/custom-error"
check 'missing CLI produces no response' test ! -s "$TEST_ROOT/custom-output"

printf '%s harness and installation checks passed (%s).\n' "$CHECKS" "${ZSH_VERSION:-bash}"
