# Self-hosted webfont

The page sets its type in **JetBrains Mono** and serves it from this origin.
Loading it from `fonts.googleapis.com` would send every visitor's IP address to
a third party and break the site's zero-external-requests rule — and with it the
consent-free operation the whole setup rests on (see `CLAUDE.md`).

## Credit & licence

> JetBrains Mono — © 2020 The JetBrains Mono Project Authors
> <https://github.com/JetBrains/JetBrainsMono>, <https://www.jetbrains.com/lp/mono/>
> Licensed under the SIL Open Font License, Version 1.1.

`OFL.txt` is the licence text as it ships in the upstream release and is copied
into the container image next to the font files: the OFL requires the licence to
travel with the font, so it has to be part of what the server hands out, not just
of the repository. The attribution is repeated in the `@font-face` comment in
`index.html`, where anyone reading the page source will see it.

The OFL asks for no attribution notice on the page itself, and the copyright
line carries no Reserved Font Name — which is what makes the subsetting below
permissible while keeping the family name.

## What is in here

| File                       | Weight            |
|----------------------------|-------------------|
| `jetbrains-mono-400.woff2` | 400 — body text   |
| `jetbrains-mono-500.woff2` | 500 — the `$` sigil |
| `jetbrains-mono-700.woff2` | 700 — wordmark, headline |

Upstream version **2.304**, taken from the official release archive
(`fonts/webfonts/` inside `JetBrainsMono-2.304.zip`). Only the three weights the
page actually uses are shipped; italics and the remaining weights are not.

Each file is subset to Latin (roughly the Google Fonts `latin` range plus the
arrows), which takes ~93 KB per weight down to ~15 KB — about 47 KB for the page
in total.

## Reproducing the files

```sh
pip install fonttools brotli

curl -fsSLO https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip
unzip -q JetBrainsMono-2.304.zip -d jbm

RANGES="U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+0304,\
U+0308,U+0329,U+2000-206F,U+2074,U+20AC,U+2122,U+2190-2193,U+2212,U+2215,U+FEFF,U+FFFD"

for pair in Regular:400 Medium:500 Bold:700; do
  pyftsubset "jbm/fonts/webfonts/JetBrainsMono-${pair%%:*}.woff2" \
    --unicodes="$RANGES" \
    --layout-features='kern,mark,mkmk,ccmp,locl' \
    --flavor=woff2 \
    --output-file="fonts/jetbrains-mono-${pair##*:}.woff2"
done

cp jbm/OFL.txt fonts/OFL.txt
```

The character the page would miss first is the arrow `→` (U+2192) in the service
row, which is why the range list reaches into `U+2190-2193`. If the copy ever
grows a character outside the Latin range, re-run the subsetting rather than
letting the browser fall back to the system monospace for that one glyph.

Updating to a newer upstream release means re-running the block above and
checking the page at desktop and mobile width; nothing else references the
version.
