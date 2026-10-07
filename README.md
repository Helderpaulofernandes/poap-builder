# PoaP Builder

A browser tool for drawing a **Program of Activities and Possessions** (PoaP): a one-page summary construction program.

- Draw swimlanes, bars and milestones; drag to change dates, rows and lanes.
- Create your own milestone and bar types (shape, colours, legend name).
- Curtains: shaded date ranges across every lane for contingency, savings and allowances, with adjustable transparency and a tag showing the duration.
- Export to Excel, edit dates there, and update the drawing from the workbook (matched by ShapeID, with a preview of every change).
- Export a branded A3 landscape PDF.
- Save to a `.poap.json` file once; after that every change saves to it automatically (Edge and Chrome).

The sample programme is example data.

## Use it

Open the published page, or download `index.html` and `brand-logo.js` into the same folder and open `index.html` in Edge or Chrome.

- The first **Save** asks where to keep the file, for example a OneDrive or SharePoint-synced folder. The status in the top bar then shows when changes were last saved.
- The page opens on a start screen: continue your last programme, start a new one, open a saved file or Excel workbook, or explore the example.
- If someone else changes the file (for example through OneDrive sync), you're offered a merge of both versions.
- Firefox and Safari can't save to a file in place, so there **Save** downloads a copy each time.

Your work stays on your computer and in the folders you choose. Nothing is uploaded.
