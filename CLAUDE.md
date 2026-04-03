# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

`ctscan` is a single-file macOS system health scanner (`bin/ctscan`) distributed via a Homebrew tap at `github.com/onur-tellioglu/homebrew-ctscan`. The entire program is one bash script; there is no build step.

## Commands

```bash
# Run all modules
bash bin/ctscan

# Run a single module
bash bin/ctscan battery

# Run tests
bash test/ctscan_test.sh
```

## Architecture

`bin/ctscan` is structured in layers:

1. **Color helpers** (`color`, `print_header`, `print_ok`, `print_warn`, `print_info`, `print_error`) — all output goes through these.
2. **Module functions** (`check_<name>`) — one function per module, always in this pattern:
   - Run quiet-mode threshold checks first (warnings appear even with `--quiet`)
   - `$QUIET && return` guard before verbose output
   - Verbose output below the guard
3. **`ALL_MODULES` array** — defines the canonical module order used for both dispatch and `--skip` filtering.
4. **`parse_args`** — populates `SELECTED_MODULES` and `SKIP_MODULES` from positional args and `--skip`.
5. **`run_modules`** — intersects selection + skip against `ALL_MODULES` order, then calls `check_${mod}` for each.

## Adding a new module

1. Write `check_<name>()` following the quiet-guard pattern above.
2. Add `<name>` to `ALL_MODULES` at the correct position.
3. Add the module to `print_usage` help text.
4. Add a smoke test in `test/ctscan_test.sh` (`assert_exit0 "module <name> runs without error" <name>`).

## Releasing

After all changes are committed and tested:

```bash
# 1. Bump VERSION in bin/ctscan and update CHANGELOG.md, then commit + tag
git tag vX.Y.Z && git push origin main && git push origin vX.Y.Z

# 2. Get the tarball SHA256
curl -sL https://github.com/onur-tellioglu/ctscan/archive/refs/tags/vX.Y.Z.tar.gz | shasum -a 256

# 3. Update url + sha256 in the tap formula
#    /opt/homebrew/Library/Taps/onur-tellioglu/homebrew-ctscan/Formula/ctscan.rb
#    Then commit and push that repo.
```

## Key conventions

- Graceful degradation: if a required command is absent, `print_info` a hint and `return` — never `exit`.
- `--quiet` only prints lines that cross a threshold (warnings). No verbose output.
- `df -H` (SI units, powers of 1000) is used for storage; `du -sh` for directory sizes.
- Module functions must be idempotent and side-effect free (read-only system calls only).
