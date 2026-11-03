# Vendored libraries and fonts

Kept in the repo so the app doesn't depend on a public CDN, and a file can't change under it.
To upgrade, download the new version from the source below, change the file name in `index.html`, and run `tests.html`.

| File | Version | Source | Licence |
|---|---|---|---|
| `xlsx-0.20.3.full.min.js` | SheetJS CE 0.20.3 | https://cdn.sheetjs.com/xlsx-0.20.3/package/dist/xlsx.full.min.js | Apache 2.0 |
| `jspdf-2.5.1.umd.min.js` | jsPDF 2.5.1 | https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js | MIT |
| `svg2pdf-2.2.3.umd.min.js` | svg2pdf.js 2.2.3 | https://unpkg.com/svg2pdf.js@2.2.3/dist/svg2pdf.umd.min.js | MIT |
| `fonts/Montserrat-Medium.ttf`, `fonts/Montserrat-Bold.ttf` | commit 555facf | https://github.com/JulietaUla/Montserrat (fonts/ttf) | SIL OFL 1.1, `fonts/Montserrat-OFL.txt` |
| `fonts/RobotoCondensed-500.ttf`, `fonts/RobotoCondensed-700.ttf` | Fontsource, Latin subset (2026-11-03) | https://cdn.jsdelivr.net/fontsource/fonts/roboto-condensed@latest/latin-{500,700}-normal.ttf | SIL OFL 1.1, `fonts/RobotoCondensed-OFL.txt` |

The fonts are embedded in exported PDFs. supabase-js (team working) is still imported from jsDelivr, pinned to 2.45.4, because it's an ES module that loads only when someone signs in.
