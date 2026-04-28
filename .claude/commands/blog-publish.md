# Publish Blog Post

Generate (or regenerate) HTML article pages and update the blog listing from blog source markdown files.

## Standards

This command is the hard gate for blog quality. Before generating HTML, every post must pass the **Pre-publish validation** checks below — derived from research on AI citation patterns (ChatGPT, Perplexity, Google AI Overviews) and traditional SERP performance. Refuse to publish any post that fails a required check; report exactly what failed and skip the post (move on to the next one if publishing in batch).

`/blog-add-post` surfaces these as warnings at ingest time, but a post can still arrive here with failures (the user may have ignored the warnings or edited the file by hand). This is the last stop.

## Input

Optional argument: $ARGUMENTS

- **If a filename is provided** (e.g. `260404-how-to-migrate-ecwid-store-seo`), publish only that post. The `.md` extension is optional.
- **If no argument is provided**, auto-detect which posts need publishing. For each `blog/YYMMDD-slug.md`, a post needs publishing if ANY of these are true:
  - **New:** `src/blog/{slug}/index.html` does not exist.
  - **MD updated:** the `.md` source is newer than `src/blog/{slug}/index.html`.
  - **OG image updated:** `blog/YYMMDD-slug-og.*` exists and is newer than `src/blog/{slug}/og.png` (or `src/blog/{slug}/og.png` does not exist).
  - **Up to date:** none of the above conditions are true. Skip.
  - List what was found (new, updated, up to date) and proceed to publish all posts that need it. If everything is up to date, report that and stop.

Exclude `CLAUDE.md` and `INDEX.md` when scanning `blog/`.

## Source files

Each post file is at `blog/{filename}.md` with YAML frontmatter and a markdown body. See `blog/CLAUDE.md` for the full format specification.

**Required frontmatter fields:** `title`, `slug`, `date`, `tag`, `read_time`, `excerpt`
**Optional frontmatter fields:** `intro`, `cta`, `date_modified`, `og_image`

If any required field is missing, report the issue and skip that post.

## Pre-publish validation

Run these checks against each post **before** generating any HTML. If any **REQUIRED** check fails, refuse to publish that post — report the failure and continue with other posts (do not block the whole batch). **WARNING-only** items are reported but do not block publishing.

For each post:

### Required (block publish on failure)

- [ ] **Word count between 500 and 2,000.** Under 500 reads as thin content to AI engines. Over 2,000 should be split into a parent post + linked deep-dives. (`wc -w` on body, excluding frontmatter.)
- [ ] **Exactly one H1.** Must be present in the rendered article (the H1 is the frontmatter `title`; do not allow a `# Heading` in the body that becomes a second H1).
- [ ] **H2 + H3 count between 7 and 20.** 1–3 subheadings is the worst-performing range for AI citation. (`grep -cE '^##{1,2} ' body`.)
- [ ] **First paragraph after H1 answers the H1 in 2–4 sentences.** No background, no scene-setting, no "in this guide we'll cover." This paragraph is the rendered `intro`. 41% of AI citations come from the first third of the article — if the answer isn't in the opening, the post can't be cited.
- [ ] **At least one list or table** in the body.
- [ ] **At least 2 internal links in body copy** (markdown links with target starting with `https://apps.fv.dev/`). Blog post body links to other site pages must be written as full URLs in the markdown source — this is the one exception to the site's relative-link default and exists so the anchors survive AI-summary citations, syndication, and feed-reader contexts where the canonical page URL isn't carried with the snippet. Nav and footer links (which are template-level relative paths) don't count. Anchor text must use the target post's H1 phrasing or a close variant — never "click here" or "this article."
- [ ] **All inline images have non-empty, descriptive alt text.** "screenshot 1", "image1", "img" and similar placeholders fail.
- [ ] **All required frontmatter fields present:** `title`, `slug`, `date`, `tag`, `read_time`, `excerpt`.
- [ ] **`date_modified` is set.** If missing on first publish, default it to `date` and write back to the source file.
- [ ] **Slug is lowercase, hyphenated, ≤60 chars, no trailing punctuation.**
- [ ] **OG image is 1200×630.** Inspect the source file in `blog/`. If wrong dimensions, fail with the actual dimensions reported.
- [ ] **JSON-LD blocks are valid JSON** and contain the required `BlogPosting` (or `Article`) and `BreadcrumbList` types with all required fields populated. Conditional schemas (`FAQPage`, `HowTo`) must also validate when emitted.

### Warnings (report but do not block)

- **`<title>` length outside 50–60 chars** after the `— FV Apps` suffix is appended. Long titles get truncated in SERPs.
- **`excerpt` (used as `<meta name="description">`) outside 140–160 chars.** Should mirror the front-loaded answer.
- **Flesch-Kincaid grade outside 14–18** (only if `textstat` is installed; skip the warning entirely if not). Peak AI citation rate is at FK 16–17. **Never auto-rewrite** — this is a flag for the editor.
- **No comparison table** when the post mentions 2+ tools, plans, or approaches.
- **H2s look semantically duplicated** (similar wording) — flag the editor; humans judge this, not the script.

### Validation report

Before generating, print a per-post compact report:

```
[260428-shopify-to-eseries-migration] PASS
  word count: 1354
  h1: 1, h2+h3: 13
  internal links: 4, lists/tables: 5
  images: 0
  intro: 4 sentences, answers H1 ✓
  fk grade: 15.2 (textstat)
  warnings: title 75 chars (>60)

[some-other-post] FAIL — refusing to publish
  ✗ word count: 320 (<500)
  ✗ h2+h3: 4 (<7)
  ✗ internal links: 0 (<2)
  ✓ everything else
```

Only proceed to "What to generate" for posts in PASS state.

## What to generate

### 1. Article page: `src/blog/{slug}/index.html`

Generate the full HTML article page. Use the existing article at `src/blog/how-to-migrate-ecwid-store-seo/index.html` as the canonical template. Match its structure exactly.

**OG image resolution:**

Determine the OG image URL in this order:
1. If `og_image` is set in frontmatter, use that value (relative paths resolve from site root, e.g. `/blog/my-post/og.png`).
2. Check if `src/blog/{slug}/og.png` exists on disk. If yes, use `https://apps.fv.dev/blog/{slug}/og.png`.
3. Fallback: `https://apps.fv.dev/shared/assets/og.png`.

Store the resolved URL as `{og_image_url}` for use in OG and Twitter meta tags below.

**HTML `<head>` must include (in this order):**

```html
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{title} — FV Apps</title>
<meta name="description" content="{excerpt}">
<!-- Canonical -->
<link rel="canonical" href="https://apps.fv.dev/blog/{slug}/">
<!-- Open Graph -->
<meta property="og:type" content="article">
<meta property="og:site_name" content="FV Apps">
<meta property="og:title" content="{title}">
<meta property="og:description" content="{excerpt}">
<meta property="og:url" content="https://apps.fv.dev/blog/{slug}/">
<meta property="og:image" content="{og_image_url}">
<meta property="article:published_time" content="{date}">
<meta property="article:modified_time" content="{date_modified or date}">
<meta property="article:author" content="Forest Valley">
<meta property="article:section" content="{tag}">
<meta property="article:tag" content="{tag}">
<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="{title}">
<meta name="twitter:description" content="{excerpt}">
<meta name="twitter:image" content="{og_image_url}">
<!-- LCP preload -->
<link rel="preload" as="image" href="/shared/assets/fv-logo.webp" type="image/webp" fetchpriority="high">
<link rel="icon" href="/shared/assets/favicon.ico">
<!-- CSS (shared + blog) -->
<link rel="stylesheet" href="/shared/shared.css">
<link rel="stylesheet" href="/blog/styles.css">
<!-- GA4 -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-X5B0LXFJ37"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-X5B0LXFJ37');
</script>
<!-- Schema: BlogPosting + BreadcrumbList (+ FAQPage and/or HowTo when applicable) -->
<script type="application/ld+json">
[
  {
    "@context": "https://schema.org",
    "@type": "BlogPosting",
    "headline": "{title}",
    "description": "{excerpt}",
    "datePublished": "{date}",
    "dateModified": "{date_modified or date}",
    "url": "https://apps.fv.dev/blog/{slug}/",
    "wordCount": {word count of article body},
    "articleSection": "{tag}",
    "image": "{og_image_url}",
    "author": {
      "@type": "Organization",
      "name": "Forest Valley",
      "url": "https://fv.dev"
    },
    "publisher": {
      "@type": "Organization",
      "name": "FV Apps",
      "url": "https://apps.fv.dev/",
      "logo": {
        "@type": "ImageObject",
        "url": "https://apps.fv.dev/shared/assets/fv-logo.png",
        "width": 616,
        "height": 341
      }
    },
    "mainEntityOfPage": {
      "@type": "WebPage",
      "@id": "https://apps.fv.dev/blog/{slug}/"
    }
  },
  {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    "itemListElement": [
      { "@type": "ListItem", "position": 1, "name": "FV Apps", "item": "https://apps.fv.dev/" },
      { "@type": "ListItem", "position": 2, "name": "Blog", "item": "https://apps.fv.dev/blog/" },
      { "@type": "ListItem", "position": 3, "name": "{title}", "item": "https://apps.fv.dev/blog/{slug}/" }
    ]
  }
  // + FAQPage block (see below) IF the post contains a FAQ section with 3+ Q&A pairs
  // + HowTo block (see below) IF the post is a step-by-step guide
]
</script>
```

**Conditional schema: `FAQPage`**

Detect a FAQ section automatically: an `## H2` heading whose text is `FAQ`, `FAQs`, `Frequently asked questions`, or `Common questions` (case-insensitive), followed by 3+ `### H3` headings each with at least one paragraph as the answer. If detected, append this block to the JSON-LD array:

```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "<H3 question text>",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "<plain-text answer paragraph(s), HTML stripped>"
      }
    }
    // … one entry per Q&A pair
  ]
}
```

If fewer than 3 Q&A pairs are detected, do not emit `FAQPage` (Google penalizes thin FAQ schema). **Never invent Q&A entries that aren't already in the body.**

**Conditional schema: `HowTo`**

Detect a step-by-step structure: H2 or H3 headings matching `Step N`, `Step N:`, or numbered (`1.`, `2.`, …) where the body explicitly walks through sequential steps. If detected, append:

```json
{
  "@context": "https://schema.org",
  "@type": "HowTo",
  "name": "<post H1>",
  "step": [
    {
      "@type": "HowToStep",
      "name": "<step heading>",
      "text": "<plain-text step body>",
      "url": "https://apps.fv.dev/blog/{slug}/#<step-anchor>"
    }
    // … one entry per step
  ]
}
```

Use `HowTo` only when the post is genuinely a procedural guide. A post that *mentions* steps but isn't structured as a how-to should not get this schema.

**Body sections (in order):**

1. **Header** — shared header. Nav links: `Blog` → `/blog/`, `fv.dev` → `https://fv.dev`. **Link convention:** template-level anchors (header, footer, cards, "Back to Blog", CTA buttons) use **relative** paths (`/blog/`, `/redirect-404-manager/`, etc.). The single exception is **links inside the rendered article body**: those come from the markdown source where authors write full URLs (`https://apps.fv.dev/...`) so the anchors survive syndication, AI-summary citations, and feed-reader contexts where the original page URL isn't carried along. Asset `<link rel="stylesheet|icon|preload">` tags always stay relative. Logo must use `<picture>` with WebP source and PNG fallback: `<picture><source srcset="/shared/assets/fv-logo.webp" type="image/webp"><img src="/shared/assets/fv-logo.png" alt="Forest Valley" class="fv-header-logo" width="616" height="341"></picture>`.

2. **Article hero** — back link, meta (tag + formatted date + read time), h1, intro paragraph.
   ```html
   <section class="article-hero">
     <div class="fv-container">
       <div class="article-back"><a href="/blog/">&larr; Back to Blog</a></div>
       <div class="article-meta">
         <span class="blog-tag">{tag}</span>
         <span class="blog-date">{date formatted as "Month D, YYYY"}</span>
         <span class="blog-read-time">{read_time}</span>
       </div>
       <h1>{title}</h1>
       <p class="article-intro">{intro or first sentence of excerpt}</p>
     </div>
   </section>
   ```

3. **Article body** — converted markdown wrapped in `<article>` and `<div class="article-content">`:
   ```html
   <article class="article-body">
     <div class="fv-container">
       <div class="article-content">
         <!-- converted markdown here -->
       </div>
     </div>
   </article>
   ```

4. **CTA section** (only if `cta` is in frontmatter):
   ```html
   <section class="article-cta">
     <div class="fv-container">
       <div class="article-cta-box">
         <h2>{cta.heading}</h2>
         <p>{cta.text}</p>
         <div class="article-cta-actions">
           <a href="{cta.primary_url}" class="fv-btn fv-btn-primary">{cta.primary_label}</a>
           <a href="{cta.secondary_url}" class="fv-btn fv-btn-outline">{cta.secondary_label}</a>
         </div>
       </div>
     </div>
   </section>
   ```

5. **Footer** — shared footer. Links: All Apps, Blog, About, Terms of Service, Privacy Policy, Regional Data Protection, info@fv.dev, fv.dev. Footer logo must use `<picture>` with WebP: `<picture><source srcset="/shared/assets/fv-logo.webp" type="image/webp"><img src="/shared/assets/fv-logo.png" alt="Forest Valley" width="616" height="341"></picture>`.

**Content rendering rules (markdown → HTML):**

- `## Heading` → `<h2>`
- `### Subheading` → `<h3>`
- Paragraphs → `<p>`
- `**bold**` → `<strong>`, `*italic*` → `<em>`
- `` `code` `` → `<code>`
- Code blocks → `<pre><code class="language-{lang}">…</code></pre>` with the fenced-block language tag
- Links → `<a>` (keep external links as-is)
- Ordered/unordered lists → `<ol>/<ul>` with `<li>`
- Tables → `<table>` with `<thead>` and `<tbody>`
- Blockquotes with bold lead word (`> **Tip:** ...`) → `<div class="article-callout"><p><strong>Tip:</strong> ...</p></div>`
- Plain blockquotes → `<div class="article-callout"><p>...</p></div>`
- `&` in text → `&amp;` (HTML entity encoding)
- Inline images `![alt](url)` → `<img src="url" alt="alt" loading="lazy">`. **Alt text is required and must describe what the image shows** — fail validation if any image has empty or placeholder alt ("screenshot 1", "image1", "img"). All images below the article hero get `loading="lazy"`. The OG/hero image (1200×630) is the only image rendered eagerly; it lives in the `<head>` `og:image` and is not embedded inline above the fold.

### 2. Copy OG image to `src/blog/{slug}/og.png`

The OG image source of truth is in `blog/` alongside the post file: `blog/YYMMDD-slug-og.*` (any image extension).

**Check and copy:**

1. Look for `blog/YYMMDD-slug-og.*` (matching the post's YYMMDD-slug prefix with `-og` suffix).
2. **If found:** compare modification times against `src/blog/{slug}/og.png`.
   - If source is newer (or dest doesn't exist): copy to `src/blog/{slug}/og.png`. Report "OG image updated."
   - If dest is already up to date: skip. Report "OG image is current."
3. **If not found:** check if `og_image` is set in frontmatter.
   - If `og_image` points to a specific path, warn that the source image is missing from `blog/`.
   - If `og_image` is not set, the fallback (`/shared/assets/og.png`) is used. No action needed.

### 3. Update blog listing: `src/blog/index.html`

Read `blog/INDEX.md` and rebuild the blog card grid in `src/blog/index.html`. Keep the full page structure (head, header, hero, footer) intact — only regenerate the cards inside `<div class="blog-grid">`.

**Card markup for each INDEX.md entry:**

```html
<a href="/blog/{slug}/" class="fv-card blog-card">
  <div class="blog-card-meta">
    <span class="blog-tag">{tag}</span>
    <span class="blog-date">{date formatted as "Month D, YYYY"}</span>
  </div>
  <h2>{title}</h2>
  <p class="blog-card-excerpt">{excerpt}</p>
  <div class="blog-card-footer">
    <span class="blog-read-time">{read_time}</span>
    <span class="blog-read-link">Read &rarr;</span>
  </div>
</a>
```

Cards are ordered newest first (same order as INDEX.md). Add an HTML comment above each card with the slug for easy identification.

### 4. Update homepage latest posts: `src/index.html`

Replace the content between `<!-- LATEST-POSTS-START -->` and `<!-- LATEST-POSTS-END -->` in `src/index.html` with cards for the **3 most recent** posts from `blog/INDEX.md` (or fewer if there aren't 3 yet).

**Card markup (same structure as blog listing, but with `<h3>` instead of `<h2>`):**

```html
<a href="/blog/{slug}/" class="fv-card blog-card">
  <div class="blog-card-meta">
    <span class="blog-tag">{tag}</span>
    <span class="blog-date">{date formatted as "Month D, YYYY"}</span>
  </div>
  <h3>{title}</h3>
  <p class="blog-card-excerpt">{excerpt}</p>
  <div class="blog-card-footer">
    <span class="blog-read-time">{read_time}</span>
    <span class="blog-read-link">Read &rarr;</span>
  </div>
</a>
```

Add an HTML comment above each card with the slug for easy identification. The markers `<!-- LATEST-POSTS-START -->` and `<!-- LATEST-POSTS-END -->` must be preserved around the cards.

### 5. Update `blog/INDEX.md`

If the post's slug is not already in the index, add it at the top (below the header/comment line). If it exists (matching slug), update the metadata on that line.

Format: `YYMMDD | slug | title | tag | read-time | excerpt`

### 6. Update `src/sitemap.xml`

Add a `<url>` entry for the article. Insert before `</urlset>`:

```xml
  <url>
    <loc>https://apps.fv.dev/blog/{slug}/</loc>
    <lastmod>{date_modified or date}</lastmod>
    <changefreq>yearly</changefreq>
    <priority>0.6</priority>
  </url>
```

`<lastmod>` must match the post's `date_modified` exactly (or `date` if `date_modified` is unset). If an entry for this slug already exists, update its `<lastmod>` rather than duplicating.

### 7. Update `src/llms.txt`

Add a blog entry. Insert before the `## Homepage` section:

```
## Blog: {title}
https://apps.fv.dev/blog/{slug}/
{excerpt}
```

If an entry for this slug already exists, update it.

## Important rules

- **No JavaScript in generated pages** — pure HTML + CSS only (the GA4 snippet in `<head>` is the single allowed exception, and it lives outside the article body)
- **Never overwrite `src/blog/styles.css`** — it's manually maintained
- **Use shared styles** — load CSS in the correct order, use `--fv-*` tokens and utility classes (`.fv-container`, `.fv-btn`, `.fv-card`, etc.)
- **Semantic HTML** — use `<article>` for the article body, `<section>` for distinct page sections, `<nav>` for navigation, proper heading hierarchy (h1 in hero, h2/h3 in body)
- **Accessible** — all images need `alt` text, all `<img>` tags need explicit `width` and `height` to prevent CLS, interactive elements need focus styles
- **Match the existing article template exactly** — use `src/blog/how-to-migrate-ecwid-store-seo/index.html` as the reference
- **Date formatting:** frontmatter `date: 2026-04-04` renders as `April 4, 2026` in visible HTML and `2026-04-04` in schema/OG meta
- **YYMMDD in INDEX.md** is derived from the date field: `2026-04-04` → `260404`
- **Refuse to publish on any required validation failure.** Report exactly what failed; skip that post and continue with others. Never silently emit a half-broken page.
- **Do not bump `dateModified`** without a real content change. Bumping a date to manufacture freshness is treated as a dark pattern by ranking systems.
- **Do not auto-rewrite content** for FK readability — flag it for the editor.
- **Do not emit JSON-LD for content that isn't on the page** (e.g., review schema with no real reviews, FAQ schema with no FAQ section, HowTo schema for a non-procedural post). Google penalizes mismatched structured data.
- **Do not change a published slug** when republishing. If the topic has shifted, that's a new post + a 301 from the old slug — not an in-place edit.
- **`dateModified` consistency:** the value in the JSON-LD `BlogPosting`, the OG `article:modified_time`, and the sitemap `<lastmod>` must all match.

## After generating

1. List all files created or modified
2. Run `npm --prefix "{project-root}" run build` to verify the build succeeds
3. Report what was generated and any warnings
4. **Commit and push:**
   - Stage all generated/modified files with `git add` (article HTML, OG images, blog listing, homepage, sitemap, llms.txt, INDEX.md)
   - Commit with a descriptive message (e.g. `blog: publish how-to-migrate-to-ecwid-seo`)
   - Push to `main` — this triggers GitHub Actions → Cloudflare Pages deployment
   - Report the commit hash and confirm the push succeeded
5. **Request GSC indexing** for each new article URL:
   - GSC → URL Inspection → `https://apps.fv.dev/blog/{slug}/` → Request indexing
   - Use Playwright to automate via the GSC web UI

## Infrastructure notes

- **apps.fv.dev hosting:** Cloudflare Pages (project: `fv-apps-hub`, account: `ak@fv.dev`)
- **Security headers** (HSTS, CSP, X-Frame-Options, etc.) are globally configured in `_headers` — do not add them to individual HTML pages and do not modify `_headers` when generating blog pages
- **Blog CSS** (`src/blog/styles.css`) covers both listing and article page styles — do not create separate CSS files per article
- **fv.dev** is hosted on Tilda, DNS on Porkbun — unrelated to this repo
