# Changelog

## [0.3.4] - 2026-04-04

### Changed
- Parallelized `system_profiler` calls (identity, thermal, wifi) — all three launch concurrently, modules read from pre-fetched globals
- Parallelized `brew leaves` + `brew list --cask` invocations via background subshells
- Replaced double-grep in `check_memory` with single awk pass for swap extraction (−1 fork)
- Converted `run_modules` selection and skip loops from O(n²) nested `for` to O(n) `case` pattern matching

## [0.3.3] - 2026-04-04

### Changed
- Removed dead `uptime_str` variable in `check_identity` (−3 forks per run)
- Cleaned up dead `avail_gb` and redundant `local` declarations in `check_storage`
- Consolidated `df -H` parsing: 4× `echo | awk` → single `read` (−3 forks)
- Replaced `awk | cut` + `awk | xargs basename` in process threshold check with bash builtins (−3 forks)
- Replaced subshell pluralization in `check_timemachine` with bash variables (−2 forks)
- Replaced `echo | grep -qi` in `check_security` with `[[ ]]` glob match (−2 forks)
- Replaced all `bc` calls with `awk` or `$(( ))` arithmetic (−5–10 forks per run)
- Rewrote `check_processes` verbose block: two single-pass awk scripts for CPU and memory tables (−30 forks)
- Consolidated `docker system df` parsing from 6× `echo | awk` into one multi-pattern awk pass (−5 forks)

## [0.3.2] - 2026-04-04

### Added
- Footer showing `ctscan <version>` at the end of every scan

## [0.3.1] - 2026-04-04

### Fixed
- `updates` module: arithmetic error when no updates available (`grep -c` exit code 1 caused `|| echo 0` to produce `"0\n0"`)

## [0.3.0] - 2026-04-04

### Added
- `processes` module: top 5 processes by CPU and by memory; warns if any process >80% CPU
- `docker` module: running containers and disk usage; graceful degradation if Docker absent
- `timemachine` module: last backup age and status; warns if backup >24h ago
- `updates` module: pending macOS software updates via `softwareupdate -l`; warns if updates available
- `storage` module: disk summary line showing used/total/percent

## [0.1.0] - 2026-04-04

### Added
- Initial release
- 10 diagnostic modules: identity, brew, agents, storage, ssd, battery, thermal, memory, wifi, security
- CLI flags: `--skip`, `--no-color`, `--quiet`, `--version`, `--help`
- Positional module selection (`ctscan battery wifi`)
- Homebrew tap distribution support
- Smoke test suite (`test/ctscan_test.sh`)
