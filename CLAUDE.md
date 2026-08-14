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
  dependencies, no JavaScript.** The site is `index.html` plus the webfont in
  `fonts/`.
- Do **not** introduce bundlers, npm packages, CSS frameworks, or client-side
  JS unless explicitly requested. Keep it a zero-dependency static page.
- **Hard rule: zero external requests.** No third-party fonts, no CDNs, no
  analytics, no external images, no `<script>`. That is what lets the page run
  without a consent banner. Concretely:
  - CSS stays inline in `<style>` — no `@import`, no `<link rel="stylesheet">`
  - one typeface, **self-hosted out of `fonts/`** (see "Typeface"), with a
    system monospace stack behind it as fallback. Never a
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
fonts/              Self-hosted JetBrains Mono (3 weights) + OFL.txt + provenance README
Dockerfile          Container image: nginx + that one file (no build step)
.dockerignore       Allow-list — only index.html, fonts/ and docker/ reach the image
docker/nginx.conf   nginx config (unprivileged, security headers, IP-free access log)
docker-compose.yml  Runs the container on the server
.github/workflows/docker.yml   Builds, smoke-tests and pushes the image to GHCR (the only deploy)
.github/dependabot.yml         Keeps the workflow's actions current (see "Staying current")
README.md           Human-facing documentation of the same ground
LICENSE             Proprietary, all rights reserved
```

Design tokens live in the `:root` CSS variables in `index.html`
(`--bg #08080a`, `--fg #d9d4c8`, `--bright #f4f1ea`, `--dim #a49f97`,
`--muted #918b82`, `--accent #ff4b33`, `--rule #1c1c20`, `--rule-soft #141418`,
`--hover #0e0e12`, plus `--mono`). Reuse those variables; don't hardcode colors.

Dark and reduced by intent — a terminal read as a business card: a hairline-ruled
header, the wordmark set large with a blinking caret in signal red, and the
service list under an `$ ls ./services` prompt against a vertical rule. All
dimmed text keeps at least 5.9:1 contrast against the background — comfortably
above the 4.5:1 WCAG asks for, because a too-dark grey is the easy mistake in a
layout like this. `--muted` is the floor of that range and the one token that
carries 12 px text (eyebrow, footer, the service role), so measure it against
`--bg` before darkening it — a warmer grey that merely *looks* the same as the
one before it can land straight on the 4.5:1 line.

Two things that look optional and are not: the caret's animation is switched off
under `prefers-reduced-motion: reduce` (a blinking element is what that
preference is for), and `header, main, footer { min-width: 0 }` keeps the grid
items from widening the page past a phone viewport — without it the header
eyebrow alone produces a horizontal scrollbar. That eyebrow is hidden below
40 rem for the same reason.

Earlier drafts (a centred variant and one with a gradient grid backdrop) are out
of the working tree but reachable through the git history.

## Typeface

The page is set in **JetBrains Mono**, served from this origin out of `fonts/`.
Loading it from Google Fonts would leak every visitor's IP to a third party and
break the consent-free operation — that is why `font-src 'self'` is in the CSP.

Credit belongs in the page source and in the docs: *JetBrains Mono, © 2020 The
JetBrains Mono Project Authors (<https://www.jetbrains.com/lp/mono/>), SIL Open
Font License 1.1*. `fonts/OFL.txt` is copied into the image and served at
`/fonts/OFL.txt` because the OFL requires the licence to travel with the font —
don't drop it from the image to save two kilobytes.

Three weights only (400 body, 500 the `$` sigil, 700 wordmark), subset to Latin,
~15 KB each. `fonts/README.md` records the upstream version and the exact
`pyftsubset` command; regenerate rather than hand-edit, and re-run it if the copy
ever grows a character outside the Latin range (`→` is already covered).

## Content

The page says very little on purpose:

| Element  | Text                                                    |
|----------|---------------------------------------------------------|
| Header   | `pklnx` · eyebrow `infrastructure & cloud engineering`  |
| Wordmark | `pklnx` + blinking caret                                |
| Tagline  | `infrastructure & cloud engineering.`                   |
| Services | `$ ls ./services` → `hermes` · `mail server` · `hermes.pklnx.space` |
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
  serves the webfont and `OFL.txt`, everything else returns 404 — which is also
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

The site's own content barely changes; the software in the container does. Three
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
  Its side effect matters too: GitHub disables scheduled workflows after 60 days
  without repository activity, and those PRs are what keep the Monday run alive.
  If they ever dry up, one `workflow_dispatch` run resets the clock.

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
byte-for-byte, delivers every `jetbrains-mono-*.woff2` the page references
byte-for-byte as `font/woff2` plus `/fonts/OFL.txt`, answers `/healthz` with 200,
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
screenshots (Chromium is available). Check desktop and mobile widths, and check
`prefers-reduced-motion` if the caret animation is touched.

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
with the single exception of `fonts/`, which is JetBrains Mono under the SIL Open
Font License 1.1 and keeps its own terms (`fonts/OFL.txt`).
It is **not** open source — do not add an open-source license or public-domain
dedication, and do not reuse the code/content elsewhere without the owner's
written permission.

## Open TODOs

- Keep `README.md` and this file in sync: they document the same decisions, and
  a change to the deployment, the CSP or the content table belongs in both.
- The `LICENSE` copyright year is hardcoded ("2026") — bump it at the turn of
  the year.
