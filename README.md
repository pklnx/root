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

`index.html` in das Document-Root des Webservers legen. Sonst nichts — kein Build, keine
Runtime, keine Abhängigkeiten.
