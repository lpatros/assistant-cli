# Exercise managed updates and discovery using isolated local files only.
PROJECT_ROOT="$(cd -- "$(dirname -- "$0")/.." && pwd)"
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/assistant skill updates.XXXXXX") || exit 1
trap 'rm -rf "$TEST_ROOT"' EXIT
cp -R "$PROJECT_ROOT/lib" "$PROJECT_ROOT/utils" "$PROJECT_ROOT/locales" "$PROJECT_ROOT/skills" "$PROJECT_ROOT/init.sh" "$TEST_ROOT/" || exit 1
export ASSISTANT_ROOT_DIR="$TEST_ROOT" ASSISTANT_NO_UPDATE_CHECK=1
# Keep semantic column checks independent of the invoking terminal layout.
COLUMNS=160
unset ASSISTANT_LIB_DIR ASSISTANT_UTILS_DIR
source "$TEST_ROOT/init.sh" || exit 1
CHECKS=0
check() {
  local label="$1"
  shift
  if "$@"; then CHECKS=$((CHECKS + 1)); else printf 'FAIL: %s\n' "$label" >&2; exit 1; fi
}
fails() { "$@" > "$TEST_ROOT/failure" 2>&1; [[ $? -ne 0 ]]; }
has() { [[ "$1" == *"$2"* ]]; }
row() { printf '%s\n' "$1" | awk -F ' *\\| *' -v name="$2" '$1 == name { print $5 "|" $6 "|" $7 }'; }
_engine_codex_skill_root() {
  if [[ "$1" == user ]]; then printf '%s/user/.agents/skills\n' "$TEST_ROOT"; else printf '%s/.agents/skills\n' "$2"; fi
}
PROJ="$TEST_ROOT/repository"
mkdir -p "$PROJ/module/deep" "$TEST_ROOT/user" "$TEST_ROOT/skills/sample"
git init -q "$PROJ" || exit 1
SOURCE="$TEST_ROOT/skills/sample/SKILL.md"
printf '%s\n' '---' 'name: sample' 'description: Test skill.' '---' 'Version one.' > "$SOURCE"
git init -q "$TEST_ROOT" || exit 1
git -C "$TEST_ROOT" -c user.name=Test -c user.email=test@example.invalid add -- skills/sample/SKILL.md || exit 1
git -C "$TEST_ROOT" -c user.name=Test -c user.email=test@example.invalid commit -qm 'fixture' || exit 1
cd "$PROJ" || exit 1
DEST="$PROJ/.agents/skills/sample"
BACKUP=$(_native_backup_path "$PROJ/.agents/skills" codex sample)
cmd() { assistant skills "$1" sample --harness codex --scope project --project "$PROJ" "${@:2}"; }
check 'diagnostics require adapter' fails assistant skills installed
check 'writes require scope' fails assistant skills update sample --harness codex
check 'writes reject all scopes' fails assistant skills update sample --harness codex --scope all
check 'adapter identifiers cannot traverse backup paths' fails assistant skills update sample --harness ../../codex --scope project
check 'read-only commands reject dry-run' fails assistant skills status --harness codex --dry-run
check 'missing installation status fails' fails assistant skills status sample --harness codex
check 'empty inventory renders' assistant skills installed --harness codex > "$TEST_ROOT/inventory"
check 'empty inventory has two lines' test "$(wc -l < "$TEST_ROOT/inventory" | tr -d ' ')" = 2
check 'installation fixture' cmd install >/dev/null
cp -R "$DEST" "$TEST_ROOT/one"
check 'restoration requires a previous version' fails cmd restore
check 'initial status' test "$(row "$(assistant skills status sample --harness codex)" sample)" = 'no|no|no'
check 'revision recorded' test "$(_native_record_value "$DEST/.assistant-install.tsv" source_version)" = "$(git -C "$TEST_ROOT" rev-parse HEAD)"
printf '\nVersion two.\n' >> "$SOURCE"
check 'status detects content change' test "$(row "$(assistant skills status sample --harness codex)" sample)" = 'no|yes|no'
check 'diff' cmd diff > "$TEST_ROOT/diff"
check 'diff includes source change' has "$(cat "$TEST_ROOT/diff")" '+Version two.'
check 'update preview' cmd update --dry-run > "$TEST_ROOT/preview"
check 'preview preserves installation' cmp -s "$DEST/SKILL.md" "$TEST_ROOT/one/SKILL.md"
check 'preview preserves record' cmp -s "$DEST/.assistant-install.tsv" "$TEST_ROOT/one/.assistant-install.tsv"
check 'preview creates no backup' test ! -e "$BACKUP"
check 'update' cmd update >/dev/null
check 'installed contents match registered source' cmp -s "$DEST/SKILL.md" "$SOURCE"
check 'backup stores original' cmp -s "$BACKUP/SKILL.md" "$TEST_ROOT/one/SKILL.md"
check 'backup validates' _native_verify_files "$BACKUP" sample codex project
check 'updated installation validates' cmd verify >/dev/null
check 'modified source revision recorded' has "$(_native_record_value "$DEST/.assistant-install.tsv" source_version)" ':modified'
check 'status includes backup' test "$(row "$(assistant skills status sample --harness codex)" sample)" = 'no|no|yes'
cp -R "$DEST" "$TEST_ROOT/two"
check 'unchanged update succeeds' cmd update >/dev/null
check 'unchanged update preserves backup' cmp -s "$BACKUP/SKILL.md" "$TEST_ROOT/one/SKILL.md"
git -C "$TEST_ROOT" -c user.name=Test -c user.email=test@example.invalid commit -qam 'content fixture' || exit 1
check 'revision-only change is not an update' test "$(row "$(assistant skills status sample --harness codex)" sample)" = 'no|no|yes'
printf '\nVersion three.\n' >> "$SOURCE"
check 'second update' cmd update >/dev/null
check 'backup replaced by immediately previous version' cmp -s "$BACKUP/SKILL.md" "$TEST_ROOT/two/SKILL.md"
cp -R "$DEST" "$TEST_ROOT/three"
check 'restore preview' cmd restore --dry-run >/dev/null
check 'restore preview preserves installation' cmp -s "$DEST/SKILL.md" "$SOURCE"
check 'restore' cmd restore >/dev/null
check 'previous version restored' cmp -s "$DEST/SKILL.md" "$TEST_ROOT/two/SKILL.md"
check 'restored provenance validates' cmd verify >/dev/null
check 'restoration keeps single undo slot' cmp -s "$BACKUP/SKILL.md" "$TEST_ROOT/three/SKILL.md"
check 'restore can undo restoration' cmd restore >/dev/null
check 'third version restored' cmp -s "$DEST/SKILL.md" "$TEST_ROOT/three/SKILL.md"
printf '\nLocal manual edit.\n' >> "$DEST/SKILL.md"
printf '\nVersion four.\n' >> "$SOURCE"
check 'local edit blocks update' fails cmd update
check 'blocked update still shows differences' has "$(cat "$TEST_ROOT/failure")" '-Local manual edit.'
check 'local edits remain' has "$(cat "$DEST/SKILL.md")" 'Local manual edit.'
check 'local edit blocks restore' fails cmd restore
check 'local edit blocks removal' fails cmd remove
check 'local edit visible in status' test "$(row "$(assistant skills status sample --harness codex)" sample)" = 'yes|yes|yes'
check 'diff permits inspection of local edits' cmd diff >/dev/null
cp "$TEST_ROOT/three/SKILL.md" "$DEST/SKILL.md"
mkdir -p "$TEST_ROOT/custom/skills/sample"
cp "$SOURCE" "$TEST_ROOT/custom/skills/sample/SKILL.md"
printf '\nCustom alternative.\n' >> "$TEST_ROOT/custom/skills/sample/SKILL.md"
check 'pinned update' cmd update > "$TEST_ROOT/pinned" 2> "$TEST_ROOT/notice"
check 'custom alternative triggers warning' has "$(cat "$TEST_ROOT/notice")" 'effective Assistant source'
check 'recorded source remains selected' cmp -s "$DEST/SKILL.md" "$SOURCE"
check 'origin does not change' test "$(_native_record_value "$DEST/.assistant-install.tsv" source)" = "$SOURCE"
cp -R "$DEST" "$TEST_ROOT/four"
printf '\nVersion five.\n' >> "$SOURCE"
# Fail one publish move, then allow rollback moves to exercise transaction recovery.
failed_publish() (
  local failed=no
  mv() {
    if [[ "$failed" == no && "$2" == */next && "$3" == "$DEST" ]]; then failed=yes; return 1; fi
    command mv "$@"
  }
  cmd update
)
check 'failed publish reports failure' fails failed_publish
check 'failed publish restores current contents' cmp -s "$DEST/SKILL.md" "$TEST_ROOT/four/SKILL.md"
check 'failed publish restores current provenance' cmd verify >/dev/null
check 'failed publish preserves previous backup' cmp -s "$BACKUP/SKILL.md" "$TEST_ROOT/three/SKILL.md"
check 'failed publish leaves no transaction' test -z "$(find "$PROJ/.agents" -name '.assistant-skill-transaction.*' -print)"
failed_backup_move() (
  local failed=no
  mv() {
    if [[ "$failed" == no && "$2" == */previous && "$3" == "$BACKUP" ]]; then failed=yes; return 1; fi
    command mv "$@"
  }
  cmd update
)
check 'failed backup publication reports failure' fails failed_backup_move
check 'failed backup publication restores current' cmp -s "$DEST/SKILL.md" "$TEST_ROOT/four/SKILL.md"
check 'failed backup publication restores older backup' cmp -s "$BACKUP/SKILL.md" "$TEST_ROOT/three/SKILL.md"
failed_copy() (
  cp() { return 1; }
  cmd update
)
check 'failed staging copy reports failure' fails failed_copy
check 'failed staging copy preserves contents' cmp -s "$DEST/SKILL.md" "$TEST_ROOT/four/SKILL.md"
without_diff() (
  command() {
    if [[ "$1" == -v && "$2" == diff ]]; then return 1; fi
    builtin command "$@"
  }
  cmd update
)
check 'missing diff blocks updates before writes' fails without_diff
check 'missing diff preserves contents' cmp -s "$DEST/SKILL.md" "$TEST_ROOT/four/SKILL.md"
mv "$BACKUP" "$BACKUP.saved"
ln -s "$TEST_ROOT/three" "$BACKUP"
check 'symlink backup blocks preview' fails cmd update --dry-run
check 'symlink backup blocks restore' fails cmd restore
check 'symlink backup blocks removal' fails cmd remove
rm "$BACKUP"
mv "$BACKUP.saved" "$BACKUP"
unstable_source() (
  _engine_codex_render_skill() { printf '\nConcurrent source edit.\n' >> "$2"; cat "$2"; }
  cmd update
)
cp "$SOURCE" "$TEST_ROOT/stable-source"
check 'source change during render blocks update' fails unstable_source
check 'unstable source preserves installed contents' cmp -s "$DEST/SKILL.md" "$TEST_ROOT/four/SKILL.md"
cp "$TEST_ROOT/stable-source" "$SOURCE"
printf local > "$DEST/additional"
check 'extra file blocks update' fails cmd update
rm "$DEST/additional"
printf '\nEdited backup.\n' >> "$BACKUP/SKILL.md"
check 'edited backup blocks update preview' fails cmd update --dry-run
check 'edited backup blocks update' fails cmd update
check 'edited backup blocks restore' fails cmd restore
check 'edited backup blocks removal' fails cmd remove
cp "$TEST_ROOT/three/SKILL.md" "$BACKUP/SKILL.md"
mkdir -p "$PROJ/.agents/.assistant-skill-locks/codex-sample"
check 'concurrent operation blocks update' fails cmd update
rmdir "$PROJ/.agents/.assistant-skill-locks/codex-sample"
check 'update after lock release' cmd update >/dev/null 2>&1
# Missing sources do not prevent rollback or removal.
mv "$SOURCE" "$SOURCE.moved"
check 'missing source blocks update' fails cmd update
check 'missing source is diagnosed' has "$(assistant skills status sample --harness codex 2>/dev/null)" 'source missing'
check 'restore does not need source' cmd restore >/dev/null
mv "$SOURCE.moved" "$SOURCE"
# User/project duplicates are visible and allowed; a duplicate in one root blocks writes.
check 'cross-scope install allowed' assistant skills install sample --harness codex --scope user > /dev/null 2> "$TEST_ROOT/duplicates"
check 'cross-scope warning names location' has "$(cat "$TEST_ROOT/duplicates")" "$DEST/SKILL.md"
USER_DEST="$TEST_ROOT/user/.agents/skills/sample"
USER_BACKUP=$(_native_backup_path "$TEST_ROOT/user/.agents/skills" codex sample)
cp "$USER_DEST/SKILL.md" "$TEST_ROOT/user-initial"
printf '\nUser source change.\n' >> "$TEST_ROOT/custom/skills/sample/SKILL.md"
check 'user update preview' assistant skills update sample --harness codex --scope user --dry-run >/dev/null 2>&1
check 'user preview preserves contents' cmp -s "$USER_DEST/SKILL.md" "$TEST_ROOT/user-initial"
check 'user preview creates no backup' test ! -e "$USER_BACKUP"
check 'user update' assistant skills update sample --harness codex --scope user >/dev/null 2>&1
check 'user backup stores previous version' cmp -s "$USER_BACKUP/SKILL.md" "$TEST_ROOT/user-initial"
check 'user backup preserves scope' test "$(_native_record_value "$USER_BACKUP/.assistant-install.tsv" scope)" = user
check 'user restoration' assistant skills restore sample --harness codex --scope user >/dev/null 2>&1
check 'user restoration preserves initial contents' cmp -s "$USER_DEST/SKILL.md" "$TEST_ROOT/user-initial"
check 'cross-scope inventory succeeds' assistant skills installed --harness codex > "$TEST_ROOT/inventory" 2> "$TEST_ROOT/duplicates"
check 'inventory includes both scopes' test "$(printf '%s\n' "$(cat "$TEST_ROOT/inventory")" | awk -F ' *\\| *' '$1 == "sample" { count++ } END { print count }')" = 2
mkdir -p "$PROJ/.agents/skills/second-folder"
cp "$SOURCE" "$PROJ/.agents/skills/second-folder/SKILL.md"
check 'same-root duplicate blocks update' fails cmd update
check 'same-root duplicate blocks restore' fails cmd restore
check 'same-root duplicate makes diagnosis fail' fails assistant skills installed --harness codex
check 'duplicate visible in diagnosis' has "$(cat "$TEST_ROOT/failure")" second-folder
check 'scope filter does not fail for another root conflict' assistant skills installed --harness codex --scope user >/dev/null 2>&1
rm -r "$PROJ/.agents/skills/second-folder"
cd "$PROJ/module/deep" || exit 1
check 'ancestor and user discovery' assistant skills installed --harness codex > "$TEST_ROOT/inventory" 2>/dev/null
check 'ancestor installations labeled' has "$(cat "$TEST_ROOT/inventory")" ancestor
check 'ancestor discovery stops at repository root' test "$(printf '%s\n' "$(_engine_codex_skill_roots "$PWD")" | wc -l | tr -d ' ')" = 4
check 'user-only filter excludes ancestors' test "$(assistant skills installed --harness codex --scope user 2>/dev/null | awk -F ' *\\| *' '$1 == "sample" { print $2 }')" = user
check 'project-only status excludes user-only package' fails assistant skills status absent --harness codex --scope project
# Corrupt records and missing skill files remain visible without trusting their paths.
printf 'corrupt\n' >> "$DEST/.assistant-install.tsv"
check 'edited provenance blocks update' fails cmd update
check 'edited provenance diagnosed' has "$(assistant skills status sample --harness codex --scope project 2>/dev/null)" 'invalid record'
cp "$TEST_ROOT/four/.assistant-install.tsv" "$DEST/.assistant-install.tsv"
cp "$TEST_ROOT/four/.assistant-install.sha256" "$DEST/.assistant-install.sha256"
cp "$TEST_ROOT/four/SKILL.md" "$DEST/SKILL.md"
mv "$DEST/SKILL.md" "$TEST_ROOT/missing-skill"
check 'missing managed file remains in inventory' has "$(assistant skills status sample --harness codex --scope project 2>/dev/null)" "$DEST"
mv "$TEST_ROOT/missing-skill" "$DEST/SKILL.md"
check 'removal with valid backup' cmd remove >/dev/null 2>&1
check 'removal deletes managed installation' test ! -e "$DEST"
check 'removal deletes managed backup' test ! -e "$BACKUP"
for lang in en es pt-br; do
  _set_lang "$lang"
  check "$lang inventory renders" assistant skills installed --harness codex >/dev/null
  check "$lang help renders" assistant help >/dev/null
done
printf '%s managed update and diagnostic checks passed (%s).\n' "$CHECKS" "${ZSH_VERSION:-bash}"
