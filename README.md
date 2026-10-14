# pklnx.space

Static business-card landing page for the domain `pklnx.space`. Private use only, no
commercial use, no services offered — it names the private services running on the domain
and nothing else.

The site is `index.html` plus the self-hosted webfonts in `fonts/`. No build step.

## Hard constraint: zero external requests

The page loads **nothing** from a third party — no web fonts from Google, no CDNs, no
analytics, no external images. That is what lets it run without a consent banner. In
practice, for every change to this file:

- CSS stays inline in `<style>`; no `@import`, no `<link rel="stylesheet">`
- no JavaScript, no `<script>` tags
- the only fonts loaded come from this origin, out of `fonts/` (see "Typeface")
- graphics only as inline SVG or CSS gradient; the favicon is a `data:` URI so the browser
  never goes looking for `/favicon.ico`
- no build step, no framework

The only `http://` in the source is `http://www.w3.org/2000/svg`, the XML namespace of the
favicon SVG. That is an identifier, not a URL that gets fetched.

## Content

The page says very little on purpose:

| Element   | Text                                            |
|-----------|-------------------------------------------------|
| Header    | logo mark · `infrastructure & cloud engineering` |
| Wordmark  | `pklnx★space` inside the space-bar bracket      |
| Tagline   | `infrastructure & cloud engineering.`           |
| Services  | `$ ls ./services` → `hermes` · `mail server` · `hermes.pklnx.space` |
| Footer    | `pklnx.space`                                   |

The tagline appears three times in the source: as the header eyebrow, visibly in
`<p class="tagline">` and in `<meta name="description">`. Change all three.

The service list names private services on the domain — it is a directory, not an offering.
That distinction is what keeps the page out of § 5 DDG's imprint duty; see "Legal".

## Design

Dark and reduced, a terminal read as a business card, in the pklnx.space brand: a
hairline-ruled header with the logo mark, the wordmark set large, and the service list
printed under an `$ ls ./services` prompt against a vertical rule.

### The logo

The wordmark is `pklnx` (Space Mono Bold), a four-pointed star standing in for the dot,
`space` (Space Mono Regular), all sitting inside the bracket of the space-bar symbol ␣:
"space" said twice, once as a word and once as a glyph. The mark — used in the header and
the favicon — is the bracket with the star alone. Both are inline SVG paths, converted from
the typeface once, so the logo renders identically before, after and without the webfont.
They are colored through two CSS classes, `.ink` and `.star`, never with hardcoded fills.
The favicon is the same mark on a dark tile, inlined as a `data:` URI.

### Tokens

Colors live as CSS custom properties in `:root`, taken from the pklnx.space design system
(dark theme): `--ground #08080a`, `--surface #111114`, `--line #2c2c31`,
`--line-soft #1a1a1e`, `--ink #f3f1ec`, `--ink-muted #a3a09a`, `--star #ff5a36`,
`--star-ink #ff7a5c`. Reuse those instead of hardcoding values. `--star` is the only accent
and appears in exactly two places: the star in the logo and the `$` sigil. Links take
`--star-ink`, its lighter text variant. All dimmed text is `--ink-muted` at 7.7:1 against
the background, comfortably above the 4.5:1 WCAG requires — the design system's fainter
grey (5.7:1) is deliberately not used here, because the page keeps every dimmed text above
5.9:1.

Nothing on the page moves. The header eyebrow is dropped below 40 rem, where tracked-out
uppercase no longer fits beside the mark and the tagline says the same thing one row below
anyway.

Earlier drafts (a centred variant, a grid-backdrop one and the JetBrains Mono version with a
blinking caret) are no longer in the working tree
but remain reachable through the git history.

## Typeface

Two faces, both served from this origin out of `fonts/` — never from
`fonts.googleapis.com`, which would hand every visitor's IP address to a third party and
cost the site its consent-free operation:

- **Space Mono** (400, 700) for everything monospaced: eyebrow, prompt, service list,
  footer.
- **IBM Plex Sans** (400) for the tagline, the one line of prose.

> Space Mono — © 2016 The Space Mono Project Authors,
> <https://github.com/googlefonts/spacemono>, licensed under the SIL Open Font License 1.1.
>
> IBM Plex Sans — © 2017 IBM Corp., Reserved Font Name "Plex",
> <https://github.com/IBM/plex>, licensed under the SIL Open Font License 1.1.

Each licence text ships with its font (`fonts/OFL-SpaceMono.txt`, `fonts/OFL-IBMPlex.txt`,
served under `/fonts/`) because the OFL requires it to travel with the files. Space Mono is
subset to Latin (~15 KB per weight). IBM Plex Sans is IBM's own Latin1 split file, unmodified
(~21 KB): its Reserved Font Name means a subset we made ourselves could not keep the name.
About 50 KB for the page in total. [`fonts/README.md`](fonts/README.md) documents the
upstream versions and the exact commands.

## Deployment

Two options. Both serve the same file.

### Without a container

Drop `index.html` **and the `fonts/` directory** into the document root of any web server.
That is all — but none of the hardening, the headers or the CSP below come with it, and a
missing `fonts/` silently falls back to the system monospace.

### As a container

The image is an `nginx:alpine` with `index.html`, `fonts/` and `docker/nginx.conf` baked in — no
build step, no runtime, no dependencies. It serves **HTTP on port 8080 only**; TLS is
handled by the reverse proxy in front. The base image is intentionally unpinned, so every
rebuild picks up the current nginx (mainline) with its security patches. A new minor can
therefore land unannounced — the smoke test below is what catches it. If a build ever needs
to be reproducible, pin the tag in the `Dockerfile` to a minor such as `nginx:1.30-alpine`.

```
docker compose up -d --build
```

Or without compose:

```
docker build -t pklnx-space .
docker run -d --name pklnx-space --read-only --tmpfs /tmp -p 127.0.0.1:8080:8080 pklnx-space
```

Prebuilt images are published on every push to the default branch as
`ghcr.io/pklnx/root:latest` (amd64 and arm64), built by
`.github/workflows/docker.yml`:

```
docker pull ghcr.io/pklnx/root:latest
```

### Keeping the container current

The page changes rarely; nginx and the Alpine packages inside the image do not.
The same workflow therefore also runs **every Monday at 04:00 UTC** and rebuilds
the unchanged commit. The image is pure `COPY` on top of an unpinned
`nginx:alpine`, so that rebuild picks up patches and new minors alike — with the
smoke test in front of it, so a base image that broke something never reaches
the registry. `pull: true` on the build steps is what makes this work at all;
without it Buildx would reuse the cached base layer.

`.github/dependabot.yml` keeps the workflow's own actions from ageing out. It
has no `docker` entry on purpose — an unpinned tag has nothing to bump. GitHub
disables scheduled workflows after 60 days without a commit; the `keepalive` job
in the same workflow re-enables it through the API on every scheduled or manual
run, which resets that clock.

Two things to know when operating this:

- **Roll back to a date tag, not a `sha-` tag.** Images are tagged `latest`,
  `<YYYYMMDD>` and `sha-<commit>`; a scheduled rebuild builds the same commit
  again and overwrites its `sha-` tag with a newer nginx, so only the date tag
  identifies one particular image over time.
- **The rebuild updates the registry, not the server.** Something on the host
  still has to `docker compose pull && docker compose up -d` — a systemd timer,
  an update watcher such as DIUN, or a manual pull. An idle rebuild is
  bit-identical on purpose (`org.opencontainers.image.created` is pinned to the
  commit date), so such a watcher only fires when the base image really moved.

A few decisions that need explaining in operation:

- **Port 8080, not 80.** The container runs as non-root (`USER nginx`), and unprivileged
  processes may not bind ports below 1024. Everything writable (pid, temp files) therefore
  lives under `/tmp`.
- **Bound to `127.0.0.1`.** The container is reachable on the loopback interface only; the
  reverse proxy on the host forwards to it. Without that binding it would sit on the public
  interface and TLS termination could be bypassed.
- **`read_only: true`** in the compose file, with a `tmpfs` for `/tmp`. Nothing else is
  written at runtime — the nginx pid file and all temp paths point below `/tmp`. If that
  ever causes trouble, it is the first line to drop.
- **Health check against `/healthz`.** A separate endpoint keeps health traffic out of the
  page's access log, and the probe stays independent of the caching rule on `/`.
- **No client IPs in the access log.** `docker/nginx.conf` uses a `privacy` log format that
  records everything except `$remote_addr`. The error log is the exception: nginx always
  stamps the client IP into it and offers no way to format that away.

Before publishing, CI builds the image, starts it with the same `--read-only --tmpfs /tmp`
hardening the compose file uses, and checks that it becomes healthy, runs as `nginx` rather
than root, serves `index.html` byte-for-byte, delivers every font weight the page asks for
byte-for-byte as `font/woff2` alongside both OFL licence texts, answers `/healthz` with a 200, sends the
CSP, and answers everything else with a 404. It also fails if a Google Fonts host reappears
in `index.html`. Pull requests run the same build and smoke test but push nothing, so a
broken image never reaches the registry.

### Reverse proxy examples

nginx on the host:

```nginx
location / {
    proxy_pass http://127.0.0.1:8080;
    proxy_set_header Host              $host;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

Caddy:

```
pklnx.space {
    reverse_proxy 127.0.0.1:8080
}
```

## Content Security Policy

`docker/nginx.conf` sets a CSP that pins down what the page already does:

```
default-src 'none'; style-src 'unsafe-inline'; img-src data:; font-src 'self';
base-uri 'none'; form-action 'none'; frame-ancestors 'none'
```

This is not decoration but the enforcement of the rule at the top: the moment somebody adds
an external resource, the browser blocks it instead of quietly loading it. `style-src
'unsafe-inline'` is required because the CSS sits inline in `<style>`; `img-src data:`
covers the favicon; `font-src 'self'` covers the self-hosted typeface — and is exactly what
a Google Fonts URL would fail against. Scripts are forbidden entirely — inline ones too.

If you extend the page and see a CSP violation in the browser console, you broke the
consent-free operation, you did not misconfigure the CSP.

## Legal

The site carries no Impressum and no privacy policy, and needs neither:

- **§ 5 DDG** binds business telemedia. The page offers nothing, sells nothing and links to
  no offering — the service list points at the domain's own private services — so the
  imprint duty does not apply to it.
- Consent-free operation rests on the zero-external-requests rule above plus the IP-free
  access log in `docker/nginx.conf`, not on a banner.

**If the page ever gains commercial content, a contact form, a service description or links
to offerings, both assumptions collapse** and an Impressum plus a privacy policy become
necessary in the same change.

## License

The site's own code and content are proprietary — see [`LICENSE`](LICENSE). The typeface in
`fonts/` is not: Space Mono and IBM Plex Sans are under the SIL Open Font License 1.1
(`fonts/OFL-SpaceMono.txt`, `fonts/OFL-IBMPlex.txt`) and keep their own terms.

Copyright (c) 2026 Patrick Klein, all rights reserved. Nothing else in this repository may
be used, copied, or redistributed without prior written permission.
