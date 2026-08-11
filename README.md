# pklnx.space

Statische Visitenkarten-Landingpage für die Domain `pklnx.space`. Rein privat, keine
geschäftliche Nutzung, keine Inhalte und keine Links auf Dienste.

Die gesamte Seite ist eine einzelne Datei: `index.html`.

## Harte Randbedingung: null externe Requests

Die Seite lädt **nichts** von außen — keine Webfonts, keine CDNs, kein Analytics, keine
externen Bilder. Damit kommt sie ohne Consent-Banner aus. Konkret heißt das für jede
Änderung an dieser Datei:

- CSS bleibt inline im `<style>`, kein `@import`, kein `<link rel="stylesheet">`
- kein JavaScript, keine `<script>`-Tags
- nur System-Font-Stacks
- Grafik nur als Inline-SVG oder CSS-Gradient; das Favicon ist ein `data:`-URI, damit der
  Browser gar nicht erst auf `/favicon.ico` losläuft
- kein Build-Step, kein Framework

Das einzige `http://` im Quelltext ist `http://www.w3.org/2000/svg`, der XML-Namespace des
Favicon-SVG. Das ist ein Bezeichner, keine URL, die abgerufen wird.

## Inhalt

Die Seite besteht aus genau drei Textelementen — mehr soll sie nicht sagen:

| Element  | Text                                 |
|----------|--------------------------------------|
| Wortmark | `pklnx`                              |
| Tagline  | `infrastructure & cloud engineering` |
| Footer   | `pklnx.space`                        |

Die Tagline steht zweimal im Quelltext: sichtbar im `<p class="tagline">` und in
`<meta name="description">`. Beim Ändern beide Stellen mitnehmen.

## Gestaltung

Dark und reduziert. Der Charakter kommt nicht aus dem Text, sondern aus der Textur: ein
Gitterhintergrund aus zwei `repeating-linear-gradient` (kein Bild, kein Request) und ein
von Haarlinien gefasstes Band für die Tagline, dessen obere Linie links einen kurzen
Akzent-Strich in Stahlblau trägt.

Ein einziger System-Monospace-Stack, keine Zweitschrift. Farben liegen als
CSS-Custom-Properties im `:root`. Alle gedimmten Texte erreichen rund 6:1 Kontrast gegen
den Hintergrund und damit deutlich mehr als die von WCAG geforderten 4.5:1 — bei dunklen,
reduzierten Layouts ist ein zu dunkles Grau der naheliegendste Fehler.

Frühere Entwürfe (eine linksbündige Terminal-Variante und eine zentrierte) liegen nicht
mehr im Arbeitsverzeichnis, sind aber über die Git-Historie erreichbar.

## Deployment

Zwei Wege. Beide liefern dieselbe Datei aus.

### Ohne Container

`index.html` in das Document-Root eines beliebigen Webservers legen. Sonst nichts.

### Als Container

Das Image ist ein `nginx:stable-alpine` mit `index.html` und `nginx.conf` darin — kein
Build-Schritt, keine Runtime, keine Abhängigkeiten. Es liefert **nur HTTP auf Port 8080**
aus; TLS macht der Reverse Proxy davor.

```
docker compose up -d
```

Oder ohne Compose:

```
docker build -t pklnx-space .
docker run -d --name pklnx-space -p 127.0.0.1:8080:8080 pklnx-space
```

Fertig gebaute Images liegen nach jedem Push auf den Default-Branch unter
`ghcr.io/pklnx/hermes:latest` (amd64 und arm64), gebaut von
`.github/workflows/docker.yml`:

```
docker pull ghcr.io/pklnx/hermes:latest
```

Ein paar Entscheidungen, die im Betrieb erklärungsbedürftig sind:

- **Port 8080, nicht 80.** Der Container läuft als nicht-root (`USER nginx`), und
  unprivilegierte Prozesse dürfen keine Ports unter 1024 binden. Alles Schreibbare
  (pid, Temp-Dateien) liegt deshalb unter `/tmp`.
- **Bindung auf `127.0.0.1`.** Der Container ist nur über das Loopback erreichbar; der
  Reverse Proxy auf dem Host leitet dorthin weiter. Ohne diese Bindung wäre er direkt am
  öffentlichen Interface offen und die TLS-Terminierung umgehbar.
- **`read_only: true`** im Compose-File, mit `tmpfs` für `/tmp` und `/var/cache/nginx`.
  Falls das je Probleme macht, ist es die erste Zeile, die man streicht.
- **Health-Check gegen `/`.** Bei einer einzigen Datei ist die Seite selbst der
  aussagekräftigste Endpoint; ein separates `/healthz` würde etwas prüfen, das niemand
  abruft.

### Reverse-Proxy-Beispiel

nginx auf dem Host:

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

## Content-Security-Policy

`nginx.conf` setzt eine CSP, die festschreibt, was die Seite ohnehin tut:

```
default-src 'none'; style-src 'unsafe-inline'; img-src data:;
base-uri 'none'; form-action 'none'; frame-ancestors 'none'
```

Das ist kein Beiwerk, sondern die Durchsetzung der Regel weiter oben: Sobald jemand eine
externe Ressource einbaut, blockiert der Browser sie, statt sie still zu laden. `style-src
'unsafe-inline'` ist nötig, weil das CSS inline im `<style>` steht; `img-src data:` deckt
das Favicon ab. Skripte sind komplett verboten — auch inline.

Wer die Seite erweitert und dabei eine CSP-Verletzung in der Browser-Konsole sieht, hat
die Consent-Freiheit gebrochen, nicht die CSP falsch konfiguriert.
