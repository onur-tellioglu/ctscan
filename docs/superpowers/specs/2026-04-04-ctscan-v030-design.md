# ctscan v0.3.0 — Design Spec
Date: 2026-04-04

## Overview

v0.3.0 adds four new modules (`processes`, `docker`, `timemachine`, `updates`) and one fix to the existing `storage` module (add total disk usage line). All additions follow the existing module pattern: a `check_<name>()` function, graceful degradation when dependencies are absent, and `--quiet` threshold warnings.

---

## Changes

### 1. Storage module fix

Add a single disk summary line at the top of the `storage` section output:

```
  · Disk: 156G used / 494G total (32% full)
```

Source: `df -H /`. No new quiet-mode threshold.

---

### 2. New module: `processes`

**Position in ALL_MODULES:** after `memory` (before `wifi`)

**Commands:** `ps aux`

**Output (verbose):**
```
══ Processes ══
  Top by CPU:
  · 34.2%  Xcode
  ·  8.1%  Google Chrome Helper (Renderer)
  ·  4.7%  com.apple.WebKit.Networking
  ·  3.2%  node
  ·  2.1%  Simulator

  Top by Memory:
  · 2.1G   Xcode
  · 1.4G   Google Chrome
  · 891M   Simulator
  · 512M   Docker Desktop
  · 340M   node
```

Shows top 5 processes by CPU%, then top 5 by RSS memory. Uses `ps aux` sorted twice — no external dependencies.

**Quiet threshold:** warn if any single process exceeds 80% CPU.

```
  ⚠ High CPU: Xcode at 92.3%
```

---

### 3. New module: `docker`

**Position in ALL_MODULES:** after `processes`

**Commands:** `docker ps`, `docker system df`

**Graceful degradation:**
- If `docker` not in PATH: print install hint, skip.
- If Docker daemon not running: print `Docker not running`, skip.

**Output (verbose):**
```
══ Docker ══
  · Running containers: 2
  · postgres:15          Up 3 hours
  · redis:7-alpine       Up 3 hours

  · Images: 14  |  Volumes: 6
  · Disk usage: 12.4GB total (images 9.1G · containers 2.8G · volumes 480M)
```

If no containers running:
```
  ✓ No containers running
  · Images: 8  |  Volumes: 3
  · Disk usage: 4.2GB total (images 4.1G · containers 12M · volumes 80M)
```

**Quiet threshold:** none — docker info is informational only.

---

### 4. New module: `timemachine`

**Position in ALL_MODULES:** after `docker`

**Commands:** `tmutil latestbackup`, `tmutil destinationinfo`, `tmutil status`

**Graceful degradation:** if Time Machine has never run or no destination is configured, print `Time Machine not configured`.

**Output (verbose):**
```
══ Time Machine ══
  ✓ Last backup: 4 hours ago (2026-04-04 09:14)
  · Destination: My Passport (local disk)
  · Status: idle
```

If backup is in progress:
```
  · Status: backing up (42% complete)
```

**Quiet threshold:** warn if last backup is more than 24 hours ago.

```
  ⚠ Last backup: 3 days ago — Time Machine may not be running
```

---

### 5. New module: `updates`

**Position in ALL_MODULES:** after `timemachine` (end of list, before or after `security` — place before `security`)

**Commands:** `softwareupdate -l`

**Note:** `softwareupdate -l` can be slow (5–10s network call). Output is printed as-is after filtering.

**Output — updates available:**
```
══ Updates ══
  ⚠ 2 updates available
  · macOS Sequoia 26.4.1  (Security Update)
  · Safari 20.1.1
```

**Output — up to date:**
```
══ Updates ══
  ✓ No updates available
```

**Quiet threshold:** warn if any updates are available.

---

## Updated module order

```
ALL_MODULES=(identity brew agents storage ssd battery thermal memory processes docker timemachine updates wifi security)
```

---

## Updated help text

```
MODULES (default: all):
  identity    System identity & uptime
  brew        Brew hygiene
  agents      Launch agents & daemons
  storage     Storage analytics
  ssd         SSD wear level (requires smartmontools)
  battery     Battery analytics
  thermal     Thermal & GPU state
  memory      RAM pressure & swap
  processes   Top CPU & memory consumers       ← NEW
  docker      Running containers & disk usage  ← NEW
  timemachine Last backup date & status        ← NEW
  updates     Pending macOS software updates   ← NEW
  wifi        Network signal strength
  security    Security & SIP status
```

---

## Module details table (updated)

| Module      | Key commands                          | Quiet threshold                        |
|-------------|---------------------------------------|----------------------------------------|
| processes   | `ps aux`                              | Any process >80% CPU                   |
| docker      | `docker ps`, `docker system df`       | None                                   |
| timemachine | `tmutil latestbackup`, `tmutil status`| Last backup >24h ago                   |
| updates     | `softwareupdate -l`                   | Any updates available                  |

---

## No changes to

- CLI interface (`parse_args`, `run_modules`, `print_usage` structure — only text additions)
- Existing modules (except the one-line storage fix)
- Distribution / tap formula (handled at release time)
- Test structure (new smoke tests added per module)

---

## Testing additions

`test/ctscan_test.sh` additions:
- `ctscan processes` runs without error
- `ctscan docker` runs without error (gracefully degrades if docker absent)
- `ctscan timemachine` runs without error (gracefully degrades if not configured)
- `ctscan updates` runs without error
- `ctscan storage` output contains "Disk:" line
- `--skip processes` excludes processes from output
