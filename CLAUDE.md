# CLAUDE.md

Guidance for AI agents (and humans) working on this repository.
Auto-loaded by Claude Code at the start of each session.

## Project

A static **single-page "business card" site** for the private domain
**`pklnx.space`** — wordmark, one-line tagline, a short list of the private
services running on the domain, footer. Nothing else.

The site is private, not commercial: it advertises nothing, sells nothing and
collects nothing. The service list is a directory of the owner's own hosts, not
an offering. That is a deliberate scope, not an unfinished state — see
"Content & legal rules".

## Tech stack & constraints

- **One HTML file with inline CSS. No build step, no framework, no
  dependencies, no JavaScript.** The site is `index.html` plus the webfonts in
  `fonts/`.
- Do **not** introduce bundlers, npm packages, CSS frameworks, or client-side
  JS unless explicitly requested. Keep it a zero-dependency static page.
- **Hard rule: zero external requests.** No third-party fonts, no CDNs, no
  analytics, no external images, no `<script>`. That is what lets the page run
  without a consent banner. Concretely:
  - CSS stays inline in `<style>` — no `@import`, no `<link rel="stylesheet">`
  - two typefaces, IBM Plex Mono and IBM Plex Sans, **self-hosted out of
    `fonts/`** (see "Typeface"), each with Carbon's system stack behind it as
    fallback. Never a
    `fonts.googleapis.com` link — that is the exact thing this rule exists to
    prevent, and CI fails if one reappears.
  - graphics only as inline SVG or CSS gradient; the favicon is a `data:` URI,
    so the browser never goes looking for `/favicon.ico`
  - the only `http://` in the source is `http://www.w3.org/2000/svg`, the XML
    namespace of the favicon SVG — an identifier, not a URL that gets fetched
- If a further font, image, or asset is ever genuinely needed, it must be
  **self-hosted** and the CSP in `docker/nginx.conf` has to be widened in the
  same commit.

## File structure

```
index.html          The entire site (markup + inline CSS)
fonts/              Self-hosted IBM Plex Mono (2 weights) + IBM Plex Sans (1) + OFL-IBMPlex.txt + provenance README
Dockerfile          Container image: nginx + that one file (no build step)
.dockerignore       Allow-list — only index.html, fonts/ and docker/ reach the image
docker/nginx.conf   nginx config (unprivileged, security headers, IP-free access log)
docker-compose.yml  Runs the container on the server
.github/workflows/docker.yml   Builds, smoke-tests and pushes the image to GHCR (the only deploy)
.github/dependabot.yml         Keeps the workflow's actions current (see "Staying current")
README.md           Human-facing documentation of the same ground
LICENSE             Proprietary, all rights reserved
```

**The brand is the pklnx design system** (`pklnx/design-system`): IBM Carbon v11,
G100 (dark) theme, Purple as the one accent, IBM Plex throughout. The page takes
its *look* from there (tokens, type scale, spacing, logo, the prompt style) and
nothing else: no Carbon CSS, no components, no JS, no Carbon class names. The
design system's voice ("one-person business", „Leistungen", first person, „Sie"
towards clients) is written for business copy and **does not apply here** — it
would turn this page into a business telemedium (see "Content & legal rules").

Design tokens live in the `:root` CSS variables in `index.html`, **under their
Carbon names and G100 values**, and only the ones the page uses:
`--background #161616`, `--background-hover rgba(141,141,141,.16)` (row hover),
`--border-subtle-00 #393939` (every rule), `--text-primary #f4f4f4`,
`--text-secondary #c6c6c6`, `--link-primary #be95ff`, `--link-primary-hover
#d4bbff`, `--focus #ffffff`, the brand token `--star #a56eff`, Carbon's
`--spacing-*` steps and the `--font-mono`/`--font-sans` stacks. Reuse those
variables; don't hardcode colors, and take any further token from the design
system's `project/tokens.css` (same name, same value) rather than inventing one.
`--star` is the only accent and appears in exactly two places, the star in the
logo and the `$` sigil; links use `--link-primary`.

Dark and reduced by intent — a terminal read as a business card: a hairline-ruled
header with the logo mark, the wordmark set large, and the service list under an
`$ ls ./services` prompt against a vertical rule. `--text-secondary` (10.6:1) is
the only dimmed token and carries every dimmed text, the 12 px eyebrow and footer
included. Carbon's fainter `text-helper` is left out so that stays one rule.

Type follows Carbon's productive scale, set by hand in the CSS (each rule names
its style in a comment): tagline `body-02`, service name and host `code-02`,
service role `body-01`, eyebrow `label-01`, footer `code-01`. The prompt is the
design system's `prompt` style (Plex Mono SemiBold 28 px), its 20 px step below
40 rem. Per the design system: sans for language, mono for host names, commands
and the brand; sentence case, never all caps; square corners, no shadows; focus
2 px `--focus` inside; icons are Carbon icons (32 grid, filled, `currentColor`)
at 16 px next to text.

**The logo is inline SVG, not text.** The wordmark (`pklnx`, a star as the dot,
`space`, inside the bracket of the space-bar symbol ␣) and the mark (bracket +
star) are paths converted from IBM Plex Mono by the design system, so they render
the same with or without the webfont. Their fills come only from the `.ink` and
`.star` classes. Do not retype the wordmark as live text or redraw the paths by
hand; take them from the design system's `project/assets/Logos/` files
(`pklnx-wordmark-dark.svg`, `pklnx-mark-dark.svg`). The favicon is
`pklnx-favicon.svg` as a `data:` URI.

One thing that looks optional and is not: `header, main, footer { min-width: 0 }`
keeps the grid items from widening the page past a phone viewport — without it
the header eyebrow alone produces a horizontal scrollbar. That eyebrow is hidden
below 40 rem, where it squeezes the mark and only repeats the tagline. Nothing on
the page animates.

Earlier drafts (a centred variant, one with a gradient grid backdrop, the
JetBrains Mono version with a blinking caret, and the Space Mono version in
orange) are out of the working tree but reachable through the git history.

## Typeface

The page is set in **IBM Plex Mono** (400: host link, footer; 600: prompt,
service name) and **IBM Plex Sans** (400: eyebrow, tagline, service role), the
design system's two faces, both served from this origin out of `fonts/`. Loading
them from Google Fonts would leak every visitor's IP to a third party and break
the consent-free operation — that is why `font-src 'self'` is in the CSP.

Credit belongs in the page source and in the docs: *IBM Plex Mono and IBM Plex
Sans, © 2017 IBM Corp., Reserved Font Name "Plex" (<https://github.com/IBM/plex>)*,
SIL Open Font License 1.1. Both families ship the same licence text, so one file,
`fonts/OFL-IBMPlex.txt`, is copied into the image and served under `/fonts/`
because the OFL requires the licence to travel with each font — don't drop it
from the image to save a few kilobytes.

**IBM Plex is not subset by us:** its Reserved Font Name "Plex" means a modified
file could not keep the name, so the page ships IBM's own `-Latin1` split files,
unmodified (~18 KB per Mono weight, ~21 KB for Sans). `fonts/README.md` records
the upstream versions and the exact commands; regenerate rather than hand-edit.
Check any copy edit against the fonts' cmaps: a character outside Latin-1 plus
common punctuation falls back to a system face. Arrows and other symbols are
inline SVG icons, not glyphs.

## Content

The page says very little on purpose:

| Element  | Text                                                    |
|----------|---------------------------------------------------------|
| Header   | logo mark · eyebrow `Infrastructure & cloud engineering` |
| Wordmark | `pklnx★space` in the space-bar bracket (inline SVG)     |
| Tagline  | `Infrastructure & cloud engineering.`                   |
| Services | `$ ls ./services` → `hermes` · `Mail server` · `hermes.pklnx.space` |
| Footer   | `pklnx.space`                                           |

The tagline appears **three times** in the source: as the header eyebrow, visibly
in `<p class="tagline">` and in `<meta name="description">`. Change all three.

The service list is a directory of the domain's own private hosts. Rows may be
added the same way, but see "Content & legal rules" before adding anything that
reads as an offering.

The page also carries `<meta name="robots" content="noindex">` — the site is
private and is not meant to show up in search results. Don't remove it without
being asked.

## Language conventions

- **Code, comments, commit messages, branch names, docs and page copy: English.**
  The `<html lang="en">` attribute matches; keep them in sync if that ever
  changes.
- Older commits are German; that is history, not a convention to continue.

## Content & legal rules

The site is **private use only** — no commercial content, no services offered,
no links to offerings. The only outbound link points at the owner's own service
on a subdomain, which is a directory entry, not an advertisement. That is why the
page carries **no Impressum and no Datenschutzerklärung**, and why it needs no
consent banner:

- The imprint duty of **§ 5 DDG** applies to business telemedia. As long as the
  page stays a pure name plate with no commercial offering, it does not apply.
  A link to a private service of one's own does not change that; a link to
  something sold or advertised would.
- Consent-free operation rests on the zero-external-requests rule above plus the
  IP-free access log in `docker/nginx.conf` — not on a banner.

**If the page ever gains commercial content, a contact form, a service
description, or links to offerings, both assumptions collapse:** an Impressum
per § 5 DDG and a privacy policy become necessary in the same change. Don't add
such content silently.

## Hosting & deployment

**The container image is the only deploy path.** Every push to `main` builds,
smoke-tests and publishes it; there is no Pages deploy and no second path. A
**weekly schedule rebuilds the unchanged commit** so the page keeps serving a
patched nginx even when nobody edits it — see "Staying current" below.

### Without a container

Dropping `index.html` **and `fonts/`** into any web server's document root also
works — but then none of the hardening, headers or the CSP below come with it,
and a missing `fonts/` degrades silently to the system monospace.

### Docker

```sh
docker compose up -d --build      # or: docker build -t pklnx-space .
curl -I http://127.0.0.1:8080/
```

- **Image:** `nginx:alpine` + `index.html` + `fonts/` + `docker/nginx.conf`. The
  `Dockerfile` is pure `COPY`, so the nginx config is the only real logic.
- **The base image is deliberately unpinned**, so every rebuild picks up the
  current nginx mainline with its security patches. The price is that a new
  minor can land unannounced — the CI smoke test is what catches it. Pin to a
  minor (`nginx:1.30-alpine`) only if a build ever has to be reproducible.
- **Published to GHCR** by `.github/workflows/docker.yml` on every push to
  `main` (amd64 + arm64), tagged `latest`, `<YYYYMMDD>` and `sha-<commit>`:
  `ghcr.io/pklnx/root:latest`. The image name is derived from
  `github.repository`, so it follows a repository rename automatically. The
  server only needs `docker compose pull && docker compose up -d`. **Roll back
  to a date tag, not a `sha-` tag:** a scheduled rebuild builds the same commit
  again and overwrites its `sha-` tag with a newer nginx, so that tag does not
  identify one particular image over time. Pull requests build and smoke-test
  the image but do not push it.
- **Unprivileged by design:** runs as the `nginx` user on port **8080**,
  read-only root filesystem, all capabilities dropped, `no-new-privileges`.
  Port 8080 rather than 80 because non-root may not bind below 1024. Everything
  writable (pid file, temp paths) lives under `/tmp`, and those temp paths must
  stay **one level** below `/tmp` — nginx creates the leaf directory at startup
  but not intermediate parents.
- **HTTP only, bound to `127.0.0.1`.** A TLS-terminating reverse proxy (Caddy,
  Traefik, nginx) in front forwards to `127.0.0.1:8080`. Without that binding
  the container would sit on the public interface and TLS termination could be
  bypassed. HSTS belongs on the proxy; there is a commented-out
  `Strict-Transport-Security` line in `docker/nginx.conf` for the case where the
  container itself terminates TLS.
- **Privacy:** the `privacy` log format deliberately omits `$remote_addr`. nginx
  always writes the client IP into *error* log entries though (404/403 at
  `error` level) — set `error_log` to `crit` if even those must go.
- **`/healthz`** answers `200 ok` for the `HEALTHCHECK` and uptime probes. A
  separate endpoint keeps health traffic out of the page's access log and out of
  the five-minute caching rule.
- **There is exactly one page.** `location = /` serves `index.html`, `^~ /fonts/`
  serves the webfonts and their `OFL-IBMPlex.txt` licence, everything else returns 404 — which is also
  why no explicit dotfile deny is needed. The fonts block spells its MIME types
  out in a `types` block, so a base image without `woff2` in `mime.types` cannot
  turn the font into an octet-stream; note that a `types` block *replaces* the
  inherited table, so nothing but `.woff2` and `.txt` belongs in that directory.
- Responses carry `expires 5m`, the fonts `expires 30d` — the font changes about
  as often as never. Do not add a `Cache-Control` header next to either —
  `expires` emits one itself and the response would carry two contradictory
  values. `expires` is not `add_header`, so the security headers survive it.
- `add_header` is **not** inherited additively: the moment a `location` block
  sets its own `add_header`, every header from the `server` block is dropped for
  that block. That is why they all live in the `server` block.

### Staying current

The site's own content barely changes; the software in the container does. Four
pieces keep that from rotting, and they only work together:

- **`schedule: '0 4 * * 1'`** in `.github/workflows/docker.yml` rebuilds the
  unchanged commit every Monday. Because the base tag is unpinned, that picks up
  nginx patches *and* new minors — and the smoke test runs first, so a base
  image that broke something never reaches the registry.
- **`pull: true`** on both build steps. Without it Buildx reuses the cached base
  layer and the schedule accomplishes nothing. Both steps need it: otherwise CI
  would smoke-test a cached base and publish a freshly pulled one.
- **`.github/dependabot.yml`** keeps the workflow's own actions from ageing out.
  There is no `docker` entry on purpose — an unpinned tag has nothing to bump.
- **The `keepalive` job** in `docker.yml` stops GitHub from disabling the
  schedule after 60 days without a commit. Unmerged Dependabot PRs do not
  count, so it re-enables the workflow through the API on every scheduled or
  manual run, which resets that clock. It needs `actions: write`, granted to
  that job only. If the schedule ever is disabled anyway,
  *Actions → the workflow → Enable workflow* revives it.

Two consequences worth remembering:

- `org.opencontainers.image.created` is pinned to the **commit** date rather
  than the build time, so an idle rebuild is bit-identical and does not change
  the manifest digest. That is what lets an update watcher (DIUN and friends)
  treat a notification as "the base image actually moved". Don't let
  `metadata-action` stamp the build time back in.
- The rebuild updates the registry, **not the server**. Something on the host
  still has to run `docker compose pull && docker compose up -d` — a systemd
  timer, DIUN, or a manual pull.

### Content Security Policy

```
default-src 'none'; style-src 'unsafe-inline'; img-src data:; font-src 'self';
base-uri 'none'; form-action 'none'; frame-ancestors 'none'
```

This is not decoration but the enforcement of the zero-external-requests rule:
the moment somebody adds an external resource, the browser blocks it instead of
quietly loading it. `style-src 'unsafe-inline'` is required because the CSS sits
inline; `img-src data:` covers the favicon; `font-src 'self'` covers the
self-hosted typeface — and blocks a `fonts.gstatic.com` URL, which is the whole
point of that directive here. Scripts are forbidden entirely, inline ones too.

A CSP violation in the browser console means the consent-free operation was
broken — not that the CSP is misconfigured.

## CI

Before publishing, CI builds the image, starts it with the same
`--read-only --tmpfs /tmp` hardening the compose file uses, and asserts that it
becomes healthy, runs as `nginx` rather than root, serves `index.html`
byte-for-byte, delivers every `/fonts/*.woff2` the page references
byte-for-byte as `font/woff2` plus the `OFL-IBMPlex.txt` licence, answers `/healthz` with 200,
sends the CSP (including `font-src 'self'`) and `X-Content-Type-Options`, and
answers everything else with 404. It also greps `index.html` for a Google Fonts
host and fails if one is back. **Any change to `index.html`, `fonts/`,
`docker/nginx.conf` or the `Dockerfile` has to keep those assertions true** — the
byte-for-byte diffs in particular mean the served files and the repo files must
not drift.

## Git workflow

- Develop on a feature branch (e.g. `claude/...`), commit, push.
- Land changes through a **PR**; the owner merges. Merging to `main` publishes
  the image to GHCR.

## Local preview

No test suite. Opening `index.html` from the filesystem works, but the font is
referenced by absolute path (`/fonts/…`) and will not load that way — serve the
directory instead, e.g. `python3 -m http.server 8099`, and take headless
screenshots (Chromium is available). Check desktop and mobile widths.

Headless Chromium's `--window-size` enforces a minimum viewport of about 500 px
and simply crops the screenshot below that, so a narrow render made that way is
not evidence about phone layout. Drive a real 390 px viewport through Playwright
(`node_modules` is not needed, the global install has it) and assert
`document.documentElement.scrollWidth === clientWidth` if the layout changed.

`docker compose up -d --build` serves the site the way the server will
(http://127.0.0.1:8080) — use it whenever a change could interact with the nginx
config, e.g. new asset types, caching, or anything the CSP has to allow. After
editing `docker/nginx.conf`, syntax-check it with
`nginx -t -c "$PWD/docker/nginx.conf"` if nginx is installed locally.

## License

This is **proprietary, all-rights-reserved** software/content (see `LICENSE`) —
with the single exception of `fonts/`, which holds IBM Plex Mono and IBM Plex
Sans under the SIL Open Font License 1.1 and keeps their own terms
(`fonts/OFL-IBMPlex.txt`).
It is **not** open source — do not add an open-source license or public-domain
dedication, and do not reuse the code/content elsewhere without the owner's
written permission.

## Open TODOs

- Keep `README.md` and this file in sync: they document the same decisions, and
  a change to the deployment, the CSP or the content table belongs in both.
- The `LICENSE` copyright year is hardcoded ("2026") — bump it at the turn of
  the year.
