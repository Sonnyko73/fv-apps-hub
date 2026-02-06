# fv-apps-hub

Hub/catalog page at `apps.fv.dev/` and shared assets at `apps.fv.dev/shared/`. This repo knows nothing about individual apps -- it only links to them.

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
│   └── assets/
│       └── hero.png
├── shared/                  # Hosted at apps.fv.dev/shared/
│   ├── styles/
│   │   ├── reset.css        # Minimal CSS reset
│   │   ├── variables.css    # Brand tokens (design system)
│   │   └── base.css         # Typography, containers, utilities
│   ├── assets/
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
- `apps.fv.dev/shared/styles/` -- Shared CSS (consumed by all app repos)
- `apps.fv.dev/shared/assets/` -- Shared assets (logos, fonts)
- `apps.fv.dev/{app-slug}/` -- Proxied to separate Cloudflare Pages project (200 rewrite)

## Shared Design System

App repos consume shared styles at runtime via `<link>` tags (zero build-time dependency):

```html
<link rel="stylesheet" href="https://apps.fv.dev/shared/styles/reset.css">
<link rel="stylesheet" href="https://apps.fv.dev/shared/styles/variables.css">
<link rel="stylesheet" href="https://apps.fv.dev/shared/styles/base.css">
```

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
2. **Hero** -- Tagline: "Tools for Ecwid merchants", short description
3. **App Grid** -- Card per app with: icon, name, one-line description, "Learn more" link, pricing badge (Free/Freemium/Paid)
4. **Footer** -- copyright, link to fv.dev, contact email

App data is hardcoded in HTML. When adding a new app, manually add a card.

## Cloudflare Routing (`_redirects`)

Proxy rewrites (200 status = invisible to user):
```
/seo-redirect-manager/*  https://seo-redirect-manager-site.pages.dev/:splat  200
/next-app/*               https://next-app-site.pages.dev/:splat              200
```

Each app's Cloudflare Pages project must set `base: /{app-slug}/` so asset paths resolve correctly.

## CORS (`_headers`)

```
/shared/*
  Access-Control-Allow-Origin: *
  Cache-Control: public, max-age=86400
```

## Adding a New App

1. Create a new Cloudflare Pages project for the app repo
2. Add a proxy line in `_redirects` in this hub repo
3. Add an app card to `src/index.html`
4. Push both repos
