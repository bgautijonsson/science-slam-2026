from pathlib import Path
import shutil

out = Path(__file__).resolve().parents[1]
original = out.parent / 'Figures'
for name in ['bomb.jpg', 'flod1.jpg']:
    shutil.copy2(original / name, out / 'figures' / name)

stages = [
('poster','bomb.jpg',15,'The worrying',
 'Let the poster register. Introduce your research as modelling extreme rainfall. Establish the apparently unreasonable attachment to a Hessian; do not explain the film reference. Keep the opening in your own voice.'),
('rain','flod1.jpg',20,'Why connected rainfall matters',
 'Use the flood photograph as motivation. A severe storm can affect more than one station. The question is how to represent that connection when we estimate rainfall extremes. This is a photograph of Reykjavik in 2016, not paired evidence from several stations. Photo: Julius Sigurjonsson, mbl.is; original attribution retained in the preparation notes.'),
('level','gev-1.png',10,'One station: level',
 'At each station, we describe the extremes with three numbers. The first sets their rough level. Point to the horizontal shift. The curves show distributions of annual rainfall maxima; there is no need to introduce the acronym GEV or its formula.'),
('spread','gev-2.png',10,'One station: spread',
 'The second controls how much those extremes vary. Point to the wider curve. This is variability between rainfall maxima, not uncertainty in our estimate of a parameter.'),
('tail','gev-3.png',10,'One station: tail',
 'The third controls the behaviour of the really rare extremes. Point to the shaded far tail. Move on after that sentence. These pictures are a way to recognise the three quantities, not a lesson in fitting a GEV.'),
('stations','stations.png',20,'Three stations: nine estimates',
 'Now give each of three stations the same three quantities: level, spread and tail. That is nine numbers to estimate. Point across one row, then down to the other stations. Keep this order when moving to the grid. Do not explain any matrix algebra.'),
('uncertainty','uncertainty.png',35,'Give ourselves a Hessian',
 'Now we are looking at possible parameter values, rather than possible rainfall values. A sharp peak pins an estimate down; a broad peak leaves room for doubt. The Hessian measures curvature near the peak, which helps us construct a normal approximation. With several parameters, it also records how their estimates are coupled. That information can be drawn as a grid. These are toy likelihood curves, not fitted GEV likelihoods.'),
('separate','hessian-1.png',15,'First: ignore the connections',
 'Each row and column is one of our nine quantities. Start with the simplest picture: keep uncertainty for each one, but pretend all those uncertainties are separate. Point to one diagonal entry. This is a deliberate approximation, not a claim that a three-parameter GEV naturally has a diagonal Hessian.'),
('within','hessian-2.png',25,'Then: keep links within a station',
 'But we estimate a station\'s three quantities from the same record. Different combinations can fit similar observations, so those estimates are linked. The three-by-three block keeps those links. Point to just one block, then show that the other two stations have their own. We are still treating the station records separately in the likelihood.'),
('between','hessian-3.png',45,'The research moment: links between stations',
 'Now let the rainfall records be dependent between stations. The same storm can affect several places, and the likelihood couples estimates across station boundaries. Point to one newly blue block. This is the part I work on: carrying those connections into an approximation we can compute with. Optional joke: Those extra blue squares took several years. Pause before returning to the science. These are schematic links for a three-station chain; the colours do not show numerical Hessian values.'),
('payoff','payoff.png',30,'Return to the rainfall',
 'Bring the story back to the storm. Several records can contain overlapping information about the same weather. Treating them as unrelated can misrepresent our uncertainty. The point of the extra connections is to reflect that dependence when estimating extremes. The normal approximation remains an approximation; we are making it account for more of the structure that matters. Avoid adding an unsupported claim about forecast accuracy or speed.'),
('ending','ending.png',10,'The accepted ending',
 'The Hessian wasn\'t the enemy. Assuming independence was the enemy. Pause between the two sentences. The independence here refers back to treating connected rainfall records as unrelated, rather than declaring every independence assumption wrong.'),
('callback','bomb.jpg',5,'Ride the Hessian',
 'Return to the poster. Hold it, finish, and stop. Do not introduce another scientific point.'),
]
assert sum(s[2] for s in stages) == 250
header = '''---
pagetitle: "Science Slam — three stations, nine estimates"
format:
  revealjs:
    width: 1536
    height: 1024
    margin: 0
    center: false
    controls: true
    progress: false
    slide-number: false
    transition: none
    background-transition: none
    navigation-mode: linear
    menu: false
    theme: simple
    embed-resources: true
    css: preview.css
---

'''
slides = []
for key, image, seconds, title, cue in stages:
    background = '#000000' if image == 'bomb.jpg' else '#faf9f9'
    caption = ''
    if key == 'rain':
        caption = '\n<div class="photo-credit">Reykjavík, 2016 · Photo: Júlíus Sigurjónsson, mbl.is</div>\n'
    slides.append(f'''## {{#{key} .art background-image="figures/{image}" background-size="contain" background-color="{background}"}}
{caption}
::: {{.notes}}
**{title} — {seconds} seconds.**

{cue}
:::
''')
(out / 'science-slam-draft.qmd').write_text(header+'\n'.join(slides), encoding='utf-8')
(out / 'preview.css').write_text('''.reveal .slides > section.art {padding:0; height:100%;}
.reveal .slides > section.art h2 {display:none;}
.reveal .photo-credit {position:absolute;bottom:35px;left:5%;width:90%;text-align:center;color:#182e48;background:#faf9f9;font:20px/1.4 sans-serif; padding:8px 0;}
''', encoding='utf-8')

intro = '''---
title: "Three stations, nine estimates"
subtitle: "Science Slam · visual working draft"
format:
  html:
    embed-resources: true
    toc: true
    toc-depth: 2
    theme: cosmo
    fontsize: 18px
    max-width: 980px
---

A separate draft for the five-minute talk, built around your proposed Hessian ladder. The live deck has not been edited. The poster and accepted ending are carried over from the current deck.

**One idea:** connected rainfall creates a joint estimation problem; the Hessian helps us retain those connections in a manageable local approximation.

[Open the click-through draft](science-slam-draft.html). Use the arrow keys. Speaker cues are embedded in the presentation; the same cues appear below. These are prompts for developing your delivery, not a timed script.

## Running order

| Beat | Time | Purpose |
| --- | ---: | --- |
| Poster + rain | 35 s | Establish the character and the problem |
| Level, spread, tail | 30 s | Give the three quantities an intuitive meaning |
| Three stations | 20 s | Establish the same nine quantities used in the matrix |
| Uncertainty + Hessian | 35 s | Switch explicitly from rainfall to parameter uncertainty |
| Separate / within / between | 85 s | Let the structure build; spend 45 seconds on the research step |
| Return to the storm | 30 s | Explain why the links matter |
| Ending + poster | 15 s | Finish with the accepted line and visual callback |
| **Total** | **250 s** | **50 seconds remain for pauses, laughter and transitions** |

There are 13 visual states but eight narrative beats: the three GEV panels and the three matrix patterns build with clicks. The matrix stays in the same position and keeps the same row/column ordering throughout.

## The three reveals

![](figures/ladder-overview.png){fig-alt="Three nine-by-nine schematic Hessian patterns: separate diagonal entries; three within-station blocks; then links between adjacent station blocks."}

The biggest distinction to preserve aloud: within-station links arise because we estimate three quantities from one record; between-station links here enter because rainfall records are dependent. Give that last step the most time.

## Speaking cues and visual sequence

'''
article = intro
for key, image, seconds, title, cue in stages:
    if key=='callback':
        article += f'### {title} · {seconds} seconds\n\n{cue}\n\n'
    else:
        article += f'### {title} · {seconds} seconds\n\n![](figures/{image}){{width=85% fig-alt="{title}"}}\n\n{cue}\n\n'
article += '''## Keep these details in the preparation notes

- **What the matrices represent:** schematic likelihood Hessian structure, and hence the local Gaussian approximation to the likelihood when the curvature has the appropriate definiteness. They are not measured Hessians from your research pipeline.
- **Diagonal:** deliberately drops mixed curvature. An ordinary GEV likelihood generally couples location, scale and shape; the diagonal is not the automatic result of assuming independent station records.
- **Within-station blocks:** records are treated separately in the likelihood. This does not rule out a spatial prior that links parameters between stations elsewhere in a hierarchical model.
- **Between-station blocks:** a toy chain connects A–B and B–C. A blank A–C block indicates no direct coupling in this illustration; it does not claim marginal independence. The drawing is not a geographical claim about real weather.
- **Colour:** navy retains the within-station entries, blue marks the added between-station entries, and pale grey marks zeros. Colour shows the pattern only, not sign or magnitude.
- **Curves:** the GEV panels vary one parameter at a time from a common baseline (location 45, scale 12, shape 0.1). The later narrow/broad peaks are illustrative exponential-rate relative likelihoods, not GEV fits. Their dashed curves are local normal approximations. No empirical result is asserted.
- **Technical translation:** the negative Hessian of the log likelihood at a suitable maximum gives the precision of the local normal likelihood approximation. Keep the sign convention and inversion off the stage.
- **Rehearsal cut:** if the middle runs long, shorten the peak explanation to one sentence and move on. Do not cut the transition that explains why links appear between stations.
- **Photograph:** Reykjavík, 2016, Júlíus Sigurjónsson, mbl.is; attribution copied from the existing deck. The user-provided poster is unchanged.

## Source and reuse

The PNG figures are 1536 × 1024 pixels; matching SVGs provide vector versions. `make-visuals.R` rebuilds the new figures with installed `grid`, `ragg` and `svglite`. Run it from the extracted folder, then render either `.qmd` with Quarto. The two HTML files embed their images and presentation assets.

Reference checks: [GEV parameters](https://search.r-project.org/CRAN/refmans/evd/html/gev.html), [Laplace approximation](https://mc-stan.org/docs/reference-manual/laplace.html), and [zeros in a Gaussian precision matrix](https://stephens999.github.io/fiveMinuteStats/normal_markov_chain.html).

The figures were inspected directly and text bounds checked at generation time. HTML build verification does not establish how the deck will look on the venue projector; rehearse it on the actual display.
'''
(out/'flow-notes.qmd').write_text(article,encoding='utf-8')
print(f'Wrote two Quarto sources with {len(stages)} visual states; planned seconds={sum(s[2] for s in stages)}.')
