# Intuitive Hessian slide. Run from design-studies/ in a UTF-8 locale.
# A toy relative likelihood over centred, rescaled Level/Spread coordinates.
# Its log-likelihood Hessian is -Q; the precision/negative Hessian is Q.
library(grid)
library(ragg)
library(svglite)

paper <- "#f8f6f0"
ink <- "#20272d"
muted <- "#7e858b"
pale <- "#e5e3dd"
interaction <- "#8a9295"
dir.create("designs", showWarnings = FALSE)

text_at <- function(label, x, y, size = 20, colour = ink,
                    face = "plain", just = "left") {
  g <- textGrob(label, x, y, just = just,
                gp = gpar(fontfamily = "Lato", fontsize = size,
                          col = colour, fontface = face, lineheight = 1.08))
  width <- convertWidth(grobWidth(g), "npc", valueOnly = TRUE)
  height <- convertHeight(grobHeight(g), "npc", valueOnly = TRUE)
  left <- if (just == "left") x else if (just == "right") x - width else x - width / 2
  stopifnot(left >= 0, left + width <= 1, y - height / 2 >= 0, y + height / 2 <= 1)
  grid.draw(g)
}
line_at <- function(x, y, colour = ink, width = 1.5, dash = "solid") {
  grid.lines(x, y, gp = gpar(col = colour, lwd = width, lty = dash))
}
badge <- function(kind, x, y) {
  grid.circle(x, y, r = unit(13, "pt"),
              gp = gpar(fill = paper, col = ink, lwd = 1.5))
  # One dot versus linked dots: visual keys, not numerical Hessian entries.
  if (kind == "1") {
    grid.circle(x, y, r = unit(4, "pt"), gp = gpar(fill = ink, col = NA))
  } else {
    line_at(x + c(-.006, .006), c(y, y), ink, 1.7)
    grid.circle(x + c(-.006, .006), c(y, y), r = unit(3, "pt"),
                gp = gpar(fill = ink, col = NA))
  }
}

Q <- matrix(c(2.4, -1.5, -1.5, 2.4), 2)
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
          fit(0, 0) == 1, fit(.5, .5) > fit(.5, -.5))

# Orthographic view. The hill is elongated along Level = Spread, not either axis.
angle <- -5 * pi / 180
project <- function(x, y, z = 0) {
  cbind(x = .32 + .11 * (cos(angle) * x - sin(angle) * y),
        y = .405 + .055 * (sin(angle) * x + cos(angle) * y) + .255 * z)
}
surface_line <- function(x, y, colour = ink, width = 2, dash = "solid") {
  p <- project(x, y, fit(x, y))
  line_at(p[, 1], p[, 2], colour, width, dash)
}
eig <- eigen(Q, symmetric = TRUE)
transform <- eig$vectors %*% diag(1 / sqrt(eig$values))
ellipse <- function(radius, angles) {
  t(transform %*% rbind(radius * cos(angles), radius * sin(angles)))
}

draw_hill <- function() {
  grid.newpage()
  grid.rect(gp = gpar(fill = paper, col = NA))
  text_at("The Hessian describes the shape", .06, .915, 30, face = "bold")
  text_at("near the best fit.", .06, .845, 30, face = "bold")

  # Ground contours make the rotation relative to the parameter axes visible.
  for (radius in c(1, 2, 3)) {
    xy <- ellipse(radius, seq(0, 2 * pi, length.out = 181))
    p <- project(xy[, 1], xy[, 2])
    line_at(p[, 1], p[, 2], "#cbc9c3", 1)
  }
  # A simple front corner for the two parameter axes.
  corner <- project(-2.4, -2.4)
  level_end <- project(2.7, -2.4)
  spread_end <- project(-2.4, 2.7)
  line_at(c(corner[1], level_end[1]), c(corner[2], level_end[2]), muted, 1.5)
  line_at(c(corner[1], spread_end[1]), c(corner[2], spread_end[2]), muted, 1.5)
  text_at("Level", level_end[1] + .018, level_end[2] - .016, 17, just = "centre")
  text_at("Spread", spread_end[1] - .018, spread_end[2] + .025, 17, just = "centre")
  text_at("Higher = better fit", .06, .745, 15, muted)

  # Radial quadrilaterals, sorted back-to-front for an opaque shaded surface.
  radii <- seq(0, 3, length.out = 29)
  angles <- seq(0, 2 * pi, length.out = 73)
  patches <- list()
  for (i in seq_len(length(radii) - 1)) for (j in seq_len(length(angles) - 1)) {
    rr <- c(radii[i], radii[i + 1], radii[i + 1], radii[i])
    aa <- c(angles[j], angles[j], angles[j + 1], angles[j + 1])
    xy <- t(transform %*% rbind(rr * cos(aa), rr * sin(aa)))
    z <- fit(xy[, 1], xy[, 2])
    depth <- mean(sin(angle) * xy[, 1] + cos(angle) * xy[, 2])
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
  # A coordinate slice corresponds to a diagonal entry; an eigenvector does not.
  # The joint path illustrates compensation, whose curvature uses the full Q.
  # Stay within the rendered radius (x'Qx <= 9).
  level_only <- seq(0, 1.8, length.out = 150)
  gentle <- seq(-2.1, 0, length.out = 150)
  stopifnot(max(Q[1, 1] * level_only^2) <= 9,
            max(sum(Q) * gentle^2) <= 9)
  surface_line(level_only, rep(0, length(level_only)), ink, 2.6)
  surface_line(gentle, gentle, ink, 2.6, "dashed")
  single_marker <- project(.85, 0, fit(.85, 0))
  joint_marker <- project(-1.05, -1.05, fit(-1.05, -1.05))
  badge("1", single_marker[1], single_marker[2])
  badge("2", joint_marker[1], joint_marker[2])
  peak <- project(0, 0, 1)
  grid.circle(peak[1], peak[2], r = unit(4, "pt"), gp = gpar(fill = ink, col = paper, lwd = 1.5))
  line_at(c(peak[1], peak[1] + .05), c(peak[2] + .012, peak[2] + .065), ink, 1.2)
  text_at("Best fit", peak[1] + .065, peak[2] + .065, 18, face = "bold")

  badge("1", .085, .195)
  text_at("Change level. Hold spread fixed.", .12, .195, 17)
  badge("2", .085, .14)
  text_at("Move both: one can offset the other.", .12, .14, 17)
  text_at("Nudge the parameters. How quickly does the fit get worse?", .06, .06, 20, face = "bold")
}

draw_matrix <- function(new_page = TRUE) {
  if (new_page) grid.newpage()
  # Transparent overlay, aligned to the same 1536 x 1024 composition.
  text_at("The Hessian", .79, .758, 25, face = "bold", just = "centre")
  x <- c(.746, .84)
  y <- c(.59, .449)
  for (i in 1:2) for (j in 1:2) {
    grid.rect(x[j], y[i], width = .086, height = .129,
              gp = gpar(fill = if (i == j) ink else interaction, col = NA))
    badge(if (i == j) "1" else "2", x[j], y[i])
  }
  for (i in 1:2) {
    text_at(c("Level", "Spread")[i], x[i], .698, 15, just = "centre")
    text_at(c("Level", "Spread")[i], .681, y[i], 15, just = "right")
  }
  badge("1", .665, .308)
  text_at("How tightly\npinned down?", .70, .307, 17)
  text_at("Holding the other fixed", .70, .245, 12.5, muted)
  badge("2", .665, .168)
  text_at("Interaction", .70, .187, 17)
  text_at("How estimates move together", .70, .146, 12.5)
}

save_figure <- function(name, draw, background = paper) {
  agg_png(file.path("designs", paste0(name, ".png")), width = 1536, height = 1024,
          res = 144, background = background)
  draw()
  dev.off()
  svglite(file.path("designs", paste0(name, ".svg")), width = 1536 / 144,
          height = 1024 / 144, bg = background)
  draw()
  dev.off()
}
save_figure("hessian-hill", draw_hill)
save_figure("hessian-hill-matrix", draw_matrix, "transparent")
agg_png("designs/hessian-hill-preview.png", width = 1536, height = 1024,
        res = 144, background = paper)
draw_hill()
draw_matrix(new_page = FALSE)
dev.off()
cat("Validated the hill's log-Hessian, positive precision, peak and compensating direction.\n")
cat("Rendered hill and matrix overlay to PNG/SVG; text bounds are inside the canvas.\n")
