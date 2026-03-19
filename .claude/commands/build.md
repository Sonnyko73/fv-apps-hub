# Build & Deploy

Check for updated docs, regenerate affected pages, build, and push to GitHub for deployment.

## Steps

### 1. Check for updated docs

Scan each `docs/{app-slug}-app-docs/` folder (these are symlinks — read-only, never modify the `.md` files).

For each app, compare source file timestamps against generated output timestamps:

- **`about.md`** → compare against `src/{app-slug}/index.html`
- **Chapter files (`01-*.md`, `02-*.md`, etc.) and `README.md`** → compare against `src/{app-slug}/docs/index.html`

Use `stat` to get modification times. Classify each app:

| about.md newer? | chapters/README newer? | Action |
|---|---|---|
| Yes | No | Regenerate landing page + update catalog card only |
| No | Yes | Regenerate docs page only |
| Yes | Yes | Regenerate landing page + docs page + catalog card |
| No | No | Skip — no changes |

If generated pages don't exist yet, treat as "newer" (needs full generation).

Report what needs regeneration per app before proceeding.

### 2. Regenerate only changed pages

For each app with changes, regenerate only the affected outputs. Follow the exact same HTML structure, content rendering rules, and markup patterns defined in `.claude/commands/generate-app-page.md`.

**If landing page needs regeneration** (`about.md` changed):
- Read `about.md` from `docs/{app-slug}-app-docs/`
- Regenerate `src/{app-slug}/index.html` (landing page)
- Regenerate `src/{app-slug}/styles/landing.css` if needed
- Update the app's catalog card in `src/index.html`

**If docs page needs regeneration** (chapter files or README changed):
- Read `README.md` and all chapter files from `docs/{app-slug}-app-docs/`
- Regenerate `src/{app-slug}/docs/index.html` (user manual)
- Regenerate `src/{app-slug}/styles/docs.css` if needed
- Skip developer-only chapters (Developer Guide, API Reference) — merchant-facing only

If no apps need regeneration, report "All pages up to date" and proceed to build.

### 3. Check for updated legal files

Scan each file in `Legal/` for the three legal documents and compare their timestamps against the generated HTML pages:

| Source file | Generated page |
|---|---|
| `Legal/FVR Privacy Policy.md` | `src/privacy/index.html` |
| `Legal/FVR Terms of service.md` | `src/terms/index.html` |
| `Legal/FVR RDPP.md` | `src/rdpp/index.html` |

Use `stat` to compare modification times. If a source `.md` file is newer than its corresponding `src/` page (or the page doesn't exist), regenerate that page:

- Read the source `.md` file
- Convert all markdown to HTML following the same rules used to create these pages originally:
  - `## N\. Title` → `<h2 id="n-title">N. Title</h2>`
  - `### Subsection` → `<h3>Subsection</h3>`
  - `**text**` → `<strong>text</strong>`, `*text*` → `<em>text</em>`
  - Bullet lists → `<ul><li>`, numbered lists → `<ol><li>`
  - `[text](url)` → `<a href="url">text</a>` (email links use `mailto:`)
  - Tables → `<table><thead><tbody>` with proper `<th>`/`<td>`
  - Remove backslash escapes (`1\.` → `1.`, `\+` → `+`)
  - Wrap summary/intro blocks in `<div class="legal-summary">`
  - Wrap TOC in `<div class="legal-toc"><h2>Table of Contents</h2><ol>...</ol></div>`
- Use the shared page template: standard FV header + `<main class="fv-container"><div class="legal-header">` + `<div class="legal-body">` + standard FV footer with all legal links
- Reference `/legal.css` in the `<head>`
- Keep the footer links consistent: All Apps, Terms of Service, Privacy Policy, Regional Data Protection, info@fv.dev, fv.dev

If no legal files changed, report "Legal pages up to date" and continue.

### 5. Check CLAUDE.md is up to date

Read `CLAUDE.md` and compare it against the current project state:

- Check the **Project Structure** tree matches actual files/folders in `src/`, `docs/`, `Shared-assets/`, `scripts/`. Look for missing or extra entries.
- Check the **URL Routing** section matches existing app pages in `src/`.
- Check the **App Docs** section matches the actual `docs/` folder contents.
- Check the **Adding a New App** workflow is still accurate.

If anything is outdated, update `CLAUDE.md` to match the current state. Report what you changed.

### 6. Build

Run `npm run build` and check for errors. If the build fails, fix the issue and retry.

### 7. Git commit & push

- Run `git status` and `git diff` to review all changes.
- Stage all relevant files (but NOT `.env`, credentials, or secrets).
- Create a descriptive commit message summarizing what changed.
- Push to `main`.

Report the commit hash and what was deployed.
