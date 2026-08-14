# CLAUDE.md

Guidance for AI agents (and humans) working on this repository.
Auto-loaded by Claude Code at the start of each session.

## Project

A static **single-page "business card" site** for the private domain
**`pklnx.space`** — wordmark, one-line tagline, footer. Nothing else.

The site is private, not commercial: it advertises no services, links nowhere,
and collects nothing. That is a deliberate scope, not an unfinished state — see
"Content & legal rules".

## Tech stack & constraints

- **One HTML file with inline CSS. No build step, no framework, no
  dependencies, no JavaScript.** The whole site is `index.html`.
- Do **not** introduce bundlers, npm packages, CSS frameworks, or client-side
  JS unless explicitly requested. Keep it a zero-dependency static page.
- **Hard rule: zero external requests.** No web fonts, no CDNs, no analytics,
  no external images, no `<script>`. That is what lets the page run without a
  consent banner. Concretely:
  - CSS stays inline in `<style>` — no `@import`, no `<link rel="stylesheet">`
  - system font stacks only (a single monospace stack, no secondary typeface)
  - graphics only as inline SVG or CSS gradient; the favicon is a `data:` URI,
    so the browser never goes looking for `/favicon.ico`
  - the only `http://` in the source is `http://www.w3.org/2000/svg`, the XML
    namespace of the favicon SVG — an identifier, not a URL that gets fetched
- If a font, image, or asset is ever genuinely needed, it must be **self-hosted**
  and the CSP in `docker/nginx.conf` has to be widened in the same commit.

## File structure

```
index.html          The entire site (markup + inline CSS)
Dockerfile          Container image: nginx + that one file (no build step)
.dockerignore       Allow-list — only index.html and docker/ reach the image
docker/nginx.conf   nginx config (unprivileged, security headers, IP-free access log)
docker-compose.yml  Runs the container on the server
.github/workflows/docker.yml   Builds, smoke-tests and pushes the image to GHCR (the only deploy)
README.md           Human-facing documentation of the same ground
LICENSE             Proprietary, all rights reserved
```

Design tokens live in the `:root` CSS variables in `index.html`
(`--bg #0a0a0c`, `--fg #e6e7ea`, `--muted #8a8f98`, `--accent #7f9cc0`,
`--rule #1c1d22`). Reuse those variables; don't hardcode colors.

Dark and reduced by intent. The character comes from the texture, not the copy:
a grid backdrop from two `repeating-linear-gradient` layers (no image, no
request) and a hairline-framed band for the tagline, whose top rule carries a
short steel-blue accent tick. All dimmed text keeps roughly 6:1 contrast against
the background — comfortably above the 4.5:1 WCAG asks for, because a too-dark
grey is the easy mistake in a layout like this. Earlier drafts (a left-aligned
terminal variant and a centred one) are out of the working tree but reachable
through the git history.

## Content

The page consists of exactly three pieces of text — it is not meant to say more:

| Element  | Text                                 |
|----------|--------------------------------------|
| Wordmark | `pklnx`                              |
| Tagline  | `infrastructure & cloud engineering` |
| Footer   | `pklnx.space`                        |

The tagline appears **twice** in the source: visibly in `<p class="tagline">`
and in `<meta name="description">`. Change both.

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
no links out. That is why it carries **no Impressum and no
Datenschutzerklärung**, and why it needs no consent banner:

- The imprint duty of **§ 5 DDG** applies to business telemedia. As long as the
  page stays a pure name plate with no commercial offering, it does not apply.
- Consent-free operation rests on the zero-external-requests rule above plus the
  IP-free access log in `docker/nginx.conf` — not on a banner.

**If the page ever gains commercial content, a contact form, a service
description, or links to offerings, both assumptions collapse:** an Impressum
per § 5 DDG and a privacy policy become necessary in the same change. Don't add
such content silently.

## Hosting & deployment

**The container image is the only deploy path.** Every push to `main` builds,
smoke-tests and publishes it; there is no Pages deploy and no second path.

### Without a container

Dropping `index.html` into any web server's document root also works — but then
none of the hardening, headers or the CSP below come with it.

### Docker

```sh
docker compose up -d --build      # or: docker build -t pklnx-space .
curl -I http://127.0.0.1:8080/
```

- **Image:** `nginx:alpine` + `index.html` + `docker/nginx.conf`. The
  `Dockerfile` is pure `COPY`, so the nginx config is the only real logic.
- **The base image is deliberately unpinned**, so every rebuild picks up the
  current nginx mainline with its security patches. The price is that a new
  minor can land unannounced — the CI smoke test is what catches it. Pin to a
  minor (`nginx:1.30-alpine`) only if a build ever has to be reproducible.
- **Published to GHCR** by `.github/workflows/docker.yml` on every push to
  `main` (amd64 + arm64), tagged `latest` and `sha-<commit>`:
  `ghcr.io/pklnx/root:latest`. The image name is derived from
  `github.repository`, so it follows a repository rename automatically. The
  server only needs `docker compose pull && docker compose up -d`; rolling back
  means pinning a `sha-` tag. Pull requests build and smoke-test the image but
  do not push it.
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
- **There is exactly one page.** `location = /` serves `index.html`; everything
  else returns 404, which is also why no explicit dotfile deny is needed.
- Responses carry `expires 5m`. Do not add a `Cache-Control` header next to it —
  `expires` emits one itself and the response would carry two contradictory
  values.
- `add_header` is **not** inherited additively: the moment a `location` block
  sets its own `add_header`, every header from the `server` block is dropped for
  that block. That is why they all live in the `server` block.

### Content Security Policy

```
default-src 'none'; style-src 'unsafe-inline'; img-src data:;
base-uri 'none'; form-action 'none'; frame-ancestors 'none'
```

This is not decoration but the enforcement of the zero-external-requests rule:
the moment somebody adds an external resource, the browser blocks it instead of
quietly loading it. `style-src 'unsafe-inline'` is required because the CSS sits
inline; `img-src data:` covers the favicon. Scripts are forbidden entirely,
inline ones too.

A CSP violation in the browser console means the consent-free operation was
broken — not that the CSP is misconfigured.

## CI

Before publishing, CI builds the image, starts it with the same
`--read-only --tmpfs /tmp` hardening the compose file uses, and asserts that it
becomes healthy, runs as `nginx` rather than root, serves `index.html`
byte-for-byte, answers `/healthz` with 200, sends the CSP and
`X-Content-Type-Options`, and answers everything else with 404. **Any change to
`index.html`, `docker/nginx.conf` or the `Dockerfile` has to keep those
assertions true** — the byte-for-byte diff in particular means the served file
and the repo file must not drift.

## Git workflow

- Develop on a feature branch (e.g. `claude/...`), commit, push.
- Land changes through a **PR**; the owner merges. Merging to `main` publishes
  the image to GHCR.

## Local preview

No test suite. To verify, open `index.html` directly in a browser, or take
headless screenshots (Chromium is available). Check desktop and mobile widths,
and check `prefers-reduced-motion` if the intro animation is touched.

`docker compose up -d --build` serves the site the way the server will
(http://127.0.0.1:8080) — use it whenever a change could interact with the nginx
config, e.g. new asset types, caching, or anything the CSP has to allow. After
editing `docker/nginx.conf`, syntax-check it with
`nginx -t -c "$PWD/docker/nginx.conf"` if nginx is installed locally.

## License

This is **proprietary, all-rights-reserved** software/content (see `LICENSE`).
It is **not** open source — do not add an open-source license or public-domain
dedication, and do not reuse the code/content elsewhere without the owner's
written permission.

## Open TODOs

- Keep `README.md` and this file in sync: they document the same decisions, and
  a change to the deployment, the CSP or the content table belongs in both.
- The `LICENSE` copyright year is hardcoded ("2026") — bump it at the turn of
  the year.
