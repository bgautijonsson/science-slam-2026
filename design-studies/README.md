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
- `designs/`: fictional station reveals (`stations-1` to `stations-3`), rainfall records leading to nine point estimates on small parameter scales, bracketed Hessian ladder with matching people diagrams and symmetric illustrative magnitude shading, and contact sheet, in PNG/SVG.
- `make-visuals.R`, `slide-designs.R`: figure-generation sources; run from this directory. The final three matrices use fixed toy precision entries with strict diagonal dominance, keeping all stages positive definite; the corresponding log-likelihood Hessians have the opposite sign. Opacity is a monotone function of absolute entry size on one common scale, with exact symmetry and unchanged retained entries. These are illustrative values, not fitted GEV results. Each person represents one parameter estimate; group bridges represent the entire neighbouring-station blocks. Zero A–C precision entries mean no direct coupling, not necessarily no marginal association.
- `hessian-hill.R`: generates the live camera sequence. `designs/hessian-panorama.png` is the static 3072×1024 part of the hill → density → matrix scene; `designs/_hessian-panorama.qmd` supplies an inline SVG with the density contours and matrix cells. Both layers move together; the two slides show adjacent 1536×1024 views, moving by 54% of a slide width. The three transparent `hessian-{level,spread,interaction}.{png,svg}` overlays connect conditional slices and joint movement to matrix entries. `hessian-normal.*` and `hessian-hill.*` are static reference views. A fourth native fragment clears the highlight; a fifth continuously morphs the SVG contours to circles and fades the off-diagonal entries. The final illustration removes dependence and standardises both axes; independence alone can leave an axis-aligned ellipse. The contour probabilities remain 95%, 80%, 50% and 20%. The generator validates the log-Hessian, full inverse precision, contour intersections, monotone uphill trail, matched parameter frames, exact SVG covariance and the circular standardised endpoint. The generated partial is included in both camera slides; regenerate it with the figures rather than editing it by hand. The toy likelihood is Gaussian-shaped, so its normal approximation is exact in this illustration. `../index.qmd` supplies native Reveal auto-animation and exclusive fragments; `../hessian-interactions.html` adds mouse clicks while retaining native forward/backward keyboard behaviour. Legacy `hessian-hill-matrix.*` and `hessian-hill-preview.png` are retired reference assets. Earlier click-through drafts and ZIP files remain historical snapshots.
- `scripts/build_design_board.py`: builds the self-contained design board and its ZIP archive using relative paths.
- `scripts/package_draft.py`: current draft generator. Running it overwrites both QMD sources with its stored draft text; keep speaker-cue changes in this script when rebuilding both views together.
- `science-slam-draft.zip`, `slide-design-assets.zip`: downloadable snapshots refreshed with this revision; rebuild the packages after later changes.

The curves and Hessian patterns are illustrative, not fitted research results. See the flow notes for the scientific distinctions and photograph credit. The author chose fictional stations on 23 September 2026. Station A changes location, B changes scale, and C changes shape, each against the same reference. The rehearsal draft uses these examples and the simplified Hessian ladder.

## Rebuild

From this directory:

```sh
LC_ALL=en_US.UTF-8 Rscript make-visuals.R
LC_ALL=en_US.UTF-8 Rscript slide-designs.R
LC_ALL=en_US.UTF-8 Rscript hessian-hill.R
python3 scripts/package_draft.py
quarto render
python3 scripts/build_design_board.py
```

R packages: grid, ragg, svglite and png; the Python builders use only the standard library. Figure text uses Lato; PNGs preserve the rendered appearance, while SVG text needs the font installed. `slide-designs.R` and `hessian-hill.R` explicitly register Lato from the macOS user font directory when available and stop if Lato cannot be resolved, preventing silent font substitution. The local Quarto configuration keeps these draft renders separate from the repository's main deck render. The HTML files embed their images and presentation assets.

Original deliverables remain in `/Users/brynjolfurjonsson/Documents/Codex/2026-09-23/referenced-chatgpt-conversation-this-is-an/outputs/`. Transient checks remain in that task's `work/` folder; the two reusable builders are now included here.
