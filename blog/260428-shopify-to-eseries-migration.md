---
title: "How to migrate from Shopify to Lightspeed eCom (E-Series) without losing your SEO"
slug: shopify-to-eseries-migration
date: 2026-04-28
tag: SEO
read_time: 10 min read
excerpt: "Lightspeed Retail (X-Series) merchants paying for a separate Shopify store can consolidate to E-Series — but every URL changes. Here's how to handle the redirects so your rankings survive the move."
intro: "If you run your retail store on Lightspeed Retail (X-Series) and you're also paying Shopify every month for your online store, you're paying twice for something that's supposed to be one business. E-Series is already included in your X-Series subscription. Most X-Series merchants know this and still don't switch, usually because the SEO risk of moving off Shopify sounds like it's not worth the headache."
og_image: "/blog/shopify-to-eseries-migration/og.png"
cta:
  heading: "Migrating from Shopify to E-Series?"
  text: "Redirect & 404 Manager handles bulk redirect imports, wildcard rules, and 404 monitoring for embedded E-Series stores on WordPress, Wix, Squarespace, or any custom site. 14-day free trial, then $5.99/month flat."
  primary_label: "Learn About the App"
  primary_url: "/redirect-404-manager/"
  secondary_label: "Install Free on Ecwid"
  secondary_url: "https://my.ecwid.com/store/130416012#apps:view=app&name=seo-redirect-manager"
---

It mostly isn't, if you handle the URL redirects properly. This guide walks through the full migration, with most of the space spent on the URL part, because that's where rankings go to die if you're careless.

---

## Why migrate from Shopify to E-Series

The case for an X-Series merchant is consolidation. E-Series talks directly to your Lightspeed Retail catalog: products, inventory, customers, gift cards all sync between the register and the online store without manual reconciliation. If you're on a Core or Plus plan, E-Series Business comes with it. Cancel Shopify and that bill goes away.

The real tradeoff is Shopify's app ecosystem, which is bigger. If you've wired up half a dozen Shopify-specific apps into your workflow, list them before you decide. Some have E-Series equivalents, some don't.

For a brick-and-mortar retailer whose online store supports the physical business rather than being the whole business, consolidating is usually worth it.

---

## What changes when you switch platforms

Three things need attention: your product catalog, your customer data, and your URLs.

### Product catalog

Shopify and E-Series organize products around the same ideas but use different words for them. Shopify "collections" are "categories" in E-Series. Shopify "options" (Size, Color) are also "options" in E-Series. What Shopify calls a "variant" (a specific Size + Color combo) is called a "combination" or "variation" in E-Series. Same thing, different label.

Most fields transfer cleanly: name, description, price, images, SKU, weight. The things that don't transfer automatically: metafields, custom attributes, and anything tied to a Shopify-specific app.

If your X-Series POS catalog is already clean, the easier path is to skip the Shopify-to-E-Series migration and sync directly from POS. That's the right move for merchants whose POS is already the source of truth.

### Customer data

Shopify stores customer email, name, address, and order history. E-Series stores the same fields, except order history, which stays in Shopify. You can export the customer list and import it, but old orders don't come along. Pick a clean break date and archive your Shopify exports before canceling.

### URLs: where the SEO risk lives

This is the part that catches people out. Shopify and E-Series use completely different URL structures, and every URL that changes is a potential SEO problem.

**Shopify URL structure:**
```
yourdomain.com/products/red-canvas-sneakers
yourdomain.com/collections/footwear
yourdomain.com/pages/about-us
```

**E-Series URL structure:**
```
yourdomain.com/store/Red-Canvas-Sneakers-p12345678
yourdomain.com/store/Footwear-c87654321
```

The exact path prefix (`/store/`, `/products/`, or the domain root) depends on where the Ecwid widget sits on your site and which URL mode is on. E-Series has a few formats: the legacy hashbang (`/#!/product-name/p/123456`), Clean Store URLs (no hashbang, no ID), and Clean URLs plus Custom Page Slugs (fully custom slugs). Instant Site stores default to clean URLs without IDs. Whichever one your store ends up on, the pattern is regular enough that a bulk redirect rule can handle it.

Every product and category URL changes. If Google has your Shopify URLs in its index (and for an established store, it does), those pages are carrying years of rankings, backlinks, and traffic. Without redirects, that equity goes to zero. Google sees the new E-Series URLs as fresh pages with no history, and your old Shopify URLs return 404s.

Redirects from the old URLs to their new equivalents aren't optional. Skip them and your organic traffic won't recover.

---

## Pre-migration checklist

Before you touch either platform:

**Catalog audit**
- Export your Shopify product catalog (Products > Export).
- Flag products that use Shopify-specific metafields or app data you'll need to recreate by hand.
- Decide: migrate from Shopify, or sync from your X-Series POS?

**SEO baseline**
- Pull organic traffic by URL from Google Search Console (Performance > Pages).
- Export the full URL list. These are the pages that need redirects.
- Mark the pages with significant traffic or backlinks. They're your priority.

**URL mapping**
- List every Shopify product and category URL with its intended E-Series equivalent.
- The E-Series product ID (`-p12345678`) doesn't exist until you create the product in E-Series, so you finish the mapping after catalog migration, before go-live.

**Timing**
- Schedule go-live for a quiet period. A weekday evening is fine. The week before a seasonal peak is not.
- Tell your team when the maintenance window is so support is ready for questions.

---

## Step 1: set up your E-Series store

Activate E-Series from your Lightspeed Retail dashboard. If you're connecting it to an existing website (WordPress, Squarespace, Wix, or something else), install the E-Series plugin or widget there. If you want to use the Lightspeed-hosted E-Series storefront, point your domain at it.

Run through the usual setup: store name, currency, tax settings, shipping zones. Connect your X-Series POS catalog if you're syncing from there, or set the catalog up manually if you're migrating from Shopify.

Keep Shopify live during all of this. Don't cancel it or take it offline until redirects are in place and tested.

---

## Step 2: migrate your product catalog

Syncing from X-Series POS: turn on catalog sync, let E-Series pull your products in, then review variants, images, and descriptions and fill in whatever didn't come through.

Migrating from Shopify directly: use a migration tool or import your Shopify CSV export. E-Series accepts CSV for products. Map the Shopify columns to E-Series fields. You'll almost certainly need to clean the CSV by hand for categories, options, and anything that doesn't translate cleanly.

Once products are created in E-Series, write down the IDs. You need them for the URL mapping. A product URL in E-Series looks like `/Red-Canvas-Sneakers-p12345678`; the number at the end is the E-Series product ID, and it's visible in the admin URL when you open the product.

---

## Step 3: build your redirect map

With your Shopify URLs (from the pre-migration export) and your E-Series URLs (from the new catalog), put together a mapping spreadsheet:

| Old Shopify URL | New E-Series URL |
|---|---|
| /products/red-canvas-sneakers | /store/Red-Canvas-Sneakers-p12345678 |
| /products/blue-running-shoes | /store/Blue-Running-Shoes-p87654321 |
| /collections/footwear | /store/Footwear-c11223344 |
| /collections/new-arrivals | /store/New-Arrivals-c55667788 |

Start with your highest-traffic pages from Google Search Console. Then category pages. Then individual products. With a large catalog, look for patterns. If the whole `/products/` path maps to `/store/`, one wildcard rule covers the lot instead of hundreds of one-off entries.

---

## Step 4: implement redirects

How you implement the redirects depends on how the E-Series store is hosted.

### If you're using the Lightspeed-hosted E-Series storefront

Point your domain at E-Series, then set up redirects at the server or CDN layer. The reliable options:

- **Your domain registrar or CDN.** Cloudflare, Fastly, and most others let you define redirect rules in the dashboard without server access. Redirect `/products/*` to the matching E-Series path.
- **`.htaccess`, if you have server access.** Standard Apache redirect syntax handles bulk redirects fine.
- **Lightspeed's built-in redirect manager (Instant Site only).** If your storefront is an E-Series Instant Site, the admin has a redirect manager for individual URL redirects. It's specific to Instant Site. It doesn't apply to embedded setups on external websites.

These are server-side redirects, so they return real HTTP 301s, which is the strongest SEO signal for permanently moved content.

### If you're embedding E-Series in your existing website (WordPress, Squarespace, Wix, or custom)

When E-Series runs as an embedded widget, your host's server handles the outer site but the Ecwid storefront is a single-page application. Redirects for Ecwid store paths have to happen at the storefront level; the server doesn't see individual product URLs the way it sees normal pages.

For embedded stores, [Redirect & 404 Manager](https://apps.ecwid.com/app/seo-redirect-manager) on the Ecwid App Market handles this. It drops a small script into your E-Series storefront that processes redirect rules client-side, supports clean and hash-based URLs, and lets you manage rules from the E-Series admin without touching your site's code.

Honest caveat: the app uses JavaScript redirects, not server-side 301s. Google does follow JavaScript redirects and does transfer link equity, but a JS redirect isn't the same HTTP status as a 301. For embedded Ecwid stores where you don't control the server at the storefront level, JavaScript redirects are the only practical option, and they work in practice.

You can import your whole redirect mapping from a CSV, which is what makes a large Shopify catalog tractable. The app also detects 404s passively after go-live, so you can catch anything you missed.

---

## Step 5: go live

When your catalog is set up and the redirects are tested:

1. Point your domain at the new E-Series storefront. Update DNS if you're switching to the hosted storefront; if you're embedding the widget, make sure it's live on your existing site.
2. Visit a handful of old Shopify URLs and check they forward to the right E-Series pages.
3. Update your XML sitemap with E-Series URLs and submit it to Google Search Console.
4. If your domain changed or the store moved significantly, use Google Search Console's **Change of Address tool** to tell Google about it.
5. Update links on your social profiles, email signatures, and any external listings that still point at old URLs.

---

## Step 6: post-migration monitoring

The week after go-live is when problems show up. Watch:

**Google Search Console.** Check Coverage and Performance daily for the first two weeks. 404 errors spiking means the redirect mapping has gaps. Patch them as you find them.

**Your 404 log.** On embedded E-Series setups with Redirect & 404 Manager, the app's 404 log shows broken URLs with hit counts and referrers. Sort by hit count and fix the worst offenders first.

**Organic traffic.** A temporary dip is normal; Google needs time to recrawl and reindex. If traffic hasn't come back inside 4-6 weeks, check Search Console for indexing issues or missing redirects.

**Cancel Shopify.** Only once traffic is stable and the critical redirects are working. Archive your Shopify data rather than deleting it. You'll want access to the historical orders and customer records later.

---

## Common mistakes

**Migrating before redirects are ready.** If you go live without redirects, Google indexes the new URLs while discovering the old ones now 404. The damage is immediate and takes weeks to recover from. Get redirects in place before the domain switch.

**Forgetting category pages.** Most merchants map product pages and forget collection/category URLs. Those often carry a lot of link equity and ranking history.

**Not testing in staging.** Before pointing the live domain, test the E-Series store on a staging URL. Check that the catalog looks right, checkout works, and redirects fire.

**Canceling Shopify too early.** Keep it active for at least 30 days post-migration. Use that time to confirm everything works and that you've pulled any data you still need.

---

## The short version

For an X-Series merchant on a separate Shopify store, migrating to E-Series is mostly a consolidation exercise. Catalog migration and URL redirects are the two pieces of real work. Redirects are the part merchants underestimate, and the part that decides whether your rankings survive. Build the map before go-live, pick the right implementation for your hosting setup, and watch for gaps afterwards.

Once you're on E-Series, your online store and X-Series POS share the same catalog, customers, and reporting.

---

*Redirect & 404 Manager is on the [Ecwid App Market](https://apps.ecwid.com/app/seo-redirect-manager) for merchants running E-Series as an embedded store on WordPress, Wix, Squarespace, Joomla, or a custom website.*
