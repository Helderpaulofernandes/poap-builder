# PoaP Builder

A browser tool for drawing a **Program of Activities and Possessions** (PoaP): a one-page summary construction program.

- Draw swimlanes, bars and milestones; drag to change dates, rows and lanes.
- Create your own milestone and bar types (shape, colours, legend name).
- Curtains: shaded date ranges across every lane for contingency, savings and allowances, with adjustable transparency and a tag showing the duration.
- Progress: set a data date, record % complete on bars (and achieved milestones), and show a baseline under each activity. The progress line runs down the sheet from the data date, bending left to activities that are behind and right to those that are ahead. **New progress update** copies the whole programme as the next revision, with its dates as the planned baseline (a narrow grey bar under each activity) and the copy's bars as the actual. The baseline can also come from another programme file or workbook (matched by ShapeID).
- Relationships and critical path: link activities by dragging the dot at a selected activity's end onto another (FS/SS/FF/SF with lags), or let **Find links automatically** propose them. Arrows show the links; the critical path (longest path, or total float within a set number of days) is outlined in red. Optionally, moving an activity pushes its successors later.
- Select several activities (Shift/Ctrl-click, or drag a box) to move, restyle, progress, link in sequence or delete them together. Press **?** for help and shortcuts.
- Summarise a P6 programme: open an XER and choose what each part of the WBS shows (a lane, one bar, its milestones, or left out), starting from a suggestion. Contingency activities become curtains, P6's critical path is outlined, and unlinked activities at the data date are flagged instead of stretching the bars. The choices are saved, so next month's XER or another scenario is summarised the same way, optionally as a separate programme with the first as its baseline.
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

## Tests

Open `tests.html` (served next to `index.html`) to run the automated checks against the real app: dates, Excel round trip, progress, critical path, links, merging, multi-select and the PDF. Run them after every change.
