# ctscan Landing Page Design

**Date:** 2026-04-04  
**Status:** Approved  
**Author:** Claude Code

---

## Goal

Create a professional single-page landing site for the ctscan CLI tool, hosted on GitHub Pages. Provides both a marketing landing page and a reference for ctscan's 14 diagnostic modules.

---

## Style & Aesthetic

- **Theme:** Dark background + clean layout (Vercel/Linear aesthetic)
- **Background:** Near-black (`#0A0A0A` or similar) with subtle gradients or borders
- **Accent Color:** Terminal green (`#27C93F`) as primary accent, with yellow (`#FFBD2E`) for warnings
- **Typography:** System sans-serif (Inter, SF Pro) for body text; monospace for terminal/code blocks
- **Icons:** Phosphor Icons via CDN (`<script src="https://unpkg.com/@phosphor-icons/web"></script>`). Use duotone or fill weight variants. Do not use emojis anywhere on the page for visual elements.
- **Framework:** Pure HTML + CSS + minimal JS. Tailwind CSS via CDN (`<script src="https://cdn.tailwindcss.com"></script>`).
- **Build Step:** None. Single static `index.html`.

---

## Structure

### 1. Hero Section
- Full-viewport-height hero, centered vertically
- Title: "ctscan" — large monospace font
- Tagline: "macOS system health. Terminal-native. 14 checks, zero friction."
- Two CTA buttons:
  - **Install via Brew** (primary, white/inverted) → copies `brew install ctscan` to clipboard
  - **★ on GitHub** (secondary, outlined) → links to GitHub repo

### 2. What is ctscan
- 3-4 sentence description
- Centered, max-width ~640px for readability
- Subtle section heading above (small caps, muted)

### 3. Key Features Grid
- 3×2 responsive grid (collapses to 2×3 on tablet, single column on mobile)
- Each card: Phosphor icon (large, accent-colored) + title + 1-line description
- Cards:
  - Lightning/Thunderbolt — "Instant" — Runs in under a second
  - Shield — "Zero Privileges" — No root, no daemons
  - List/Table — "14 Modules" — Modular, pipe-friendly
  - Lock — "Security Checks" — FileVault, SIP, Gatekeeper status
  - Battery — "Battery Health" — Cycles, wear, charge percentage
  - Package — "Homebrew" — `brew install ctscan`

### 4. Terminal Preview
- Styled macOS terminal window (traffic light dots, dark interior)
- Sample ctscan output with colored checkmarks and status indicators
- Monospace font, ~11px, with realistic module output
- Should visually match the actual `ctscan` terminal output colors
- No JavaScript animation — static render of representative output

### 5. Installation
- Code block with copy-to-clipboard toggle
- Primary: `brew tap onurtellioglu/ctscan && brew install ctscan`
- Secondary: `git clone https://github.com/onur-tellioglu/ctscan`
- Brief "Requirements: macOS, Bash 3.2+" text

### 6. Full Module Reference
- HTML table showing all 14 modules (copied from README)
- Columns: Module name, Description, Warning conditions
- Collapsible/accordion on mobile if needed

### 7. Footer
- "MIT License · onur-tellioglu/ctscan"
- Links: GitHub, Report Issue
- Minimal, muted text

---

## Technical

- **File:** `docs/index.html` in the ctscan repo root (served by GitHub Pages from `docs/` folder on `main` branch)
- **CDN Dependencies:** Only Tailwind CSS and Phosphor Icons. No JavaScript framework.
- **Interactivity:** Minimal JS for copy-to-clipboard on install buttons. No build step, no bundler.
- **Mobile:** Fully responsive. Single-column layout below 768px.
- **SEO:** Meta description, Open Graph tags, favicon (can generate from ctscan logo concept).
- **Analytics:** None.

---

## Deployment

- Enable GitHub Pages on `main` branch → `/docs` folder in repo settings
- Custom domain not configured initially (uses `onur-tellioglu.github.io/ctscan`)
