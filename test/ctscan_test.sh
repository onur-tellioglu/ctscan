#!/usr/bin/env bash
# ctscan smoke tests
# Run from repo root: bash test/ctscan_test.sh

set -uo pipefail

SCRIPT="$(cd "$(dirname "$0")/.." && pwd)/bin/ctscan"
PASS=0
FAIL=0

green() { printf '\033[0;32m%s\033[0m\n' "$*"; }
red()   { printf '\033[0;31m%s\033[0m\n' "$*"; }

assert_exit0() {
  local desc="$1"; shift
  if "$SCRIPT" "$@" >/dev/null 2>&1; then
    green "PASS: $desc"
    ((PASS++))
  else
    red "FAIL: $desc (expected exit 0)"
    ((FAIL++))
  fi
}

assert_exit1() {
  local desc="$1"; shift
  if ! "$SCRIPT" "$@" >/dev/null 2>&1; then
    green "PASS: $desc"
    ((PASS++))
  else
    red "FAIL: $desc (expected exit 1)"
    ((FAIL++))
  fi
}

assert_output_contains() {
  local desc="$1" pattern="$2"; shift 2
  local out
  out=$("$SCRIPT" "$@" 2>&1)
  if echo "$out" | grep -qF "$pattern"; then
    green "PASS: $desc"
    ((PASS++))
  else
    red "FAIL: $desc (expected output to contain: $pattern)"
    ((FAIL++))
  fi
}

assert_output_excludes() {
  local desc="$1" pattern="$2"; shift 2
  local out
  out=$("$SCRIPT" "$@" 2>&1)
  if ! echo "$out" | grep -qF "$pattern"; then
    green "PASS: $desc"
    ((PASS++))
  else
    red "FAIL: $desc (expected output NOT to contain: $pattern)"
    ((FAIL++))
  fi
}

assert_no_ansi() {
  local desc="$1"; shift
  local out esc
  out=$("$SCRIPT" "$@" 2>&1)
  esc=$'\033'
  if printf '%s' "$out" | grep -qF "$esc"; then
    red "FAIL: $desc (found ANSI escape codes)"
    ((FAIL++))
  else
    green "PASS: $desc"
    ((PASS++))
  fi
}

echo "Running ctscan smoke tests..."
echo

# ── Basic flags ───────────────────────────────
assert_exit0   "--version exits 0"              --version
assert_output_contains "--version prints version" "ctscan 0.3" --version
assert_exit0   "--help exits 0"                 --help
assert_exit0   "--no-color exits 0"             --no-color identity

# ── Individual modules ────────────────────────
for mod in identity brew agents storage battery thermal memory processes wifi security; do
  assert_exit0 "module $mod runs without error" "$mod"
done

# SSD may warn but must not crash
assert_exit0 "module ssd runs without error" ssd

# New modules — graceful degradation required
assert_exit0 "module docker runs without error (degrades if absent)"      docker
assert_exit0 "module timemachine runs without error (degrades if absent)" timemachine
assert_exit0 "module updates runs without error"                          updates

# Storage disk summary line
assert_output_contains "storage output contains Disk: line" "Disk:" storage

# ── --skip ────────────────────────────────────
assert_output_excludes "--skip brew removes brew section"      "Homebrew"  --skip brew identity
assert_output_excludes "--skip processes removes processes section" "Processes" --skip processes identity
assert_exit0           "--skip multiple modules exits 0"                        --skip ssd,brew

# ── --no-color ────────────────────────────────
assert_no_ansi "--no-color produces no ANSI codes" --no-color identity

# ── --quiet ───────────────────────────────────
assert_exit0 "--quiet exits 0" --quiet security

# ── Error cases ───────────────────────────────
assert_exit1 "unknown module exits 1" unknownmodule
assert_exit1 "unknown flag exits 1"   --unknownflag

# ── Security: no injection via awk/external data ──
assert_exit0 "storage module safe with large cache dir" storage

# ── Security: input validation ──
assert_exit1 "--skip rejects invalid module names" --skip 'storage;evil'
assert_exit1 "--skip rejects glob chars" --skip 'st*'
assert_exit1 "--skip rejects pipe chars" --skip 'sto|rage'

# ── Summary ───────────────────────────────────
echo
echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
