# Forest Valley Shared Design System

All FV apps share a common design system in the `shared/` directory, served at `/shared/` on the site. This keeps branding, layout, and UI components consistent across all app pages.

## Quick Start

Add these to your app's `<head>` (order matters):

```html
<link rel="icon" href="/shared/assets/favicon.ico">
<link rel="stylesheet" href="/shared/styles/reset.css">
<link rel="stylesheet" href="/shared/styles/variables.css">
<link rel="stylesheet" href="/shared/styles/base.css">
<link rel="stylesheet" href="/shared/components/header.css">
<link rel="stylesheet" href="/shared/components/footer.css">

<!-- Your app-specific styles AFTER the shared ones -->
<link rel="stylesheet" href="/your-app-styles.css">
```

## What's Included

### Styles

| File | URL | What it does |
|------|-----|--------------|
| `reset.css` | `/shared/styles/reset.css` | Minimal CSS reset |
| `variables.css` | `/shared/styles/variables.css` | Design tokens (colors, fonts, spacing) |
| `base.css` | `/shared/styles/base.css` | Typography, containers, buttons, cards, utilities |

### Components

| File | URL | What it does |
|------|-----|--------------|
| `header.css` | `/shared/components/header.css` | Shared header layout and styles |
| `footer.css` | `/shared/components/footer.css` | Shared footer layout and styles |

### Assets

| File | URL |
|------|-----|
| `fv-logo.png` | `/shared/assets/fv-logo.png` |
| `favicon.ico` | `/shared/assets/favicon.ico` |

## Design Tokens (`variables.css`)

Use these CSS custom properties in your app styles:

### Colors

```css
/* Primary */
--fv-green: #27ae60;
--fv-green-dark: #219a52;
--fv-green-light: #2ecc71;

/* Neutrals */
--fv-navy: #2c3e50;
--fv-navy-light: #34495e;
--fv-white: #ffffff;

/* Grays */
--fv-gray-50: #fafbfc;
--fv-gray-100: #f0f2f5;
--fv-gray-200: #e1e5ea;
--fv-gray-300: #cdd3da;
--fv-gray-400: #adb5bd;
--fv-gray-500: #6c757d;
--fv-gray-600: #495057;
--fv-gray-700: #495057;
--fv-gray-800: #343a40;

/* Status */
--fv-danger: #e74c3c;
--fv-warning: #f39c12;
--fv-info: #3498db;
```

### Typography

```css
--fv-font: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
--fv-font-mono: 'SF Mono', SFMono-Regular, Consolas, 'Liberation Mono', Menlo, monospace;

--fv-fs-xs: 0.75rem;    /* 12px */
--fv-fs-sm: 0.875rem;   /* 14px */
--fv-fs-base: 1rem;     /* 16px */
--fv-fs-lg: 1.125rem;   /* 18px */
--fv-fs-xl: 1.25rem;    /* 20px */
--fv-fs-2xl: 1.75rem;   /* 28px */
--fv-fs-3xl: 2.5rem;    /* 40px */
```

### Spacing

```css
--fv-space-xs: 4px;
--fv-space-sm: 8px;
--fv-space-md: 16px;
--fv-space-lg: 24px;
--fv-space-xl: 32px;
--fv-space-2xl: 48px;
--fv-space-3xl: 64px;
```

### Layout

```css
--fv-max-width: 1120px;
--fv-radius: 8px;
--fv-radius-sm: 4px;
--fv-radius-lg: 12px;
--fv-shadow: 0 1px 3px rgba(0, 0, 0, 0.08), 0 1px 2px rgba(0, 0, 0, 0.06);
--fv-shadow-lg: 0 10px 25px rgba(0, 0, 0, 0.1), 0 4px 10px rgba(0, 0, 0, 0.05);
--fv-transition: 0.2s ease;
```

## Utility Classes (`base.css`)

| Class | Description |
|-------|-------------|
| `.fv-container` | Centered max-width container (1120px) with horizontal padding |
| `.fv-btn` | Base button styles (inline-flex, rounded, transitions) |
| `.fv-btn-primary` | Green filled button |
| `.fv-btn-outline` | Green outlined button (fills on hover) |
| `.fv-card` | White card with rounded corners and shadow (lifts on hover) |
| `.fv-text-muted` | Gray muted text |
| `.fv-text-center` | Centered text |

## Shared Header & Footer HTML

Copy this markup into your app pages. The CSS classes are styled by `header.css` and `footer.css`.

### Header

```html
<header class="fv-header">
  <div class="fv-container">
    <a href="/" class="fv-header-brand">
      <img src="/shared/assets/fv-logo.png" alt="Forest Valley" class="fv-header-logo">
      <span class="fv-header-title">Forest Valley Apps</span>
    </a>
    <nav class="fv-header-nav">
      <a href="https://fv.dev">fv.dev</a>
    </nav>
  </div>
</header>
```

### Footer

```html
<footer class="fv-footer">
  <div class="fv-container">
    <div class="fv-footer-brand">
      <img src="/shared/assets/fv-logo.png" alt="Forest Valley">
      <span>Forest Valley</span>
    </div>
    <div class="fv-footer-links">
      <a href="https://fv.dev">fv.dev</a>
      <a href="mailto:info@fv.dev">info@fv.dev</a>
    </div>
    <div class="fv-footer-copy">
      &copy; 2025 Forest Valley. All rights reserved.
    </div>
  </div>
</footer>
```

## Full Page Template

Here's a minimal app page using all shared resources:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Your App Name — Forest Valley Apps</title>
  <link rel="icon" href="/shared/assets/favicon.ico">
  <link rel="stylesheet" href="/shared/styles/reset.css">
  <link rel="stylesheet" href="/shared/styles/variables.css">
  <link rel="stylesheet" href="/shared/styles/base.css">
  <link rel="stylesheet" href="/shared/components/header.css">
  <link rel="stylesheet" href="/shared/components/footer.css">
  <link rel="stylesheet" href="/your-app-styles.css">
</head>
<body>

  <header class="fv-header">
    <div class="fv-container">
      <a href="/" class="fv-header-brand">
        <img src="/shared/assets/fv-logo.png" alt="Forest Valley" class="fv-header-logo">
        <span class="fv-header-title">Forest Valley Apps</span>
      </a>
      <nav class="fv-header-nav">
        <a href="https://fv.dev">fv.dev</a>
      </nav>
    </div>
  </header>

  <main class="fv-container">
    <!-- Your app content here -->
  </main>

  <footer class="fv-footer">
    <div class="fv-container">
      <div class="fv-footer-brand">
        <img src="/shared/assets/fv-logo.png" alt="Forest Valley">
        <span>Forest Valley</span>
      </div>
      <div class="fv-footer-links">
        <a href="https://fv.dev">fv.dev</a>
        <a href="mailto:info@fv.dev">info@fv.dev</a>
      </div>
      <div class="fv-footer-copy">
        &copy; 2025 Forest Valley. All rights reserved.
      </div>
    </div>
  </footer>

</body>
</html>
```

## Notes

- **Same repo**: All apps and the shared styles live in one repository. Use relative paths (`/shared/...`).
- **Load order matters**: Always load `reset.css` first, then `variables.css`, then `base.css`, then components, then your app styles last.
- **No build step**: Just add `<link>` tags. No npm install, no imports, no bundler config.
- **Source**: The `shared/` directory in the project root.
