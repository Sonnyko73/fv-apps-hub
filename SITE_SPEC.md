# Spec: App Pages on apps.fv.dev

## Context

All app pages live inside this repo (`fv-apps-hub`) and deploy to `apps.fv.dev/{app-slug}/` as part of the main Cloudflare Pages site. There is no separate deployment per app.

App content comes from `docs/{app-slug}-app-docs/` (the source of truth). The generated HTML pages go into `src/{app-slug}/`.

---

## Docs Folder Convention (`docs/`)

Each app has a folder: `docs/{app-slug}-app-docs/`

| File | Purpose |
|------|---------|
| `about.md` | App description, features, pricing, FAQ, links. Used to build the catalog card on `src/index.html` and the app landing page. |
| `README.md` | Manual table of contents — lists chapters with links. |
| `01-*.md`, `02-*.md`, ... | Manual chapters (getting started, managing features, troubleshooting, etc.). |
| `*.png` / `*.svg` | App logo and other assets referenced in docs. |

---

## Generated Output (`src/{app-slug}/`)

Each app gets an `index.html` under `src/{app-slug}/` that serves as both the landing page and the user manual. The page is built from the docs and follows the shared design system.

### Structure

```
src/{app-slug}/
├── index.html        # Landing page + manual (generated from docs)
├── styles/
│   ├── landing.css   # Landing page styles
│   └── docs.css      # Manual/docs styles
└── assets/           # App-specific images (screenshots, icons, og image)
```

### URL

`apps.fv.dev/{app-slug}/` — served from this repo, same Cloudflare Pages project as the catalog.

---

## Shared Styles

App pages load FV brand CSS from `/shared/` before their own styles:

```html
<link rel="stylesheet" href="/shared/styles/reset.css">
<link rel="stylesheet" href="/shared/styles/variables.css">
<link rel="stylesheet" href="/shared/styles/base.css">
<link rel="stylesheet" href="/shared/components/header.css">
<link rel="stylesheet" href="/shared/components/footer.css">
<link rel="stylesheet" href="/{app-slug}/styles/landing.css">
```

Use `--fv-*` CSS variables for all colors, spacing, typography. Only define app-specific overrides locally.

---

## Landing Page Sections

Each app landing page should include these sections (content pulled from `about.md`):

1. **Header** — FV logo (links to `/`), app name, nav links (Features, Pricing, Docs), CTA button
2. **Hero** — Headline, subheadline, primary CTA (install link), secondary CTA (docs link), screenshot
3. **Problem** — What problem the app solves (pain points)
4. **Features** — Feature cards in a grid, with Free/Pro badges
5. **How It Works** — 3-step walkthrough with icons
6. **Pricing** — Free vs Pro comparison cards
7. **FAQ** — Collapsible accordion (CSS-only `<details><summary>`)
8. **Footer** — FV branding, links to docs/support/privacy

---

## Manual / Docs Section

The user manual is a single-page layout with sidebar navigation, built from the chapter `.md` files listed in `README.md`.

### Layout

- Sticky sidebar on the left (table of contents from `README.md`)
- Content area on the right (rendered from chapter files)
- On mobile: sidebar collapses

### Content Source

Chapter files from `docs/{app-slug}-app-docs/`:
- `README.md` defines the order and structure
- Each `##` heading in a chapter becomes a sidebar nav entry

---

## SEO Meta Tags

Each app page should include:

```html
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{App Name} for {Platform} — {Page-specific suffix}</title>
<meta name="description" content="{Page-specific description}">
<meta property="og:title" content="{Same as title}">
<meta property="og:description" content="{Same as description}">
<meta property="og:image" content="https://apps.fv.dev/{app-slug}/assets/og.png">
<meta property="og:url" content="https://apps.fv.dev/{app-slug}/">
<meta property="og:type" content="website">
<link rel="icon" href="/shared/assets/favicon.ico">
```

---

## Image Guidelines

- Screenshots: 2x resolution (retina), cropped to relevant area, no browser chrome
- Max width: 1200px
- Format: PNG for screenshots, SVG for icons/illustrations
- Compress PNGs (use `pngquant` or similar)
- All images should have `alt` text for accessibility

---

## Constraints

- No JavaScript (pure HTML + CSS)
- No build step per app (static files, built by the main `scripts/build.js`)
- No app logic, no API calls
- All content is manually written in docs and generated into HTML

---

## Deployment

App pages deploy as part of the main `fv-apps-hub` Cloudflare Pages project. Push to `main` triggers GitHub Actions → builds → deploys everything (catalog + shared + all app pages) to Cloudflare Pages.

No separate deployment per app. No separate Cloudflare Pages project per app.
