# Action Plan — apps.fv.dev SEO Audit
**Date:** April 8, 2026 | **Health Score:** 73/100

## Critical (Fix Immediately)

- [ ] **[C1]** Resubmit sitemap after adding `lastmod` + removing `priority`/`changefreq` — investigate why 0/9 URLs indexed
- [ ] **[C2]** ~~Add a named founder/developer to About page and blog post byline~~ — postponed
- [ ] **[C3]** ~~Expand About page from ~210 to 500+ words (founding year, team, philosophy)~~ — postponed
- [ ] **[C4]** ~~Expand blog post from ~1,050 to 1,600+ words; fix "8 min read" label discrepancy~~ — postponed
- [x] **[C5]** Fix or disclose `-dev` suffix on Ecwid App Market install URL — dev-mode app install is a trust-killer (Authoritativeness 12/25 in E-E-A-T)

## High (This Week)

- [x] **[H1]** Add HSTS, X-Frame-Options, X-Content-Type-Options, Referrer-Policy headers
- [x] **[H2]** Add `claude-seo@healthy-splice-492206-e6.iam.gserviceaccount.com` as Owner in GSC — prerequisite for validating C1 sitemap resubmission worked
- [x] **[H3]** Inline `/styles.css` + `/shared/shared.css` to eliminate 450ms render-blocking
- [x] **[H4]** ~~Audit GTM usage~~ — n/a, site uses GA4 gtag.js directly (not GTM); audit misidentified the script
- [ ] **[H5]** Rewrite blog H2 headings to question format for AI search visibility

## Medium (This Month)

- [ ] Add `og:image:width` + `og:image:height` to all pages
- [ ] Update homepage H1 to include "Ecwid" keyword
- [ ] Add `priceValidUntil` + `availability` to SoftwareApplication Offer schema
- [ ] Add `aggregateRating` to SoftwareApplication schema once reviews exist (significant CTR opportunity)
- [ ] Add CollectionPage/AboutPage WebPage schema
- [ ] Add ItemList schema to homepage app catalog
- [ ] Expand llms.txt with FAQ answer blocks + RSL 1.0 license declaration
- [ ] Implement IndexNow (Bing key + publish hook)
- [ ] Add canonical tag to `/rdpp/`
- [ ] Add HowTo schema to blog post (6-step process)
- [ ] Publish second blog post on Ecwid SEO topic
- [ ] Add 134-167 word self-contained answer blocks under each H2
- [ ] Fix 10 color contrast failures (accessibility)
- [ ] Standardize footer email to one address across all pages

## Low (Backlog)

- [ ] Extend static asset cache TTL to 1 year
- [ ] Convert `seo-redirect-app-logo.png` to WebP
- [ ] Add `<main>` landmark
- [ ] Add RSS feed link in `<head>`
- [ ] Add Sitelinks SearchAction to WebSite schema (if site search added)
- [ ] Person author schema on blog posts
- [ ] ContactPoint on About Organization schema
- [ ] Add `apps.fv.dev` to Organization sameAs array
- [ ] Logo: provide square variant for schema use
- [ ] Start Reddit presence (r/ecwid, r/SEO)
- [ ] Publish 3-5 YouTube tutorials (Ecwid redirect/SEO walkthroughs)
