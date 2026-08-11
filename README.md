# pklnx.space

Statische Visitenkarten-Landingpage für die Domain `pklnx.space`. Rein privat, keine
geschäftliche Nutzung, keine Inhalte und keine Links auf Dienste.

## Harte Randbedingung: null externe Requests

Die Seite lädt **nichts** von außen — keine Webfonts, keine CDNs, kein Analytics, keine
externen Bilder. Damit kommt sie ohne Consent-Banner aus. Konkret heißt das für jede
Änderung an diesen Dateien:

- CSS bleibt inline im `<style>`, kein `@import`, kein `<link rel="stylesheet">`
- kein JavaScript, keine `<script>`-Tags
- nur System-Font-Stacks
- Grafik nur als Inline-SVG oder CSS-Gradient; das Favicon ist ein `data:`-URI, damit der
  Browser gar nicht erst auf `/favicon.ico` losläuft
- kein Build-Step, kein Framework — jede Datei ist für sich allein lauffähig

Das einzige `http://` im Quelltext ist `http://www.w3.org/2000/svg`, der XML-Namespace des
Favicon-SVG. Das ist ein Bezeichner, keine URL, die abgerufen wird.

## Inhalt

Die Seite besteht aus genau drei Textelementen — mehr soll sie nicht sagen:

| Element  | Text                                   |
|----------|----------------------------------------|
| Wortmark | `pklnx`                                |
| Tagline  | `infrastructure & backend engineering` |
| Footer   | `pklnx.space`                          |

## Varianten

Drei Gestaltungsentwürfe, jeweils eigenständig und direkt im Browser zu öffnen. Bei so
wenig Text kommt der Unterschied nicht aus dem Inhalt, sondern aus Komposition, Typografie
und Textur:

| Datei | Träger | Stil |
|---|---|---|
| `variants/a-terminal.html` | Komposition | linksbündig, im oberen Drittel verankert, Block-Cursor als einziger Akzent, gedämpftes Grün |
| `variants/b-stele.html` | Typografie | axial zentriert, weit gesperrte Wortmarke, Gold-Haarlinie als Schlusspunkt |
| `variants/c-spec.html` | Textur | Datenblatt-Band aus Haarlinien vor einem Gitterhintergrund aus CSS-Gradienten, Stahlblau |

Die ausgewählte Variante wird als `index.html` in den Repo-Root kopiert.

## Typografie und Farbe

Ein einziger System-Monospace-Stack, keine Zweitschrift. Farben liegen als CSS-Custom-
Properties im `:root` jeder Datei. Alle gedimmten Texte (Tagline, Footer) erreichen rund
6:1 Kontrast gegen den Hintergrund und damit deutlich mehr als die von WCAG geforderten
4.5:1 — bei dunklen, reduzierten Layouts ist ein zu dunkles Grau der naheliegendste Fehler.

## Deployment

Eine einzelne statische Datei ausliefern, sonst nichts:

```
cp variants/<gewählt>.html index.html
```

Dann `index.html` in das Document-Root des Webservers legen. Kein Build, keine Runtime,
keine Abhängigkeiten.
