# ctscan Landing Page Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a single-file, dark-themed landing page for ctscan hosted on GitHub Pages from `docs/index.html`.

**Architecture:** One static `docs/index.html` with all CSS (Tailwind CDN) and minimal JS inline. Each task builds one section of the page cumulatively — the file is valid and viewable after every step.

**Tech Stack:** Tailwind CSS v4 (CDN), Phosphor Icons (CDN), vanilla JS.

**File Structure:**
- `docs/index.html` — the only file. All sections, styles, and scripts live here.
- `README.md` — reference only for module table content.

---

### Task 1: HTML Skeleton & Tailwind Config

**Files:**
- Create: `docs/index.html`

- [ ] **Step 1: Create the base HTML file with Tailwind, Phosphor icons, and dark theme config**

This creates a valid (empty) page that serves as the foundation. Copy the full file below:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ctscan - macOS System Health</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="https://unpkg.com/@phosphor-icons/web@latest" />
  <script>
    tailwind.config = {
      theme: {
        extend: {
          colors: {
            green: { terminal: '#27C93F' },
            yellow: { terminal: '#FFBD2E' },
            bg: '#0A0A0A',
            surface: { DEFAULT: '#111111', light: '#1A1A1A', lighter: '#2D2D2D' },
            muted: '#888888',
            body: '#E0E0E0',
          },
          fontFamily: {
            mono: ['SF Mono', 'Fira Code', 'Fira Code', 'Cascadia Code', 'monospace'],
          },
        },
      },
    };
  </script>
</head>
<body class="bg-bg text-body antialiased">
  <!-- Hero -->
  <section>
  </section>
</body>
</html>
```

- [ ] **Step 2: Verify the page renders**

Open `docs/index.html` in a browser or run:
```bash
open docs/index.html
```
Expected: Blank dark page with title "ctscan - macOS System Health" (visible in browser tab).

- [ ] **Step 3: Commit**

```bash
git add docs/index.html
git commit -m "docs: add landing page skeleton with Tailwind and Phosphor icons"
```

---

### Task 2: Hero Section

**Files:**
- Modify: `docs/index.html`

- [ ] **Step 1: Build the hero section**

Replace the empty `<section>` with:

```html
  <!-- Hero -->
  <section class="min-h-screen flex items-center justify-center px-4 relative overflow-hidden">
    <div class="text-center">
      <h1 class="text-6xl md:text-8xl font-bold font-mono tracking-tight text-white">ctscan</h1>
      <p class="mt-4 text-lg md:text-xl text-muted max-w-xl mx-auto">
        macOS system health. Terminal-native. 14 checks, zero friction.
      </p>
      <div class="mt-8 flex flex-col sm:flex-row items-center justify-center gap-4">
        <button class="bg-white text-bg font-semibold px-6 py-3 rounded-lg hover:bg-gray-200 transition-colors cursor-pointer" onclick="navigator.clipboard.writeText('brew install ctscan'); this.textContent='Copied!'; setTimeout(() => this.textContent='Install via Brew', 2000);">
          <i class="ph ph-package mr-2"></i>Install via Brew
        </button>
        <a href="https://github.com/onurtellioglu/ctscan" target="_blank" class="border border-surface-lighter text-body px-6 py-3 rounded-lg hover:bg-surface-light transition-colors inline-flex items-center">
          <i class="ph ph-github-logo mr-2"></i>on GitHub
        </a>
      </div>
    </div>
  </section>
```

- [ ] **Step 2: Verify**

```bash
open docs/index.html
```
Expected: Full-screen dark hero with "ctscan" title, tagline, and two buttons (Install via Brew + on GitHub).

- [ ] **Step 3: Commit**

```bash
git add docs/index.html
git commit -m "docs: add hero section with CTAs"
```

---

### Task 3: What is ctscan + Key Features Grid

**Files:**
- Modify: `docs/index.html`

- [ ] **Step 1: Add both sections after the hero**

Insert these two `<section>` blocks after the Hero's closing `</section>`:

```html
  <!-- What is ctscan -->
  <section class="py-24 px-4">
    <div class="max-w-2xl mx-auto text-center">
      <p class="text-xs uppercase tracking-widest text-muted mb-4">About</p>
      <h2 class="text-3xl font-bold text-white mb-6">What is ctscan?</h2>
      <p class="text-muted text-lg leading-relaxed">
        ctscan is a lightweight macOS health scanner that runs 14 diagnostic checks from the terminal — battery, memory, storage, security, network, and more.
        No daemon, no GUI, no background processes. Just run it and get a clean, color-coded report in seconds.
        Ships with Homebrew, requires only Bash.
      </p>
    </div>
  </section>

  <!-- Features Grid -->
  <section class="py-16 px-4">
    <div class="max-w-4xl mx-auto">
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        <div class="bg-surface border border-surface-lighter rounded-xl p-6 text-center hover:border-green-terminal/30 transition-colors">
          <i class="ph-duotone ph-lightning text-4xl text-green-terminal mb-3"></i>
          <h3 class="text-white font-semibold mb-1">Instant</h3>
          <p class="text-muted text-sm">Runs in under a second</p>
        </div>
        <div class="bg-surface border border-surface-lighter rounded-xl p-6 text-center hover:border-green-terminal/30 transition-colors">
          <i class="ph-duotone ph-shield-check text-4xl text-green-terminal mb-3"></i>
          <h3 class="text-white font-semibold mb-1">Zero Privileges</h3>
          <p class="text-muted text-sm">No root, no daemons</p>
        </div>
        <div class="bg-surface border border-surface-lighter rounded-xl p-6 text-center hover:border-green-terminal/30 transition-colors">
          <i class="ph-duotone ph-list-checks text-4xl text-green-terminal mb-3"></i>
          <h3 class="text-white font-semibold mb-1">14 Modules</h3>
          <p class="text-muted text-sm">Modular, pipe-friendly output</p>
        </div>
        <div class="bg-surface border border-surface-lighter rounded-xl p-6 text-center hover:border-green-terminal/30 transition-colors">
          <i class="ph-duotone ph-lock-key text-4xl text-green-terminal mb-3"></i>
          <h3 class="text-white font-semibold mb-1">Security Checks</h3>
          <p class="text-muted text-sm">FileVault, SIP, Gatekeeper</p>
        </div>
        <div class="bg-surface border border-surface-lighter rounded-xl p-6 text-center hover:border-green-terminal/30 transition-colors">
          <i class="ph-duotone ph-battery-charging text-4xl text-green-terminal mb-3"></i>
          <h3 class="text-white font-semibold mb-1">Battery Health</h3>
          <p class="text-muted text-sm">Cycles, wear, charge</p>
        </div>
        <div class="bg-surface border border-surface-lighter rounded-xl p-6 text-center hover:border-green-terminal/30 transition-colors">
          <i class="ph-duotone ph-package text-4xl text-green-terminal mb-3"></i>
          <h3 class="text-white font-semibold mb-1">Homebrew</h3>
          <p class="text-muted text-sm"><code class="bg-surface-lighter px-1 rounded">brew install ctscan</code></p>
        </div>
      </div>
    </div>
  </section>
```

- [ ] **Step 2: Verify**

```bash
open docs/index.html
```
Expected: Scrollable page with hero → "What is ctscan" description → 6-card features grid with Phosphor icons.

- [ ] **Step 3: Commit**

```bash
git add docs/index.html
git commit -m "docs: add About and Features sections"
```

---

### Task 4: Terminal Preview Section

**Files:**
- Modify: `docs/index.html`

- [ ] **Step 1: Add the terminal preview after the Features grid**

Insert after the Features section's closing `</section>`:

```html
  <!-- Terminal Preview -->
  <section class="py-16 px-4">
    <div class="max-w-2xl mx-auto">
      <p class="text-xs uppercase tracking-widest text-muted mb-6 text-center">Output</p>
      <div class="bg-surface border border-surface-lighter rounded-lg overflow-hidden">
        <div class="flex items-center gap-2 px-4 py-2 bg-surface-lighter">
          <span class="w-3 h-3 rounded-full bg-red-500"></span>
          <span class="w-3 h-3 rounded-full bg-yellow-400"></span>
          <span class="w-3 h-3 rounded-full bg-green-terminal"></span>
          <span class="ml-2 text-xs text-muted">Terminal — ctscan</span>
        </div>
        <pre class="p-4 text-xs leading-relaxed overflow-x-auto" style="font-family: 'SF Mono', 'Fira Code', monospace;"><code><span class="text-green-terminal">✓ IDENTITY</span>  MacBook Pro (M3 Max) | macOS 15.4 | Uptime: 3d 14h
<span class="text-green-terminal">✓ BATTERY</span>   Health: 96% | Cycles: 87 | 72%
<span class="text-yellow-terminal">⚠ THERMAL</span>   GPU throttling detected
<span class="text-green-terminal">✓ MEMORY</span>    16.2 GB free / 36 GB | 0 swap used
<span class="text-green-terminal">✓ STORE</span>     234 GB used / 1 TB | 766 GB free
<span class="text-green-terminal">✓ SECURITY</span>  FileVault ✓ | SIP ✓ | Gatekeeper ✓
<span class="text-green-terminal">✓ WIFI</span>      Signal: -42 dBm | Network: Home_5G</code></pre>
      </div>
    </div>
  </section>
```

- [ ] **Step 2: Verify**

```bash
open docs/index.html
```
Expected: Terminal window with traffic light dots and realistic ctscan output below the features grid.

- [ ] **Step 3: Commit**

```bash
git add docs/index.html
git commit -m "docs: add terminal preview section"
```

---

### Task 5: Installation Section & Footer

**Files:**
- Modify: `docs/index.html`

- [ ] **Step 1: Add Installation and Footer sections**

Insert after the Terminal Preview's closing `</section>`:

```html
  <!-- Installation -->
  <section class="py-16 px-4">
    <div class="max-w-2xl mx-auto text-center">
      <p class="text-xs uppercase tracking-widest text-muted mb-6">Get Started</p>
      <h2 class="text-2xl font-bold text-white mb-6">Install ctscan</h2>
      <div class="bg-surface border border-surface-lighter rounded-lg p-4 mb-4 relative group text-left">
        <button class="absolute top-3 right-3 text-muted hover:text-white text-xs px-3 py-1 rounded bg-surface-lighter transition-colors" onclick="copyToClipboard(this, 'brew tap onurtellioglu/ctscan && brew install ctscan')">Copy</button>
        <code class="text-sm font-mono text-green-terminal">brew tap onurtellioglu/ctscan && brew install ctscan</code>
      </div>
      <div class="bg-surface border border-surface-lighter rounded-lg p-4 relative group text-left">
        <button class="absolute top-3 right-3 text-muted hover:text-white text-xs px-3 py-1 rounded bg-surface-lighter transition-colors" onclick="copyToClipboard(this, 'git clone https://github.com/onur-tellioglu/ctscan')">Copy</button>
        <code class="text-sm font-mono text-body">git clone https://github.com/onur-tellioglu/ctscan</code>
      </div>
      <p class="text-muted text-sm mt-6">
        <strong class="text-white">Requirements:</strong> macOS · Bash 3.2+ ·
        <span class="inline-block"><code class="text-xs bg-surface-lighter px-1 rounded">smartmontools</code> (optional, for SSD wear)</span>
      </p>
    </div>
  </section>

  <!-- Footer -->
  <footer class="py-8 px-4 border-t border-surface-lighter">
    <div class="max-w-4xl mx-auto text-center text-muted text-sm">
      <p>MIT License · <a href="https://github.com/onurtellioglu/ctscan" class="text-body hover:underline">onurtellioglu/ctscan</a></p>
      <div class="mt-2 flex justify-center gap-4">
        <a href="https://github.com/onurtellioglu/ctscan" class="hover:text-white transition-colors"><i class="ph ph-github-logo mr-1"></i>GitHub</a>
        <a href="https://github.com/onurtellioglu/ctscan/issues" class="hover:text-white transition-colors"><i class="ph ph-bug mr-1"></i>Report Issue</a>
      </div>
    </div>
  </footer>
```

- [ ] **Step 2: Add the copy-to-clipboard script before `</body>`**

Insert before the closing `</body>` tag:

```html
  <script>
    function copyToClipboard(btn, text) {
      navigator.clipboard.writeText(text).then(() => {
        const original = btn.textContent;
        btn.textContent = 'Copied!';
        setTimeout(() => btn.textContent = original, 2000);
      });
    }
  </script>
```

- [ ] **Step 3: Verify**

```bash
open docs/index.html
```
Expected: Install blocks with copy buttons + minimal footer with GitHub/Report Issue links.

- [ ] **Step 4: Commit**

```bash
git add docs/index.html
git commit -m "docs: add installation and footer sections"
```

---

### Task 6: Full Module Reference Table

**Files:**
- Modify: `docs/index.html`

- [ ] **Step 1: Add the module reference table before the Footer**

Insert the following before the `<!-- Footer -->` comment:

```html
  <!-- Module Reference -->
  <section class="py-16 px-4">
    <div class="max-w-4xl mx-auto">
      <p class="text-xs uppercase tracking-widest text-muted mb-6 text-center">Reference</p>
      <h2 class="text-2xl font-bold text-white mb-8 text-center">Modules</h2>
      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead>
            <tr class="border-b border-surface-lighter">
              <th class="text-left py-3 px-4 text-muted font-medium uppercase tracking-wider text-xs">Module</th>
              <th class="text-left py-3 px-4 text-muted font-medium uppercase tracking-wider text-xs">Description</th>
              <th class="text-left py-3 px-4 text-muted font-medium uppercase tracking-wider text-xs hidden sm:table-cell">Warning Condition</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-surface-lighter">
            <tr class="hover:bg-surface-light/50"><td class="py-3 px-4 font-mono text-green-terminal">identity</td><td class="py-3 px-4 text-muted">Hostname, model, macOS version, uptime</td><td class="py-3 px-4 text-muted hidden sm:table-cell">—</td></tr>
            <tr class="hover:bg-surface-light/50"><td class="py-3 px-4 font-mono text-green-terminal">brew</td><td class="py-3 px-4 text-muted">Homebrew formula &amp; cask counts, outdated pkgs</td><td class="py-3 px-4 text-muted hidden sm:table-cell">Outdated packages detected</td></tr>
            <tr class="hover:bg-surface-light/50"><td class="py-3 px-4 font-mono text-green-terminal">agents</td><td class="py-3 px-4 text-muted">Launch agents &amp; daemon counts</td><td class="py-3 px-4 text-muted hidden sm:table-cell">—</td></tr>
            <tr class="hover:bg-surface-light/50"><td class="py-3 px-4 font-mono text-green-terminal">storage</td><td class="py-3 px-4 text-muted">Disk usage, cache size</td><td class="py-3 px-4 text-muted hidden sm:table-cell">Disk nearly full</td></tr>
            <tr class="hover:bg-surface-light/50"><td class="py-3 px-4 font-mono text-green-terminal">ssd</td><td class="py-3 px-4 text-muted">SSD wear level (requires <code class="text-xs bg-surface-lighter px-1 rounded">smartmontools</code>)</td><td class="py-3 px-4 text-muted hidden sm:table-cell">High wear level</td></tr>
            <tr class="hover:bg-surface-light/50"><td class="py-3 px-4 font-mono text-green-terminal">battery</td><td class="py-3 px-4 text-muted">Health %, cycle count, current charge</td><td class="py-3 px-4 text-muted hidden sm:table-cell">Low health / high cycles</td></tr>
            <tr class="hover:bg-surface-light/50"><td class="py-3 px-4 font-mono text-green-terminal">thermal</td><td class="py-3 px-4 text-muted">Thermal throttling, GPU model</td><td class="py-3 px-4 text-muted hidden sm:table-cell">Throttling detected</td></tr>
            <tr class="hover:bg-surface-light/50"><td class="py-3 px-4 font-mono text-green-terminal">memory</td><td class="py-3 px-4 text-muted">Swap usage, memory free %, total RAM</td><td class="py-3 px-4 text-muted hidden sm:table-cell">High swap / low memory</td></tr>
            <tr class="hover:bg-surface-light/50"><td class="py-3 px-4 font-mono text-green-terminal">processes</td><td class="py-3 px-4 text-muted">Top 5 by CPU and memory</td><td class="py-3 px-4 text-muted hidden sm:table-cell">Process >80% CPU</td></tr>
            <tr class="hover:bg-surface-light/50"><td class="py-3 px-4 font-mono text-green-terminal">docker</td><td class="py-3 px-4 text-muted">Running containers, disk usage</td><td class="py-3 px-4 text-muted hidden sm:table-cell">—</td></tr>
            <tr class="hover:bg-surface-light/50"><td class="py-3 px-4 font-mono text-green-terminal">timemachine</td><td class="py-3 px-4 text-muted">Last backup age and status</td><td class="py-3 px-4 text-muted hidden sm:table-cell">Backup >24h old</td></tr>
            <tr class="hover:bg-surface-light/50"><td class="py-3 px-4 font-mono text-green-terminal">updates</td><td class="py-3 px-4 text-muted">Pending macOS software updates</td><td class="py-3 px-4 text-muted hidden sm:table-cell">Updates available</td></tr>
            <tr class="hover:bg-surface-light/50"><td class="py-3 px-4 font-mono text-green-terminal">wifi</td><td class="py-3 px-4 text-muted">Signal strength (dBm), network name</td><td class="py-3 px-4 text-muted hidden sm:table-cell">Weak signal</td></tr>
            <tr class="hover:bg-surface-light/50"><td class="py-3 px-4 font-mono text-green-terminal">security</td><td class="py-3 px-4 text-muted">FileVault, SIP, Gatekeeper status</td><td class="py-3 px-4 text-muted hidden sm:table-cell">Any disabled</td></tr>
          </tbody>
        </table>
      </div>
    </div>
  </section>
```

- [ ] **Step 2: Verify**

```bash
open docs/index.html
```
Expected: Module reference table below installation. On mobile (< 640px), the "Warning Condition" column hides.

- [ ] **Step 3: Commit**

```bash
git add docs/index.html
git commit -m "docs: add module reference table"
```

---

### Task 7: SEO Meta & Final Polish

**Files:**
- Modify: `docs/index.html`

- [ ] **Step 1: Add SEO meta tags and social sharing**

Replace the `<head>` section with:

```html
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ctscan - macOS System Health Scanner</title>
  <meta name="description" content="A lightweight macOS system health scanner for the terminal. 14 diagnostic checks, zero friction. Install via Homebrew.">
  <meta name="theme-color" content="#0A0A0A">
  <link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>⬛</text></svg>">
  <meta property="og:title" content="ctscan - macOS System Health Scanner">
  <meta property="og:description" content="14 diagnostic checks. Terminal-native. Zero friction.">
  <meta property="og:type" content="website">
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="https://unpkg.com/@phosphor-icons/web@latest" />
  <script>
    tailwind.config = {
      theme: {
        extend: {
          colors: {
            green: { terminal: '#27C93F' },
            yellow: { terminal: '#FFBD2E' },
            bg: '#0A0A0A',
            surface: { DEFAULT: '#111111', light: '#1A1A1A', lighter: '#2D2D2D' },
            muted: '#888888',
            body: '#E0E0E0',
          },
          fontFamily: {
            mono: ['SF Mono', 'Fira Code', 'Fira Code', 'Cascadia Code', 'monospace'],
          },
        },
      },
    };
  </script>
</head>
```

Also add `scroll-smooth` to the `<body>` tag:
```html
<body class="bg-bg text-body antialiased scroll-smooth">
```

- [ ] **Step 2: Add smooth scroll and section anchors (optional navigation)**

After the `<body>` opening tag, before the Hero section, add a fixed header nav:

```html
  <!-- Top Nav -->
  <nav class="fixed top-0 left-0 right-0 z-50 bg-bg/80 backdrop-blur-sm border-b border-surface-lighter">
    <div class="max-w-4xl mx-auto px-4 flex items-center justify-between h-12 text-sm">
      <a href="#" class="font-mono font-bold text-white">ctscan</a>
      <div class="flex items-center gap-4">
        <a href="#modules" class="text-muted hover:text-white transition-colors">Modules</a>
        <a href="#install" class="text-muted hover:text-white transition-colors">Install</a>
        <a href="https://github.com/onurtellioglu/ctscan" class="text-muted hover:text-white transition-colors" target="_blank"><i class="ph ph-github-logo"></i></a>
      </div>
    </div>
  </nav>
```

Add `id` attributes to sections so the nav links work. Update the Hero opening `<section>` tag:
```html
  <section id="home" class="min-h-screen flex ...
```

Update the Installation section opening tag:
```html
  <section id="install" class="py-16 ...
```

Update the Module Reference section opening tag:
```html
  <section id="modules" class="py-16 ...
```

- [ ] **Step 3: Full verification**

```bash
open docs/index.html
```
Expected:
- Fixed top nav with "ctscan" logo, Modules/Install/GitHub links
- Smooth scrolling to sections when clicking nav links
- All content renders: Hero → About → Features → Terminal → Install → Modules → Footer
- Responsive: columns collapse to single on mobile, Module table hides "Warning Condition"
- SEO meta present in inspect element

- [ ] **Step 4: Final commit**

```bash
git add docs/index.html
git commit -m "docs: add SEO meta, top nav, and smooth scrolling"
```
