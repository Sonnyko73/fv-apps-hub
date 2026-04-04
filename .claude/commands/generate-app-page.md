# Generate App Page

Generate (or regenerate) the landing page, manual page, and catalog card for an app from its docs.

## Input

The app slug is provided as: $ARGUMENTS

- If a slug is provided (e.g. `seo-redirect-manager`), generate for that app.
- If no slug is provided, list all available apps by scanning `docs/*-app-docs/` folders (symlinks, named `{app-slug}-app-docs`) and ask which one to generate.

## Source files

All content comes from `docs/{app-slug}-app-docs/` (a symlink to the app's manual folder in Google Drive):

- **`about.md`** — App name, description, problem statement, features, pricing, FAQ, links. This is the primary source for the landing page and catalog card.
- **`README.md`** — Manual table of contents with chapter list.
- **Chapter files** (`01-*.md`, `02-*.md`, etc.) — Full manual content.

Read ALL of these files before generating anything.

## What to generate

### 1. Landing page: `src/{app-slug}/index.html`

A single-page site built from `about.md`. Follow the structure in `SITE_SPEC.md`.

**HTML structure:**

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{App Name} for {Platform} — Forest Valley Apps</title>
  <meta name="description" content="{One-line description from about.md}">
  <!-- Canonical -->
  <link rel="canonical" href="https://apps.fv.dev/{app-slug}/">
  <!-- Open Graph -->
  <meta property="og:type" content="website">
  <meta property="og:title" content="{Same as title}">
  <meta property="og:description" content="{Same as description}">
  <meta property="og:url" content="https://apps.fv.dev/{app-slug}/">
  <meta property="og:image" content="https://apps.fv.dev/{app-slug}/assets/og.png">
  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="{Same as title}">
  <meta name="twitter:description" content="{Same as description}">
  <meta name="twitter:image" content="https://apps.fv.dev/{app-slug}/assets/og.png">
  <!-- LCP preload — must be first link tag -->
  <link rel="preload" as="image" href="/shared/assets/fv-logo.png" fetchpriority="high">
  <link rel="icon" href="/shared/assets/favicon.ico">
  <link rel="stylesheet" href="/shared/styles/reset.css">
  <link rel="stylesheet" href="/shared/styles/variables.css">
  <link rel="stylesheet" href="/shared/styles/base.css">
  <link rel="stylesheet" href="/shared/components/header.css">
  <link rel="stylesheet" href="/shared/components/footer.css">
  <link rel="stylesheet" href="/{app-slug}/styles/landing.css">
  <!-- GA4 -->
  <script async src="https://www.googletagmanager.com/gtag/js?id=G-X5B0LXFJ37"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'G-X5B0LXFJ37');
  </script>
  <!-- Schema: SoftwareApplication + BreadcrumbList + FAQPage -->
  <script type="application/ld+json">
  [
    {
      "@context": "https://schema.org",
      "@type": "SoftwareApplication",
      "name": "{App Name}",
      "description": "{One-line description from about.md}",
      "applicationCategory": "BusinessApplication",
      "operatingSystem": "Web",
      "url": "https://apps.fv.dev/{app-slug}/",
      "offers": [
        {
          "@type": "Offer",
          "price": "0",
          "priceCurrency": "USD",
          "name": "Free Plan"
        },
        {
          "@type": "Offer",
          "price": "{Pro plan monthly price from about.md, e.g. 9.99}",
          "priceCurrency": "USD",
          "name": "Pro Plan"
        }
      ],
      "publisher": {
        "@type": "Organization",
        "name": "Forest Valley",
        "url": "https://fv.dev"
      }
    },
    {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      "itemListElement": [
        {
          "@type": "ListItem",
          "position": 1,
          "name": "Forest Valley Apps",
          "item": "https://apps.fv.dev/"
        },
        {
          "@type": "ListItem",
          "position": 2,
          "name": "{App Name}",
          "item": "https://apps.fv.dev/{app-slug}/"
        }
      ]
    },
    {
      "@context": "https://schema.org",
      "@type": "FAQPage",
      "mainEntity": [
        {
          "@type": "Question",
          "name": "{FAQ question from about.md}",
          "acceptedAnswer": {
            "@type": "Answer",
            "text": "{FAQ answer from about.md}"
          }
        }
        // ... one entry per FAQ item in about.md
      ]
    }
  ]
  </script>
</head>
```

**Notes on schema values:**
- Fill `SoftwareApplication.offers` from "Plans & Pricing" in `about.md`. If free-only, use a single Offer with price "0". If freemium, include both Free and Pro offers with accurate prices.
- Fill `FAQPage.mainEntity` with every Q&A from the "FAQ" section of `about.md`.
- If the app is paid-only (no free tier), remove the Free plan Offer entry.

**Required sections (in order):**

1. **Header** — Use the shared header markup from `SHARED-STYLES.md`, but customize nav to include: Features (#features), Pricing (#pricing), Docs (link to `/{app-slug}/docs/`), and a CTA button linking to the platform install URL from `about.md`. The logo `<img>` must include explicit dimensions to prevent CLS:
   ```html
   <img src="/shared/assets/fv-logo.png" alt="Forest Valley" class="fv-header-logo" width="616" height="341">
   ```

2. **Hero** — Headline (what the app does), subheadline (one paragraph expanding on it), primary CTA button ("Install Free on {Platform}" linking to install URL), secondary CTA ("View Documentation" linking to `/{app-slug}/docs/`).

3. **Problem** — From the "The Problem" section in `about.md`. Three pain points with short descriptions.

4. **Features** — From "What the App Does" in `about.md`. Feature cards in a grid. Each card has: feature name, short description, and a badge (Free or Pro). Use `<div class="fv-card">` for each.

5. **How It Works** — From "How It Works" in `about.md`. Three steps, horizontal layout.

6. **Pricing** — From "Plans & Pricing" in `about.md`. Two cards side by side (Free and Pro). Each with feature list and CTA button.

7. **FAQ** — From "FAQ" in `about.md`. Use CSS-only `<details><summary>` accordion. No JavaScript.

8. **Footer** — Use the shared footer markup from `SHARED-STYLES.md`, but add links to: All Apps (`/`), Blog (`/blog/`), Documentation (`/{app-slug}/docs/`), About (`/about/`), Terms of Service, Privacy Policy, Regional Data Protection, Support email (from about.md), fv.dev.

### 2. Landing page styles: `src/{app-slug}/styles/landing.css`

App-specific CSS for the landing page. Use `--fv-*` design tokens from the shared system. Only define styles for sections not covered by shared styles. Keep it clean and minimal.

### 3. Manual page: `src/{app-slug}/docs/index.html`

A single-page user manual with sidebar navigation, built from chapter files.

**HTML structure:**

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{App Name} — User Manual — Forest Valley Apps</title>
  <meta name="description" content="User manual for {App Name}. {Short description}.">
  <!-- Canonical -->
  <link rel="canonical" href="https://apps.fv.dev/{app-slug}/docs/">
  <!-- Open Graph -->
  <meta property="og:type" content="website">
  <meta property="og:title" content="{App Name} — User Manual — Forest Valley Apps">
  <meta property="og:description" content="User manual for {App Name}. {Short description}.">
  <meta property="og:url" content="https://apps.fv.dev/{app-slug}/docs/">
  <meta property="og:image" content="https://apps.fv.dev/{app-slug}/assets/og.png">
  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="{App Name} — User Manual — Forest Valley Apps">
  <meta name="twitter:description" content="User manual for {App Name}. {Short description}.">
  <meta name="twitter:image" content="https://apps.fv.dev/{app-slug}/assets/og.png">
  <!-- LCP preload — must be first link tag -->
  <link rel="preload" as="image" href="/shared/assets/fv-logo.png" fetchpriority="high">
  <link rel="icon" href="/shared/assets/favicon.ico">
  <link rel="stylesheet" href="/shared/styles/reset.css">
  <link rel="stylesheet" href="/shared/styles/variables.css">
  <link rel="stylesheet" href="/shared/styles/base.css">
  <link rel="stylesheet" href="/shared/components/header.css">
  <link rel="stylesheet" href="/shared/components/footer.css">
  <link rel="stylesheet" href="/{app-slug}/styles/docs.css">
  <!-- GA4 -->
  <script async src="https://www.googletagmanager.com/gtag/js?id=G-X5B0LXFJ37"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'G-X5B0LXFJ37');
  </script>
  <!-- Schema: BreadcrumbList -->
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    "itemListElement": [
      {
        "@type": "ListItem",
        "position": 1,
        "name": "Forest Valley Apps",
        "item": "https://apps.fv.dev/"
      },
      {
        "@type": "ListItem",
        "position": 2,
        "name": "{App Name}",
        "item": "https://apps.fv.dev/{app-slug}/"
      },
      {
        "@type": "ListItem",
        "position": 3,
        "name": "User Manual",
        "item": "https://apps.fv.dev/{app-slug}/docs/"
      }
    ]
  }
  </script>
</head>
```

**Layout:**

- Shared header (same as landing, but with "Back to {App Name}" link). Logo `<img>` must include explicit dimensions: `width="616" height="341"`.
- Two-column layout:
  - **Left sidebar** (sticky): Table of contents from `README.md`. Each chapter is a section. Sub-headings (`##`) within chapters become nested nav items. Link to anchors.
  - **Right content area**: All chapter content rendered as HTML. Each chapter is a `<section>` with an `id` matching the sidebar links. Convert markdown content to semantic HTML: headings, paragraphs, lists, code blocks, tables, bold, italics, links.
- Shared footer
- On mobile (below 768px): sidebar collapses above content or becomes a top nav

**Content rendering rules:**
- `# Heading` → `<h2>` (since `<h1>` is the page title)
- `## Subheading` → `<h3>`
- `### Sub-subheading` → `<h4>`
- `` `code` `` → `<code>`
- Code blocks → `<pre><code>`
- Tables → `<table>` with proper `<thead>` and `<tbody>`
- Bold → `<strong>`, Italic → `<em>`
- Links → `<a>` (keep external links as-is)
- Lists → `<ul>/<ol>` with `<li>`
- Horizontal rules (`---`) → `<hr>`
- **Skip** the developer-only chapters (like "Developer Guide" and "API Reference") — only include merchant-facing chapters

### 4. Manual page styles: `src/{app-slug}/styles/docs.css`

CSS for the manual layout: sidebar, content area, responsive behavior, code block styling, table styling. Use `--fv-*` tokens.

### 5. Discover app assets folder in Shared-assets

The `Shared-assets/apps-assets/` directory contains one folder per app, but the folder name does not always match the app slug (e.g. `seo-redirect-logo` for `redirect-404-manager`). Discover the correct folder by scanning for a `screenshots.md` file whose first line is `# screenshots: {app-slug}`:

```bash
grep -rl "# screenshots: {app-slug}" Shared-assets/apps-assets/
```

- **If found** — the folder containing that file is `{assets-folder}` (e.g. `Shared-assets/apps-assets/seo-redirect-logo/`).
- **If not found** — fall back to `Shared-assets/apps-assets/{app-slug}-logo/`. If that also doesn't exist, warn the user that the Shared-assets folder could not be located.

Store this path as `{assets-folder}` for use in all steps below.

### 6. OG image: `src/{app-slug}/assets/og.png`

The OG image source of truth is `{assets-folder}/og.png`.

Check both existence and freshness:

```bash
# Check if source exists
ls "{assets-folder}/og.png"

# Compare modification times (source newer than dest = needs update)
# Source newer if dest doesn't exist OR source mtime > dest mtime
```

- **If source exists and is newer than `src/{app-slug}/assets/og.png`** (or dest doesn't exist) — copy it:
  ```bash
  mkdir -p src/{app-slug}/assets/
  cp "{assets-folder}/og.png" src/{app-slug}/assets/og.png
  echo "OG image updated from source of truth."
  ```
- **If source exists and dest is already up to date** — skip copy, note "OG image is current."
- **If source does not exist** — warn the user. The `og:image` meta tag will return 404 until the image is created at `{assets-folder}/og.png` (1200×630px).

Also check the main site OG freshness:

```bash
# Source: Shared-assets/assets/og.png → Dest: Shared-assets-git/assets/og.png
```

If source is newer than dest (or dest missing): run `bash scripts/sync-assets.sh` to sync it. If source is missing, warn the user.

### 7. Screenshots: `src/{app-slug}/assets/screenshot-*.png`

Screenshots source of truth: `{assets-folder}/screenshots.md` + the image files alongside it.

**Parse `screenshots.md`:**

```
# screenshots: {app-slug}

1. filename.png | Section Title | Caption text
2. filename.png | Section Title | Caption text
...
```

Ignore comment/instruction lines (those that don't start with a digit). Each numbered entry is: `N. filename | Title | Caption`.

**Copy each screenshot** from `{assets-folder}/{filename}` to `src/{app-slug}/assets/{filename}`:

```bash
mkdir -p src/{app-slug}/assets/
# For each file listed in screenshots.md:
cp "{assets-folder}/{filename}" src/{app-slug}/assets/{filename}
```

Only copy files that are missing or where the source is newer than the dest. Report what was copied vs. skipped.

If `screenshots.md` does not exist in `{assets-folder}`, skip the screenshots section entirely and note "No screenshots.md found — screenshots section omitted."

**Add a Screenshots section to the landing page** — insert it between "How It Works" and "Pricing":

```html
<!-- Screenshots -->
<section class="screenshots">
  <div class="fv-container">
    <h2>See It in Action</h2>
    <div class="screenshots-list">
      <!-- Repeat for each entry in screenshots.md, in order (N = 01, 02, 03...): -->
      <figure class="screenshot-item">
        <figcaption>
          <span class="screenshot-num">0N</span>
          <div class="screenshot-text">
            <strong>{Title}</strong>
            <span>{Caption}</span>
          </div>
        </figcaption>
        <img src="/{app-slug}/assets/{filename}" alt="{Title}" width="1200" height="750" loading="lazy">
      </figure>
    </div>
  </div>
</section>
```

Note: figcaption goes **above** the image inside each `<figure>`. The number badge (`screenshot-num`) is zero-padded (01, 02, 03...).

Add corresponding CSS to `src/{app-slug}/styles/landing.css`:

```css
/* Screenshots */
.screenshots { padding: var(--fv-space-3xl) 0; background: var(--fv-gray-50); }
.screenshots h2 { text-align: center; margin-bottom: var(--fv-space-2xl); }
.screenshots-list { display: flex; flex-direction: column; gap: var(--fv-space-2xl); }
.screenshot-item { margin: 0; background: var(--fv-white); border-radius: var(--fv-radius-lg); box-shadow: var(--fv-shadow); overflow: hidden; }
.screenshot-item figcaption { display: flex; align-items: flex-start; gap: var(--fv-space-md); padding: var(--fv-space-md) var(--fv-space-lg); border-bottom: 1px solid var(--fv-gray-50); }
.screenshot-num { font-size: var(--fv-fs-xs); font-weight: 700; color: var(--fv-green); background: #e8f8ef; border-radius: var(--fv-radius-sm); padding: 2px 8px; letter-spacing: 0.05em; flex-shrink: 0; margin-top: 2px; }
.screenshot-text { display: flex; flex-direction: column; gap: 2px; }
.screenshot-text strong { font-size: var(--fv-fs-base); color: var(--fv-navy); }
.screenshot-text span { font-size: var(--fv-fs-sm); color: var(--fv-gray-800); line-height: 1.5; }
.screenshot-item img { width: 100%; height: auto; display: block; }
```

---

### 8. Sitemap update: `src/sitemap.xml`

Add two new `<url>` entries for the app landing page and docs page. Insert before `</urlset>`:

```xml
  <url>
    <loc>https://apps.fv.dev/{app-slug}/</loc>
    <changefreq>monthly</changefreq>
    <priority>0.9</priority>
  </url>
  <url>
    <loc>https://apps.fv.dev/{app-slug}/docs/</loc>
    <changefreq>monthly</changefreq>
    <priority>0.7</priority>
  </url>
```

If entries for this app already exist, update them (don't duplicate).

### 9. llms.txt update: `src/llms.txt`

Add a new section for the app. Insert before the `## Homepage` section:

```
## {App Name}
https://apps.fv.dev/{app-slug}/
{One-sentence description of what the app does and for which platform.}

## {App Name} Documentation
https://apps.fv.dev/{app-slug}/docs/
{One-sentence description of what the docs cover.}
```

If entries for this app already exist, update them (don't duplicate).

### 10. Catalog card update: `src/index.html`

Read the current `src/index.html`. Look at the `<!-- App Grid -->` section.

- If a card for this app already exists (search for the app slug in href), **update it** with current info from `about.md`.
- If no card exists, **add a new card** inside the `.app-grid` div.

**Card markup pattern** (match the existing style exactly):

```html
<div class="fv-card app-card">
  <div class="app-card-header">
    <div class="app-card-icon">
      <img src="/shared/assets/{app-slug}-app-logo.png" alt="{App Name}" width="40" height="40">
    </div>
    <span class="app-card-badge badge-free">{Pricing badge: Free/Freemium/Paid}</span>
  </div>
  <h3 class="app-card-name">{App Name}</h3>
  <p class="app-card-desc">{One-line description}</p>
  <div class="app-card-platforms">
    <span class="platform-badge">{Platform}</span>
  </div>
  <div class="app-card-actions">
    <a href="/{app-slug}/" class="fv-btn fv-btn-outline app-card-btn">View details</a>
    <a href="{install-url}" class="fv-btn fv-btn-outline app-card-btn">Install on {Platform}</a>
  </div>
</div>
```

Pricing badge: Use "Free" if the app has a free tier, "Freemium" if it has both free and paid tiers, "Paid" if it's paid-only. Use the appropriate badge class: `badge-free`, `badge-freemium`, or `badge-paid`.

## Important rules

- **No JavaScript.** Pure HTML + CSS only. Use `<details><summary>` for accordions, CSS `:target` or sticky positioning for navigation.
- **Use shared styles.** Load the shared CSS in the correct order. Use `--fv-*` tokens and utility classes (`.fv-container`, `.fv-btn`, `.fv-card`, etc.). Only write app-specific CSS for things the shared system doesn't cover.
- **Semantic HTML.** Use proper heading hierarchy, `<section>`, `<nav>`, `<main>`, `<article>` where appropriate.
- **Accessible.** All images need `alt` text. All interactive elements need focus styles. Use sufficient color contrast.
- **Clean formatting.** Well-indented HTML. CSS organized by section.

## After generating

1. List all files that were created or modified
2. Run `npm run build` to verify the build succeeds
3. If the build succeeds, deploy:
   - Stage all generated/modified files with `git add`, including:
     `src/{app-slug}/index.html`, `src/{app-slug}/styles/landing.css`,
     `src/{app-slug}/docs/index.html`, `src/{app-slug}/styles/docs.css`,
     `src/index.html`, `src/sitemap.xml`, `src/llms.txt`
   - Commit with a message like `feat: add {App Name} app page`
   - Push to `main` — this triggers GitHub Actions → Cloudflare Pages deployment
4. Report the commit hash and confirm the push succeeded
5. **Request GSC indexing** for the two new URLs (use Playwright or instruct the user):
   - GSC → URL Inspection → `https://apps.fv.dev/{app-slug}/` → Request indexing
   - GSC → URL Inspection → `https://apps.fv.dev/{app-slug}/docs/` → Request indexing

## Infrastructure notes

- **apps.fv.dev hosting:** Cloudflare Pages (project: `fv-apps-hub`, account: `ak@fv.dev`)
- **Security headers** (HSTS, CSP, X-Frame-Options, etc.) are globally configured in `_headers` — do not add them to individual HTML pages and do not modify `_headers` when generating app pages
- **fv.dev** is hosted on Tilda, DNS on Porkbun — unrelated to this repo
