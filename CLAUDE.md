# Modelling Dependence or: How I Learned to Stop Worrying and Love the Hessian (science-slam-2026)

Deck slug: `science-slam-2026`
Talk date: 2026-09-24
Repo: not yet created (will be `bgautijonsson/science-slam-2026` when published)
Public URL: `bggj.is/science-slam-2026` (post-publish)

## Workflow status

Per [`~/talks/.claude/skills/slide-workshop/SKILL.md`](../../.claude/skills/slide-workshop/SKILL.md):

| Step                                          | Status |
| --------------------------------------------- | ------ |
| 0 — Skeleton + brand applied                  | ✓ done 2026-09-23 |
| 1 — Rough sequence                            | ✓ done 2026-09-23 |
| 2 — Conversation / framing                    | ✓ done 2026-09-23 |
| 3 — Audience artefact (4 sentences)           | ✓ done 2026-09-23 |
| 4 — Computation plan                          | ✓ done 2026-09-23 (fig 6 stylisation: author to check) |
| 5 — Slide map                                 | draft 2026-09-23 |
| 6 — Render-and-check (deliberate visual pass) | □       |
| 7 — Draft slide-by-slide                      | □       |
| 8 — Post-talk annotated pass                  | □       |

## Audience

_From Stefanía Benónísdóttir's emails (2026-09-10, 09-18, 09-23), amended and signed off by the author 2026-09-23._

1. Open event, wider than the University of Iceland Centre for AI: many are AI-centre researchers (gradients, optimisers, latent spaces), but slammers include e.g. a political-science postdoc (author, 2026-09-23), so pitch for a general academic audience new to extreme-value statistics; head-count unknown ("participation exceeded our expectations").
2. 5 minutes, hard maximum (cut from 5–10 because of the number of slammers); no Q&A mentioned.
3. Science Slam: an informal competition where entertainment value is key; slides, props, music or stand-up all allowed; in English.
4. Gróska, Parket at Vísindagarðar, Thu 24 Sept 15:00–17:00, many slammers back to back; venue open for rehearsal 12:00–14:00.

## Framing

**Signed off 2026-09-23 (author's edit: no software names; three kinds of Hessian):**

Modelling data-level dependence is hard, and every road leads back to the normal distribution. We simplify with normal approximations, and the Hessian is what builds them: it measures how sharply the peak curves, and that curvature is the precision of the normal. The talk uses covariance as a stepping stone to precision, hands the audience a Hessian without explaining the optimisation, then shows three kinds of Hessian: diagonal, block diagonal, and block and banded. It ends on the Strangelove punchline: it's just an approximation, and we ride the Hessian anyway.

Working notes (step 2):

- One thing to remember (author, 2026-09-23, draft): "Modeling data-level dependence is hard"
- Where "hard" goes (author, 2026-09-23): "It's hard and every road leads back to the normal distribution really. Max-and-smooth does a normal approximation and INLA does one as well. So we can simplify with normal approximations but that's just approximations"
- Spine (confirmed by author, 2026-09-23): the explainers are the ingredients of one normal approximation (optimisation finds the peak, the Hessian measures its curvature, precision is that curvature); the walk shows three normal approximations, each built from a different Hessian.
- Covariance (author, 2026-09-23): "only as a stepping stone to precision… Most people have an idea of covariance which might help lead into precision". Slide-map note: in the rough sequence covariance and precision are three beats apart; revisit order at step 5.
- Ending (author agreed, 2026-09-23): "…but that's just approximations" is the punchline, not a disclaimer. Strangelove's "love" is knowingly riding the thing down anyway: you know it's only a normal approximation and you ride the Hessian regardless.
- Imagery (author, 2026-09-23): "me riding the bomb (hessian)". Major Kong riding the bomb; asset to source at step 4 (edited still, or a stage prop).
- Cut (author, 2026-09-23): "We can skip how optimisation works and just give ourselves a hessian".
- No software names (author, 2026-09-23): "Let's just look at three types of hessian: Diagonal hessian (inla style), block diagonal hessian (max-and-smooth), block and banded hessian (copula-extended max-and-smooth)".

## Rough sequence

Verbatim, 2026-09-23:

> Explain covariance
> Explain hessian
> Explain optimisation
> Explain precision
> Walk through the difference in Hessians going from INLA -> Max-and-Smooth -> Copula-Extended Max-and-Smooth

## Computation plan

Decisions (author, 2026-09-23): stylised toy Hessians, not real package output; author handles the bomb imagery; open with a ~20 s rainfall hook using the February flood photos.

All generated figures come from `R/figures.R` (run from the deck root: `Rscript R/figures.R`); toy data only, nothing from the research pipeline. Palette: `#08519c` (in-band navy, nearest passing step to theme `#08306b`) + `#4292c6` (theme light blue); passes the dataviz validator on `#faf9f9`.

| # | File | Beat | Content | Status |
| - | ---- | ---- | ------- | ------ |
| 1 | `Figures/fig1-covariance.png` | covariance | "Rain here" vs "rain next door": correlated toy draws (ρ = 0.8) + ellipse | made 2026-09-23 |
| 2 | `Figures/fig2-cov-vs-prec.png` | precision | Chain of 10 sites (AR(1), ρ = 0.8): covariance dense vs precision tridiagonal, abs values | made 2026-09-23 |
| 3 | `Figures/fig3-hessian-peaks.png` | Hessian | Sharp vs flat peak (exponential-rate likelihood, n = 30 vs n = 3) with the normal fitted at the top | made 2026-09-23 |
| 4 | `Figures/fig4-hessian-diagonal.png` | walk 1 | 24×24 diagonal | made 2026-09-23 |
| 5 | `Figures/fig5-hessian-block.png` | walk 2 | 8 sites × 3 parameters: 3×3 blocks on the diagonal | made 2026-09-23 |
| 6 | `Figures/fig6-hessian-banded.png` | walk 3 | Blocks + neighbouring-site blocks (chain, as in fig 2); stylisation for author to check | made 2026-09-23 |
| 7 | — | opening + ending | Riding the bomb (Hessian) | author |
| 8 | `Figures/flod1.jpg`, `Figures/flod2.webp` | rain hook | Reykjavík 2016 (photo Júlíus Sigurjónsson, mbl.is), Siglufjörður 2024 (photo Eva Björk Benediktsdóttir, RÚV); copied from `phd/talks/talk_uniice_2026/images`, credits from its `references.bib` | copied |

## Slide map

**Draft 2026-09-23, awaiting slide-critic + author sign-off.** Target ≈ 280 s of 300 s.

```
 1. [Intro]       Title card; bomb imagery (author). The worrying.                        ~15 s
 2. [Intro]       Rain hook: flood photos. When it rains hard here, it rains hard next door. ~20 s
 3. [Dependence]  Covariance: rain here vs rain next door (fig 1)                          ~30 s
 4. [Dependence]  Precision: same chain as covariance (dense) vs precision (sparse) (fig 2) ~35 s
 5. [Hessian]     Give ourselves a Hessian: sharp vs flat peak; curvature at the top =
                  precision of the normal; the flat peak shows it's an approximation (fig 3) ~40 s
 6. [Hessian]     Hessian 1: diagonal (fig 4)                                              ~30 s
 7. [Hessian]     Hessian 2: block diagonal, each site's parameters linked (fig 5)         ~30 s
 8. [Hessian]     Hessian 3: block + banded, neighbouring sites linked through the data;
                  modelling data-level dependence is hard (fig 6)                          ~40 s
 9. [Outro]       Every road leads back to the normal distribution
                  (optional: the dependence model is itself a Gaussian copula)             ~20 s
10. [Outro]       Punchline: it's just an approximation, and we ride the Hessian anyway
                  (bomb callback to slide 1)                                               ~20 s
```

Covariance and precision are now adjacent (resolves the step-2 note).

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
