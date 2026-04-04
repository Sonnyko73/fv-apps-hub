# Action Plan: apps.fv.dev
Priority-ordered fixes from the SEO audit | April 2, 2026
Google API data added: April 3, 2026 (Tier 2 — GSC + CrUX + GA4)

---

## Google API Findings (Confirmed April 3, 2026)

| Signal | Result | Implication |
|--------|--------|-------------|
| GSC — Homepage indexation | **Unknown to Google** | Never crawled |
| GSC — Product page indexation | **Unknown to Google** | Never crawled |
| GSC — Search impressions (28d) | **0** | No organic visibility |
| GSC — Clicks (28d) | **0** | No organic traffic |
| CrUX field data | **No data** | Insufficient Chrome user traffic |
| GA4 organic traffic | **No data** | Tracking snippet not installed yet |

**This changes the priority framing.** This is not an "optimize existing rankings" situation — the site does not exist in Google's index at all. Every action below is about getting indexed first, then optimizing.

---

## CRITICAL — Fix Immediately (Indexation & Crawlability at Risk)

### 1. Fix robots.txt ✅ Done — Apr 3, 2026
**Effort:** 15 min | **Impact:** High

Replace `/robots.txt` content with a valid RFC 9309 file. The current file is a legal copyright notice with no crawl directives. Add valid robots content first, then retain the legal block as comments below.

```
User-agent: GPTBot
Allow: /

User-agent: OAI-SearchBot
Allow: /

User-agent: ClaudeBot
Allow: /

User-agent: PerplexityBot
Allow: /

User-agent: CCBot
Disallow: /

User-agent: anthropic-ai
Disallow: /

User-agent: *
Allow: /

Sitemap: https://apps.fv.dev/sitemap.xml

# --- Content Rights Reservation (EU DSM Directive 2019/790 Art. 4) ---
# search: yes
# ai-input: no
# ai-train: no
```

---

### 2. Create sitemap.xml ✅ Done — Apr 3, 2026
**Effort:** 30 min | **Impact:** High

Create `/sitemap.xml` and deploy at the root. Submit to Google Search Console and Bing Webmaster Tools.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://apps.fv.dev/</loc>
    <changefreq>monthly</changefreq>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>https://apps.fv.dev/redirect-404-manager/</loc>
    <changefreq>monthly</changefreq>
    <priority>0.9</priority>
  </url>
  <url>
    <loc>https://apps.fv.dev/redirect-404-manager/docs/</loc>
    <changefreq>monthly</changefreq>
    <priority>0.7</priority>
  </url>
  <url>
    <loc>https://apps.fv.dev/terms/</loc>
    <changefreq>yearly</changefreq>
    <priority>0.3</priority>
  </url>
  <url>
    <loc>https://apps.fv.dev/privacy/</loc>
    <changefreq>yearly</changefreq>
    <priority>0.3</priority>
  </url>
  <url>
    <loc>https://apps.fv.dev/rdpp/</loc>
    <changefreq>yearly</changefreq>
    <priority>0.2</priority>
  </url>
</urlset>
```

---

### 3. Submit sitemap to Google Search Console ✅ Done — Apr 3, 2026
**Effort:** 5 min | **Impact:** Critical (triggers first crawl)

After deploying sitemap.xml, submit it in GSC:
GSC → Sitemaps → Add a new sitemap → `https://apps.fv.dev/sitemap.xml` → Submit.

Also request indexation for the two most important URLs:
GSC → URL Inspection → `https://apps.fv.dev/` → Request indexing
GSC → URL Inspection → `https://apps.fv.dev/redirect-404-manager/` → Request indexing

---

### 4. Install GA4 tracking snippet on apps.fv.dev ✅ Done — Apr 3, 2026
**Effort:** 15 min | **Impact:** Critical (no analytics data without this)

The GA4 property was created but the tracking code is not on the site — confirmed by zero GA4 data. Add the `G-XXXXXXXXXX` Measurement ID snippet to every page's `<head>`. Since the site is on Cloudflare Pages, add it to the shared HTML template.

**Note:** `properties/531155258` (in `~/.config/claude-seo/google-api.json`) is the Data API property ID used for reading analytics via the service account. The `G-XXXXXXXXXX` Measurement ID for the client-side tracking snippet is a separate value.

Get your Measurement ID: GA4 → Admin → Data streams → apps.fv.dev → Measurement ID.

```html
<!-- Add to <head> on every page -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX');
</script>
```

---

## HIGH — Fix Within 1 Week (Ranking & Trust Impact)

### 6. Add canonical tags to all pages ✅ Done — Apr 3, 2026 (main pages; missing on /privacy/, /terms/, /rdpp/)
**Effort:** 30 min | **Impact:** High

Add to every page's `<head>`:
```html
<link rel="canonical" href="https://apps.fv.dev/" />           <!-- homepage -->
<link rel="canonical" href="https://apps.fv.dev/redirect-404-manager/" />  <!-- product page -->
<!-- etc. for each page -->
```

---

### 7. Fix logo CLS (add width/height to all fv-logo.png instances) ✅ Done — Apr 3, 2026
**Effort:** 5 min | **Impact:** High (eliminates CLS risk)

4 instances total (header + footer on homepage, header + footer on product page):
```html
<img src="/shared/assets/fv-logo.png" alt="Forest Valley" class="fv-header-logo" width="616" height="341">
```

---

### 5. Add LCP preload hint ✅ Done — Apr 3, 2026
**Effort:** 5 min | **Impact:** Medium-High

Add as the first `<link>` in `<head>` on homepage and product page:
```html
<link rel="preload" as="image" href="/shared/assets/fv-logo.png" fetchpriority="high">
```

---

### 6. Deploy Organization + WebSite schema on homepage ✅ Done — Apr 3, 2026
**Effort:** 1 hour | **Impact:** High (Knowledge Panel signals, entity foundation)

See schema blocks in FULL-AUDIT-REPORT.md. This establishes the brand entity that all other schema references.

---

### 7. Deploy SoftwareApplication schema on product page ✅ Done — Apr 3, 2026
**Effort:** 1 hour | **Impact:** High (rich results eligibility)

Adds price, availability, and app category to Google SERP appearance.

---

### 8. Add BreadcrumbList schema to all pages ✅ Done — Apr 3, 2026
**Effort:** 30 min | **Impact:** Medium (SERP breadcrumb trail)

---

### 9. Enable HSTS via Cloudflare ✅ Done — Apr 3, 2026 (added to _headers file)
**Effort:** 5 min | **Impact:** Medium

Cloudflare dashboard → SSL/TLS → Edge Certificates → HTTP Strict Transport Security → Enable.
Set: `max-age=31536000; includeSubDomains`

---

### 10. Add CSP and X-Frame-Options headers ✅ Done — Apr 3, 2026
**Effort:** 30 min | **Impact:** Medium

Configure as Cloudflare Transform Rules:
```
Content-Security-Policy: default-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' https: data:; frame-ancestors 'none';
X-Frame-Options: DENY
```

---

### 11. Create About page with named author ✅ Done — Apr 3, 2026
**Effort:** 2-3 hours | **Impact:** High (E-E-A-T / Dec 2025 update compliance)

Must include: developer name, brief bio referencing e-commerce experience, LinkedIn/GitHub link, company registration info, founding context. This is the single highest-impact E-E-A-T fix available.

---

### 12. Add customer testimonials to product page ⏭ N/A — No reviews yet
**Effort:** 2-4 hours (sourcing + implementation) | **Impact:** High

Source from: Ecwid App Market reviews, support email exchanges (with permission), or direct outreach to trial users. Minimum 2-3 attributed quotes with name, store type, and specific outcome.

---

## MEDIUM — Fix Within 1 Month

### 13. Add OG tags to homepage ✅ Done — Apr 3, 2026 (applied to all main pages)
**Effort:** 15 min | **Impact:** Medium

```html
<meta property="og:type" content="website" />
<meta property="og:title" content="Forest Valley Apps — Business Apps by Forest Valley" />
<meta property="og:description" content="Specialized apps for Ecwid merchants. Manage redirects, fix 404 errors, and protect your SEO with Redirect & 404 Manager." />
<meta property="og:url" content="https://apps.fv.dev/" />
<meta property="og:image" content="https://apps.fv.dev/shared/assets/og.png" />
```

---

### 14. Fix the missing OG image on product page ✅ Done — Apr 4, 2026
**Effort:** 15 min | **Impact:** High for social sharing

`/redirect-404-manager/assets/og.png` returns 404. Create this file (1200×630px) or update the meta tag to point to an existing image.

---

### 15. Add Twitter Card meta tags to all pages ✅ Done — Apr 3, 2026
**Effort:** 30 min | **Impact:** Medium

```html
<meta name="twitter:card" content="summary_large_image" />
<meta name="twitter:title" content="[page title]" />
<meta name="twitter:description" content="[page description]" />
<meta name="twitter:image" content="[og:image URL]" />
```

---

### 16. Add FAQPage schema to product page ✅ Done — Apr 3, 2026
**Effort:** 1 hour | **Impact:** High for AI citation

No Google rich results (commercial site restriction), but significant AI/LLM citation value. See full JSON-LD in FULL-AUDIT-REPORT.md.

---

### 17. Rewrite homepage meta description ✅ Done — Apr 3, 2026
**Effort:** 10 min | **Impact:** Medium (CTR improvement)

Current description mentions "accounting" and "analytics" — irrelevant to the actual product. Replace with Ecwid-specific copy.

---

### 18. Create llms.txt ✅ Done — Apr 3, 2026
**Effort:** 15 min | **Impact:** High for AI discoverability

Deploy at `https://apps.fv.dev/llms.txt`. Content provided in FULL-AUDIT-REPORT.md (AI Search section).

---

### 19. Add product screenshots to product page ✅ Done — Apr 4, 2026
**Effort:** 2 hours | **Impact:** High (Experience E-E-A-T signal)

3-5 screenshots of: dashboard overview, redirect rule editor, 404 detection list. These are required for the Experience dimension of E-E-A-T.

---

### 20. Configure www redirect ✅ Done — Apr 3, 2026 (Porkbun URL forwarding — currently 302, change to 301)
**Effort:** 10 min | **Impact:** Low

Add CNAME `www.apps.fv.dev → apps.fv.dev` in DNS, then 301-redirect in Cloudflare.

---

### 21. Expand homepage content to 600+ words ✅ Done — Apr 4, 2026
**Effort:** 2-3 hours | **Impact:** High (thin content risk mitigation)

Expanded What We Do (5 paragraphs), added "Who We Build For" section (4 audience segments: Ecwid merchants, agencies/devs, service businesses, merchants in migration), expanded all 3 Why items. Broad multi-platform framing, not Ecwid-only.

---

## LOW — Backlog (Address Within 90 Days)

### 22. Publish a targeted blog post / guide
**Best topic:** "How to Migrate Your Ecwid Store Without Losing SEO Rankings"
**Why:** Directly targets the high-intent problem the product solves; creates first topical authority content; provides internal linking to product page.

### 23. Create a YouTube walkthrough video
**Best topic:** "How to Fix 404 Errors on Your Embedded Ecwid Store (WordPress, Wix, Squarespace)"
**Why:** Strongest known correlator with AI citation (0.737). Screen recording + voiceover, 3-5 minutes.

### 24. Consolidate CSS files (6 → 1-2)
Combine the 5 shared CSS files into a single `shared.min.css`. Total uncompressed payload is only ~7KB — no reason to serve 6 separate files.

### 25. Convert fv-logo.png to WebP
22.6KB PNG → ~10KB WebP. Use `<picture>` element with PNG fallback.

### 26. Implement IndexNow
Generate a UUID key file, deploy at `/{key}.txt`, and POST to IndexNow API on any page publish/update.

### 27. Add Permissions-Policy header
```
Permissions-Policy: camera=(), microphone=(), geolocation=(), payment=()
```

### 28. Establish Ecwid community presence
Answer threads on r/ecwid and the Ecwid Community Forum about 404 errors and redirect management. Genuine, helpful answers that mention the product in context.

### 29. Ensure Ecwid App Market listing is fully populated
500+ word description, all feature bullet points, platform compatibility explicitly listed. This listing is the highest-authority citation source for AI engines answering Ecwid-related queries.

### 30. Add "last updated" dates to product page and docs
Undated content is deprioritized by AI engines for time-sensitive queries.

### 31. Cross-link apps.fv.dev from fv.dev
A single link with anchor text "Ecwid Apps" from the parent agency domain would consolidate entity authority.

---

## Summary Timeline

| Timeframe | Key Actions | Expected Outcome |
|-----------|------------|-----------------|
| **Today** | robots.txt, sitemap.xml, GSC submission, GA4 snippet | Site enters Google's crawl queue for the first time |
| This week | Canonicals, logo dimensions, HSTS, schema foundation (Org + SoftwareApp) | Indexation confirmed, rich result eligibility unlocked |
| Week 2 | About page, testimonials, security headers, OG tags | E-E-A-T baseline established |
| Month 1 | Content expansion, FAQ schema, llms.txt, screenshots | Content quality score improvement |
| Month 2-3 | Blog post, YouTube video, community presence | Topical authority + AI citation growth |

---

## Implementation Notes for Claude Code

### Before Starting — Explore the Repo First

The plan references shared `<head>` elements, but the exact file structure is unknown from the outside. Before making any changes, run:

```bash
find . -name "*.html" | head -30
ls -la
```

Key questions to answer by reading the repo:
- Is there a shared HTML template/layout file, or is `<head>` duplicated in each page's `index.html`?
- Where is the site root for static files? (robots.txt and sitemap.xml must go there)
- Is there a build step, or are files served as-is?

### Placeholders That Must Be Filled Before Implementing

| Placeholder | Where Used | How to Find |
|-------------|-----------|-------------|
| `G-XXXXXXXXXX` | GA4 snippet (action 4) | GA4 → Admin → Data streams → apps.fv.dev → Measurement ID |
| Ecwid App Market listing URL | Organization schema `sameAs` | Your Ecwid App Market listing URL |
| `screenshot.png` | SoftwareApplication schema | Confirm actual screenshot filename in `/redirect-404-manager/assets/` |

### Deployment

Confirm deployment method by checking for:
- `.git/` directory → likely git push to Cloudflare Pages
- `wrangler.toml` → Cloudflare Wrangler CLI deployment
- No build config → files are served as-is, no build step needed

Do not run deployment until all changes in a batch are ready. Group related changes (all `<head>` additions, all schema blocks) into a single commit.

### What Requires Human Action (Cannot Be Done by Claude Code)

These items require browser/dashboard access and cannot be automated:

1. **GSC sitemap submission** — after deploying sitemap.xml, submit manually at Search Console → Sitemaps
2. **GSC URL inspection + request indexing** — for homepage and product page
3. **Cloudflare security headers** — HSTS, CSP, X-Frame-Options are set in Cloudflare dashboard (Transform Rules), not in code
4. **Testimonials** — sourcing customer quotes requires human outreach
5. **Screenshots** — product interface screenshots require access to the live app dashboard

### Commit Strategy

Group changes into logical commits rather than one giant commit:

1. `fix: robots.txt + sitemap.xml` (critical indexation fixes — deploy first, submit to GSC before continuing)
2. `feat: GA4 tracking snippet` (analytics)
3. `feat: canonical tags + OG tags on all pages` (on-page)
4. `feat: schema markup — Organization, SoftwareApplication, BreadcrumbList, FAQPage`
5. `fix: logo image dimensions for CLS` + `feat: LCP preload hint`
6. `content: homepage copy expansion + meta description update`

---

## Monitoring Checkpoints (once indexed)

Google API credentials are **fully configured at Tier 2** — no setup needed:
- Config: `~/.config/claude-seo/google-api.json`
- Service account: `~/.config/claude-seo/service_account.json`
- GSC property: `sc-domain:apps.fv.dev`
- GA4 property: `properties/531155258`

Scripts live at `~/.claude/skills/seo/scripts/` — do not call them directly. Use skill commands:

```
# Check indexation + search performance
/seo google gsc sc-domain:apps.fv.dev

# CrUX field data + PageSpeed
/seo google pagespeed https://apps.fv.dev

# GA4 organic traffic
/seo google ga4

# Verify credentials
python ~/.claude/skills/seo/scripts/google_auth.py --check
```
