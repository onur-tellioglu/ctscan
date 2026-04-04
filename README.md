# ctscan

![Latest Release](https://img.shields.io/github/v/release/onur-tellioglu/ctscan?style=flat-square)
![License](https://img.shields.io/github/license/onur-tellioglu/ctscan?style=flat-square)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey?style=flat-square)
![Shell](https://img.shields.io/badge/shell-bash-4EAA25?style=flat-square)

A macOS system health scanner for the terminal. Runs 14 diagnostic checks covering identity, storage, battery, thermals, memory, processes, network, security, and more.

## Install

```bash
brew tap onurtellioglu/ctscan
brew install ctscan
```

## Usage

```
ctscan [OPTIONS] [MODULES...]
```

Run all checks:
```bash
ctscan
```

Run specific modules:
```bash
ctscan battery wifi
```

Skip modules:
```bash
ctscan --skip ssd,storage
```

Pipe-friendly output:
```bash
ctscan --no-color | tee health.log
```

Critical values only (CI/scripts):
```bash
ctscan --quiet
```

## Modules

| Module     | What it checks                                              |
|------------|-------------------------------------------------------------|
| identity   | Hostname, model, macOS version, uptime                      |
| brew       | Homebrew formula & cask counts, outdated pkgs               |
| agents     | Launch agents & daemon counts                               |
| storage    | Disk usage, cache size                                      |
| ssd        | SSD wear level (requires `smartmontools`)                   |
| battery    | Health %, cycle count, current charge                       |
| thermal    | Thermal throttling, GPU model                               |
| memory     | Swap usage, memory free %, total RAM                        |
| processes  | Top 5 by CPU and memory; warns if any process >80% CPU      |
| docker     | Running containers, disk usage (graceful if Docker absent)  |
| timemachine| Last backup age and status; warns if backup >24h old        |
| updates    | Pending macOS software updates; warns if updates available  |
| wifi       | Signal strength (dBm), network name                         |
| security   | FileVault, SIP, Gatekeeper status                           |

## Options

| Flag | Description |
|------|-------------|
| `--skip <mod1,mod2,...>` | Skip specified modules (comma-separated) |
| `--no-color` | Disable colored output |
| `--quiet` | Print critical values only |
| `--version` | Print version |
| `--help` | Print usage |

## Requirements

- macOS (Apple Silicon or Intel)
- Bash 3.2+ (ships with macOS)
- `smartmontools` (optional, for SSD wear — `brew install smartmontools`)

## Testing

```bash
bash test/ctscan_test.sh
```

## License

MIT — see [LICENSE](LICENSE)
