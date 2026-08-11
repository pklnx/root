# Die Seite ist eine einzige statische Datei — es gibt nichts zu bauen.
# Kein Multi-Stage, keine Toolchain, nur nginx und index.html.
FROM nginx:stable-alpine

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/index.html

# nginx laeuft hier als nicht-root (uid 101). Diese Pfade muessen ihm gehoeren;
# alles Schreibbare liegt sonst unter /tmp, siehe nginx.conf.
RUN chown -R nginx:nginx /var/cache/nginx /usr/share/nginx/html

USER nginx

# Unprivilegierter Port, weil nicht-root nicht auf 80 binden darf.
# TLS und Port 443 macht der Reverse Proxy davor.
EXPOSE 8080

# Bei einer einzelnen Datei ist die Seite selbst der beste Health-Endpoint —
# ein separates /healthz wuerde etwas pruefen, das niemand abruft.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -q --spider http://127.0.0.1:8080/ || exit 1
