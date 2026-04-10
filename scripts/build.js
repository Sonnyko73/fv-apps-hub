const fs = require('fs');
const path = require('path');
const { minify } = require('html-minifier-terser');

const ROOT = path.resolve(__dirname, '..');
const DIST = path.join(ROOT, 'dist');

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function copyDir(src, dest) {
  ensureDir(dest);
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const srcPath = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    if (entry.isDirectory()) {
      copyDir(srcPath, destPath);
    } else {
      fs.copyFileSync(srcPath, destPath);
    }
  }
}

function minifyCSS(css) {
  return css
    .replace(/\/\*[\s\S]*?\*\//g, '')
    .replace(/\s+/g, ' ')
    .replace(/\s*([{}:;,])\s*/g, '$1')
    .replace(/;}/g, '}')
    .trim();
}

function inlineStylesheets(html) {
  return html.replace(/<link\b[^>]*rel="stylesheet"[^>]*>/g, (match) => {
    const hrefMatch = match.match(/\bhref="([^"]+)"/);
    if (!hrefMatch) return match;
    const href = hrefMatch[1];
    // Skip external URLs
    if (/^https?:\/\//.test(href)) return match;
    const cssPath = path.join(DIST, href);
    if (!fs.existsSync(cssPath)) {
      console.warn(`  WARN: CSS not found for inlining: ${href}`);
      return match;
    }
    const css = minifyCSS(fs.readFileSync(cssPath, 'utf8'));
    return `<style>${css}</style>`;
  });
}

async function build() {
  // Clean dist
  if (fs.existsSync(DIST)) {
    fs.rmSync(DIST, { recursive: true });
  }

  // Copy src → dist
  copyDir(path.join(ROOT, 'src'), DIST);

  // Copy Shared-assets-git → dist/shared (committed copy of shared design system)
  copyDir(path.join(ROOT, 'Shared-assets-git'), path.join(DIST, 'shared'));

  // Copy _redirects and _headers to dist
  for (const file of ['_redirects', '_headers']) {
    const src = path.join(ROOT, file);
    if (fs.existsSync(src)) {
      fs.copyFileSync(src, path.join(DIST, file));
    }
  }

  // Inline local stylesheets into HTML (eliminates render-blocking CSS requests)
  const htmlFilesForInlining = findFiles(DIST, '.html');
  for (const file of htmlFilesForInlining) {
    const html = fs.readFileSync(file, 'utf8');
    const inlined = inlineStylesheets(html);
    if (inlined !== html) {
      fs.writeFileSync(file, inlined);
      console.log(`  CSS inlined: ${path.relative(DIST, file)}`);
    }
  }

  // Minify HTML files
  const htmlFiles = findFiles(DIST, '.html');
  for (const file of htmlFiles) {
    const html = fs.readFileSync(file, 'utf8');
    const minified = await minify(html, {
      collapseWhitespace: true,
      removeComments: true,
      removeRedundantAttributes: true,
      removeScriptTypeAttributes: true,
      removeStyleLinkTypeAttributes: true,
      minifyCSS: true,
    });
    fs.writeFileSync(file, minified);
    console.log(`  HTML: ${path.relative(DIST, file)}`);
  }

  // Minify CSS files
  const cssFiles = findFiles(DIST, '.css');
  for (const file of cssFiles) {
    const css = fs.readFileSync(file, 'utf8');
    const minified = minifyCSS(css);
    fs.writeFileSync(file, minified);
    console.log(`  CSS:  ${path.relative(DIST, file)}`);
  }

  console.log('\nBuild complete → dist/');
}

function findFiles(dir, ext) {
  const results = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      results.push(...findFiles(full, ext));
    } else if (entry.name.endsWith(ext)) {
      results.push(full);
    }
  }
  return results;
}

build().catch((err) => {
  console.error('Build failed:', err);
  process.exit(1);
});
