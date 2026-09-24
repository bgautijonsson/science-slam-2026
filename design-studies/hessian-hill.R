# Intuitive Hessian slide. Run from design-studies/ in a UTF-8 locale.
# A toy relative likelihood over centred, rescaled Level/Spread coordinates.
# Its log-likelihood Hessian is -Q; the precision/negative Hessian is Q.
library(grid)
library(ragg)
library(svglite)

paper <- "#f8f6f0"
ink <- "#20272d"
muted <- "#7e858b"
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
eig <- eigen(Q, symmetric = TRUE)
transform <- eig$vectors %*% diag(1 / sqrt(eig$values))

draw_hill <- function() {
  grid.newpage()
  grid.rect(gp = gpar(fill = paper, col = NA))
  text_at("The Hessian", .06, .90, 34, face = "bold")

  # A simple front corner for the two parameter axes.
  corner <- project(-2.4, -2.4)
  level_end <- project(2.7, -2.4)
  spread_end <- project(-2.4, 2.7)
  line_at(c(corner[1], level_end[1]), c(corner[2], level_end[2]), muted, 1.5)
  line_at(c(corner[1], spread_end[1]), c(corner[2], spread_end[2]), muted, 1.5)
  text_at("Level", level_end[1] + .018, level_end[2] - .016, 17, just = "centre")
  text_at("Spread", spread_end[1] - .018, spread_end[2] + .025, 17, just = "centre")

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
  peak <- project(0, 0, 1)
  grid.circle(peak[1], peak[2], r = unit(4, "pt"), gp = gpar(fill = ink, col = paper, lwd = 1.5))

}

draw_matrix <- function(new_page = TRUE) {
  if (new_page) grid.newpage()
  # Transparent overlay, aligned to the same 1536 x 1024 composition.
  x <- c(.746, .84)
  y <- c(.59, .449)
  for (i in 1:2) for (j in 1:2) {
    grid.rect(x[j], y[i], width = .086, height = .129,
              gp = gpar(fill = if (i == j) ink else interaction, col = NA))
  }
  for (i in 1:2) {
    text_at(c("Level", "Spread")[i], x[i], .698, 15, just = "centre")
    text_at(c("Level", "Spread")[i], .681, y[i], 15, just = "right")
  }

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
