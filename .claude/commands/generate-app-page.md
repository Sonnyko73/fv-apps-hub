# Generate App Page

Generate (or regenerate) the landing page, manual page, and catalog card for an app from its docs.

## Standards

App landing pages share most quality signals with blog posts (where they overlap, the rules align with `/blog-publish`). Before generating HTML, every app must pass the **Pre-generation validation** checks below. Failures in the **Required** list block generation; **Warnings** are reported but do not block. Refusing to generate is preferable to emitting a half-broken page.

These rules are tuned for AI citation (ChatGPT, Perplexity, Google AI Overviews) and traditional SERP performance, adapted to the constraints of a landing page rather than long-form prose.

## Input

Optional argument: $ARGUMENTS

- **If a slug is provided** (e.g. `redirect-404-manager`), run the freshness check (below) for that app only.
- **If no argument is provided**, run the freshness check for every app. Scan all `docs/*-app-docs/` folders.

**Freshness check** — for each `docs/{app-slug}-app-docs/` folder:
  1. Derive the slug by stripping `-app-docs` from the folder name.
  2. Find the newest modification time among ALL source files: `docs/{app-slug}-app-docs/about.md`, `docs/{app-slug}-app-docs/README.md`, `docs/{app-slug}-app-docs/*.md` (chapter files). Also check the assets folder (discovered in step 5 below): `{assets-folder}/og.png`, `{assets-folder}/screenshots.md`, and any screenshot image files listed in `screenshots.md`. The newest mtime across all of these is `{source_mtime}`.
  3. Find the oldest modification time among the two generated HTML files: `src/{app-slug}/index.html` and `src/{app-slug}/docs/index.html`. If either file does not exist, the app is **new**. Otherwise the older of the two is `{dest_mtime}`.
  4. Classify the app:
     - **New:** either generated HTML file does not exist.
     - **Updated:** `{source_mtime}` is newer than `{dest_mtime}`.
     - **Up to date:** `{dest_mtime}` is newer than or equal to `{source_mtime}`.
  5. List what was found (new, updated, up to date) and proceed to generate all apps that need it. If everything is up to date, report that and stop.

## Source files

All content comes from `docs/{app-slug}-app-docs/` (a symlink to the app's manual folder in Google Drive):

- **`about.md`** — App name, description, problem statement, features, pricing, FAQ, links. This is the primary source for the landing page and catalog card.
- **`README.md`** — Manual table of contents with chapter list.
- **Chapter files** (`01-*.md`, `02-*.md`, etc.) — Full manual content.

Read ALL of these files before generating anything.

## Pre-generation validation

Run these checks against `about.md`, `README.md`, the chapter files, and the asset folder **before** generating any HTML. Required failures block generation for that app and the publisher continues with the next app (do not block the whole batch).

### Required (block generation on failure)

- [ ] **`about.md` exists and parses** — sections found: app name, one-line description, problem statement, features, plans/pricing, FAQ.
- [ ] **App name and description are present** — non-empty.
- [ ] **At least 7 distinct H2/H3 headings** would render in the landing page (Hero, Problem, Features, How It Works, Pricing, FAQ, plus per-feature/per-FAQ H3s). Counting H2+H3 from the planned output should give ≥ 7.
- [ ] **Exactly one H1 in the rendered landing page** — the Hero headline. No other element (including section headings) renders as `<h1>`.
- [ ] **OG image is 1200×630.** Inspect `{assets-folder}/og.png`. If wrong dimensions, fail with the actual dimensions reported.
- [ ] **All inline images and screenshots have non-empty, descriptive alt text.** Empty or placeholder alts ("screenshot 1", "image1", "icon") fail.
- [ ] **Slug is lowercase, hyphenated, no trailing punctuation, ≤60 chars.** Slugs are derived from the `docs/{app-slug}-app-docs/` folder name and are permanent — never change a slug once an app is published; if the app's positioning shifts, create a new app folder and 301 the old slug.
- [ ] **JSON-LD blocks (planned output) are valid JSON** and contain the required `SoftwareApplication`, `BreadcrumbList`, and (if FAQ exists) `FAQPage` types with all required fields populated.

### Warnings (report but do not block)

- **Total visible body copy < 500 words** across the landing page — reads as thin to AI engines.
- **Hero subheadline doesn't answer the headline in 2–4 sentences** — visitors and AI crawlers should know what the app does within the first paragraph.
- **`<title>` length outside 50–60 chars** after the `— FV Apps` suffix.
- **`<meta description>` (one-line description from about.md) outside 140–160 chars.**
- **Internal links in body copy < 2** — features/FAQ/manual sections should link to related blog posts, docs, or other site pages. Nav, footer, and primary CTA links don't count.
- **Missing list or missing table** — landing pages should have **both**. Pricing already renders as a table; features should be a list. Both present yields a measurable AI-citation lift for product pages.
- **Flesch-Kincaid grade outside 14–18** (only if `textstat` is installed; skip the warning entirely if not). Landing-page copy may legitimately run lower than blog prose. **Never auto-rewrite** — flag for the editor.
- **No screenshots** when `screenshots.md` is missing — landing pages with screenshots perform better.

### Validation report

Print a per-app compact report before generating:

```
[redirect-404-manager] PASS
  about.md sections: app name, description, problem, features, pricing, FAQ ✓
  planned h1: 1, h2+h3: 18
  og image: 1200×630 ✓
  images with alt: 12/12
  warnings: title 71 chars (>60); body copy 432 words (<500)

[some-app] FAIL — refusing to generate
  ✗ og image: 1080×1080 (expected 1200×630)
  ✗ images with alt: 8/12 (4 empty)
  ✓ everything else
```

Only proceed to "What to generate" for apps in PASS state.

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
  <title>{App Name} for {Platform} — FV Apps</title>
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
  <link rel="preload" as="image" href="/shared/assets/fv-logo.webp" type="image/webp" fetchpriority="high">
  <link rel="icon" href="/shared/assets/favicon.ico">
  <link rel="stylesheet" href="/shared/shared.css">
  <link rel="stylesheet" href="/{app-slug}/styles/landing.css">
  <!-- GA4 -->
  <script async src="https://www.googletagmanager.com/gtag/js?id=G-X5B0LXFJ37"></script>
  <script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'G-X5B0LXFJ37');
  </script>
  <!-- Schema: SoftwareApplication + BreadcrumbList + FAQPage (+ HowTo when applicable) -->
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
      "image": "https://apps.fv.dev/{app-slug}/assets/og.png",
      "datePublished": "{YYYY-MM-DD of original publish; preserve from prior generation if present, otherwise today}",
      "dateModified": "{YYYY-MM-DD; today only if the source files actually changed since last generation}",
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
          "name": "FV Apps",
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
    // + HowTo block (see below) IF the "How It Works" section has 3+ ordered steps
  ]
  </script>
</head>
```

**Notes on schema values:**
- Fill `SoftwareApplication.offers` from "Plans & Pricing" in `about.md`. If free-only, use a single Offer with price "0". If freemium, include both Free and Pro offers with accurate prices.
- Fill `FAQPage.mainEntity` with every Q&A from the "FAQ" section of `about.md`. Skip the `FAQPage` block entirely if fewer than 3 Q&A pairs are present (Google penalizes thin FAQ schema). **Never invent Q&A entries that aren't already in `about.md`.**
- If the app is paid-only (no free tier), remove the Free plan Offer entry.
- **`datePublished`** is set on first generation and preserved across regenerations. To find a prior value, parse the existing `src/{app-slug}/index.html` JSON-LD for the `datePublished` field. If not present (truly new app), use today's date.
- **`dateModified`** is set to today **only** when the source files (`about.md`, `README.md`, chapter files, screenshots, OG image) have actually changed since the last generation. On a no-op regeneration, preserve the prior `dateModified` value. **Never bump `dateModified` to manufacture freshness** — that's flagged as a dark pattern by ranking systems.

**Conditional schema: `HowTo`**

If the "How It Works" section in `about.md` has 3+ ordered steps and reads as a procedural walkthrough (not just feature highlights), append this block to the JSON-LD array:

```json
{
  "@context": "https://schema.org",
  "@type": "HowTo",
  "name": "How to use {App Name}",
  "step": [
    {
      "@type": "HowToStep",
      "name": "{Step heading}",
      "text": "{Step body, plain-text, HTML stripped}",
      "url": "https://apps.fv.dev/{app-slug}/#how-it-works"
    }
    // … one entry per step
  ]
}
```

If "How It Works" describes feature benefits rather than walking through real steps, do **not** emit `HowTo`. Use `HowTo` only when the section is genuinely procedural.

**Required sections (in order):**

1. **Header** — Use the shared header markup from `SHARED-STYLES.md`, but customize nav to include: Features (#features), Pricing (#pricing), Docs (link to `/{app-slug}/docs/`), and a CTA button linking to the platform install URL from `about.md`. The logo must use a `<picture>` element with WebP source and PNG fallback, with explicit dimensions to prevent CLS:
   ```html
   <picture><source srcset="/shared/assets/fv-logo.webp" type="image/webp"><img src="/shared/assets/fv-logo.png" alt="Forest Valley" class="fv-header-logo" width="616" height="341"></picture>
   ```

2. **Hero** — Headline (what the app does), subheadline (one paragraph expanding on it), primary CTA button ("Install Free on {Platform}" linking to install URL), secondary CTA ("View Documentation" linking to `/{app-slug}/docs/`).

3. **Problem** — From the "The Problem" section in `about.md`. Three pain points with short descriptions.

4. **Features** — From "What the App Does" in `about.md`. Feature cards in a grid. Each card has: feature name, short description, and a badge (Free or Pro). Use `<div class="fv-card">` for each.

5. **How It Works** — From "How It Works" in `about.md`. Three steps, horizontal layout.

6. **Pricing** — From "Plans & Pricing" in `about.md`. Two cards side by side (Free and Pro). Each with feature list and CTA button.

7. **FAQ** — From "FAQ" in `about.md`. Use CSS-only `<details><summary>` accordion. No JavaScript.

8. **Last Updated** — A centered line just before the footer showing the page's `dateModified` (the same value used in the SoftwareApplication JSON-LD and the sitemap `<lastmod>`):
   ```html
   <div class="fv-container last-updated">
     <p>Last updated: {Month D, YYYY}</p>
   </div>
   ```
   Render the date as `Month D, YYYY` (e.g. `April 28, 2026`) for human readers. This must match the JSON-LD `dateModified` and the sitemap `<lastmod>` byte-for-byte (after format conversion). On a no-op regeneration, preserve the prior date instead of bumping to today.

9. **Footer** — Use the shared footer markup from `SHARED-STYLES.md`, but add links to: All Apps (`/`), Blog (`/blog/`), Documentation (`/{app-slug}/docs/`), About (`/about/`), Terms of Service, Privacy Policy, Regional Data Protection, Support email (from about.md), fv.dev. Footer logo must also use `<picture>` with WebP: `<picture><source srcset="/shared/assets/fv-logo.webp" type="image/webp"><img src="/shared/assets/fv-logo.png" alt="Forest Valley" width="616" height="341"></picture>`.

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
  <title>{App Name} — User Manual — FV Apps</title>
  <meta name="description" content="User manual for {App Name}. {Short description}.">
  <!-- Canonical -->
  <link rel="canonical" href="https://apps.fv.dev/{app-slug}/docs/">
  <!-- Open Graph -->
  <meta property="og:type" content="website">
  <meta property="og:title" content="{App Name} — User Manual — FV Apps">
  <meta property="og:description" content="User manual for {App Name}. {Short description}.">
  <meta property="og:url" content="https://apps.fv.dev/{app-slug}/docs/">
  <meta property="og:image" content="https://apps.fv.dev/{app-slug}/assets/og.png">
  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="{App Name} — User Manual — FV Apps">
  <meta name="twitter:description" content="User manual for {App Name}. {Short description}.">
  <meta name="twitter:image" content="https://apps.fv.dev/{app-slug}/assets/og.png">
  <!-- LCP preload — must be first link tag -->
  <link rel="preload" as="image" href="/shared/assets/fv-logo.webp" type="image/webp" fetchpriority="high">
  <link rel="icon" href="/shared/assets/favicon.ico">
  <link rel="stylesheet" href="/shared/shared.css">
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
        "name": "FV Apps",
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

- Shared header (same as landing, but with "Back to {App Name}" link). Logo must use `<picture>` with WebP source and PNG fallback: `<picture><source srcset="/shared/assets/fv-logo.webp" type="image/webp"><img src="/shared/assets/fv-logo.png" alt="Forest Valley" class="fv-header-logo" width="616" height="341"></picture>`.
- Two-column layout:
  - **Left sidebar** (sticky): Table of contents from `README.md`. Each chapter is a section. Sub-headings (`##`) within chapters become nested nav items. Link to anchors.
  - **Right content area**: All chapter content rendered as HTML. Each chapter is a `<section>` with an `id` matching the sidebar links. Convert markdown content to semantic HTML: headings, paragraphs, lists, code blocks, tables, bold, italics, links. Add a "Last updated" line right after the intro paragraph:
    ```html
    <p class="last-updated">Last updated: {Month D, YYYY}</p>
    ```
    Use the docs page's own `dateModified` (matching its sitemap `<lastmod>`). Today only when the manual sources actually changed since last generation; otherwise preserve the prior date.
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

CSS for the manual layout: sidebar, content area, responsive behavior, code block styling, table styling. Use `--fv-*` tokens. Include a `.last-updated` rule:

```css
.last-updated { color: var(--fv-gray-500); font-size: var(--fv-fs-sm); margin-bottom: var(--fv-space-lg); }
```

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

/* Last Updated */
.last-updated { text-align: center; padding: var(--fv-space-lg) 0; }
.last-updated p { color: var(--fv-gray-500); font-size: var(--fv-fs-sm); margin: 0; }
```

---

### 8. Sitemap update: `src/sitemap.xml`

Add two new `<url>` entries for the app landing page and docs page. Insert before `</urlset>`. Do not add `<priority>` or `<changefreq>` — Google ignores these tags:

```xml
  <url>
    <loc>https://apps.fv.dev/{app-slug}/</loc>
    <lastmod>{landing-page dateModified}</lastmod>
  </url>
  <url>
    <loc>https://apps.fv.dev/{app-slug}/docs/</loc>
    <lastmod>{docs-page dateModified}</lastmod>
  </url>
```

The `<lastmod>` for each URL must match the `dateModified` in the corresponding page's JSON-LD schema (and the visible "Last Updated" line). On a no-op regeneration, preserve the prior `<lastmod>` rather than bumping to today.

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

- **No JavaScript.** Pure HTML + CSS only. Use `<details><summary>` for accordions, CSS `:target` or sticky positioning for navigation. (The GA4 snippet in `<head>` is the single allowed exception.)
- **Use shared styles.** Load the shared CSS in the correct order. Use `--fv-*` tokens and utility classes (`.fv-container`, `.fv-btn`, `.fv-card`, etc.). Only write app-specific CSS for things the shared system doesn't cover.
- **Semantic HTML.** Use proper heading hierarchy, `<section>`, `<nav>`, `<main>`, `<article>` where appropriate.
- **Accessible.** All images need `alt` text. All interactive elements need focus styles. Use sufficient color contrast. Inline images below the fold get `loading="lazy"`.
- **Clean formatting.** Well-indented HTML. CSS organized by section.
- **Refuse to generate** on any required validation failure. Report exactly what failed; skip that app and continue with others. Never silently emit a half-broken page.
- **Do not bump `dateModified`** when the source files haven't changed. Manufacturing freshness is treated as a dark pattern by ranking systems. Preserve `datePublished` from the prior generation.
- **`dateModified` consistency:** the value in the JSON-LD `SoftwareApplication`, the visible "Last Updated" line on the page, and the sitemap `<lastmod>` must all match.
- **Do not auto-rewrite copy** for FK readability — flag it for the editor.
- **Do not pad word count** with filler to clear the 500-word threshold.
- **Do not generate FAQ entries that aren't already in `about.md`** — including emitting `FAQPage` schema for absent Q&A. Same rule for `HowTo`: don't emit if the section isn't genuinely procedural.
- **Do not change a published slug.** If the app's positioning shifts after publish, that's a new app folder + a 301 from the old slug — not an in-place edit.
- **Do not emit JSON-LD for content that isn't on the page** (offers without prices, FAQ without Q&A, HowTo without steps, screenshots in schema that don't render). Google penalizes mismatched structured data.

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
5. **Request GSC indexing** for the two URLs:
   - GSC → URL Inspection → `https://apps.fv.dev/{app-slug}/` → Request indexing
   - GSC → URL Inspection → `https://apps.fv.dev/{app-slug}/docs/` → Request indexing
   - Use Playwright to automate via the GSC web UI

## Infrastructure notes

- **apps.fv.dev hosting:** Cloudflare Pages (project: `fv-apps-hub`, account: `ak@fv.dev`)
- **Security headers** are globally configured in `_headers` for `/*` — do not add them to individual HTML pages. Current headers: `Strict-Transport-Security` (preload), `X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin`, `Permissions-Policy`, and a CSP that allows: self, unsafe-inline styles, https images, GTM scripts, Google Analytics connects. If the new app page loads any external resource not covered by this CSP (e.g. a new CDN font, external iframe, third-party script), update `_headers` CSP accordingly — otherwise the resource will be blocked in production.
- **CSS inlining** is handled automatically by `scripts/build.js` at build time — always use `<link rel="stylesheet">` in source HTML. Never manually inline CSS in source files. The build replaces every local `<link rel="stylesheet">` with a `<style>` block, eliminating render-blocking requests in production.
- **fv.dev** is hosted on Tilda, DNS on Porkbun — unrelated to this repo
