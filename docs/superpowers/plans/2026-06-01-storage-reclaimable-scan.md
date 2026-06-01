---
type: feat
domain: storage
parent-spec: none
touched-files: [bin/ctscan, test/ctscan_test.sh]
shared-modules-touched: [check_storage]
trigger-tasks-touched: []
db-migration: false
rls-affecting: false
optimization-required: false
security-required: false
---

# Storage Reclaimable Scan Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend `check_storage` to scan well-known reclaimable developer locations (CoreSimulator, Xcode DeviceSupport, DerivedData, caches, package-manager stores, Docker reclaimable) and report sizes with safety tags, plus a total reclaimable summary line.

**Architecture:** All logic stays inside `check_storage` in `bin/ctscan`. A new `_scan_reclaimable` inner helper collects `(label, size_kb, safety_tag, hint)` tuples into parallel arrays, then the caller prints them and sums the "safe" bytes for a summary line. No new files. No flags added — the summary line is always printed in verbose mode (after `$QUIET && return`).

**Tech Stack:** bash, du, df, brew, pnpm, docker — all invoked defensively with existence checks.

---

## Tasks

1. Add smoke test for extended storage (write failing test first)
2. Fix `df` volume to use `/System/Volumes/Data` for accurate disk totals
3. Implement `_scan_reclaimable` — measure each known developer path
4. Render the reclaimable table and summary line inside `check_storage`
5. Commit and push

---

## Design Decisions

### always-on summary line vs. `--reclaimable` flag
Adding `--reclaimable` would require touching `parse_args`, `print_usage`, and the `--*)` unknown-flag branch — three extra change sites for cosmetic gain. The summary line is useful every time `storage` runs verbosely. Decision: **always-on summary line** printed at the end of the verbose block. This is simpler, correct, and requires zero flag-parsing changes.

### `df /` vs. `df /System/Volumes/Data`
On modern macOS (APFS sealed system), `df /` measures only the read-only system seal. Actual user data lives on `/System/Volumes/Data`. The existing code works around this via `total_k - avail_k` (already correct). The new reclaimable paths (`~/Library`, `~/.cache`) are all on the Data volume — no `df` call needed for them, only `du -sk` on specific known paths.

### Performance
`du -sk <specific_path>` walks only that subtree. We call it on a fixed set of ~8 known paths, each with an `[[ -d ]]` guard. We do NOT glob or recurse across `$HOME`. `brew --cache` and `pnpm store path` are cheap subcommand invocations. `docker system df` is one syscall if Docker is running. No `timeout` binary (not on stock macOS) — instead, each guard ensures we only `du` paths that exist.

---

## File Map

| File | Change |
|---|---|
| `bin/ctscan` | Extend `check_storage` — add `_scan_reclaimable` logic and summary line |
| `test/ctscan_test.sh` | Add smoke test verifying the extended storage path exits 0 and emits "Reclaimable" |

---

## Task 1: Write the failing smoke test

**Files:**
- Modify: `test/ctscan_test.sh` (after the existing `"storage output contains Disk: line"` test, around line 99)

This test checks that the extended storage module exits 0 (graceful degradation even if none of the dev paths exist) and that the output contains a "Reclaimable" summary line. It WILL fail until Task 4 is implemented.

- [ ] **Step 1.1: Add test to `test/ctscan_test.sh`**

Insert after line 99 (after `assert_output_contains "storage output contains Disk: line" "Disk:" storage`):

```bash
# Extended reclaimable scan — must exit 0 on any machine (all paths optional)
assert_exit0 "storage reclaimable scan exits 0 on any machine" storage
assert_output_contains "storage output contains Reclaimable summary" "Reclaimable:" storage
```

- [ ] **Step 1.2: Run the test to confirm it fails**

```bash
bash test/ctscan_test.sh 2>&1 | grep -E "PASS|FAIL|Results"
```

Expected: `FAIL: storage output contains Reclaimable summary` — because the summary line doesn't exist yet.

---

## Task 2: Fix disk-total measurement to use `/System/Volumes/Data`

**Files:**
- Modify: `bin/ctscan`, function `check_storage`, lines 197–199

On modern macOS APFS the sealed system volume is at `/`. User data (all of `~/Library`, `~/.cache`, etc.) lives on `/System/Volumes/Data`. `df /` under-reports used space. Replace the `df -k /` call with `df -k /System/Volumes/Data`, and fall back to `/` if the Data volume is absent (e.g., older macOS or VM).

- [ ] **Step 2.1: Replace the `df` line**

Current code (lines 197–199):
```bash
  local total_k avail_k used_k _rest
  read -r _rest total_k _rest avail_k _rest < <(df -k / 2>/dev/null | tail -1)
  used_k=$(( total_k - avail_k ))
```

Replace with:
```bash
  local total_k avail_k used_k _rest
  local _df_target="/"
  [[ -d /System/Volumes/Data ]] && _df_target="/System/Volumes/Data"
  read -r _rest total_k _rest avail_k _rest < <(df -k "$_df_target" 2>/dev/null | tail -1)
  used_k=$(( total_k - avail_k ))
```

- [ ] **Step 2.2: Verify storage module still exits 0**

```bash
bash bin/ctscan storage 2>&1 | grep "Disk:"
```

Expected: a `Disk: X used / Y total (Z% full)` line (values differ per machine).

---

## Task 3: Implement `_scan_reclaimable` inner function

**Files:**
- Modify: `bin/ctscan`, inside `check_storage`, just before the `$QUIET && return` guard

This inner function populates four parallel arrays: `_rlabel`, `_rkb`, `_rtag`, `_rhint`. Each entry is one reclaimable location. Entries where the path doesn't exist are silently skipped. The caller (Task 4) iterates these arrays.

Safety tags:
- `safe` — can be deleted without consequence (caches regenerate automatically)
- `regen` — regenerable but may slow down the next build/run
- `review` — check before deleting (simulator devices, OS support files)

- [ ] **Step 3.1: Add the inner function inside `check_storage` (before `$QUIET && return`)**

Insert the following block immediately before the `$QUIET && return` line (currently line 229):

```bash
  # ── Reclaimable developer paths ──────────────
  _rlabel=(); _rkb=(); _rtag=(); _rhint=()

  _add_reclaim() {
    # Usage: _add_reclaim <label> <path> <tag> <hint>
    local lbl="$1" path="$2" tag="$3" hint="$4"
    [[ -d "$path" ]] || return 0
    local kb
    kb=$(du -sk "$path" 2>/dev/null | awk '{print $1}')
    [[ -z "$kb" || "$kb" -eq 0 ]] && return 0
    _rlabel+=("$lbl"); _rkb+=("$kb"); _rtag+=("$tag"); _rhint+=("$hint")
  }

  # CoreSimulator devices
  _add_reclaim "CoreSimulator/Devices" \
    "$HOME/Library/Developer/CoreSimulator/Devices" \
    "review" \
    "run: xcrun simctl delete unavailable"

  # Xcode iOS DeviceSupport (old OS versions)
  _add_reclaim "Xcode iOS DeviceSupport" \
    "$HOME/Library/Developer/Xcode/iOS DeviceSupport" \
    "review" \
    "delete old OS version folders manually"

  # Xcode DerivedData
  _add_reclaim "Xcode DerivedData" \
    "$HOME/Library/Developer/Xcode/DerivedData" \
    "regen" \
    "run: rm -rf ~/Library/Developer/Xcode/DerivedData"

  # Dotcache (uv, pnpm, puppeteer, pip, etc.)
  _add_reclaim "~/.cache" \
    "$HOME/.cache" \
    "safe" \
    "caches auto-regenerate on next use"

  # CocoaPods cache
  _add_reclaim "CocoaPods cache" \
    "$HOME/Library/Caches/CocoaPods" \
    "safe" \
    "run: pod cache clean --all"

  # Homebrew download cache
  local _brew_cache=""
  if command -v brew &>/dev/null; then
    _brew_cache=$(brew --cache 2>/dev/null)
  fi
  if [[ -n "$_brew_cache" && -d "$_brew_cache" ]]; then
    local _brew_kb
    _brew_kb=$(du -sk "$_brew_cache" 2>/dev/null | awk '{print $1}')
    if [[ -n "$_brew_kb" && "$_brew_kb" -gt 0 ]]; then
      _rlabel+=("Homebrew cache"); _rkb+=("$_brew_kb")
      _rtag+=("safe"); _rhint+=("run: brew cleanup")
    fi
  fi

  # pnpm store
  local _pnpm_store=""
  if command -v pnpm &>/dev/null; then
    _pnpm_store=$(pnpm store path 2>/dev/null)
  fi
  if [[ -n "$_pnpm_store" && -d "$_pnpm_store" ]]; then
    local _pnpm_kb
    _pnpm_kb=$(du -sk "$_pnpm_store" 2>/dev/null | awk '{print $1}')
    if [[ -n "$_pnpm_kb" && "$_pnpm_kb" -gt 0 ]]; then
      _rlabel+=("pnpm store"); _rkb+=("$_pnpm_kb")
      _rtag+=("safe"); _rhint+=("run: pnpm store prune")
    fi
  fi

  # Docker reclaimable space
  local _docker_reclaim_kb=0
  if command -v docker &>/dev/null && docker ps &>/dev/null 2>&1; then
    local _docker_df
    _docker_df=$(docker system df 2>/dev/null)
    if [[ -n "$_docker_df" ]]; then
      # Parse RECLAIMABLE column — format: "1.2GB (30%)" — strip unit suffix
      local _docker_reclaim_raw
      _docker_reclaim_raw=$(echo "$_docker_df" | awk '
        /^Images/       { r=r" "$6 }
        /^Containers/   { r=r" "$6 }
        /^Local Volumes/{ r=r" "$6 }
        /^Build Cache/  { r=r" "$6 }
        END{ print r }
      ')
      # Sum up the numeric GB/MB values from the RECLAIMABLE column
      local _docker_reclaim_gb
      _docker_reclaim_gb=$(echo "$_docker_df" | awk '
        /^Images|^Containers|^Local Volumes|^Build Cache/ {
          # field 6 is RECLAIMABLE, e.g. "1.2GB" or "512MB" or "0B"
          v=$6
          gsub(/\(.*\)/, "", v)
          if (v ~ /GB$/) { gsub(/GB$/,"",v); total+=v*1024*1024 }
          else if (v ~ /MB$/) { gsub(/MB$/,"",v); total+=v*1024 }
          else if (v ~ /kB$/) { gsub(/kB$/,"",v); total+=v }
        }
        END { printf "%d", total }
      ')
      _docker_reclaim_kb="${_docker_reclaim_gb:-0}"
      if [[ "$_docker_reclaim_kb" -gt 0 ]]; then
        _rlabel+=("Docker reclaimable"); _rkb+=("$_docker_reclaim_kb")
        _rtag+=("review"); _rhint+=("run: docker system prune")
      fi
    fi
  fi
```

- [ ] **Step 3.2: Verify no syntax errors**

```bash
bash -n bin/ctscan && echo "syntax OK"
```

Expected: `syntax OK`

---

## Task 4: Render the reclaimable table and summary line

**Files:**
- Modify: `bin/ctscan`, inside `check_storage`, after the `$QUIET && return` guard

Replace the current verbose block (lines 231–232) with a version that also renders the reclaimable table. The existing cache/AppSupport listing is kept but moved above the new table.

- [ ] **Step 4.1: Replace the verbose block after `$QUIET && return`**

Current verbose block (lines 231–233):
```bash
  # Raw du output — cache and AppSupport merged, no sub-headers
  du -sh ~/Library/Caches/* 2>/dev/null | sort -rh | head -5 | while IFS= read -r line; do print_info "$line"; done
  du -sh ~/Library/Application\ Support/* 2>/dev/null | sort -rh | head -5 | while IFS= read -r line; do print_info "$line"; done
```

Replace with:
```bash
  # Raw du output — cache and AppSupport merged, no sub-headers
  du -sh ~/Library/Caches/* 2>/dev/null | sort -rh | head -5 | while IFS= read -r line; do print_info "$line"; done
  du -sh ~/Library/Application\ Support/* 2>/dev/null | sort -rh | head -5 | while IFS= read -r line; do print_info "$line"; done

  # ── Reclaimable table ──────────────────────────
  if [[ "${#_rlabel[@]}" -gt 0 ]]; then
    echo
    color "0;32" "  Dev cache breakdown (reclaimable):"
    local _total_safe_kb=0
    local _total_reclaim_kb=0
    local i
    for i in "${!_rlabel[@]}"; do
      local _sz
      _sz=$(_fmt_kb "${_rkb[$i]}")
      printf -v _padded_sz "%8s" "$_sz"
      print_info "$(printf '%s  %-28s  [%s]  %s' "$_padded_sz" "${_rlabel[$i]}" "${_rtag[$i]}" "${_rhint[$i]}")"
      _total_reclaim_kb=$(( _total_reclaim_kb + _rkb[$i] ))
      [[ "${_rtag[$i]}" == "safe" ]] && _total_safe_kb=$(( _total_safe_kb + _rkb[$i] ))
    done
    echo
    local _total_sz _safe_sz
    _total_sz=$(_fmt_kb "$_total_reclaim_kb")
    _safe_sz=$(_fmt_kb "$_total_safe_kb")
    print_info "Reclaimable: ${_total_sz} total  |  ${_safe_sz} safe-to-delete"
  fi
```

- [ ] **Step 4.2: Run the test suite to verify all tests pass**

```bash
bash test/ctscan_test.sh 2>&1 | tail -5
```

Expected: `Results: N passed, 0 failed`

- [ ] **Step 4.3: Manual smoke check — verbose output**

```bash
bash bin/ctscan storage 2>&1 | grep -E "Reclaimable|CoreSimulator|DerivedData|DeviceSupport|cache"
```

Expected: at least one size line and a `Reclaimable:` summary. If none of the dev paths exist on this machine, the table is simply absent — that is correct behavior (graceful degradation).

- [ ] **Step 4.4: Manual smoke check — quiet mode (no table, no summary)**

```bash
bash bin/ctscan --quiet storage 2>&1
```

Expected: only the `Disk:` line and any cache-size warnings. No reclaimable table.

- [ ] **Step 4.5: Shellcheck (if installed)**

```bash
command -v shellcheck && shellcheck bin/ctscan || echo "shellcheck not installed — skip"
```

Expected: no errors (SC2034/unused-variable warnings for `_rest` are acceptable; add `# shellcheck disable=SC2034` inline if needed).

---

## Task 5: Commit and push

**Pre-commit checklist:**
1. `bash test/ctscan_test.sh` — all tests pass
2. `shellcheck bin/ctscan` if available — no errors

- [ ] **Step 5.1: Check git status**

```bash
git status --short
```

Confirm only `bin/ctscan` and `test/ctscan_test.sh` are modified (plus any unrelated untracked docs files — leave those untouched).

- [ ] **Step 5.2: Stage only the two changed files**

```bash
git add bin/ctscan test/ctscan_test.sh
```

- [ ] **Step 5.3: Commit**

```bash
git commit -m "feat: extend storage module to scan dev caches and report reclaimable space refs #3"
```

- [ ] **Step 5.4: Push**

```bash
git push -u origin HEAD
```

---

## Self-Review Checklist

- [x] CoreSimulator, Xcode DeviceSupport, DerivedData, ~/.cache, CocoaPods, brew cache, pnpm store, Docker reclaimable — all covered.
- [x] Every path guarded with `[[ -d ]]` or command existence check before `du`.
- [x] No `exit` in any error path — only `return 0` / skip.
- [x] Quiet-guard pattern respected: reclaimable table is after `$QUIET && return`.
- [x] Cache threshold warning (existing) stays before `$QUIET && return` — unchanged.
- [x] `_fmt_kb` inner function defined before first use (it is defined at line ~202 in the existing code, within `check_storage`).
- [x] `print_*` helpers used everywhere — no raw `echo` for module output.
- [x] `df` now targets `/System/Volumes/Data` (with fallback to `/`).
- [x] No new CLI flags — `print_usage` and `ALL_MODULES` unchanged.
- [x] Smoke test added in `test/ctscan_test.sh`.
- [x] Docker degrades gracefully: two guards (`command -v docker`, `docker ps` success).
- [x] pnpm degrades gracefully: `command -v pnpm` guard.
- [x] brew cache degrades gracefully: `command -v brew` + path-existence guard.
- [x] No `timeout` binary used.
- [x] Commit message includes `refs #3`.

