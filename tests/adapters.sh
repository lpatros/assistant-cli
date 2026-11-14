# Exercise adapter commands in an isolated installation without running LLM CLIs.
PROJECT_ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/assistant adapters.XXXXXX") || exit 1
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
row() {
  printf '%s\n' "$1" | awk -F ' *\\| *' -v name="$2" '$1 == name { print $1 "|" $2 "|" $3 "|" $4 }'
}
without_prompt() (
  _prompt_read() { printf unexpected > "$TEST_ROOT/prompted"; return 1; }
  assistant "$@"
)

check 'adapters is a reserved command' _skill_is_reserved adapters
check 'initial selection' assistant adapters codex >/dev/null
BEFORE=$(cat "$ASSISTANT_CONFIG_FILE")
LIST=$(without_prompt adapters --list)
check 'built-in origin and active marker' has "$(row "$LIST" codex)" 'codex|built-in|'
check 'selected adapter marked active' test "$(row "$LIST" codex | awk -F '|' '{ print $4 }')" = yes
check 'list uses shared table layout' has "$LIST" '-+-'
for alias in adapters engine harness; do
  check "$alias noninteractive --list" test "$(without_prompt "$alias" --list)" = "$LIST"
  check "$alias list synonym" test "$(without_prompt "$alias" list)" = "$LIST"
  check "$alias default status" test "$(assistant "$alias")" = "$(assistant adapters status)"
  check "$alias capabilities" test "$(assistant "$alias" capabilities codex)" = "$(assistant adapters capabilities codex)"
  check "$alias rejects unknown selection" fails assistant "$alias" absent
  check "$alias rejects unknown capabilities" fails assistant "$alias" capabilities absent
  check "$alias rejects list arguments" fails assistant "$alias" --list extra
  check "$alias rejects status arguments" fails assistant "$alias" status extra
  check "$alias rejects capabilities arguments" fails assistant "$alias" capabilities codex extra
  check "$alias rejects menu arguments" fails assistant "$alias" select extra
  check "$alias rejects selection arguments" fails assistant "$alias" codex extra
  check "$alias rejects flags" fails assistant "$alias" --unknown
done
check 'empty custom list contains only header and separator' test "$(without_prompt custom adapters --list | wc -l | tr -d ' ')" = 2
check 'empty custom menu fails without prompting' fails without_prompt custom adapters select
check 'custom status with built-in active' has "$(assistant custom adapters status)" 'No custom adapter is active.'
check 'read-only and invalid commands preserve configuration' test "$(cat "$ASSISTANT_CONFIG_FILE")" = "$BEFORE"
check 'listing never prompts' test ! -e "$TEST_ROOT/prompted"

mkdir -p "$TEST_ROOT/custom/adapters/test-custom" "$TEST_ROOT/custom/adapters/unavailable" "$TEST_ROOT/custom/adapters/codex"
cat > "$TEST_ROOT/custom/adapters/test-custom/init.sh" <<'ADAPTER'
_engine_test_custom_binary() { printf '%s\n' printf; }
_engine_test_custom_capabilities() { printf '%s\n' prompt; }
ADAPTER
cat > "$TEST_ROOT/custom/adapters/unavailable/init.sh" <<'ADAPTER'
_engine_unavailable_binary() { printf '%s\n' assistant-test-missing-executable; }
ADAPTER
cat > "$TEST_ROOT/custom/adapters/codex/init.sh" <<'ADAPTER'
_engine_codex_is_installed() { return 1; }
ADAPTER
_load_adapter_modules
LIST=$(without_prompt adapters --list)
CUSTOM_LIST=$(without_prompt custom adapters --list)
check 'discovered custom binary available' test "$(row "$LIST" test-custom)" = 'test-custom|custom|yes|no'
check 'missing custom executable visible' test "$(row "$LIST" unavailable)" = 'unavailable|custom|no|no'
check 'custom override takes precedence' test "$(row "$LIST" codex)" = 'codex|custom|no|yes'
check 'override has one row' test "$(printf '%s\n' "$LIST" | awk -F ' *\\| *' '$1 == "codex" { count++ } END { print count }')" = 1
check 'custom list excludes built-ins' test "$(row "$CUSTOM_LIST" ollama)" = ''
check 'all custom rows retained' test "$(printf '%s\n' "$CUSTOM_LIST" | wc -l | tr -d ' ')" = 5
check 'custom capabilities excludes built-ins' test "$(assistant custom adapters capabilities | awk -F ' *\\| *' '$1 == "ollama" { print $1 }')" = ''
for alias in adapters engine harness engines; do
  _set_engine codex
  check "custom $alias list alias" test "$(without_prompt custom "$alias" --list)" = "$CUSTOM_LIST"
  check "custom $alias list synonym" test "$(without_prompt custom "$alias" list)" = "$CUSTOM_LIST"
  check "custom $alias rejects built-in selection" fails assistant custom "$alias" ollama
  check "custom $alias rejects built-in capabilities" fails assistant custom "$alias" capabilities ollama
  check "custom $alias capabilities alias" test "$(assistant custom "$alias" capabilities test-custom)" = "$(assistant adapters capabilities test-custom)"
  check "custom $alias named selection" assistant custom "$alias" test-custom >/dev/null
  check "custom $alias changes global selection" test "$(_get_engine)" = test-custom
  check "custom $alias status alias" test "$(assistant custom "$alias" status)" = "$(assistant adapters status)"
done
check 'custom selection reflected globally' test "$(row "$(assistant adapters --list)" test-custom)" = 'test-custom|custom|yes|yes'
for alias in adapters engine harness; do
  check "$alias named selection" assistant "$alias" ollama >/dev/null
  check "$alias updates same persisted setting" has "$(cat "$ASSISTANT_CONFIG_FILE")" 'ASSISTANT_ENGINE="ollama"'
done
check 'missing executable does not prevent configuration' assistant adapters unavailable >/dev/null
check 'missing executable still marked active' test "$(row "$(assistant adapters --list)" unavailable)" = 'unavailable|custom|no|yes'
check 'no read-only command requested input' test ! -e "$TEST_ROOT/prompted"

# Replace terminal input with fixture stdin while exercising the real menus.
_prompt_read() { read -r "$1"; }
printf '%s\n' test-custom > "$TEST_ROOT/choice"
for alias in adapters engine harness; do
  check "$alias select menu" assistant "$alias" select < "$TEST_ROOT/choice" > "$TEST_ROOT/menu"
  check "$alias menu selected name" test "$(_get_engine)" = test-custom
  check "$alias menu includes built-ins" has "$(cat "$TEST_ROOT/menu")" ollama
  check "custom $alias select menu" assistant custom "$alias" select < "$TEST_ROOT/choice" > "$TEST_ROOT/menu"
  check "custom $alias menu excludes built-ins" test "$(awk '/\) .*ollama/ { print }' "$TEST_ROOT/menu")" = ''
done
BEFORE=$(cat "$ASSISTANT_CONFIG_FILE")
check 'select handles end of input' assistant adapters select < /dev/null >/dev/null
check 'cancelled menu preserves configuration' test "$(cat "$ASSISTANT_CONFIG_FILE")" = "$BEFORE"
for lang in en es pt-br; do
  _set_lang "$lang"
  check "$lang list renders" assistant adapters --list >/dev/null
  check "$lang capabilities renders" assistant adapters capabilities >/dev/null
done
printf '%s adapter checks passed (%s).\n' "$CHECKS" "${ZSH_VERSION:-bash}"
