# fv-apps-hub

Monorepo for `apps.fv.dev/` -- catalog page, shared design system, and all app pages.

## Tech Stack

- Static site: plain HTML + CSS, no JavaScript frameworks
- Build: Node.js 20 script (`scripts/build.js`) -- copies `src/` to `dist/`, `shared/` to `dist/shared/`, minifies HTML + CSS
- Hosting: Cloudflare Pages (global CDN)
- Deployment: GitHub Actions (`.github/workflows/deploy.yml`) via `cloudflare/wrangler-action@v3`
- Project name: `fv-apps-hub`

## Project Structure

```
fv-apps-hub/
├── src/
│   ├── index.html          # Catalog page (hardcoded app cards)
│   ├── styles.css           # Catalog-specific styles
│   ├── 404.html             # Custom 404 page
│   ├── assets/
│   │   └── hero.png
│   └── {app-slug}/         # App pages (generated from docs/)
│       └── index.html
├── docs/                    # App manuals (source of truth)
│   └── {app-slug}-app-docs/
│       ├── about.md         # App info for catalog card + landing page
│       ├── README.md        # Manual table of contents
│       └── *.md             # Manual chapters
├── shared/                  # Hosted at apps.fv.dev/shared/
│   ├── styles/
│   │   ├── reset.css        # Minimal CSS reset
│   │   ├── variables.css    # Brand tokens (design system)
│   │   └── base.css         # Typography, containers, utilities
│   ├── assets/
│   │   ├── fv-logo.png         # Primary logo (used in headers/footers)
│   │   ├── fv-logo.svg
│   │   ├── fv-logo-dark.svg
│   │   └── favicon.ico
│   └── components/
│       ├── header.css       # Shared header styles
│       └── footer.css       # Shared footer styles
├── scripts/
│   └── build.js
├── dist/                    # Build output (gitignored)
├── _redirects               # Cloudflare Pages proxy rules
├── _headers                 # CORS + cache headers for /shared/*
└── package.json
```

## URL Routing

- `apps.fv.dev/` -- Main catalog page
- `apps.fv.dev/shared/styles/` -- Shared CSS (consumed by all app pages)
- `apps.fv.dev/shared/assets/` -- Shared assets (logos, fonts)
- `apps.fv.dev/{app-slug}/` -- App pages (served from this repo)

## Shared Design System

App pages consume shared styles via `<link>` tags with relative paths:

```html
<link rel="stylesheet" href="/shared/styles/reset.css">
<link rel="stylesheet" href="/shared/styles/variables.css">
<link rel="stylesheet" href="/shared/styles/base.css">
```

See `SHARED-STYLES.md` for the full reference (tokens, utility classes, header/footer markup, page template).

### Design Tokens (`variables.css`)

**Colors:**
- Primary: `--fv-green: #27ae60`, `--fv-green-dark: #219a52`, `--fv-green-light: #2ecc71`
- Neutrals: `--fv-navy: #2c3e50`, `--fv-navy-light: #34495e`, `--fv-white: #ffffff`
- Grays: `--fv-gray-50` (#fafbfc) through `--fv-gray-800` (#343a40)
- Status: `--fv-danger: #e74c3c`, `--fv-warning: #f39c12`, `--fv-info: #3498db`

**Typography:**
- `--fv-font`: system font stack (-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif)
- `--fv-font-mono`: 'SF Mono', SFMono-Regular, Consolas, monospace
- Sizes: `--fv-fs-xs` (0.75rem) through `--fv-fs-3xl` (2.5rem)

**Spacing:** `--fv-space-xs` (4px) through `--fv-space-3xl` (64px)

**Layout:**
- `--fv-max-width: 1120px`
- Border radius: `--fv-radius: 8px`, `--fv-radius-sm: 4px`, `--fv-radius-lg: 12px`
- Shadows: `--fv-shadow` (subtle), `--fv-shadow-lg` (elevated)
- `--fv-transition: 0.2s ease`

### Utility Classes (`base.css`)

- `.fv-container` -- max-width container with auto margins and padding
- `.fv-btn`, `.fv-btn-primary`, `.fv-btn-outline` -- button styles
- `.fv-card` -- card component (white bg, rounded corners, shadow)
- `.fv-text-muted`, `.fv-text-center` -- text utilities

## Catalog Page (`src/index.html`)

Sections:
1. **Header** -- FV logo, "Forest Valley Apps" title, link to fv.dev
2. **Hero** -- Tagline: "Business Apps by Forest Valley", subtitle about integrations and tools
3. **What We Do** -- Description of the company's approach and focus
4. **App Grid** -- Card per app with: icon, name, one-line description, platform badges, pricing badge (Free/Freemium/Paid), "View details" link
5. **Why Forest Valley** -- Three value props: Built by Developers, Reliable & Secure, Real Support
6. **Footer** -- copyright, link to fv.dev, contact email

App data is hardcoded in HTML. When adding a new app, manually add a card. App info comes from `docs/{app-slug}-app-docs/about.md`.

## Caching (`_headers`)

```
/shared/*
  Cache-Control: public, max-age=86400
```

## Repository & Deployment

- **GitHub:** https://github.com/Sonnyko73/fv-apps-hub
- **Live URL:** https://fv-apps-hub.pages.dev (custom domain: apps.fv.dev)
- **Deploy:** Push to `main` triggers GitHub Actions → builds → deploys to Cloudflare Pages
- **Secrets (GitHub):** `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`
- **Cloudflare Account:** ak@fv.dev

## Commands

- `npm run build` -- Build to `dist/` (copies src + shared, minifies HTML/CSS)
- `npm run dev` -- Serve `dist/` locally via `npx serve`

## App Docs (`docs/`)

Each app has a manual in `docs/{app-slug}-app-docs/` with:

- **`about.md`** -- App description, features, pricing, FAQ. Used to generate the catalog card on `src/index.html` and the app landing page at `src/{app-slug}/index.html`.
- **`README.md`** -- Manual table of contents linking to chapter files.
- **`01-*.md`, `02-*.md`, ...** -- Manual chapters (getting started, features, troubleshooting, etc.).

The docs folder is the **source of truth** for all app content on the site. App pages and catalog cards should be built from these docs.

## Adding a New App

1. Add app manual to `docs/{app-slug}-app-docs/` (about.md + README.md + chapter files)
2. Generate the app page under `src/{app-slug}/` from the docs
3. Add an app card to `src/index.html` (using info from `about.md`)
4. Push to `main`
