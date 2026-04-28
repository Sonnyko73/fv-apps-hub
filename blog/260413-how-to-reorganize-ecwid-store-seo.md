---
title: "How to Set Up and Manage Redirects for Your Ecwid Store on WordPress, Wix, or Squarespace"
slug: ecwid-store-redirects-wordpress-wix-squarespace
date: 2026-04-15
date_modified: 2026-04-15
tag: SEO
read_time: 10 min read
excerpt: "The redirect tools built into WordPress, Wix, and Squarespace can't target Ecwid product URLs. This guide covers what works for embedded stores, where platform tools fall short, and how to handle catalog changes without losing rankings."
intro: "You changed a product URL, deleted an old category, or restructured your store. Now you need redirects. If your Ecwid store is embedded on WordPress, Wix, or Squarespace, the redirect tools you'd normally use won't work the way you expect. Every unredirected URL is a lost ranking. This guide covers why platform tools fall short, what works for embedded stores, and how to handle everything whether it's a single slug change or a full catalog overhaul."
cta:
  heading: "Need redirects for your embedded Ecwid store?"
  text: "Redirect & 404 Manager handles redirect creation, wildcard patterns, 404 detection, and auto-redirects on product deletion, built for Ecwid embedded stores on WordPress, Wix, Squarespace, and any other site. All features described in this article are included in the 14-day free trial and the paid plan ($5.99/month). No feature-gated tiers. After the trial ends, the app stops processing redirects until you subscribe."
  primary_label: "Learn About the App"
  primary_url: "https://apps.fv.dev/redirect-404-manager/"
  secondary_label: "Install Free on Ecwid"
  secondary_url: "https://my.ecwid.com/store/130416012#apps:view=app&name=seo-redirect-manager"
related:
  - slug: how-to-migrate-to-ecwid-seo
    label: "Switching from Shopify, WooCommerce, or BigCommerce? Read: How to Migrate to Ecwid Without Losing SEO"
---

## Why redirects are different on embedded Ecwid stores

When your Ecwid store is embedded on a third-party site, there's a wrinkle that most redirect guides don't address.

Ecwid is a JavaScript widget. Your hosting platform (WordPress, Wix, Squarespace) serves a page that loads the Ecwid storefront as JavaScript. Product pages like `example.com/store/blue-flannel-shirt-p69981208` aren't real server-side pages. They're views rendered by the Ecwid widget after the page loads. No file exists at that path on your server.

Your hosting platform's redirect tools work at the server level. They intercept requests before any page renders. They can redirect an old URL to the page that contains your Ecwid store. But they have no awareness of Ecwid's product URLs as individual destinations. You can get a visitor to `/store`. You cannot get them to `/store/blue-flannel-shirt-p69981208`.

For most redirect needs on an embedded Ecwid store, page-level routing isn't enough.

## How Ecwid URLs work

Your URL format determines how vulnerable your store is to catalog changes. Ecwid stores use three formats: hashbang URLs (with product IDs, resilient to renames), clean URLs (shorter, better for SEO, but renaming a product breaks the old link), and custom slugs (full control over the path, but any slug change breaks the old URL). For a full breakdown, see [How to Migrate to Ecwid Without Losing SEO](https://apps.fv.dev/blog/how-to-migrate-to-ecwid-seo).

The cleaner your URLs are for SEO, the more fragile they are when things change. Even hashbang URLs benefit from redirects. Renaming a product won't break the link for visitors, but Google may have both the old and new versions indexed. A redirect keeps search engines pointed at the current URL.

## What your hosting platform can and can't do

WordPress plugins, Wix's URL Redirect Manager, Squarespace's URL Mappings, and Cloudflare Redirect Rules all work at the server or DNS level. They can redirect old pages to the page containing your Ecwid store. None of them can redirect between specific Ecwid product or category URLs, because those are JavaScript-rendered views on a single host page, not actual server-side pages. For a platform-by-platform breakdown, see [How to Migrate to Ecwid Without Losing SEO](https://apps.fv.dev/blog/how-to-migrate-to-ecwid-seo).

One thing to watch on WordPress: if your setup uses clean URLs for Ecwid, do not redirect `/store/*` paths. Use rewrites instead. If your server 301-redirects all `/store/*` to `/store`, Ecwid's JavaScript can't resolve individual product pages. The WordPress Ecwid plugin handles this rewriting on its own. Make sure any redirect rules you add don't conflict with it.

For anything involving specific Ecwid product or category URLs, which covers most redirect needs on an active store, you need a storefront-level solution.

## What Ecwid offers natively

Ecwid's built-in redirect manager works only on Instant Site (New-Gen version), requires the Business plan ($29.90/month) or higher, and doesn't support wildcards, 404 monitoring, or redirect chain validation. It does auto-redirect old slugs when you change a custom URL slug. It may be enough for Instant Site merchants with simple needs. For embedded stores, you need a different approach.

## What works for embedded stores

Because Ecwid runs as JavaScript in the browser, the only way to redirect between specific product URLs is to run redirect logic in that same JavaScript environment, after the page loads but before the storefront renders.

If you're comfortable writing JavaScript, Ecwid's JS API provides event handlers like `Ecwid.OnPageLoaded` that let you intercept page navigation and redirect based on product or category IDs. Ecwid publishes a developer gist showing this approach for category redirects. It works, but you write and maintain every rule by hand. There's no 404 detection or wildcard matching, and nothing happens automatically when products change or get deleted.

A storefront-level redirect app handles this differently. It loads your redirect rules, intercepts navigation to a matching source URL, and sends the visitor to the correct destination before the storefront content appears. The storefront element stays hidden during this process so visitors don't see a flash of wrong content.

These are not server-side 301 redirects. Google needs to execute JavaScript to discover and follow a client-side redirect. Google's rendering engine does execute JavaScript and follows these redirects, so ranking signals pass to the destination URL. A server-side 301 is stronger when available, but for most embedded Ecwid stores it is not an option for store-internal redirects. A 404 transfers zero link equity; a JavaScript redirect transfers most of it.

### Combining approaches

If you run WordPress or another platform where you have server access, you can use server-side redirects for your highest-traffic pages and a redirect app for everything else: wildcard patterns, ongoing slug changes, 404 detection, and auto-redirects on product deletion.

> **Instant Site users:** If your store runs on Ecwid's Instant Site, client-side storefront redirect apps do not work. Instant Site's server handles URL routing before the storefront JavaScript loads. Use Ecwid's built-in redirect features instead.

## What can be automated

Most broken URLs in an active store come from routine catalog maintenance. You rename a product, delete a discontinued item. Each change breaks an indexed URL.

Redirect & 404 Manager monitors your store via Ecwid webhooks and handles two scenarios automatically.

When a product or category slug changes, whether you renamed it, edited its custom slug, or Ecwid auto-generated a new slug, the app creates a redirect from the old URL to the new one. This works for both auto-generated and custom slugs.

When you delete a product or category, the app records the old URL and creates a redirect to the default redirect destination you've configured in Settings (defaults to `/`, your store homepage). The redirect is live before Google next crawls that URL.

The webhook fires when Ecwid processes the deletion. If a product was created and deleted before the first webhook for that product fired, no URL was recorded, so no auto-redirect is created. Any product that was live long enough to be indexed will have the auto-redirect in place.

Between them, these cover the catalog changes that produce the most broken URLs.

## When you need manual redirects

Automation covers slug changes and deletions. Some situations need human judgment.

If you're deleting a product and a more relevant destination exists than your default redirect destination, create that redirect before you delete the product. The app redirects deleted products to whatever URL you've set in Settings (the store homepage by default). Redirecting a discontinued winter boots product to your footwear sale page sends a stronger signal to Google than the homepage would.

Category merges are trickier. The app catches the slug change on the surviving category but doesn't know that the deleted category's URL should point to the merged one. Build a redirect map for these.

Larger restructuring projects (reorganizing categories, bulk slug renames, reimporting product data) need planned redirects. The automation catches each individual change as it happens, but a redirect map gives you control over where each URL lands.

## How to handle planned bulk changes

For large-scale restructuring, set up your redirects *before* making the actual changes in Ecwid.

### Step 1: Audit your current URLs

Crawl your storefront (the website where the store is embedded, not the Ecwid admin) and record every product and category URL. Screaming Frog, Sitebulb, or Google Search Console will give you this list.

In Google Search Console, go to **Performance > Pages** and export all URLs with impressions in the last 12 months. These are the URLs Google knows about. Every one of them needs to either survive the restructuring or get a redirect.

### Step 2: Build a redirect map

For each URL that will change:

- The product has a direct replacement in Ecwid. Redirect the old URL to the new one.
- The product is discontinued but a relevant category exists. Redirect there.
- No relevant destination exists. Redirect to the homepage rather than leaving a 404.

Google treats a redirect to a relevant destination as a signal that the content moved. A redirect to the homepage looks like a soft 404. Be as specific as you can.

### Step 3: Upload via CSV import

Upload your redirect map as a CSV file before you make the changes. The format is two columns: `source_path` (old URL path) and `destination_path` (new URL path). The import preview validates each row: duplicate sources, missing destinations, loops, and chains.

For pattern-based changes, wildcard redirects replace hundreds of individual rules. A rule like `/old-category/*` to `/new-category/*` covers every product in that category at once. The `*` in the destination appends whatever matched the `*` in the source, so `/old-category/blue-flannel-p69981208` redirects to `/new-category/blue-flannel-p69981208`. You still need individual rules where the slug itself changed.

Wildcard matching follows two priority rules: exact matches always win over wildcards, and among wildcards, the most specific prefix wins. `/old-category/shirts/*` takes priority over `/old-category/*` for a URL that matches both.

### Step 4: Make the changes in Ecwid

Once your redirects are in place, make the actual catalog changes. The automation catches any slug changes on top of the rules you already uploaded. If a slug change creates a redirect that already exists in your map, the app skips the duplicate.

## Watch for redirect chains

If your store has been around for a while, you may already have redirects from previous changes. When you add new redirects, check whether any of your old URLs are themselves redirect destinations from even older URLs.

Say you previously redirected `/old-shoes` to `/shoes`, and now you're changing `/shoes` to `/footwear`. You have a chain: `/old-shoes` to `/shoes` to `/footwear`. Each hop dilutes the SEO signal and adds latency.

Fix this by updating the original redirect to point to the final destination: `/old-shoes` to `/footwear`. The app detects chains two ways: it warns you when creating a redirect that would form a chain, and its Test URL feature lets you trace the full hop sequence for any URL.

## Update internal links

Redirects handle external links and bookmarked URLs. Your own internal links (navigation menus, homepage widgets, blog post links to specific products) should point to the new URLs rather than going through a redirect.

After changing product slugs or reorganizing categories, check your website for internal links that point to old URLs. Update them to the new destinations. This removes redirect latency and sends cleaner signals to Google.

## Testing and monitoring

### Test before going live

Before you consider a redirect live, test it. The Test URL tool lets you enter any URL and see the full match chain: which rule matched, what type of match (exact or wildcard), and the final destination. It flags chains and loops.

Test every redirect you create, especially before a restructure where you're adding many rules at once.

### Real-time 404 detection

Redirects you plan in advance only cover what you anticipated. Broken links accumulate in the background: products get deleted, URLs get changed, external sites link to outdated paths.

The 404 detection runs passively and needs no configuration. The storefront script watches for product and category pages that fail to resolve, records the URL, and sends a batched report. The dashboard sorts 404 errors by hit count, with the most-hit URLs at the top. You can create a redirect for any entry with one click.

### Google Search Console

Watch two reports after making changes:

- **Pages > Not found (404):** any 404 errors here mean a redirect was missed. Fix them right away.
- **Pages > Redirect:** verify these resolve to the correct destinations.

GSC reports 404s with a delay of several days. The app's real-time 404 log catches them faster, so use both.

## How long does recovery take?

For individual slug changes and deletions handled by webhook automation, redirects are created in seconds. Google may take a few days to recrawl the affected page, but ranking disruption is minimal.

For larger restructuring projects like merging categories or bulk slug changes, expect Google to take 2 to 4 weeks to reprocess the affected URLs.

Your existing pages built up ranking value over months. A few minutes of redirect planning keeps that intact.

> **Migrating from another platform?** If you're switching to Ecwid from Shopify, WooCommerce, or BigCommerce, handle the platform migration redirects first. Read [How to Migrate to Ecwid Without Losing SEO](https://apps.fv.dev/blog/how-to-migrate-to-ecwid-seo), then come back here for ongoing catalog management.
