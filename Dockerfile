# pklnx.space — static single-page landing site.
#
# The site is a single HTML file with inline CSS and no build step, so the image
# is nothing but nginx plus that file. Build and run:
#
#   docker build -t pklnx-space .
#   docker run --rm --read-only --tmpfs /tmp -p 8080:8080 pklnx-space
#
# Bump the base image by changing the minor version below (patch releases are
# picked up automatically on rebuild).
FROM nginx:1.30-alpine

LABEL org.opencontainers.image.title="pklnx.space" \
      org.opencontainers.image.description="Static landing page of pklnx — infrastructure & cloud engineering" \
      org.opencontainers.image.url="https://pklnx.space/" \
      org.opencontainers.image.licenses="LicenseRef-Proprietary"

COPY docker/nginx.conf /etc/nginx/nginx.conf

# The site itself — one file. .dockerignore keeps everything else (README,
# LICENSE, workflows, git metadata) out of the web root.
COPY index.html /usr/share/nginx/html/index.html

# nginx runs unprivileged on 8080 and keeps its pid file and temp paths in /tmp,
# so the root filesystem can be mounted read-only. No chown is needed: the file
# above lands world-readable, and nothing writes below /var any more.
USER nginx

# Unprivileged port, because non-root may not bind below 1024.
# TLS and port 443 are handled by the reverse proxy in front.
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --spider http://127.0.0.1:8080/healthz || exit 1
