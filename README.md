# pklnx.space

Static business-card landing page for the domain `pklnx.space`. Private use only, no
commercial use, no content and no links to services.

The entire site is a single file: `index.html`.

## Hard constraint: zero external requests

The page loads **nothing** from the outside — no web fonts, no CDNs, no analytics, no
external images. That is what lets it run without a consent banner. In practice, for every
change to this file:

- CSS stays inline in `<style>`; no `@import`, no `<link rel="stylesheet">`
- no JavaScript, no `<script>` tags
- system font stacks only
- graphics only as inline SVG or CSS gradient; the favicon is a `data:` URI so the browser
  never goes looking for `/favicon.ico`
- no build step, no framework

The only `http://` in the source is `http://www.w3.org/2000/svg`, the XML namespace of the
favicon SVG. That is an identifier, not a URL that gets fetched.

## Content

The page consists of exactly three pieces of text — it is not meant to say more:

| Element  | Text                                 |
|----------|--------------------------------------|
| Wordmark | `pklnx`                              |
| Tagline  | `infrastructure & cloud engineering` |
| Footer   | `pklnx.space`                        |

The tagline appears twice in the source: visibly in `<p class="tagline">` and in
`<meta name="description">`. Change both.

## Design

Dark and reduced. The character does not come from the text but from the texture: a grid
backdrop built from two `repeating-linear-gradient` layers (no image, no request) and a
band framed by hairlines for the tagline, whose top rule carries a short steel-blue accent
tick on the left.

A single system monospace stack, no secondary typeface. Colors live as CSS custom
properties in `:root`. All dimmed text reaches roughly 6:1 contrast against the background,
comfortably above the 4.5:1 WCAG requires — in dark, reduced layouts a too-dark grey is the
easiest mistake to make.

Earlier drafts (a left-aligned terminal variant and a centred one) are no longer in the
working tree but remain reachable through the git history.

## Deployment

Two options. Both serve the same file.

### Without a container

Drop `index.html` into the document root of any web server. That is all.

### As a container

The image is an `nginx:stable-alpine` with `index.html` and `nginx.conf` baked in — no
build step, no runtime, no dependencies. It serves **HTTP on port 8080 only**; TLS is
handled by the reverse proxy in front.

```
docker compose up -d
```

Or without compose:

```
docker build -t pklnx-space .
docker run -d --name pklnx-space -p 127.0.0.1:8080:8080 pklnx-space
```

Prebuilt images are published on every push to the default branch as
`ghcr.io/pklnx/hermes:latest` (amd64 and arm64), built by
`.github/workflows/docker.yml`:

```
docker pull ghcr.io/pklnx/hermes:latest
```

A few decisions that need explaining in operation:

- **Port 8080, not 80.** The container runs as non-root (`USER nginx`), and unprivileged
  processes may not bind ports below 1024. Everything writable (pid, temp files) therefore
  lives under `/tmp`.
- **Bound to `127.0.0.1`.** The container is reachable on the loopback interface only; the
  reverse proxy on the host forwards to it. Without that binding it would sit on the public
  interface and TLS termination could be bypassed.
- **`read_only: true`** in the compose file, with `tmpfs` for `/tmp` and `/var/cache/nginx`.
  If that ever causes trouble, it is the first line to drop.
- **Health check against `/`.** With a single file, the page itself is the most meaningful
  endpoint; a separate `/healthz` would test something nobody ever requests.

Before publishing, CI builds the image, starts it, and checks that it becomes healthy, runs
as `nginx` rather than root, serves `index.html` byte-for-byte, sends the CSP, and answers
everything except `/` with a 404. A broken image never reaches the registry.

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

`nginx.conf` sets a CSP that pins down what the page already does:

```
default-src 'none'; style-src 'unsafe-inline'; img-src data:;
base-uri 'none'; form-action 'none'; frame-ancestors 'none'
```

This is not decoration but the enforcement of the rule at the top: the moment somebody adds
an external resource, the browser blocks it instead of quietly loading it. `style-src
'unsafe-inline'` is required because the CSS sits inline in `<style>`; `img-src data:`
covers the favicon. Scripts are forbidden entirely — inline ones too.

If you extend the page and see a CSP violation in the browser console, you broke the
consent-free operation, you did not misconfigure the CSP.
