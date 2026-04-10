---
title: "How to Migrate to Ecwid from Shopify, WooCommerce, or BigCommerce Without Losing SEO"
slug: how-to-migrate-to-ecwid-seo
date: 2026-04-04
tag: SEO
read_time: 12 min read
excerpt: "Switching to Ecwid from another e-commerce platform? Every URL changes at once. Here's the exact process for auditing your old URLs, building a redirect map, and keeping Google happy through the transition."
intro: "When you migrate from Shopify, WooCommerce, BigCommerce, or another e-commerce platform to Ecwid, every product and category URL changes at once. If you had 500 indexed product pages, you now have 500 potential 404 errors on day one. This guide covers the exact process for preserving your organic rankings through the switch."
cta:
  heading: "Managing Redirects on an Embedded Ecwid Store?"
  text: "Redirect & 404 Manager handles the Ecwid-specific parts automatically — bulk CSV import for planned migrations, wildcard redirects for pattern-based URL changes, redirect chain detection, and a real-time 404 dashboard so nothing slips through."
  primary_label: "Learn About the App"
  primary_url: "/redirect-404-manager/"
  secondary_label: "Install Free on Ecwid"
  secondary_url: "https://my.ecwid.com/store/130416012#apps:view=app&name=seo-redirect-manager"
---

## Why platform migrations break your SEO

When you switch platforms, every URL changes. Google sees the old URLs returning 404 errors while new URLs appear with no history, no backlinks, and no authority. Rankings you built for the old URLs don't transfer on their own.

Redirects are how you bridge that gap. Google follows the trail from old URL to new URL and carries the ranking signals over. Whether you keep your rankings or lose them comes down to whether those redirects exist before you flip the switch.

### The embedded-store problem

Most SEO migration guides assume you control your web server. With Ecwid, you usually don't. Ecwid is typically embedded in a third-party website (WordPress, Wix, Squarespace, Joomla), so you can't add a line to `.htaccess` or configure Nginx rules. The hosting platform controls the server, and Ecwid controls the product URLs.

Standard migration advice ("set up 301 redirects on your server") doesn't work here. You need an approach built for the embedded store reality. More on your options in Step 4.

## Step 1: Audit your old platform's URLs

The most common migration mistake is switching before documenting what exists. Once you point your domain to the new site, the original URLs are gone. Capture them first.

### Export from your current platform

- **Shopify:** Export your product CSV (which includes handles/URLs), and crawl your live site for category and content page URLs.
- **WooCommerce:** Export products via WooCommerce's built-in CSV export, and use a crawler on your WordPress site.
- **BigCommerce:** Export your product catalog, and crawl the live site for all indexed URLs.

### Export from Google Search Console

Go to **Performance > Pages** and export all URLs with impressions in the last 12 months. Your platform export might miss pages that aren't products (blog posts, custom pages, informational content) that still drive organic traffic. GSC catches everything Google knows about.

Combine both exports into a single spreadsheet. This becomes your redirect map.

## Step 2: Understand Ecwid's URL system

Before you build your redirect map, you need to know what the new URLs will look like.

Ecwid generates product and category URLs based on product names and appends product IDs (e.g., `/summer-linen-dress-p12345`). These will look nothing like your old platform's URLs. Shopify uses `/products/summer-linen-dress`, WooCommerce uses `/product/summer-linen-dress`, BigCommerce uses its own structure. Ecwid's format differs from all of them.

### Check your URL format

Ecwid stores use different URL formats depending on your website setup:

- **Default (hashbang) URLs**, e.g., `example.com/store/#!/product-name/p/123456`. Long and unfriendly for SEO, but resilient because the product ID is in the URL.
- **Clean URLs**, e.g., `example.com/store/product-name`. Shorter and better for SEO. Requires server rewrite rules on your hosting platform. On Ecwid's Instant Site, Clean URLs are enabled by default.
- **Clean URLs + Custom Slugs**, e.g., `example.com/store/best-pizza`. Available on Business and Unlimited plans when Clean URLs are enabled. Gives you full control over the URL path.

If your new hosting setup supports Clean URLs, configure the server rewrite rules *before* you start mapping URLs. The format you choose determines what your new URLs will look like, and you need to know that before building the redirect map.

### When Clean URLs aren't possible

On some platforms (Webflow, Sitejet, and certain managed hosting environments), you can't access server configuration files, so server-level rewrite rules aren't an option. Ecwid falls back to query-based clean URLs in those cases (e.g., `example.com/store?store-page=Product-p123`). These are functional but less effective for SEO than true clean URLs, and Ecwid's own documentation says as much.

If you're on one of these platforms, your redirect map destinations will use this query-based format. Factor that in before you start building the map, and know that your SEO ceiling is lower from the start compared to a setup with proper clean URLs.

## Step 3: Build a redirect map

A redirect map is a two-column spreadsheet: old URL on the left, new Ecwid URL on the right. Every indexed URL from your old platform needs a row.

### The URL generation catch

Most migration guides skip this friction point: Ecwid auto-generates product URLs when you import your catalog, and you can't pre-define slugs during the import process. You have to import your products first, wait for Ecwid to generate the URLs, then export the catalog again to discover what URLs it created. Only then can you start matching old URLs to new ones.

On Business and Unlimited plans, you can edit slugs after import using Custom Slugs. But you're still doing it product by product, after the fact. With a large catalog, plan for this step to take longer than you'd expect.

After importing your product catalog and exporting the new URLs from your Ecwid admin, match each old URL to its Ecwid equivalent:

| Old URL (Shopify) | New URL (Ecwid) |
|---|---|
| `/products/summer-linen-dress` | `/store/summer-linen-dress-p12345` |
| `/collections/womens-clothing` | `/store/womens-clothing` |
| `/products/vintage-boots` | *(discontinued, redirect to)* `/store/footwear` |

### Sort by traffic

Sort your redirect map by traffic volume (impressions from GSC). Do the high-traffic URLs first. A missed redirect on a page that gets 5,000 impressions a month costs you far more than one on a page that gets 20.

### Be specific with destinations

Redirecting everything to the homepage is better than leaving 404s, but it's a weak signal to Google compared to redirecting to a related page. If you discontinued a winter boots product, redirecting to your footwear category is far stronger than redirecting to `/`.

For each old URL, decide:

- **Direct match:** the product exists in Ecwid. Redirect to its new URL.
- **Category fallback:** the product was discontinued but a relevant category exists. Redirect there.
- **Homepage fallback:** no relevant destination exists. Redirect to the homepage rather than leaving a 404.

## Step 4: Set up redirects before going live

Redirects must be in place *before* you point your domain to the new Ecwid-embedded site, not after you notice traffic dropped.

### Know what Ecwid offers natively

Ecwid has a built-in 301 redirect manager, but with hard constraints. It requires the Business plan ($29.90/month) or higher, works only on Ecwid Instant Site (New-Gen version), and caps manual creation at 10 redirects before requiring CSV import.

For Instant Site merchants on the Business plan or above, the native tool covers the basics: pointing old URLs to new ones, redirecting discontinued product pages, and setting up vanity URLs for marketing campaigns. When you change a custom URL slug, Ecwid auto-redirects the old slug to the new one.

The native tool does not support wildcard or regex redirects (every redirect must be individually specified), 404 monitoring, broken link detection, or redirect chain validation. For Instant Site merchants with straightforward needs, it may be enough. For everyone else, and for any migration involving pattern-based URL changes, you'll need one of the approaches below.

### Choose your redirect implementation

Most embedded Ecwid stores have several options depending on the hosting setup.

**Option A: Server-level redirects (WordPress, self-hosted sites)**

If your store is embedded in WordPress, you can configure redirects via a plugin like Redirection (2M+ active installs), Rank Math's redirect module, or Yoast SEO Premium. If you have direct server access, `.htaccess` rules or Nginx configuration work too.

One distinction trips up many merchants here: server-level rules for Ecwid stores must **rewrite**, not **redirect**, the store subpaths. Ecwid's own developer documentation warns: *"Do not redirect the 'store/anything/' to '/store'. The rewrite rules should only map one URL to another, without redirection."*

Ecwid's storefront is a JavaScript widget that renders within a single host page. When a visitor goes to `/store/Blue-Flannel-p69981208`, no corresponding file or directory exists on the server. Ecwid's JavaScript intercepts the URL and renders the correct product. If your server 301-redirects all `/store/*` paths to `/store` instead of silently serving the store page, Ecwid's JS can't resolve the individual product page. Google won't index your products, and visitors hitting direct product links will see the wrong content.

The WordPress Ecwid plugin handles this rewriting automatically. But if you're adding redirect rules on top of that for migration purposes, make sure those rules redirect old non-Ecwid paths to the correct new Ecwid URLs. Don't let them interfere with the rewrite rules that make Ecwid's clean URLs work.

One more limitation: WordPress redirect plugins work at the WordPress routing level. They can redirect an old static URL like `/old-product-info` to your Ecwid store page at `/store`. But redirecting between specific Ecwid product URLs within the store is unreliable, because Ecwid products aren't separate WordPress pages. They're JavaScript-rendered views on a single host page, and WordPress has no awareness of them as individual routes.

**Option B: Client-side redirects via a redirect app**

If you don't have server access (common with hosted website builders like Wix or Squarespace), you need a JavaScript-based solution. Redirect & 404 Manager integrates with Ecwid's API, reads your redirect rules, and executes them on page load.

Wix and Squarespace have their own built-in redirect tools (Wix's URL Redirect Manager; Squarespace's URL Mappings). These work at the page level: they can redirect an old page to the page containing the Ecwid store widget. But like WordPress plugins, they cannot redirect between specific Ecwid product URLs within the embedded store. If your old Shopify URL `/products/blue-flannel` needs to land on Ecwid's `/store/Blue-Flannel-p69981208`, the platform's built-in tool can get the visitor to `/store` but not to the specific product view.

A storefront-level redirect app fills that gap. It runs inside Ecwid's JavaScript environment and can route visitors to specific products, categories, or pages within the store.

**Option C: DNS-level redirects via Cloudflare**

If your domain runs through Cloudflare, you can use Cloudflare Redirect Rules or Bulk Redirects to handle domain-level and path-based redirects at scale (Cloudflare supports millions of URL rules). This works regardless of your hosting platform and fires before any page content loads.

Two limitations: Cloudflare cannot redirect hash-based URLs (the fragment after `#` never reaches the server, so Cloudflare never sees it), and you need to configure Cloudflare rules carefully to avoid conflicting with the rewrite rules that make Ecwid's clean URLs work. Cloudflare handles old non-Ecwid paths well (like your former Shopify `/products/*` URLs pointing to specific new Ecwid URLs), but it won't help with hash-based Ecwid URLs.

### How these approaches differ for SEO

Server-level redirects respond with an HTTP 301 status code before the page renders. Search engines see the redirect immediately and transfer link equity to the new URL. This is the strongest approach.

DNS-level redirects (Cloudflare) behave the same way. The redirect fires before the browser receives any page content, and search engines treat them identically to server-level 301s.

Client-side redirects work differently. The page loads, JavaScript executes, and then the visitor goes to the correct destination. Google can follow JavaScript redirects and has indicated they pass ranking signals, but server-side 301s remain preferred. The app hides the storefront element at load (before the redirect fires) so visitors don't see a flash of wrong content, but crawlers still need to execute JavaScript to discover the redirect.

Server-side or DNS-level is better when available. But client-side redirects are far better than nothing. A 404 error transfers zero link equity. A JavaScript redirect transfers most of it. For most embedded Ecwid stores where the hosting platform controls the server, client-side redirects through a storefront app are the only option, and they fill a gap that would otherwise leave you with no redirect capability at all.

### Combining approaches

For stores on WordPress or other self-hosted platforms, you can use server-side redirects for your highest-traffic pages and the app for everything else (wildcard patterns, 404 detection, ongoing monitoring). Server-side redirect plugins have no awareness of Ecwid's product catalog, so you create and maintain every redirect by hand. They won't detect when a product URL changes or a product gets deleted.

> **Instant Site users:** If your store runs on Ecwid's Instant Site, the app's client-side storefront features do not work. Instant Site's server handles URL routing before the storefront JavaScript loads.

### Upload via CSV import

Upload your redirect map via CSV import. The CSV format is two columns: `source_path` (old URL path) and `destination_path` (new Ecwid URL path). The import preview validates each row, checking for duplicate sources, confirming destinations exist in your Ecwid catalog, and flagging potential issues.

### Use wildcard redirects for patterns

When many old URLs follow a predictable pattern, a single wildcard redirect can replace hundreds of individual rules. If all your Shopify product URLs lived under `/products/*` and your Ecwid store uses `/store/*`, one wildcard rule handles the entire batch. You'll still need individual rules where the slug changed between old and new.

### Test before going live

The app's redirect testing feature lets you verify that destinations resolve correctly, check for redirect chains (A > B > C), and detect redirect loops before you flip the switch.

## Step 5: Update internal links

Redirects handle external links and bookmarked URLs. But your own internal links need to point directly to the new Ecwid URLs rather than going through a redirect.

This is a bigger job than it sounds. You need to update every internal link on your website with Ecwid URLs: navigation menus, blog post product links, landing page CTAs, footer links. Anything that pointed to your old platform's URLs needs to change.

Crawl your own site after launch and look for any internal links that return a redirect response. Update them to point to the final destination. This removes redirect latency and sends cleaner signals to Google.

## Step 6: Monitor after launch

Even a well-executed migration shows some short-term volatility in rankings. Google needs to recrawl and reprocess the URLs. This takes days to weeks depending on your site's crawl budget.

### Google Search Console

Watch two reports after launch:

- **Pages > Not found (404):** Any 404 errors here mean you missed a redirect. Fix them immediately.
- **Pages > Redirect:** Verify these resolve to the correct destinations.

A spike in 404 errors in the first few days is normal for pages Google hasn't recrawled yet. 404s that persist beyond two weeks mean something is broken.

### Real-time 404 detection

Google Search Console reports 404s with a delay, often several days after they first occur. During a migration, that delay means broken URLs can sit undetected during the most critical window.

Redirect & 404 Manager's 404 dashboard catches broken URLs in real time as visitors encounter them on your storefront. You can spot and fix missed redirects within hours of going live, instead of waiting for GSC to flag them days later.

Use both: the app's dashboard for immediate post-migration triage, and GSC for ongoing monitoring once things stabilize.

## How long does recovery take?

A platform switch will show a temporary dip in rankings even with perfect redirects. Google drops the old URLs from its index and re-evaluates the new ones. For most sites, this resolves within 4 to 8 weeks.

The difference between a well-executed migration and a damaging one is the shape of the recovery. With proper redirects, rankings return to pre-migration levels within a month or two. Without redirects, you're rebuilding from scratch. For competitive search terms, that rebuild can take 6 to 12 months or more.

The SEO equity in your existing pages is real and worth protecting. A few hours of migration planning saves months of recovery work.
