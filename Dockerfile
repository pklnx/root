# The site is a single static file — there is nothing to build.
# No multi-stage, no toolchain, just nginx and index.html.
FROM nginx:stable-alpine

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html

# nginx runs as non-root here (uid 101). These paths must belong to it;
# everything writable otherwise lives under /tmp, see nginx.conf.
RUN chown -R nginx:nginx /var/cache/nginx /usr/share/nginx/html

USER nginx

# Unprivileged port, because non-root may not bind below 1024.
# TLS and port 443 are handled by the reverse proxy in front.
EXPOSE 8080

# With a single file, the page itself is the most meaningful health endpoint —
# a separate /healthz would test something nobody ever requests.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -q --spider http://127.0.0.1:8080/ || exit 1
