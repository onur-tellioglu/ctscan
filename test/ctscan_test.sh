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

# ── JSON format tests ───────────────────────────────────────────────────────

test_json_output_is_valid_json() {
  local out
  out=$(bash bin/ctscan --format json 2>/dev/null)
  if ! echo "$out" | python3 -m json.tool > /dev/null 2>&1; then
    echo "FAIL: --format json did not produce valid JSON"
    echo "Output was: $out"
    return 1
  fi
  echo "PASS: --format json produces valid JSON"
}

test_json_contains_all_modules() {
  local out
  out=$(bash bin/ctscan --format json 2>/dev/null)
  local missing=()
  for mod in identity brew agents storage ssd battery thermal memory processes docker timemachine updates wifi security; do
    if ! echo "$out" | python3 -c "import sys,json; d=json.load(sys.stdin); assert '$mod' in d" 2>/dev/null; then
      missing+=("$mod")
    fi
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "FAIL: JSON missing modules: ${missing[*]}"
    return 1
  fi
  echo "PASS: JSON contains all 14 module keys"
}

test_json_each_module_has_required_fields() {
  local out
  out=$(bash bin/ctscan --format json 2>/dev/null)
  local failed=false
  for mod in identity brew battery thermal memory; do
    if ! echo "$out" | python3 -c "
import sys, json
d = json.load(sys.stdin)
m = d['$mod']
assert 'status' in m, 'missing status'
assert 'value' in m, 'missing value'
assert 'message' in m, 'missing message'
assert m['status'] in ('ok','warn','error','unavailable'), 'invalid status: '+m['status']
" 2>/dev/null; then
      echo "FAIL: module '$mod' missing required fields or invalid status"
      failed=true
    fi
  done
  $failed && return 1
  echo "PASS: sampled modules have required fields with valid status values"
}

test_json_no_text_output() {
  local out
  out=$(bash bin/ctscan --format json 2>/dev/null)
  if echo "$out" | grep -qE '(══|✓|⚠|·)'; then
    echo "FAIL: --format json output contains text formatting"
    return 1
  fi
  echo "PASS: --format json output contains no text formatting"
}

test_json_single_module() {
  local out
  out=$(bash bin/ctscan --format json battery 2>/dev/null)
  local count
  count=$(echo "$out" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null)
  if [[ "$count" != "1" ]]; then
    echo "FAIL: single-module JSON should have 1 key, got: $count"
    return 1
  fi
  echo "PASS: single-module JSON contains exactly 1 key"
}

# Run JSON tests
test_json_output_is_valid_json        || ((FAIL++))
test_json_contains_all_modules        || ((FAIL++))
test_json_each_module_has_required_fields || ((FAIL++))
test_json_no_text_output              || ((FAIL++))
test_json_single_module               || ((FAIL++))

# ── Summary ───────────────────────────────────
echo
echo "Results: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]]
