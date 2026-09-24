# Modelling Dependence or: How I Learned to Stop Worrying and Love the Hessian (science-slam-2026)

Deck slug: `science-slam-2026`
Talk date: 2026-09-24
Modelled response: annual maximum hourly precipitation — the wettest hour of each year (author confirmed 2026-09-24).
Repo: `bgautijonsson/science-slam-2026` (public, created 2026-09-23)
Public URL: https://bggj.is/science-slam-2026/ (GitHub Pages from `main:/docs`; first build from commit `9773042`, verified live 2026-09-23: 11 slides, all images 200)

How `bggj.is/{slug}` works (verified 2026-09-23): the user site `bgautijonsson.github.io` has custom domain `bggj.is`, so GitHub serves every project repo with Pages enabled at `bggj.is/{repo}`. No proxy or redirect. To update: `quarto render && git add -A && git commit && git push`.

## Workflow status

Per [`~/talks/.claude/skills/slide-workshop/SKILL.md`](../../.claude/skills/slide-workshop/SKILL.md):

| Step                                          | Status |
| --------------------------------------------- | ------ |
| 0 — Skeleton + brand applied                  | ✓ done 2026-09-23 |
| 1 — Rough sequence                            | ✓ done 2026-09-23 |
| 2 — Conversation / framing                    | ✓ done 2026-09-23 |
| 3 — Audience artefact (4 sentences)           | ✓ done 2026-09-23 |
| 4 — Computation plan                          | ✓ done 2026-09-23 (fig 6 stylisation: author to check) |
| 5 — Slide map                                 | ✓ done 2026-09-23 |
| 6 — Render-and-check (deliberate visual pass) | ✓ done 2026-09-23 (DOM measurements; squash fixed) |
| 7 — Draft slide-by-slide                      | ✓ 2026-09-23 (Codex flow adopted; 11 states) |
| 8 — Post-talk annotated pass                  | □       |

## Design studies

`design-studies/` holds the Codex drafts and figure sources (start with `design-studies/README.md`). **Adopted into `index.qmd` on 2026-09-23** (author's choice): Codex running order, figures referenced in place from `design-studies/designs/` and `design-studies/figures/`, one visual system (paper `#f8f6f0`, ink `#20272d`, blue `#347eab` only for the added between-station links). `make-visuals.R` was moved onto that palette the same day; the current uncertainty slide pairs the hill with grey density contours; blue remains reserved for the between-station links, in both the matrix cells and the matching bridges between people groups. Re-run the R scripts in a UTF-8 locale (`LC_ALL=en_US.UTF-8`), or non-ASCII labels such as "→" render as "…".

## Audience

_From Stefanía Benónísdóttir's emails (2026-09-10, 09-18, 09-23), amended and signed off by the author 2026-09-23._

1. Open event, wider than the University of Iceland Centre for AI: many are AI-centre researchers (gradients, optimisers, latent spaces), but slammers include e.g. a political-science postdoc (author, 2026-09-23), so pitch for a general academic audience new to extreme-value statistics; head-count unknown ("participation exceeded our expectations").
2. 5 minutes, hard maximum (cut from 5–10 because of the number of slammers); no Q&A mentioned.
3. Science Slam: an informal competition where entertainment value is key; slides, props, music or stand-up all allowed; in English.
4. Gróska, Parket at Vísindagarðar, Thu 24 Sept 15:00–17:00, many slammers back to back; venue open for rehearsal 12:00–14:00.

## Framing

**Signed off 2026-09-23; structure revised the same day when the author adopted the Codex flow (see Slide map):**

Modelling data-level dependence is hard, and every road leads back to the normal distribution. We simplify with normal approximations, and the Hessian is what builds them: it measures how sharply the peak curves. The talk introduces three fictional stations (A raises the level, B the spread, C the tail), shows each station's annual maximum hourly rainfall record becoming three estimates, then links a two-parameter hill to a normal density approximation through the Hessian. A rightward camera move carries the density left and brings in a 2×2 matrix. Three clicks link conditional level and spread slices to the diagonal, then joint movement to the off-diagonal. A fourth click clears the highlight; a fifth rounds the contours on standardised axes and fades the off-diagonal entries to illustrate independence, before one fixed, bracketed 9×9 grid gains connections. Nine people in three station groups show the same progression: working alone, sharing within stations, sharing with neighbours. Symmetric cell opacity varies with illustrative magnitude, on a fixed scale across all three views. It ends over the new closing poster: "The Hessian wasn't the enemy. Assuming independence was the enemy."

Working notes (step 2):

- One thing to remember (author, 2026-09-23, draft): "Modeling data-level dependence is hard"
- Where "hard" goes (author, 2026-09-23): "It's hard and every road leads back to the normal distribution really. Max-and-smooth does a normal approximation and INLA does one as well. So we can simplify with normal approximations but that's just approximations"
- Spine (confirmed by author, 2026-09-23): the explainers are the ingredients of one normal approximation (optimisation finds the peak, the Hessian measures its curvature, precision is that curvature); the walk shows three normal approximations, each built from a different Hessian.
- Covariance (author, 2026-09-23): "only as a stepping stone to precision… Most people have an idea of covariance which might help lead into precision". Slide-map note: in the rough sequence covariance and precision are three beats apart; revisit order at step 5.
- Ending (author agreed, 2026-09-23): "…but that's just approximations" is the punchline, not a disclaimer. Strangelove's "love" is knowingly riding the thing down anyway: you know it's only a normal approximation and you ride the Hessian regardless.
- Imagery (author, 2026-09-23): "me riding the bomb (hessian)". Major Kong riding the bomb; asset to source at step 4 (edited still, or a stage prop).
- Cut (author, 2026-09-23): "We can skip how optimisation works and just give ourselves a hessian".
- **Ending changed (author, 2026-09-23, step 7 → 2 backtrack):** after reading a ChatGPT draft script, the author chose its ending, in his words: "The Hessian wasn't the enemy. Assuming independence was the enemy". Supersedes the signed-off "just an approximation, ride the Hessian anyway" punchline; closing-slide set-up still open. Author: "Don't take anything word for word" from that script.
- No software names (author, 2026-09-23): "Let's just look at three types of hessian: Diagonal hessian (inla style), block diagonal hessian (max-and-smooth), block and banded hessian (copula-extended max-and-smooth)".

## Rough sequence

Verbatim, 2026-09-23:

> Explain covariance
> Explain hessian
> Explain optimisation
> Explain precision
> Walk through the difference in Hessians going from INLA -> Max-and-Smooth -> Copula-Extended Max-and-Smooth

## Computation plan

**Current (2026-09-23, Codex flow adopted):** all slide figures are 1536×1024 compositions (the deck is 1536×1024) shown as contain-sized backgrounds on matching paper.

| Slide | File | Source | Status |
| ----- | ---- | ------ | ------ |
| opening | inline title, presenter and event label | `index.qmd`, `theme.scss` | made; neutral browser title preserves the reveal |
| poster | `Figures/bomb.jpg` | author's image (ChatGPT) | made |
| callback | `Figures/hessian-ending.png` | author-supplied `hessian_ending.png`, 2026-09-24 | copied unchanged; full image, no crop |
| Gauss interlude | `Figures/gauss.png` | author's GPT poster, supplied 2026-09-24 | made; full portrait, no crop |
| rain | `Figures/flod1.jpg` (610×406, shown at 820 px as a print) | photo Júlíus Sigurjónsson, mbl.is | copied |
| level / spread / tail | `design-studies/designs/stations-{1,2,3}.png` | `design-studies/slide-designs.R` | made (Codex) |
| stations | `design-studies/designs/station-tokens.png` | `slide-designs.R` | redesigned 2026-09-24: three illustrative annual-maximum records → nine estimates |
| uncertainty | `design-studies/designs/hessian-panorama.png` | `design-studies/hessian-hill.R` | shared camera strip plus generated inline SVG; initial view: hill + normal density |
| density + Hessian matrix | same panorama and `_hessian-panorama.qmd` SVG plus three highlight overlays | `design-studies/hessian-hill.R` | camera pans one panel right; three exclusive highlights, clear overlay, then independence morph |
| separate / within / between | `design-studies/designs/matrix-{1,2,3}.png` | `slide-designs.R` | redesigned 2026-09-24: symmetric magnitudes, brackets and matching people groups |

**Retired 2026-09-23** (kept for reference, not referenced by `index.qmd`): `R/figures.R` and `Figures/fig1`–`fig6`, `Figures/flod2.webp`: the covariance/precision/24×24 walk version (last used in commit `8ba1694`).

## Slide map

**Current (2026-09-24): observations → estimates → normal approximation → Hessian matrix**, with a shared 3D hill chosen by the author. A restrained Science Slam opening lets the author control the first poster reveal. Ending spoken over the new closing poster; the "Same storm" payoff slide remains cut. 14 slides, 19 visual states including three matrix highlights, a clear-overlay pause and the independence animation, with 248 s of suggested speaking cues within the 300 s maximum. This is a planning allocation, not a measured duration; the author plans mentally and does not want a full rehearsal. `index.qmd` holds the current notes; the older `design-studies/science-slam-draft.qmd` is a historical draft.

```
 1. opening       Science Slam introduction; hold for poster cue  ~10 s
 2. poster        Comic poster reveal; give the joke a beat        ~5 s
 3. rain          Flood photo as a print + credit                 ~20 s
 4. level         Station A: higher level                         ~10 s
 5. spread        Station B: more spread                          ~10 s
 6. tail          Station C: heavier tail                         ~10 s
 7. stations      Rainfall records → nine estimates               ~20 s
 8. gauss         Gauss poster: estimation → normal approximation ~8 s
 9. uncertainty   Hill → normal density via the Hessian            ~30 s
10. hessian-hill  Pan to density + matrix; 5 click steps           ~25 s
11. separate      Working alone (diagonal)                        ~15 s
12. within        Sharing within stations (blocks)                        ~25 s
13. between       Sharing with neighbours (blue): the research     ~45 s
14. callback      New closing poster; spoken: "The Hessian wasn't the enemy. Assuming independence was the enemy."  ~15 s
```

The earlier 8-slide map (covariance → precision → 24×24 walk) is in git at `8ba1694`.

## Iteration log

| date       | change                                                  | why                 |
| ---------- | ------------------------------------------------------- | ------------------- |
| 2026-09-23 | Skeleton scaffolded via `/new-deck`, academic brand applied | Initial scaffolding |
| 2026-09-23 | Audience drafted from the organiser's emails            | Facts known before step 1; author confirms |
| 2026-09-23 | Rough sequence captured (4 explainers + 3-stage Hessian walk) | Step 1 |
| 2026-09-23 | Optimisation beat cut; framing paragraph drafted from author's answers | Step 2 |
| 2026-09-23 | Framing: software names dropped, three Hessian types; audience widened | Author sign-off, steps 2–3 |
| 2026-09-23 | Title → "Modelling Dependence or: …"; computation plan written | Author: more inclusive, easier to digest; step 4 |
| 2026-09-23 | Figures 1–6 generated (`R/figures.R`); fig 3 key moved off the curves; opaque slide background | Step 4; visual check |
| 2026-09-23 | Slide map drafted (10 slides, ~280 s) | Step 5 |
| 2026-09-23 | Map → 7 slides (~250 s) after slide-critic; simplemenu bar off | Author took all four critic edits |
| 2026-09-23 | All 7 slides drafted; Hessian squash + rain-photo heights fixed; slide 6 notes bug fixed | Step 6 measurements; second slide-critic pass |
| 2026-09-23 | Ending → "The Hessian wasn't the enemy. Assuming independence was the enemy" | Author, after reading a ChatGPT draft |
| 2026-09-23 | Poster opener + closing callback; closing = normal line → two-click ending; slide 4 heading off; bridge cue → slide 6 | Author's answers + second slide-critic pass |
| 2026-09-23 | Adopted the Codex flow and visual system; ending spoken over the poster; payoff slide cut; make-visuals.R unified; stale docs/ figures removed | Author: "improve the aesthetic" using design-studies/ |
| 2026-09-23 | Published: public repo `bgautijonsson/science-slam-2026`, Pages from main:/docs, live at bggj.is/science-slam-2026 (build of `9773042`) | Author asked Claude to publish (overriding the user-only publish-deck rule for this deck) |
| 2026-09-24 | Added the intuitive Hessian hill before the matrix sequence, with a two-by-two grid on one click; shortened the preceding uncertainty cues | Author identified the missing definition and chose a hill; diagonal curvature and interaction now have a visual explanation |
| 2026-09-24 | Linked the hill paths to diagonal and off-diagonal matrix cells with matching symbols; changed the solid path to a Level-only slice; made the conditional-uncertainty qualifier visible | Author wanted certainty and co-movement connected directly to the matrix; overall uncertainty and joint movement use the full Hessian |
| 2026-09-24 | Simplified the Hessian slide to the hill, peak marker, parameter labels and a plain matrix reveal; removed paths, symbols and explanatory captions | Author found the slide too busy and will explain the details verbally |
| 2026-09-24 | Opening talking points: self, PhD project title and advisor; changing sub-daily precipitation and infrastructure design; illustrative hundred-year threshold becoming eighty- or fifty-year | Author supplied the opening in the slide-by-slide discussion. Follow up: station figure currently says wettest day; confirm the sub-daily duration before changing it |
| 2026-09-24 | Changed station captions to wettest hour of each year; recorded annual maximum hourly precipitation as the response; station talking points name the GEV and introduce location/level, scale/spread and shape/tail without a distribution tutorial | Author confirmed the hourly duration and the intended explanation; resolves the previous daily-label follow-up |
| 2026-09-24 | Rebuilt the three-slide bridge: rainfall records → nine estimates; hill → normal density contours via the Hessian; identical hill + two-by-two matrix. Removed the extra matrix reveal and updated talking-point notes | Author approved the paired hill/density design and humorous normal-approximation loop; keeps uncertainty in parameter space and gives each slide a distinct role |
| 2026-09-24 | Added the author's Gauss poster between the station estimates and normal approximation, as a brief full-image interlude | Author supplied a second humorous poster to connect estimation to the normal approximation; the scientific explanation stays on the following hill slide |
| 2026-09-24 | Replaced identical L/S/T tokens on the stations slide with point estimates on fixed ticked scales, with different positions at all three stations | Author wanted station-specific parameter estimates visible; schematic positions preserve higher level at A, spread at B and tail at C without adding exact numbers or uncertainty intervals |
| 2026-09-24 | Replaced the Gauss interlude with the author's improved gauss2.png poster and paper-coloured surround | Its hill, contours and restrained palette connect directly to the following normal-approximation slide |
| 2026-09-24 | Labelled maximum likelihood estimate, Hessian and uncertainty explicitly; added a schematic uphill trail from a starting point; aligned both parameter frames exactly and retained the same hill on the matrix slide | Author requested a simple estimation cue and cleaner alignment between the hill and density plot |
| 2026-09-24 | Replaced the hill on the matrix slide with the shared density; added a camera pan and three mouse/keyboard reveals for level, spread and interaction | Author wanted the density to link directly to matrix entries. Diagonal reveals use conditional slices; the full matrix determines joint widths |
| 2026-09-24 | Added two clicks after the interaction highlight: first clear the overlay, then live density contours morph into circles while off-diagonal entries fade; both live SVG and static artwork share the camera pan | Author requested independence animation with a separate click to clear the tilted overlay first. Caption names standardised axes; independence alone need not produce a circle. Forward/backward controls are native Reveal fragments |
| 2026-09-24 | Rebuilt the final three matrices with square brackets, fixed symmetric magnitude shading and nine people grouped by station; grey within-group links and blue neighbour bridges match the retained blocks | Author proposed a communication analogy. People represent estimates; independence does not require identical uncertainty, and absent A–C precision links do not rule out association through B |
| 2026-09-24 | Added a restrained Science Slam opening with the short topic title, presenter, venue and date; moved the introduction there and kept the complete poster reveal on one advance | Author wants control over comedic timing so the whole audience sees the poster together. Opening plus poster share the previous 15-second planning cue |
| 2026-09-24 | Replaced the closing callback image with the author's new hessian_ending.png; retained the spoken ending and original opening poster | Author supplied a distinct final poster. Full image retained with paper-coloured surround |
