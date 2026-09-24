# Modelling Dependence or: How I Learned to Stop Worrying and Love the Hessian (science-slam-2026)

Deck slug: `science-slam-2026`
Talk date: 2026-09-24
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

`design-studies/` holds the Codex drafts and figure sources (start with `design-studies/README.md`). **Adopted into `index.qmd` on 2026-09-23** (author's choice): Codex running order, figures referenced in place from `design-studies/designs/` and `design-studies/figures/`, one visual system (paper `#f8f6f0`, ink `#20272d`, blue `#347eab` only for the added between-station links). `make-visuals.R` was moved onto that palette the same day; the uncertainty slide's normal approximation is grey-dashed, not blue. Re-run the R scripts in a UTF-8 locale (`LC_ALL=en_US.UTF-8`), or non-ASCII labels such as "→" render as "…".

## Audience

_From Stefanía Benónísdóttir's emails (2026-09-10, 09-18, 09-23), amended and signed off by the author 2026-09-23._

1. Open event, wider than the University of Iceland Centre for AI: many are AI-centre researchers (gradients, optimisers, latent spaces), but slammers include e.g. a political-science postdoc (author, 2026-09-23), so pitch for a general academic audience new to extreme-value statistics; head-count unknown ("participation exceeded our expectations").
2. 5 minutes, hard maximum (cut from 5–10 because of the number of slammers); no Q&A mentioned.
3. Science Slam: an informal competition where entertainment value is key; slides, props, music or stand-up all allowed; in English.
4. Gróska, Parket at Vísindagarðar, Thu 24 Sept 15:00–17:00, many slammers back to back; venue open for rehearsal 12:00–14:00.

## Framing

**Signed off 2026-09-23; structure revised the same day when the author adopted the Codex flow (see Slide map):**

Modelling data-level dependence is hard, and every road leads back to the normal distribution. We simplify with normal approximations, and the Hessian is what builds them: it measures how sharply the peak curves. The talk introduces three fictional stations (A raises the level, B the spread, C the tail) so the audience holds nine estimates, hands them a Hessian as "how sure are we about an estimate?", defines its local curvature with a two-parameter hill and a 2×2 matrix reveal, then shows one fixed 9×9 grid gain connections: each estimate alone, within stations, between stations. It ends over the returning poster: "The Hessian wasn't the enemy. Assuming independence was the enemy."

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
| poster, callback | `Figures/bomb.jpg` | author's image (ChatGPT) | made |
| rain | `Figures/flod1.jpg` (610×406, shown at 820 px as a print) | photo Júlíus Sigurjónsson, mbl.is | copied |
| level / spread / tail | `design-studies/designs/stations-{1,2,3}.png` | `design-studies/slide-designs.R` | made (Codex) |
| stations | `design-studies/designs/station-tokens.png` | `slide-designs.R` | made (Codex) |
| uncertainty | `design-studies/figures/uncertainty.png` | `design-studies/make-visuals.R` | re-rendered 2026-09-23 on the unified palette |
| Hessian hill + matrix reveal | `design-studies/designs/hessian-hill.png`, `hessian-hill-matrix.png` | `design-studies/hessian-hill.R` | made 2026-09-24; log-Hessian checked analytically and numerically; browser alignment measured |
| separate / within / between | `design-studies/designs/matrix-{1,2,3}.png` | `slide-designs.R` | made (Codex) |

**Retired 2026-09-23** (kept for reference, not referenced by `index.qmd`): `R/figures.R` and `Figures/fig1`–`fig6`, `Figures/flod2.webp`: the covariance/precision/24×24 walk version (last used in commit `8ba1694`).

## Slide map

**Current (2026-09-24): the Codex flow plus an intuitive Hessian definition**, with a 3D hill chosen by the author. Ending spoken over the returning poster; the "Same storm" payoff slide remains cut. 12 slides, 13 visual states including the matrix reveal, with 240 s of suggested speaking cues within the 300 s maximum. This is a planning allocation, not a measured duration; the author plans mentally and does not want a full rehearsal. `index.qmd` holds the current notes; the older `design-studies/science-slam-draft.qmd` is a historical draft.

```
 1. poster        The worrying.                                   ~15 s
 2. rain          Flood photo as a print + credit                 ~20 s
 3. level         Station A: higher level                         ~10 s
 4. spread        Station B: more spread                          ~10 s
 5. tail          Station C: heavier tail                         ~10 s
 6. stations      Three stations, nine estimates                  ~20 s
 7. uncertainty   Rainfall values → uncertainty about a parameter ~20 s
 8. hessian-hill  Shape near the best fit; click for 2×2 Hessian    ~35 s
 9. separate      Each estimate (diagonal)                        ~15 s
10. within        Within stations (blocks)                        ~25 s
11. between       Between stations (blue links): the research     ~45 s
12. callback      Poster; spoken: "The Hessian wasn't the enemy. Assuming independence was the enemy."  ~15 s
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
