# Blog Source Files

Source markdown for all blog posts on apps.fv.dev/blog/.

## Naming convention

Files: `YYMMDD-slug.md` (e.g. `260404-how-to-migrate-ecwid-store-seo.md`)
- YYMMDD = publish date (two-digit year, month, day)
- slug = URL path segment (lowercase, hyphens, no special chars)

## Post format

Each post has YAML frontmatter + markdown body:

- `title` (required) -- article headline
- `slug` (required) -- URL path: /blog/{slug}/
- `date` (required) -- ISO date: YYYY-MM-DD
- `tag` (required) -- single tag shown on the card (e.g. SEO, Migrations, Guides)
- `read_time` (required) -- e.g. "8 min read"
- `excerpt` (required) -- 1-2 sentence summary for the listing card and meta description
- `intro` (optional) -- opening paragraph for the article hero. If omitted, the first sentence of `excerpt` is used.
- `date_modified` (optional) -- ISO date for last update (YYYY-MM-DD). If omitted, `date` is used in schema `dateModified` and `article:modified_time`.
- `og_image` (optional) -- custom OG image path (relative to site root, e.g. `/blog/my-post/og.png`). If omitted, checks for `src/blog/{slug}/og.png` on disk, then falls back to `/shared/assets/og.png`.
- `cta` (optional) -- call-to-action box at the end of the article
  - `heading`, `text`, `primary_label`, `primary_url`, `secondary_label`, `secondary_url`

## OG images

Each post must have an OG image. The image file lives alongside the post in `blog/`:

- Post: `blog/YYMMDD-slug.md`
- OG image: `blog/YYMMDD-slug-og.png`

The `/add-post` command requires an OG image path and copies it with this naming. The `/publish-blog` command copies it to `src/blog/{slug}/og.png` (with freshness checking).

Recommended size: 1200x630px.

## Body conventions

- Standard markdown (headings, paragraphs, lists, code, links, bold, italic)
- Blockquotes with bold lead word become callout boxes: `> **Tip:** ...`
- Heading levels: `## H2` and `### H3` in body (H1 is the title from frontmatter)
- Tables use standard markdown table syntax
- No HTML in body -- the publish command handles conversion

## Index

`INDEX.md` tracks all published posts with metadata. Updated by `/publish-blog`.

## Relationship to src/blog/

- `blog/*.md` = source of truth (this folder)
- `src/blog/{slug}/index.html` = generated HTML article page
- `src/blog/index.html` = generated listing page (rebuilt on every publish)
- `src/blog/styles.css` = shared blog CSS (manually maintained, NOT generated)

## Commands

- `/add-post {path-to-any.md}` -- Ingest a markdown file into this folder. Renames to `YYMMDD-slug.md`, adds/completes frontmatter, updates INDEX.md. Does NOT generate HTML.
- `/publish-blog` -- Generates HTML for new or updated posts. Compares `blog/*.md` against `src/blog/*/index.html` to detect what needs publishing. Also accepts a specific filename to publish one post.
- `/publish-blog {YYMMDD-slug}` -- Publish only the specified post.
