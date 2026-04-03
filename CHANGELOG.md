# Changelog

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
