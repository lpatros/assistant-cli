# Behavioral checks run in isolated copies, with simulated model executors.
PROJECT_ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/assistant tests.XXXXXX") || exit 1
trap 'rm -rf "$TEST_ROOT"' EXIT
cp -R "$PROJECT_ROOT/lib" "$PROJECT_ROOT/utils" "$PROJECT_ROOT/locales" "$PROJECT_ROOT/skills" "$PROJECT_ROOT/init.sh" "$TEST_ROOT/" || exit 1
export ASSISTANT_ROOT_DIR="$TEST_ROOT" ASSISTANT_NO_UPDATE_CHECK=1
unset ASSISTANT_LIB_DIR ASSISTANT_UTILS_DIR
mkdir -p "$TEST_ROOT/custom/engines" "$TEST_ROOT/custom/locales" || exit 1
source "$TEST_ROOT/init.sh" || exit 1
cd "$TEST_ROOT" || exit 1
git init -q work || exit 1
cd work || exit 1
CHECKS=0
check() {
  local label="$1"
  shift
  if "$@"; then
    CHECKS=$((CHECKS + 1))
  else
    printf 'FAIL (%s): %s\n' "${ZSH_VERSION:-bash}" "$label" >&2
    exit 1
  fi
}
fails() { "$@" >/dev/null 2>&1; [[ $? -ne 0 ]]; }
has() { [[ "$1" == *"$2"* ]]; }
skill() {
  local origin="$1" name="$2"
  mkdir -p "$TEST_ROOT/$origin/$name"
  printf '%s\n' '---' "name: $name" "description: Test $name." '---' "Instructions for $name." > "$TEST_ROOT/$origin/$name/SKILL.md"
}
_llm_run_prompt() {
  printf '%s' "$1" > "$TEST_ROOT/prompt"
  printf '%s' "$2" > "$TEST_ROOT/output-path"
  if [[ -n "$2" ]]; then
    printf 'generated output' > "$2"
  fi
}
_get_engine() { printf '%s' mock; }
_get_model() { printf '%s' test; }
_get_model_for_engine() { printf '%s' test; }

check 'empty custom engine directory' test -z "$(_get_custom_engines)"
check 'empty custom locale directory' test -z "$(_get_custom_locales)"
check 'built-in discovery with empty custom directory' has "$(_get_available_engines)" codex
check 'locale listing with empty custom directory' _cmd_lang_list >/dev/null
if [[ -n "${ZSH_VERSION:-}" ]]; then
  zsh_nomatch_enabled() { [[ -o nomatch ]]; }
  check 'zsh nomatch option preserved' zsh_nomatch_enabled
fi

check 'initial registry' _cmd_skills list >/dev/null
skill skills plain
skill custom/skills translate
printf 'touch "%s/executed"\n' "$TEST_ROOT" > "$TEST_ROOT/custom/skills/translate/init.sh"
printf 'touch "%s/executed"\n' "$TEST_ROOT" > "$TEST_ROOT/skills/plain/init.sh"
check 'plain built-in discovery' assistant plain request
check 'plain instructions' has "$(cat "$TEST_ROOT/prompt")" 'Instructions for plain.'
check 'custom discovery' assistant translate 'Extra context'
check 'additional context' has "$(cat "$TEST_ROOT/prompt")" 'Extra context'
check 'discovery and execution never source package scripts' test ! -e "$TEST_ROOT/executed"
check 'frontmatter excluded from prompt' fails has "$(cat "$TEST_ROOT/prompt")" 'description:'
printf legacy > "$TEST_ROOT/custom/skills/legacy-assistant.md"
_resolve_skill legacy >/dev/null 2>&1
check 'legacy files not discovered' test "$?" -eq 2
check 'legacy command not executable' fails assistant legacy

skill custom/skills help
check 'reserved definition shown as error' fails assistant skills list
check 'help remains administrative' assistant help >/dev/null
check 'status remains administrative' assistant status >/dev/null
check 'aliases remain administrative' assistant --help >/dev/null
check 'reserved name import rejected' fails assistant create skill help "$TEST_ROOT/custom/skills/help/SKILL.md"

skill custom/skills commit
check 'override retains native handler' assistant commit
check 'override changes instructions' has "$(cat "$TEST_ROOT/prompt")" 'Instructions for commit.'
check 'override retains git context' has "$(cat "$TEST_ROOT/prompt")" '=== git diff (staged) ==='
check 'list shows overridden origin' has "$(_skill_registry)" overridden
check 'existing custom destination not overwritten' fails assistant create skill commit "$TEST_ROOT/custom/skills/commit/SKILL.md"

skill custom/skills broken
printf '%s\n' '---' 'name: broken' '---' 'Invalid.' > "$TEST_ROOT/custom/skills/broken/SKILL.md"
check 'missing description rejected' fails assistant broken
skill custom/skills mismatch
sed 's/name: mismatch/name: commit/' "$TEST_ROOT/custom/skills/mismatch/SKILL.md" > "$TEST_ROOT/mismatch.md"
cp "$TEST_ROOT/mismatch.md" "$TEST_ROOT/custom/skills/mismatch/SKILL.md"
check 'duplicate declared identity blocks execution' fails assistant commit
check 'folder mismatch blocks execution' fails assistant mismatch
check 'duplicates visible' has "$(_skill_registry)" conflict

printf '%s\n' '---' 'name: fresh' 'description: "Fresh instructions."' '---' 'Fresh body.' > "$TEST_ROOT/import.md"
check 'import new format' assistant create skill fresh "$TEST_ROOT/import.md" >/dev/null
check 'imported destination' test -f "$TEST_ROOT/custom/skills/fresh/SKILL.md"
check 'imported skill executes' assistant fresh
check 'incomplete readme lang' fails assistant readme --lang
check 'incomplete readme name' fails assistant readme --lang en --name
check 'option cannot consume another option' fails assistant readme --lang --name README

_analyze_single_project() { [[ "$1" != bad ]]; }
check 'parallel failure propagated' fails assistant resume good bad
check 'parallel success' assistant resume good also-good >/dev/null

# Invalid metadata is rejected without evaluation.
for bad_metadata in 'description: |' 'description: [list]' 'description: "unterminated' 'description: unquoted: value'; do
  printf '%s\n' '---' 'name: malformed' "$bad_metadata" '---' 'Body.' > "$TEST_ROOT/malformed.md"
  check "unsupported metadata: $bad_metadata" fails _skill_metadata "$TEST_ROOT/malformed.md"
done
printf '%s\n' '---' 'name: malformed' 'name: malformed' 'description: Duplicate field.' '---' > "$TEST_ROOT/malformed.md"
check 'duplicate metadata fields' fails _skill_metadata "$TEST_ROOT/malformed.md"
printf '%s\n' '---' 'name: literal' 'description: $(touch should-not-exist)' '---' 'Body.' > "$TEST_ROOT/literal.md"
check 'metadata shell syntax remains literal' _skill_metadata "$TEST_ROOT/literal.md" >/dev/null
check 'metadata never evaluated' test ! -e should-not-exist
skill custom/skills readme
check 'readme override generates a file' assistant readme --lang en --name "$TEST_ROOT/generated" >/dev/null
check 'readme output contract preserved' has "$(cat "$TEST_ROOT/generated.md")" 'generated output'
check 'readme override instructions used' has "$(cat "$TEST_ROOT/prompt")" 'Instructions for readme.'
check 'readme context preserved' has "$(cat "$TEST_ROOT/prompt")" '=== Project Context ==='
check 'unrelated valid skill survives conflicts' assistant fresh
check 'invalid listing action' fails assistant skills unknown
check 'invalid import metadata' fails assistant create skill malformed "$TEST_ROOT/malformed.md"
printf '%s\r\n' '---' 'name: windows' 'description: Windows file.' '---' 'Windows body.' > "$TEST_ROOT/windows.md"
check 'CRLF metadata' _skill_metadata "$TEST_ROOT/windows.md" >/dev/null
check 'CRLF header excluded' fails has "$(_read_guidelines "$TEST_ROOT/windows.md")" 'description:'

# Exercise real adapters and fallback with simulated CLIs.
source "$PROJECT_ROOT/lib/llm.sh"
_ensure_engine_installed() { return 0; }
_update_check_start() { :; }
_update_check_notify() { :; }
codex() { printf 'partial output'; printf 'codex diagnostic' >&2; return 7; }
copilot() { printf 'partial output'; printf 'copilot diagnostic' >&2; return 8; }
mock() { printf 'partial output'; printf 'fallback diagnostic' >&2; return 9; }
_engine_codex_run_prompt prompt "$TEST_ROOT/output" 2> "$TEST_ROOT/error"
check 'codex exit code' test "$?" -eq 7
check 'codex diagnostic replay' has "$(cat "$TEST_ROOT/error")" 'codex diagnostic'
_engine_copilot_run_prompt prompt "$TEST_ROOT/output" 2> "$TEST_ROOT/error"
check 'copilot exit code' test "$?" -eq 8
check 'copilot diagnostic replay' has "$(cat "$TEST_ROOT/error")" 'copilot diagnostic'
_llm_run_prompt prompt "$TEST_ROOT/output" 2> "$TEST_ROOT/error"
check 'fallback exit code' test "$?" -eq 9
check 'fallback diagnostic replay' has "$(cat "$TEST_ROOT/error")" 'fallback diagnostic'
printf '%s behavioral checks passed (%s).\n' "$CHECKS" "${ZSH_VERSION:-bash}"
