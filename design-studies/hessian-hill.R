# Paired normal-approximation and Hessian slides. Run here in a UTF-8 locale.
# A toy relative likelihood over centred, rescaled Level/Spread coordinates.
# Its log-likelihood Hessian is -Q; the precision/negative Hessian is Q.
library(grid)
library(ragg)
library(svglite)

lato_files <- file.path(path.expand("~/Library/Fonts"),
                        paste0("Lato-", c("Regular", "Bold", "Italic", "BoldItalic"), ".ttf"))
if (all(file.exists(lato_files))) {
  systemfonts::register_font("Lato", plain = lato_files[1], bold = lato_files[2],
                            italic = lato_files[3], bolditalic = lato_files[4])
}
stopifnot(grepl("Lato", basename(systemfonts::match_fonts("Lato")$path), ignore.case = TRUE))

paper <- "#f8f6f0"
ink <- "#20272d"
muted <- "#7e858b"
interaction <- "#8a9295"
drawing_width <- 1
dir.create("designs", showWarnings = FALSE)

text_at <- function(label, x, y, size = 20, colour = ink,
                    face = "plain", just = "left", rot = 0) {
  g <- textGrob(label, x, y, just = just, rot = rot,
                gp = gpar(fontfamily = "Lato", fontsize = size,
                          col = colour, fontface = face, lineheight = 1.08))
  width <- convertWidth(grobWidth(g), "npc", valueOnly = TRUE)
  height <- convertHeight(grobHeight(g), "npc", valueOnly = TRUE)
  left <- if (just == "left") x else if (just == "right") x - width else x - width / 2
  stopifnot(left >= 0, left + width <= drawing_width,
            y - height / 2 >= 0, y + height / 2 <= 1)
  grid.draw(g)
}
line_at <- function(x, y, colour = ink, width = 1.5, dash = "solid") {
  grid.lines(x, y, gp = gpar(col = colour, lwd = width, lty = dash))
}

Q <- matrix(c(2.4, -1.5, -1.5, 2.4), 2)
Sigma <- solve(Q)
log_fit <- function(x) -drop(t(x) %*% Q %*% x) / 2
fit <- function(x, y) exp(-(Q[1, 1] * x^2 + 2 * Q[1, 2] * x * y + Q[2, 2] * y^2) / 2)
# Validate the actual plotted surface against the stated Hessian.
step <- 1e-4
numeric_H <- matrix(0, 2, 2)
for (i in 1:2) for (j in 1:2) {
  ei <- diag(2)[, i] * step
  ej <- diag(2)[, j] * step
  numeric_H[i, j] <- (log_fit(ei + ej) - log_fit(ei - ej) -
                     log_fit(-ei + ej) + log_fit(-ei - ej)) / (4 * step^2)
}
stopifnot(max(abs(numeric_H + Q)) < 1e-7,
          min(eigen(Q, symmetric = TRUE)$values) > 0,
          fit(0, 0) == 1, fit(.5, .5) > fit(.5, -.5),
          max(abs(Sigma %*% Q - diag(2))) < 1e-12)

# Matched parameter frames: same extents, scale, baseline and axis directions.
# Only the hill has a height component, so its summit sits above the 2D centre.
panel_centres <- c(.255, .795)
parameter_centre_y <- .47
parameter_scale <- c(.075, .075)
parameter_limit <- 2.5
hill_height <- .19
parameter_plane <- function(x, y, centre_x) {
  cbind(x = centre_x + parameter_scale[1] * x,
        y = parameter_centre_y + parameter_scale[2] * y)
}
project <- function(x, y, z = 0) {
  p <- parameter_plane(x, y, panel_centres[1])
  p[, 2] <- p[, 2] + hill_height * z
  p
}
eig <- eigen(Q, symmetric = TRUE)
transform <- eig$vectors %*% diag(1 / sqrt(eig$values))

draw_axes <- function(centre_x) {
  corner <- parameter_plane(-parameter_limit, -parameter_limit, centre_x)
  level_end <- parameter_plane(parameter_limit, -parameter_limit, centre_x)
  spread_end <- parameter_plane(-parameter_limit, parameter_limit, centre_x)
  line_at(c(corner[1], level_end[1]), c(corner[2], level_end[2]), muted, 1.5)
  line_at(c(corner[1], spread_end[1]), c(corner[2], spread_end[2]), muted, 1.5)
  text_at("Level", centre_x, corner[2] - .055, 17, just = "centre")
  text_at("Spread", corner[1] - .025, parameter_centre_y, 17, just = "centre", rot = 90)
}

# A schematic climb, evaluated on the surface rather than drawn in image space.
trail_t <- seq(0, 1, length.out = 160)
trail_x <- -1.75 * (1 - trail_t)
trail_y <- -1.30 * (1 - trail_t) + .20 * sin(pi * trail_t)
trail_z <- fit(trail_x, trail_y)
trail <- project(trail_x, trail_y, trail_z)
stopifnot(all(diff(trail_z) >= -1e-12), tail(trail_z, 1) == 1,
          max(abs(tail(trail, 1) - project(0, 0, 1))) < 1e-12)
plane_left <- parameter_plane(c(-2.5, 0, 2.5), c(-2.5, 0, 2.5), panel_centres[1])
plane_right <- parameter_plane(c(-2.5, 0, 2.5), c(-2.5, 0, 2.5), panel_centres[2])
stopifnot(max(abs(plane_left[, 2] - plane_right[, 2])) < 1e-12,
          max(abs((plane_right[, 1] - plane_left[, 1]) - diff(panel_centres))) < 1e-12)

draw_hill <- function() {
  draw_axes(panel_centres[1])

  # Radial quadrilaterals, sorted back-to-front for an opaque shaded surface.
  radii <- seq(0, 3, length.out = 29)
  angles <- seq(0, 2 * pi, length.out = 73)
  patches <- list()
  for (i in seq_len(length(radii) - 1)) for (j in seq_len(length(angles) - 1)) {
    rr <- c(radii[i], radii[i + 1], radii[i + 1], radii[i])
    aa <- c(angles[j], angles[j], angles[j + 1], angles[j + 1])
    xy <- t(transform %*% rbind(rr * cos(aa), rr * sin(aa)))
    z <- fit(xy[, 1], xy[, 2])
    depth <- mean(xy[, 2])
    xy_mid <- colMeans(xy)
    gradient <- -fit(xy_mid[1], xy_mid[2]) * drop(Q %*% xy_mid)
    normal <- c(-gradient, 1)
    normal <- normal / sqrt(sum(normal^2))
    light <- c(-.5, -.7, 1)
    light <- light / sqrt(sum(light^2))
    shade <- .66 + .25 * max(0, sum(normal * light))
    patches[[length(patches) + 1]] <- list(p = project(xy[, 1], xy[, 2], z),
                                          depth = depth, fill = gray(shade))
  }
  for (i in order(vapply(patches, function(p) p$depth, numeric(1)), decreasing = TRUE)) {
    patch <- patches[[i]]
    grid.polygon(patch$p[, 1], patch$p[, 2],
                 gp = gpar(fill = patch$fill, col = patch$fill, lwd = .35))
  }
  line_at(trail[, 1], trail[, 2], paper, 4.5)
  line_at(trail[, 1], trail[, 2], ink, 2, "44")
  grid.circle(trail[1, 1], trail[1, 2], r = unit(3.5, "pt"),
              gp = gpar(fill = paper, col = ink, lwd = 1.5))
  text_at("Starting point", trail[1, 1] + .028, trail[1, 2] - .054, 15, just = "centre")
  peak <- project(0, 0, 1)
  grid.circle(peak[1], peak[2], r = unit(4, "pt"), gp = gpar(fill = ink, col = paper, lwd = 1.5))
  text_at("Maximum likelihood estimate", peak[1], peak[2] + .057, 17, just = "centre")
}

draw_matrix <- function(centre_x = panel_centres[2], active = NULL, labels = TRUE, cells = TRUE) {
  x <- centre_x + c(-.049, .045)
  y <- c(.59, .449)
  if (cells) for (i in 1:2) for (j in 1:2) {
    fill <- if (i == j) ink else interaction
    if (!is.null(active)) {
      selected <- (active == "level" && i == 1 && j == 1) ||
        (active == "spread" && i == 2 && j == 2) ||
        (active == "interaction" && i != j)
      fill <- if (selected) ink else "#deded8"
    }
    grid.rect(x[j], y[i], width = .086, height = .129,
              gp = gpar(fill = fill, col = if (is.null(active)) NA else fill, lwd = .6))
  }
  if (labels) for (i in 1:2) {
    text_at(c("Level", "Spread")[i], x[i], .698, 15, just = "centre")
    text_at(c("Level", "Spread")[i], centre_x - .114, y[i], 15, just = "right")
  }
}

draw_density <- function(centre_x = panel_centres[2]) {
  # The same parameter plane viewed without the likelihood height component.
  # Both panels use the same scales; covariance is the full inverse precision.
  centre <- parameter_plane(0, 0, centre_x)
  aa <- seq(0, 2 * pi, length.out = 241)
  radii <- sqrt(qchisq(c(.95, .80, .50, .20), df = 2))
  shades <- c("#eeece6", "#deded8", "#c6cac6", "#a6afad")
  for (i in seq_along(radii)) {
    xy <- t(transform %*% rbind(radii[i] * cos(aa), radii[i] * sin(aa)))
    # Each ellipse is a genuine equal-density contour of the hill.
    d2 <- rowSums((xy %*% Q) * xy)
    stopifnot(max(abs(d2 - radii[i]^2)) < 1e-10)
    p <- parameter_plane(xy[, 1], xy[, 2], centre_x)
    stopifnot(all(abs(xy) < parameter_limit))
    grid.polygon(p[, 1], p[, 2], gp = gpar(fill = shades[i], col = "#929b98", lwd = 1.1))
  }
  draw_axes(centre_x)
  grid.circle(centre[1], centre[2], r = unit(4, "pt"),
              gp = gpar(fill = ink, col = paper, lwd = 1.5))
}

draw_arrow <- function(offset = 0, label = FALSE) {
  if (label) text_at("Hessian", .50 + offset, .54, 16, just = "centre")
  grid.lines(c(.468, .535) + offset, c(.49, .49),
             arrow = arrow(length = unit(5, "pt"), type = "closed"),
             gp = gpar(col = muted, fill = muted, lwd = 1.5))
}

draw_highlight <- function(part, new_page = TRUE) {
  if (new_page) grid.newpage()
  # Intersections with one fixed density contour. These are conditional slices,
  # not the marginal standard deviations from diag(solve(Q)).
  radius <- sqrt(qchisq(.95, df = 2))
  if (part == "level") {
    ends <- cbind(c(-1, 1) * radius / sqrt(Q[1, 1]), 0)
    caption <- "Level varies; spread held fixed"
  } else if (part == "spread") {
    ends <- cbind(0, c(-1, 1) * radius / sqrt(Q[2, 2]))
    caption <- "Spread varies; level held fixed"
  } else {
    major <- which.min(eig$values)
    ends <- outer(c(-1, 1) * radius / sqrt(eig$values[major]), eig$vectors[, major])
    caption <- "Level and spread move together"
  }
  stopifnot(max(abs(rowSums((ends %*% Q) * ends) - radius^2)) < 1e-10)
  p <- parameter_plane(ends[, 1], ends[, 2], panel_centres[1])
  line_at(p[, 1], p[, 2], paper, 6)
  grid.lines(p[, 1], p[, 2],
             arrow = arrow(ends = "both", length = unit(5, "pt"), type = "closed"),
             gp = gpar(col = ink, fill = ink, lwd = 2.5))
  centre <- parameter_plane(0, 0, panel_centres[1])
  grid.circle(centre[1], centre[2], r = unit(4, "pt"),
              gp = gpar(fill = ink, col = paper, lwd = 1.5))
  draw_matrix(active = part, labels = FALSE)
  text_at(caption, .5, .105, 20, just = "centre")
}

draw_pair <- function(normal = FALSE) {
  grid.newpage()
  grid.rect(gp = gpar(fill = paper, col = NA))
  text_at(if (normal) "A normal approximation" else "The Hessian",
          .06, .92, 34, face = "bold")
  text_at(if (normal) "Fit to the data" else "Uncertainty", panel_centres[1], .79, 21, just = "centre")
  text_at(if (normal) "Uncertainty" else "Curvature near the peak",
          panel_centres[2], .79, 21, just = "centre")
  if (normal) {
    draw_hill()
    draw_arrow(label = TRUE)
    draw_density()
  } else {
    draw_density(panel_centres[1])
    draw_arrow()
    draw_matrix()
  }
}

draw_panorama <- function() {
  grid.newpage()
  grid.rect(gp = gpar(fill = paper, col = NA))
  # Keep all existing coordinates in a 1536x1024 viewport on a twice-wide page.
  pushViewport(viewport(x = 0, y = 0, just = c("left", "bottom"),
                        width = unit(1536 / 144, "inches"),
                        height = unit(1024 / 144, "inches"), clip = "off"))
  drawing_width <<- 2
  shift <- diff(panel_centres)
  text_at("Fit to the data", panel_centres[1], .79, 21, just = "centre")
  text_at("Uncertainty", panel_centres[2], .79, 21, just = "centre")
  text_at("Curvature near the peak", panel_centres[2] + shift, .79, 21, just = "centre")
  draw_hill()
  draw_arrow(label = TRUE)
  # Density and matrix cells are live SVG, above this static strip.
  draw_axes(panel_centres[2])
  draw_arrow(offset = shift)
  draw_matrix(panel_centres[2] + shift, cells = FALSE)
  drawing_width <<- 1
  popViewport()
}

# A single shared SVG layer pans with the strip. Its symmetric square-root
# transform interpolates smoothly to a circle on the fifth matrix fragment.
# This last illustration both removes dependence and standardises the axes;
# it does not imply that independence alone gives equal marginal variances.
save_live_panorama <- function() {
  pixels <- c(1536, 1024)
  plane <- diag(parameter_scale * pixels * c(1, -1))
  pixel_covariance <- plane %*% Sigma %*% plane
  root_eig <- eigen(pixel_covariance, symmetric = TRUE)
  root <- root_eig$vectors %*% diag(sqrt(root_eig$values)) %*% t(root_eig$vectors)
  circle_sd <- sqrt(prod(parameter_scale * pixels)) / sqrt(Q[1, 1])
  dependent <- root / circle_sd
  stopifnot(max(abs(root %*% t(root) - pixel_covariance)) < 1e-9)
  # Validate endpoints here; CSS decomposes the transform during interpolation.
  # Browser checks exercise the actual forward and reverse animation.
  stopifnot(min(eigen(dependent, symmetric = TRUE)$values) > 0, circle_sd > 0)
  radii <- circle_sd * sqrt(qchisq(c(.95, .80, .50, .20), df = 2))
  shades <- c("#eeece6", "#deded8", "#c6cac6", "#a6afad")
  centre <- c(panel_centres[2] * pixels[1], (1 - parameter_centre_y) * pixels[2])
  matrix_centre <- panel_centres[2] + diff(panel_centres)
  matrix_x <- (matrix_centre + c(-.049, .045) - .086 / 2) * pixels[1]
  matrix_y <- (1 - c(.59, .449) - .129 / 2) * pixels[2]
  cells <- character()
  for (i in 1:2) for (j in 1:2) {
    cells <- c(cells, sprintf(
      '<rect class="matrix-cell %s" x="%.6f" y="%.6f" width="%.6f" height="%.6f" fill="%s"/>',
      if (i == j) "diagonal" else "off-diagonal", matrix_x[j], matrix_y[i],
      .086 * pixels[1], .129 * pixels[2], if (i == j) ink else interaction))
  }
  markup <- c(
    '```{=html}',
    '<img class="hessian-panorama" data-id="hessian-panorama" src="design-studies/designs/hessian-panorama.png" alt="Likelihood hill with a trail to the maximum likelihood estimate, followed by uncertainty and curvature near the peak.">',
    '<div class="live-panorama" data-id="hessian-live">',
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 3072 1024" role="img" aria-label="Joint normal uncertainty and a two-by-two matrix. The independence step rounds the contours on standardised axes and fades the off-diagonal entries.">',
    sprintf('<g transform="translate(%.6f %.6f)">', centre[1], centre[2]),
    sprintf('<g class="density-shape" style="--dependent-transform:matrix(%.9f,%.9f,%.9f,%.9f,0,0)">',
            dependent[1, 1], dependent[2, 1], dependent[1, 2], dependent[2, 2]),
    vapply(seq_along(radii), function(i) sprintf(
      '<circle class="density-contour" r="%.9f" fill="%s" stroke="#929b98" stroke-width="1.65" vector-effect="non-scaling-stroke"/>',
      radii[i], shades[i]), character(1)),
    '</g>',
    '<circle r="8" fill="#20272d" stroke="#f8f6f0" stroke-width="3"/>',
    '</g>', cells, '</svg>', '</div>', '```')
  writeLines(markup, file.path("designs", "_hessian-panorama.qmd"))
}

save_figure <- function(name, draw, background = paper, width = 1536) {
  agg_png(file.path("designs", paste0(name, ".png")), width = width, height = 1024,
          res = 144, background = background)
  draw()
  dev.off()
  svglite(file.path("designs", paste0(name, ".svg")), width = width / 144,
          height = 1024 / 144, bg = background)
  draw()
  dev.off()
}
save_figure("hessian-normal", function() draw_pair(normal = TRUE))
save_figure("hessian-hill", draw_pair)
save_figure("hessian-panorama", draw_panorama, width = 3072)
save_live_panorama()
for (part in c("level", "spread", "interaction")) {
  save_figure(paste0("hessian-", part), function() draw_highlight(part), "transparent")
}
cat("Validated the hill's log-Hessian, covariance, peak and equal-density contours.\n")
cat("Validated the trail's monotone ascent and exactly matched parameter frames.\n")
cat("Rendered the camera panorama, static views and three matrix overlays; text bounds checked.\n")
cat("Validated the live SVG covariance and circular standardised endpoint.\n")
