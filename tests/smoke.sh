# tests/smoke.sh — automated smoke checks for Assistant CLI.
# Checks syntax in bash/zsh
# (plus `fish -n init.fish` when fish is installed), locale key parity,
# missing-t_* scan, read-only commands, usage errors and behavioral checks.
#
# Usage: bash tests/smoke.sh
# Exits 0 when every executed check passes, 1 otherwise.

set -u

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ERR_FILE="$(mktemp)"
trap 'rm -f "$ERR_FILE"' EXIT

source "$ROOT_DIR/utils/colors.sh"

PASS=0
FAIL=0
SKIP=0

pass() { PASS=$((PASS + 1)); printf "  ${GREEN}PASS${RESET} %s\n" "$1"; }
fail() { FAIL=$((FAIL + 1)); printf "  ${RED}FAIL${RESET} %s\n" "$1"; sed 's/^/      /' "$ERR_FILE"; }
skip() { SKIP=$((SKIP + 1)); printf "  ${YELLOW}SKIP${RESET} %s\n" "$1"; }
section() { printf "\n${BOLD}== %s ==${RESET}\n" "$1"; }

cd -- "$ROOT_DIR"

PROJECT_FILES="init.sh lib/*.sh lib/adapters/*/init.sh utils/*.sh skills/*/init.sh locales/*.sh"
CALLER_FILES="init.sh lib/*.sh lib/adapters/*/init.sh utils/*.sh skills/*/init.sh"

section "Syntax checks"

syntax_check() {
  local interpreter="$1" file
  shift
  for file in "$@"; do
    "$interpreter" -n "$file" 2>"$ERR_FILE" || return 1
  done
}

if syntax_check bash $PROJECT_FILES install.sh tests/*.sh; then
  pass "bash -n accepts all project scripts, installer and tests"
else
  fail "bash -n rejected a script"
fi

if command -v zsh >/dev/null 2>&1; then
  if syntax_check zsh $PROJECT_FILES; then
    pass "zsh -n accepts all project scripts"
  else
    fail "zsh -n rejected a script"
  fi
else
  skip "zsh not installed"
fi

if command -v fish >/dev/null 2>&1; then
  if fish -n init.fish 2>"$ERR_FILE"; then
    pass "fish -n accepts init.fish"
  else
    fail "fish -n rejected init.fish"
  fi
else
  skip "fish not installed"
fi

section "Locale parity"

if diff <(grep -oE '^t_[a-z0-9_]+' locales/en.sh | sort) <(grep -oE '^t_[a-z0-9_]+' locales/es.sh | sort) >"$ERR_FILE" 2>&1; then
  pass "en.sh and es.sh define identical t_* key sets"
else
  fail "t_* key sets differ between en.sh and es.sh"
fi

if diff <(grep -oE '^t_[a-z0-9_]+' locales/en.sh | sort) <(grep -oE '^t_[a-z0-9_]+' locales/pt-br.sh | sort) >"$ERR_FILE" 2>&1; then
  pass "en.sh and pt-br.sh define identical t_* key sets"
else
  fail "t_* key sets differ between en.sh and pt-br.sh"
fi

section "Message keys"

comm -23 <(grep -ohE '\bt_[a-z0-9_]+' $CALLER_FILES | sort -u) <(grep -oE '^t_[a-z0-9_]+' locales/en.sh | sort -u) >"$ERR_FILE"
if [ -s "$ERR_FILE" ]; then
  fail "t_* functions called but missing from locales/en.sh"
else
  pass "every t_* call has a definition in locales/en.sh"
fi

section "Runtime (read-only commands)"

export ASSISTANT_NO_UPDATE_CHECK=1

runtime() {
  local label="$1"
  shift
  if bash -c 'source "$1/init.sh" && shift && assistant "$@"' assistant "$ROOT_DIR" "$@" >/dev/null 2>"$ERR_FILE"; then
    pass "$label"
  else
    fail "$label"
  fi
}

runtime "assistant --version" --version
runtime "assistant help" help
runtime "assistant status" status
runtime "assistant model status" model status
runtime "assistant lang --list" lang --list
runtime "assistant custom status" custom status
runtime "assistant custom adapters status" custom adapters status
runtime "assistant skills list" skills list
runtime "assistant adapters --list" adapters --list
runtime "assistant adapters status" adapters status
runtime "assistant adapters capabilities" adapters capabilities
runtime "assistant custom adapters --list" custom adapters --list
runtime "assistant custom harness --list" custom harness --list
runtime "assistant engine --list" engine --list
runtime "assistant harness status" harness status
runtime "assistant harness capabilities" harness capabilities
runtime "assistant engine capabilities codex" engine capabilities codex

section "Runtime (usage error path)"

if bash -c 'source "$1/init.sh" && shift && assistant "$@"' assistant "$ROOT_DIR" create >/dev/null 2>&1; then
  fail "usage error: assistant create should exit non-zero"
else
  pass "usage error: assistant create exits non-zero"
fi

section "Behavior (simulated executors)"

if bash tests/behavior.sh >"$ERR_FILE" 2>&1; then
  pass "behavioral checks in bash"
else
  fail "behavioral checks in bash"
fi
if command -v zsh >/dev/null 2>&1; then
  if zsh tests/behavior.sh >"$ERR_FILE" 2>&1; then
    pass "behavioral checks in zsh"
  else
    fail "behavioral checks in zsh"
  fi
else
  skip "behavioral checks in zsh: interpreter not installed"
fi

section "Harnesses and native installation (simulated executors)"

if bash tests/adapters.sh >"$ERR_FILE" 2>&1; then
  pass "adapter command checks in bash"
else
  fail "adapter command checks in bash"
fi
if command -v zsh >/dev/null 2>&1; then
  if zsh tests/adapters.sh >"$ERR_FILE" 2>&1; then
    pass "adapter command checks in zsh"
  else
    fail "adapter command checks in zsh"
  fi
else
  skip "adapter checks in zsh: interpreter not installed"
fi

if bash tests/harness.sh >"$ERR_FILE" 2>&1; then
  pass "harness and installation checks in bash"
else
  fail "harness and installation checks in bash"
fi
if command -v zsh >/dev/null 2>&1; then
  if zsh tests/harness.sh >"$ERR_FILE" 2>&1; then
    pass "harness and installation checks in zsh"
  else
    fail "harness and installation checks in zsh"
  fi
else
  skip "harness checks in zsh: interpreter not installed"
fi

section "Managed skill updates and diagnostics (isolated files)"

for interpreter in bash zsh; do
  if command -v "$interpreter" >/dev/null 2>&1; then
    if "$interpreter" tests/skill-update.sh >"$ERR_FILE" 2>&1; then
      pass "managed update and diagnostic checks in $interpreter"
    else
      fail "managed update and diagnostic checks in $interpreter"
    fi
  else
    skip "managed update checks in $interpreter: interpreter not installed"
  fi
done

section "Summary"

printf "  ${BOLD}%d passed${RESET}, %d failed" "$PASS" "$FAIL"
if [ "$SKIP" -gt 0 ]; then
  printf ", %d skipped" "$SKIP"
fi
printf "\n"

if [ "$FAIL" -gt 0 ]; then
  printf "  ${RED}Smoke checks failed.${RESET}\n"
  exit 1
fi

printf "  ${GREEN}All smoke checks passed.${RESET}\n"
exit 0
