# Add Blog Post

Ingest a markdown file into the `blog/` folder with proper naming, frontmatter, and index entry. Optionally copy an OG image alongside it.

## Standards

This command enforces the ingest-time subset of the blog quality standards (slug rules, structural baselines, frontmatter shape) and surfaces warnings for everything else. `/blog-publish` enforces the full set as a hard gate before generating HTML — drafts that pass ingest can still fail publish, so address the warnings here before running publish.

The standards below are derived from research on AI citation patterns (ChatGPT, Perplexity, Google AI Overviews) and traditional SERP performance.

## Input

Arguments are provided as: $ARGUMENTS

**Expected format:**
- `/blog-add-post path/to/post.md path/to/og.png` — both arguments required

**If either argument is missing, stop with an error:**
- Missing `.md` path: `Error: provide path to blog post .md file`
- Missing OG image path: `Error: provide path to OG image (1200x630px .png/.jpg/.webp)`

Do not proceed without both arguments.

Paths can be absolute or relative to the project root. They can point to any file anywhere on disk (e.g. a draft in Google Drive, a marketing folder, etc.).

## Steps

### 1. Read and analyze the source file

Read the source `.md`. Determine what it already has:

- **Has YAML frontmatter?** Check for `---` delimiters at the top. If yes, parse the frontmatter fields.
- **Has a markdown body?** Everything after the frontmatter (or the entire file if no frontmatter).

**Capture structural metrics** for validation (used in Report and as warnings):

- Word count of body (`wc -w`)
- H1 count (`grep -cE '^# ' body`)
- H2 + H3 count (`grep -cE '^##{1,2} ' body`)
- Internal link count in body (markdown links with target starting with `https://apps.fv.dev/`). Blog post body links to other site pages must be written as full URLs in markdown — this is the one exception to the site's relative-link default. Reason: the rendered anchors need to survive AI-summary citations, syndication, and feed-reader contexts where the canonical page URL isn't carried with the snippet. Template-level links (header, footer, cards) stay relative.
- Lists or tables present (any `^- `, `^\d+\. `, or `|`-delimited table line)
- Images present (any `![alt](url)`); for each, whether `alt` text is non-empty and descriptive (reject "screenshot 1", "image1", "img", and similar placeholders)
- First paragraph after H1: sentence count and whether it directly answers the H1
- Flesch-Kincaid grade level (only if `textstat` is installed): `python3 -c "import textstat,sys; print(textstat.flesch_kincaid_grade(open(sys.argv[1]).read()))" {body.md}` — skip the check entirely if `textstat` import fails

**Surface warnings** (do not block ingestion — drafts may still need work):

- **Word count < 500 or > 2000** — under 500 reads as thin content to AI engines; over 2000 should be split into a parent post + linked deep-dives.
- **H1 count ≠ 1** — exactly one H1 per post.
- **H2 + H3 count outside 7–20** — 1–3 subheadings is the worst-performing range for AI citation.
- **First paragraph after H1 doesn't answer the H1 in 2–4 sentences** — front-loaded answer is non-negotiable for AI citation; no scene-setting, no "in this guide we'll cover." This paragraph becomes the `intro` field.
- **Internal links < 2 in body** — at least two body-copy links to other posts/pages on the site (nav and footer don't count).
- **No list or table present** — at least one of either is required.
- **Any image with missing or placeholder alt text** — alt must describe what the image shows.
- **FK grade outside 14–18** — flag for editor only. **Never auto-rewrite content for readability.** Peak AI citation rate is at FK 16–17.

These warnings become hard gates at `/blog-publish` — a draft that ignores them will be refused later.

### 2. Build or complete the frontmatter

Required fields: `title`, `slug`, `date`, `tag`, `read_time`, `excerpt`
Optional fields: `intro`, `cta`, `date_modified`, `og_image`

**For each required field:**

- If present in existing frontmatter, keep it.
- If missing, derive it:
  - `title` — use the first `# H1` heading in the body. If no H1, ask the user. The H1 should be phrased as a real user question or a direct claim, max 110 chars.
  - `slug` — derive from the **target query**, not the H1 verbatim. Strip filler words (a, the, how to, …). Lowercase, hyphenated, no trailing punctuation. **Maximum 5 words / ~60 chars.** Show the user and confirm. Slugs are permanent — never change one after publish; if the topic shifts, publish a new post and 301-redirect the old slug.
  - `date` — use today's date (YYYY-MM-DD format).
  - `tag` — infer from content (common tags: SEO, Migrations, Guides, Ecwid, Technical). Show the user and confirm.
  - `read_time` — estimate from word count (average 200 words/minute, round to nearest minute, format as "N min read").
  - `excerpt` — generate a 1-2 sentence summary from the content, **140–160 chars** (it's used as the `<meta name="description">`). Should mirror the front-loaded answer in the intro. Show the user and confirm.

**For optional fields:**

- `intro` — if the body starts with a paragraph before the first `## H2`, use that as the intro and remove it from the body (it will be rendered in the article hero, not the article body). The intro must answer the H1 directly in 2–4 sentences.
- `cta` — do not auto-generate. Only include if it was in the source frontmatter.
- `date_modified` — set equal to `date` on first ingest (every post needs `dateModified` for schema and sitemap `<lastmod>`). On a re-ingest, only bump `date_modified` if the body actually changed; leave it untouched otherwise. **Never bump `date_modified` to manufacture freshness** — that's flagged as a dark pattern by ranking systems.
- `og_image` — set automatically if an OG image path is provided (see step 5). Do not auto-generate.

### 3. Clean the body

- If the body starts with `# Title` that matches the frontmatter `title`, remove it (the title comes from frontmatter, not the body).
- If the body starts with a paragraph before the first `## H2` and it was extracted as `intro`, remove it from the body.
- Ensure body headings start at `##` (H2), not `#` (H1).
- Trim leading/trailing whitespace.

### 4. Determine the filename

Format: `YYMMDD-slug.md`

- `YYMMDD` from the `date` field: `2026-04-04` → `260404`
- `slug` from the frontmatter

Check if `blog/YYMMDD-slug.md` already exists:
- If it exists, warn the user: "A post with this filename already exists. Overwrite?" Wait for confirmation.
- If it doesn't exist, proceed.

### 5. Handle OG image

The OG image path (second argument) is required.

1. Verify the file exists. If not, stop with error: `Error: OG image not found at {path}`.
2. Verify it's a valid image extension (`.png`, `.jpg`, `.jpeg`, `.webp`). If not, stop with error.
3. Copy it to `blog/YYMMDD-slug-og.png` (same base name as the post file, with `-og` suffix, keeping the original extension).
4. Set `og_image` in frontmatter to `/blog/{slug}/og.png` (the path where `/blog-publish` will copy it to `src/`).

### 6. Write the post file

Write the complete file to `blog/YYMMDD-slug.md`:

```markdown
---
title: "{title}"
slug: {slug}
date: {date}
tag: {tag}
read_time: {read_time}
excerpt: "{excerpt}"
intro: "{intro}"            # only if present
date_modified: {date}       # always set; equal to `date` on first ingest
og_image: "/blog/{slug}/og.png"  # only if OG image was provided
cta:                        # only if present
  heading: "..."
  text: "..."
  primary_label: "..."
  primary_url: "..."
  secondary_label: "..."
  secondary_url: "..."
---

{cleaned body}
```

### 7. Update `blog/INDEX.md`

Add or update the entry in `blog/INDEX.md`. Insert at the top (below the header/comment), newest first.

Format: `YYMMDD | slug | title | tag | read-time | excerpt`

If an entry with the same slug already exists, update it in place.

### 8. Report

Show the user:
- Filename created: `blog/YYMMDD-slug.md`
- OG image: copied to `blog/YYMMDD-slug-og.png` (or "none")
- Frontmatter summary (title, slug, date, tag, read_time, excerpt)
- Word count and estimated read time
- Structural metrics from step 1: H1 count, H2+H3 count, internal links count, lists/tables present, images with alt status, FK grade (if available)
- Any warnings triggered (word count out of range, headings out of range, missing front-loaded answer, etc.) — list them explicitly so the user knows what needs fixing before `/blog-publish` will accept the post
- Whether INDEX.md was updated (new entry or updated existing)
- Remind: run `/blog-publish` to generate the HTML article page and update the listing

## Important rules

- **Do not generate HTML.** This command only manages the markdown source, OG image, and index. HTML generation is done by `/blog-publish`.
- **Do not modify `src/` files.** This command only touches `blog/` folder files.
- **Preserve the original content.** Do not rewrite, edit, or "improve" the body text. Only structural changes (remove duplicate H1, extract intro paragraph).
- **Do not auto-rewrite for readability.** If FK grade is outside 14–18, flag it for the editor — do not paraphrase or restructure on the editor's behalf.
- **Do not pad word count** with filler to reach the 500-word floor. Posts under 500 words should be expanded with substance or rejected, not padded.
- **Do not generate FAQ entries** the post doesn't actually answer. FAQ-style headings exist in the body or they don't.
- **Do not bump `date_modified`** to manufacture freshness. Bump it only when the body has actually changed.
- **Do not change a published slug.** If the topic shifts after publish, create a new post and 301 the old slug.
- **Quote strings in frontmatter** that contain colons, quotes, or special YAML characters.
- **Always show the user** the derived slug, tag, and excerpt before writing. These are the fields most likely to need adjustment.
- **OG image naming:** the image file in `blog/` always matches the post filename with `-og` suffix: `YYMMDD-slug-og.png`. This keeps post and image paired in the filesystem.
