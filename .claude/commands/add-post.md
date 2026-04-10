# Add Blog Post

Ingest a markdown file into the `blog/` folder with proper naming, frontmatter, and index entry. Optionally copy an OG image alongside it.

## Input

Arguments are provided as: $ARGUMENTS

**Expected format:**
- `/add-post path/to/post.md path/to/og.png` — both arguments required

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

### 2. Build or complete the frontmatter

Required fields: `title`, `slug`, `date`, `tag`, `read_time`, `excerpt`
Optional fields: `intro`, `cta`, `date_modified`, `og_image`

**For each required field:**

- If present in existing frontmatter, keep it.
- If missing, derive it:
  - `title` — use the first `# H1` heading in the body. If no H1, ask the user.
  - `slug` — derive from title: lowercase, replace spaces with hyphens, strip special characters, max 60 chars. Show the user and confirm.
  - `date` — use today's date (YYYY-MM-DD format).
  - `tag` — infer from content (common tags: SEO, Migrations, Guides, Ecwid, Technical). Show the user and confirm.
  - `read_time` — estimate from word count (average 200 words/minute, round to nearest minute, format as "N min read").
  - `excerpt` — generate a 1-2 sentence summary from the content. Show the user and confirm.

**For optional fields:**

- `intro` — if the body starts with a paragraph before the first `## H2`, use that as the intro and remove it from the body (it will be rendered in the article hero, not the article body).
- `cta` — do not auto-generate. Only include if it was in the source frontmatter.
- `date_modified` — only include if it was in the source frontmatter.
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
4. Set `og_image` in frontmatter to `/blog/{slug}/og.png` (the path where `/publish-blog` will copy it to `src/`).

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
date_modified: {date}       # only if present
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
- Whether INDEX.md was updated (new entry or updated existing)
- Remind: run `/publish-blog` to generate the HTML article page and update the listing

## Important rules

- **Do not generate HTML.** This command only manages the markdown source, OG image, and index. HTML generation is done by `/publish-blog`.
- **Do not modify `src/` files.** This command only touches `blog/` folder files.
- **Preserve the original content.** Do not rewrite, edit, or "improve" the body text. Only structural changes (remove duplicate H1, extract intro paragraph).
- **Quote strings in frontmatter** that contain colons, quotes, or special YAML characters.
- **Always show the user** the derived slug, tag, and excerpt before writing. These are the fields most likely to need adjustment.
- **OG image naming:** the image file in `blog/` always matches the post filename with `-og` suffix: `YYMMDD-slug-og.png`. This keeps post and image paired in the filesystem.
