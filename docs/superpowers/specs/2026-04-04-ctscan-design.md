# ctscan — Design Spec
Date: 2026-04-04

## Overview

`ctscan` is a macOS system health scanner distributed as a single Bash script via a Homebrew tap. It runs 10 diagnostic checks covering identity, storage, battery, thermals, memory, network, and security — either all at once or selectively via CLI flags.

---

## Goals

- Give macOS power users a fast, readable system health snapshot from the terminal
- Distribute easily via `brew tap onurtellioglu/ctscan && brew install ctscan`
- Stay dependency-free (pure Bash, macOS built-in commands only, except optional `smartmontools`)

---

## Non-Goals

- JSON or machine-readable output (not in v1)
- Cross-platform support (macOS only, by design)
- Plugin system or extensible architecture

---

## CLI Interface

```
ctscan [OPTIONS] [MODULES...]

MODULES (default: all):
  identity    System identity & uptime
  brew        Brew hygiene
  agents      Launch agents & daemons
  storage     Storage analytics
  ssd         SSD wear level (requires smartmontools)
  battery     Battery analytics
  thermal     Thermal & GPU state
  memory      RAM pressure & swap
  wifi        Network signal strength
  security    Security & SIP status

OPTIONS:
  --skip <mod1,mod2>   Skip specified modules
  --no-color           Disable colored output (for pipe/CI)
  --quiet              Print critical values only
  --version            Print version
  --help               Print usage
```

Positional module names are equivalent to `--only`:
```bash
ctscan                          # run all modules
ctscan battery wifi             # run only these two
ctscan --skip storage ssd       # run all except these
ctscan --no-color | tee log.txt
```

---

## Architecture

Single file: `bin/ctscan`

```
bin/ctscan
├── Constants & config (VERSION, COLOR, QUIET, MODULES[])
├── Helper functions
│   ├── print_header()  — colored section header
│   ├── print_ok()      — green success line
│   └── print_warn()    — yellow warning line
├── Module functions
│   ├── check_identity()
│   ├── check_brew()
│   ├── check_agents()
│   ├── check_storage()
│   ├── check_ssd()
│   ├── check_battery()
│   ├── check_thermal()
│   ├── check_memory()
│   ├── check_wifi()
│   └── check_security()
├── parse_args()        — flag & positional argument parsing
└── run_modules()       — dispatcher: iterates ALL_MODULES, calls matching check_*
```

`--quiet` mode: each `check_*` only emits lines explicitly tagged critical (e.g. battery health < 80%, SIP disabled, swap > 2GB).

`--no-color`: `print_header`, `print_ok`, `print_warn` strip ANSI codes.

---

## Module Details

| Module   | Key commands                                      | Critical threshold (quiet mode)       |
|----------|---------------------------------------------------|---------------------------------------|
| identity | `scutil`, `uptime`                                | —                                     |
| brew     | `brew leaves`, `brew list --cask`                 | —                                     |
| agents   | `ls ~/Library/LaunchAgents /Library/LaunchDaemons`| —                                     |
| storage  | `du -sh ~/Library/Caches/*`                       | Cache > 5GB                           |
| ssd      | `smartctl -a /dev/disk0`                          | Percentage Used > 80%                 |
| battery  | `pmset`, `ioreg AppleSmartBattery`                | Health < 80% or cycles > 1000        |
| thermal  | `pmset -g therm`, `system_profiler SPDisplaysDataType` | Thermal pressure not "Nominal"   |
| memory   | `memory_pressure`, `sysctl vm.swapusage`          | Swap > 2GB                            |
| wifi     | `system_profiler SPAirPortDataType`               | Signal < -70 dBm                      |
| security | `fdesetup status`, `csrutil status`               | FileVault off or SIP disabled         |

---

## Repo Structure

```
ctscan/                          # github.com/onurtellioglu/ctscan
├── bin/
│   └── ctscan
├── test/
│   └── ctscan_test.sh           # smoke tests (--version, --help, individual modules)
├── docs/
│   └── superpowers/specs/
│       └── 2026-04-04-ctscan-design.md
├── README.md
├── LICENSE                      # MIT
└── CHANGELOG.md
```

Separate tap repo: `github.com/onurtellioglu/homebrew-ctscan`

```
homebrew-ctscan/
└── Formula/
    └── ctscan.rb
```

---

## Distribution

**Install:**
```bash
brew tap onurtellioglu/ctscan
brew install ctscan
```

**Formula (`ctscan.rb`):**
```ruby
class Ctscan < Formula
  desc "macOS system health scanner"
  homepage "https://github.com/onurtellioglu/ctscan"
  url "https://github.com/onurtellioglu/ctscan/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "<computed at release time>"
  license "MIT"

  def install
    bin.install "bin/ctscan"
  end

  test do
    system "#{bin}/ctscan", "--version"
  end
end
```

**Release flow:**
1. Tag `vX.Y.Z` on main repo → create GitHub release
2. Compute `sha256` of the tarball
3. Update `url` and `sha256` in tap formula
4. Users update via `brew upgrade ctscan`

---

## Testing

`test/ctscan_test.sh` covers:
- `ctscan --version` exits 0 and prints version string
- `ctscan --help` exits 0
- Each module runs without error: `ctscan <module>`
- `--skip` excludes the skipped module from output
- `--no-color` produces no ANSI escape codes

Tests run without `sudo` — SSD check gracefully degrades if `smartctl` is absent.

---

## Error Handling

- Missing optional dependency (`smartmontools`): print install hint, skip module, continue
- `sudo` not available: skip SSD check gracefully
- Unknown module name: print error and exit 1
- Unknown flag: print usage and exit 1
