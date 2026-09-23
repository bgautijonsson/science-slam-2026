# Science Slam design studies

Working drafts and assets developed with Codex, brought into the talk repository on 23 September 2026. This directory is the working home for further design development. The presentation at `../index.qmd` is the existing live deck.

## Start here

- [Slide design board](slide-design-board.html): visual direction, interactive Hessian ladder and image-generation recommendations.
- [Click-through draft](science-slam-draft.html): proposed five-minute flow with speaker cues.
- [Flow and speaking notes](flow-notes.html): timing, narrative and scientific qualifications.
- [Design overview](designs/contact-sheet.png): the simplified visual sequence at a glance.

## Editable sources and assets

- `science-slam-draft.qmd`, `flow-notes.qmd`, `preview.css`: presentation and notes sources.
- `figures/`: first draft figures in PNG/SVG, plus copies of the existing poster and flood photograph.
- `designs/`: simpler slide studies in PNG/SVG, plus the contact sheet.
- `make-visuals.R`, `slide-designs.R`: figure-generation sources; run from this directory.
- `scripts/build_design_board.py`: builds the self-contained design board and its ZIP archive using relative paths.
- `scripts/package_draft.py`: original draft generator. Running it overwrites both QMD sources with its stored draft text; edit the QMD files directly for normal slide development.
- `science-slam-draft.zip`, `slide-design-assets.zip`: copies of the original downloadable packages. These are snapshots, not automatically synchronised with later edits.

The curves and Hessian patterns are illustrative, not fitted research results. See the flow notes for the scientific distinctions and photograph credit. The later suggestion to use real place names has not yet been implemented in these studies.

## Rebuild

From this directory:

```sh
Rscript make-visuals.R
Rscript slide-designs.R
quarto render
python3 scripts/build_design_board.py
```

R packages: grid, ragg, svglite and png; the Python builders use only the standard library. Figure text uses Lato; PNGs preserve the rendered appearance, while SVG text needs the font installed. The local Quarto configuration keeps these draft renders separate from the repository's main deck render. The HTML files embed their images and presentation assets.

Original deliverables remain in `/Users/brynjolfurjonsson/Documents/Codex/2026-09-23/referenced-chatgpt-conversation-this-is-an/outputs/`. Transient checks remain in that task's `work/` folder; the two reusable builders are now included here.
