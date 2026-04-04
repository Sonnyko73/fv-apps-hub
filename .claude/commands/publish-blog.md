# Publish Blog Post

Generate (or regenerate) HTML article pages and update the blog listing from blog source markdown files.

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
<title>{title} — Forest Valley Apps</title>
<meta name="description" content="{excerpt}">
<!-- Canonical -->
<link rel="canonical" href="https://apps.fv.dev/blog/{slug}/">
<!-- Open Graph -->
<meta property="og:type" content="article">
<meta property="og:site_name" content="Forest Valley Apps">
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
<link rel="preload" as="image" href="/shared/assets/fv-logo.png" fetchpriority="high">
<link rel="icon" href="/shared/assets/favicon.ico">
<!-- CSS (shared + blog) -->
<link rel="stylesheet" href="/shared/styles/reset.css">
<link rel="stylesheet" href="/shared/styles/variables.css">
<link rel="stylesheet" href="/shared/styles/base.css">
<link rel="stylesheet" href="/shared/components/header.css">
<link rel="stylesheet" href="/shared/components/footer.css">
<link rel="stylesheet" href="/blog/styles.css">
<!-- GA4 -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-X5B0LXFJ37"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-X5B0LXFJ37');
</script>
<!-- Schema: BlogPosting + BreadcrumbList -->
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
      "name": "Forest Valley Apps",
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
      { "@type": "ListItem", "position": 1, "name": "Forest Valley Apps", "item": "https://apps.fv.dev/" },
      { "@type": "ListItem", "position": 2, "name": "Blog", "item": "https://apps.fv.dev/blog/" },
      { "@type": "ListItem", "position": 3, "name": "{title}", "item": "https://apps.fv.dev/blog/{slug}/" }
    ]
  }
]
</script>
```

**Body sections (in order):**

1. **Header** — shared header. Nav links: `Blog` → `/blog/`, `fv.dev` → `https://fv.dev`. Logo `<img>` must include explicit dimensions: `width="616" height="341"`.

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

5. **Footer** — shared footer. Links: All Apps, Blog, About, Terms of Service, Privacy Policy, Regional Data Protection, info@fv.dev, fv.dev. Logo `<img>` must include `width="616" height="341"`.

**Content rendering rules (markdown → HTML):**

- `## Heading` → `<h2>`
- `### Subheading` → `<h3>`
- Paragraphs → `<p>`
- `**bold**` → `<strong>`, `*italic*` → `<em>`
- `` `code` `` → `<code>`
- Code blocks → `<pre><code>`
- Links → `<a>` (keep external links as-is)
- Ordered/unordered lists → `<ol>/<ul>` with `<li>`
- Tables → `<table>` with `<thead>` and `<tbody>`
- Blockquotes with bold lead word (`> **Tip:** ...`) → `<div class="article-callout"><p><strong>Tip:</strong> ...</p></div>`
- Plain blockquotes → `<div class="article-callout"><p>...</p></div>`
- `&` in text → `&amp;` (HTML entity encoding)

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
    <changefreq>yearly</changefreq>
    <priority>0.6</priority>
  </url>
```

If an entry for this slug already exists, don't duplicate it.

### 7. Update `src/llms.txt`

Add a blog entry. Insert before the `## Homepage` section:

```
## Blog: {title}
https://apps.fv.dev/blog/{slug}/
{excerpt}
```

If an entry for this slug already exists, update it.

## Important rules

- **No JavaScript in generated pages** — pure HTML + CSS only
- **Never overwrite `src/blog/styles.css`** — it's manually maintained
- **Use shared styles** — load CSS in the correct order, use `--fv-*` tokens and utility classes (`.fv-container`, `.fv-btn`, `.fv-card`, etc.)
- **Semantic HTML** — use `<article>` for the article body, `<section>` for distinct page sections, `<nav>` for navigation, proper heading hierarchy (h1 in hero, h2/h3 in body)
- **Accessible** — all images need `alt` text, all `<img>` tags need explicit `width` and `height` to prevent CLS, interactive elements need focus styles
- **Match the existing article template exactly** — use `src/blog/how-to-migrate-ecwid-store-seo/index.html` as the reference
- **Date formatting:** frontmatter `date: 2026-04-04` renders as `April 4, 2026` in visible HTML and `2026-04-04` in schema/OG meta
- **YYMMDD in INDEX.md** is derived from the date field: `2026-04-04` → `260404`

## After generating

1. List all files created or modified
2. Run `npm --prefix "{project-root}" run build` to verify the build succeeds
3. Report what was generated and any warnings
4. Do NOT commit or push — the user will decide when to commit
5. **Request GSC indexing** for each new article URL:
   - GSC → URL Inspection → `https://apps.fv.dev/blog/{slug}/` → Request indexing
   - Either use Playwright to automate, or instruct the user to do it manually

## Infrastructure notes

- **apps.fv.dev hosting:** Cloudflare Pages (project: `fv-apps-hub`, account: `ak@fv.dev`)
- **Security headers** (HSTS, CSP, X-Frame-Options, etc.) are globally configured in `_headers` — do not add them to individual HTML pages and do not modify `_headers` when generating blog pages
- **Blog CSS** (`src/blog/styles.css`) covers both listing and article page styles — do not create separate CSS files per article
- **fv.dev** is hosted on Tilda, DNS on Porkbun — unrelated to this repo
