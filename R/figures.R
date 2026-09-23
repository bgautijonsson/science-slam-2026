# Figures for "Modelling Dependence or: How I Learned to Stop Worrying and
# Love the Hessian" (Science Slam, 2026-09-24).
#
# Run from the deck root:  Rscript R/figures.R
# Writes Figures/fig*.png. Toy data only; nothing here comes from the
# research pipeline.

library(ggplot2)

col_main <- "#08519c" # in-band navy (validator's nearest pass to #08306b)
col_accent <- "#4292c6" # theme light blue
col_light <- "#c6dbef" # low end of the sequential ramp
col_empty <- "#e9ecf1" # a zero entry in a matrix
col_ink <- "#333333"
col_bg <- "#faf9f9" # slide background ($body-bg in theme.scss)
font <- "Lato"

dir.create("Figures", showWarnings = FALSE)

theme_slide <- function(base_size = 24) {
  ggplot2::theme_void(base_size = base_size, base_family = font) +
    ggplot2::theme(
      text = ggplot2::element_text(colour = col_ink),
      strip.text = ggplot2::element_text(
        size = base_size, face = "bold",
        margin = ggplot2::margin(b = 10)
      ),
      plot.background = ggplot2::element_rect(fill = col_bg, colour = NA),
      panel.background = ggplot2::element_rect(fill = col_bg, colour = NA),
      plot.margin = ggplot2::margin(10, 10, 10, 10)
    )
}

save_fig <- function(plot, file, width, height) {
  ggplot2::ggsave(
    file.path("Figures", file), plot,
    width = width, height = height, dpi = 300,
    device = ragg::agg_png, bg = col_bg
  )
}

# A matrix as tiles: every cell drawn, zeros in the empty colour, a small gap
# between cells so the structure reads from the back of the room.
matrix_tiles <- function(m, name = "M") {
  n <- nrow(m)
  data.frame(
    matrix = name,
    row    = rep(seq_len(n), times = n),
    col    = rep(seq_len(n), each = n),
    value  = as.vector(m)
  )
}

# ---- Figure 1: covariance --------------------------------------------------
# "Rain here" vs "rain next door": two correlated quantities.

set.seed(2026)
rho1 <- 0.8
n1 <- 250
z1 <- stats::rnorm(n1)
z2 <- rho1 * z1 + sqrt(1 - rho1^2) * stats::rnorm(n1)
rain <- data.frame(here = z1, next_door = z2)

fig1 <- ggplot2::ggplot(rain, ggplot2::aes(here, next_door)) +
  ggplot2::stat_ellipse(level = 0.95, colour = col_accent, linewidth = 1.4) +
  ggplot2::geom_point(colour = col_main, alpha = 0.55, size = 3) +
  ggplot2::coord_equal() +
  ggplot2::labs(x = "Rain here", y = "Rain next door") +
  theme_slide() +
  ggplot2::theme(
    axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 10)),
    axis.title.y = ggplot2::element_text(angle = 90, margin = ggplot2::margin(r = 10)),
    axis.line    = ggplot2::element_line(colour = col_ink, linewidth = 0.6)
  )

save_fig(fig1, "fig1-covariance.png", width = 7, height = 7)

# ---- Figure 2: covariance vs precision -------------------------------------
# A chain of 10 sites, each linked only to its neighbours (AR(1), rho = 0.8).
# Covariance is dense; precision is tridiagonal. Absolute values, each matrix
# scaled to its own maximum: the picture is about where the zeros are.

n2 <- 10
rho2 <- 0.8
Sigma <- rho2^abs(outer(seq_len(n2), seq_len(n2), "-")) / (1 - rho2^2)
Q <- diag(c(1, rep(1 + rho2^2, n2 - 2), 1))
Q[cbind(1:(n2 - 1), 2:n2)] <- -rho2
Q[cbind(2:n2, 1:(n2 - 1))] <- -rho2

cov_prec <- rbind(
  matrix_tiles(abs(Sigma) / max(abs(Sigma)), "Covariance"),
  matrix_tiles(abs(Q) / max(abs(Q)), "Precision")
)
cov_prec$matrix <- factor(cov_prec$matrix, levels = c("Covariance", "Precision"))
nonzero <- cov_prec[cov_prec$value > 1e-12, ]

fig2 <- ggplot2::ggplot(cov_prec, ggplot2::aes(col, row)) +
  ggplot2::geom_tile(fill = col_empty, width = 0.9, height = 0.9) +
  ggplot2::geom_tile(ggplot2::aes(fill = value),
    data = nonzero,
    width = 0.9, height = 0.9
  ) +
  ggplot2::scale_fill_gradient(low = col_light, high = col_main, guide = "none") +
  ggplot2::scale_y_reverse() +
  ggplot2::coord_equal() +
  ggplot2::facet_wrap(ggplot2::vars(matrix), nrow = 1) +
  theme_slide() +
  ggplot2::theme(panel.spacing = ggplot2::unit(2, "lines"))

save_fig(fig2, "fig2-cov-vs-prec.png", width = 12, height = 6.6)

# ---- Figure 3: the Hessian is the curvature at the peak ---------------------
# Likelihood of an exponential rate with the peak at 1, from n = 30 and n = 3
# observations, against the normal whose precision is the (negative) Hessian at
# the peak, n / peak^2. Both on the relative scale (peak height 1).

lambda <- seq(0.01, 3.5, length.out = 600)
peaks <- rbind(
  data.frame(panel = "Sharp peak", lambda = lambda, n = 30),
  data.frame(panel = "Flat peak", lambda = lambda, n = 3)
)
peaks$truth <- exp(peaks$n * (log(peaks$lambda) - (peaks$lambda - 1)))
peaks$normal <- exp(-peaks$n * (peaks$lambda - 1)^2 / 2)
peaks$panel <- factor(peaks$panel, levels = c("Sharp peak", "Flat peak"))

# A small key in the empty top-right of the flat panel; labels placed on the
# curves themselves collide with them where the two lines cross.
flat <- factor("Flat peak", levels = levels(peaks$panel))
key3 <- data.frame(panel = flat, x = 2.0, xend = 2.3, y = c(0.95, 0.76))
labels3 <- data.frame(
  panel  = flat,
  lambda = 2.38,
  y      = c(0.95, 0.76),
  label  = c("the truth", "normal\napproximation"),
  colour = c(col_main, col_accent)
)

fig3 <- ggplot2::ggplot(peaks, ggplot2::aes(lambda)) +
  ggplot2::geom_line(ggplot2::aes(y = normal),
    colour = col_accent,
    linewidth = 1.6, linetype = "22"
  ) +
  ggplot2::geom_line(ggplot2::aes(y = truth), colour = col_main, linewidth = 1.6) +
  ggplot2::geom_segment(ggplot2::aes(x = x, xend = xend, y = y, yend = y),
    data = key3[1, ], colour = col_main, linewidth = 1.6
  ) +
  ggplot2::geom_segment(ggplot2::aes(x = x, xend = xend, y = y, yend = y),
    data = key3[2, ], colour = col_accent, linewidth = 1.6, linetype = "22"
  ) +
  ggplot2::geom_text(ggplot2::aes(y = y, label = label),
    data = labels3,
    colour = labels3$colour, family = font, size = 7,
    lineheight = 0.9, hjust = 0
  ) +
  ggplot2::facet_wrap(ggplot2::vars(panel), nrow = 1) +
  ggplot2::scale_y_continuous(limits = c(0, 1.05)) +
  ggplot2::coord_cartesian(clip = "off") +
  theme_slide() +
  ggplot2::theme(
    axis.line.x   = ggplot2::element_line(colour = col_ink, linewidth = 0.6),
    panel.spacing = ggplot2::unit(3, "lines")
  )

save_fig(fig3, "fig3-hessian-peaks.png", width = 12, height = 5.5)

# ---- Figures 4-6: three kinds of Hessian ------------------------------------
# 8 sites x 3 parameters per site = 24 x 24, ordered site by site.
#   4. diagonal: one quantity per entry, nothing shared
#   5. block diagonal: each site's 3 parameters linked to each other
#   6. block + banded: neighbouring sites linked through the data, drawn with
#      the same chain of neighbours as figure 2 (accent colour = the new links)

n_site <- 8
n_par <- 3
n_h <- n_site * n_par
site_of <- rep(seq_len(n_site), each = n_par)

hessian_tiles <- function(kind) {
  cells <- expand.grid(row = seq_len(n_h), col = seq_len(n_h))
  same_site <- site_of[cells$row] == site_of[cells$col]
  neighbours <- abs(site_of[cells$row] - site_of[cells$col]) == 1
  cells$type <- "zero"
  if (kind == "diagonal") {
    cells$type[cells$row == cells$col] <- "own"
  } else {
    cells$type[same_site] <- "own"
  }
  if (kind == "banded") cells$type[neighbours] <- "neighbour"
  cells
}

hessian_fig <- function(kind) {
  cells <- hessian_tiles(kind)
  ggplot2::ggplot(cells, ggplot2::aes(col, row, fill = type)) +
    ggplot2::geom_tile(width = 0.86, height = 0.86) +
    ggplot2::scale_fill_manual(
      values = c(zero = col_empty, own = col_main, neighbour = col_accent),
      guide = "none"
    ) +
    ggplot2::scale_y_reverse() +
    ggplot2::coord_equal() +
    theme_slide()
}

save_fig(hessian_fig("diagonal"), "fig4-hessian-diagonal.png", width = 6, height = 6)
save_fig(hessian_fig("block"), "fig5-hessian-block.png", width = 6, height = 6)
save_fig(hessian_fig("banded"), "fig6-hessian-banded.png", width = 6, height = 6)

message("Wrote: ", paste(list.files("Figures", pattern = "^fig"), collapse = ", "))
