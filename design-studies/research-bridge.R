# Illustrative research bridge: larger block Hessian -> UK spatial field.
# Run from design-studies/. Neither panel contains fitted research results.
library(grid)
library(ragg)
library(svglite)
library(sf)

lato_files <- file.path(path.expand('~/Library/Fonts'),
                       paste0('Lato-', c('Regular', 'Bold', 'Italic', 'BoldItalic'), '.ttf'))
systemfonts::register_font('Lato', plain = lato_files[1], bold = lato_files[2],
                          italic = lato_files[3], bolditalic = lato_files[4])
stopifnot(grepl('Lato', basename(systemfonts::match_fonts('Lato')$path)))
paper <- '#f8f6f0'; ink <- '#20272d'; grey <- '#7e858b'; blue <- '#347eab'
text_at <- function(label, x, y, size = 20, colour = ink, bold = FALSE, just = 'centre') {
  g <- textGrob(label, x, y, just = just,
                gp = gpar(fontfamily = 'Lato', fontsize = size, col = colour,
                          fontface = if (bold) 'bold' else 'plain', lineheight = 1.08))
  w <- convertWidth(grobWidth(g), 'npc', valueOnly = TRUE)
  h <- convertHeight(grobHeight(g), 'npc', valueOnly = TRUE)
  left <- if (just == 'left') x else x - w / 2
  stopifnot(left >= 0, left + w <= 1, y - h / 2 >= 0, y + h / 2 <= 1)
  grid.draw(g)
}

# Thirty fictional stations, three parameters each, in schematic chain order.
# No assertion that this ordering is the geographical neighbourhood graph.
n_stations <- 30L
n <- 3L * n_stations
station <- rep(seq_len(n_stations), each = 3)
Q <- matrix(0, n, n)
set.seed(240926)
for (i in 1:(n - 1L)) for (j in (i + 1L):n) {
  if (station[i] == station[j]) Q[i, j] <- -runif(1, .35, .85)
  if (abs(station[i] - station[j]) == 1L) Q[i, j] <- -runif(1, .13, .43)
  Q[j, i] <- Q[i, j]
}
diag(Q) <- rowSums(abs(Q)) + runif(n, .6, 1.2)
alpha <- .18 + .82 * sqrt(abs(Q) / max(abs(Q)))
stopifnot(identical(Q, t(Q)), identical(alpha, t(alpha)),
          min(eigen(Q, symmetric = TRUE, only.values = TRUE)$values) > 0,
          all(Q[abs(outer(station, station, '-')) > 1] == 0),
          sum(Q != 0) == n_stations * 9L + (n_stations - 1L) * 18L)

# Natural Earth 1:50m boundaries are bundled with rnaturalearthdata (public
# domain). Use a projected UK outline, including Northern Ireland and islands.
uk <- rnaturalearth::ne_countries(scale = 50, country = 'united kingdom', returnclass = 'sf')
ireland <- rnaturalearth::ne_countries(scale = 50, country = 'ireland', returnclass = 'sf')
uk <- st_transform(uk, 27700)
ireland <- st_transform(ireland, 27700)
stopifnot(all(st_is_valid(uk)))
bounds <- st_bbox(uk)
# Include the Republic of Ireland as subdued context around Northern Ireland.
bounds['xmin'] <- min(bounds['xmin'], st_bbox(ireland)['xmin'])
bounds[c('xmin', 'ymin')] <- bounds[c('xmin', 'ymin')] - 12000
bounds[c('xmax', 'ymax')] <- bounds[c('xmax', 'ymax')] + 12000
nx <- 380L; ny <- 650L
xs <- seq(bounds['xmin'], bounds['xmax'], length.out = nx)
ys <- seq(bounds['ymax'], bounds['ymin'], length.out = ny)
xy <- expand.grid(x = xs, y = ys)
inside <- lengths(st_intersects(st_as_sf(xy, coords = c('x', 'y'), crs = 27700), uk)) > 0
# A reproducible smooth random field made from Gaussian radial basis functions.
# Normalised arbitrary values; no units or numerical fit are implied.
set.seed(9242026)
knots <- cbind(runif(24, min(xs), max(xs)), runif(24, min(ys), max(ys)))
weights <- rnorm(24)
length_scale <- 105000
field <- numeric(nrow(xy))
for (k in seq_len(nrow(knots))) {
  d2 <- (xy$x - knots[k, 1])^2 + (xy$y - knots[k, 2])^2
  field <- field + weights[k] * exp(-d2 / (2 * length_scale^2))
}
field_range <- range(field[inside])
field <- (field - field_range[1]) / diff(field_range)
stopifnot(all(is.finite(field)), sum(inside) > 1000, diff(range(field[inside])) > .99)
colours <- colorRampPalette(c('#eeece6', '#c6cac6', '#8a9295', '#414c50'))(256)
colour_id <- pmax(1L, pmin(256L, 1L + floor(field * 255)))
map_colours <- rep(NA_character_, length(field))
map_colours[inside] <- colours[colour_id[inside]]
map_raster <- as.raster(matrix(map_colours, nrow = ny, ncol = nx, byrow = TRUE))

# Fit the projected map into a fixed physical rectangle; preserve its aspect.
map_height <- .66
map_width <- map_height * 1024 / 1536 * diff(bounds[c('xmin', 'xmax')]) / diff(bounds[c('ymin', 'ymax')])
map_cx <- .765; map_cy <- .472
stopifnot(map_width < .37, map_cx + map_width / 2 < .96)
map_xy <- function(coords) cbind(
  x = map_cx - map_width / 2 + (coords[, 1] - bounds['xmin']) / diff(bounds[c('xmin', 'xmax')]) * map_width,
  y = map_cy - map_height / 2 + (coords[, 2] - bounds['ymin']) / diff(bounds[c('ymin', 'ymax')]) * map_height)
draw_border <- function(shape, fill = NA, colour = grey, width = .7) {
  polygons <- suppressWarnings(st_cast(st_geometry(shape), 'POLYGON'))
  for (polygon in polygons) {
    rings <- lapply(polygon, map_xy)
    coords <- do.call(rbind, rings)
    grid.path(coords[, 1], coords[, 2], id.lengths = vapply(rings, nrow, integer(1)),
              rule = 'evenodd', gp = gpar(fill = fill, col = colour, lwd = width))
  }
}

draw_bridge <- function() {
  grid.newpage()
  grid.rect(gp = gpar(fill = paper, col = NA))
  text_at('From stations to a spatial field', .06, .92, 34, bold = TRUE, just = 'left')
  text_at('Estimates + Hessian', .255, .815, 21)
  text_at('Rainfall level', map_cx, .85, 21)
  x0 <- .065; top <- .755; width <- .38
  cw <- width / n; ch <- cw * 1536 / 1024
  bottom <- top - n * ch
  stopifnot(abs(cw * 1536 - ch * 1024) < 1e-10)
  for (i in seq_len(n)) for (j in seq_len(n)) {
    fill <- '#eeece6'
    if (Q[i, j] != 0) {
      colour <- if (station[i] == station[j]) ink else blue
      fill <- adjustcolor(colour, alpha.f = alpha[i, j])
    }
    grid.rect(x0 + (j - .5) * cw, top - (i - .5) * ch,
               width = cw * .87, height = ch * .87, gp = gpar(fill = fill, col = NA))
  }
  for (side in c(-1, 1)) {
    edge <- if (side < 0) x0 - .008 else x0 + width + .008
    inner <- edge - side * .007
    grid.lines(c(inner, edge, edge, inner), c(top, top, bottom, bottom),
                gp = gpar(col = ink, lwd = 1.8))
  }
  text_at('Same blocks. More stations.', .255, .13, 16, grey)
  text_at('Spatial\nmodel', .516, .545, 16)
  grid.lines(c(.477, .555), c(.47, .47),
              arrow = arrow(length = unit(5, 'pt'), type = 'closed'),
              gp = gpar(col = grey, fill = grey, lwd = 1.5))
  draw_border(ireland, fill = '#e8e6e0', colour = '#c6c7c1', width = .6)
  grid.raster(map_raster, map_cx, map_cy, width = map_width, height = map_height, interpolate = FALSE)
  draw_border(uk, colour = '#626c6d', width = .7)
  legend_width <- .13
  grid.raster(as.raster(matrix(colours, nrow = 1)), map_cx, .105,
              width = legend_width, height = .009, interpolate = TRUE)
  text_at('Lower', map_cx - legend_width / 2 - .023, .105, 12, grey)
  text_at('Higher', map_cx + legend_width / 2 + .028, .105, 12, grey)
  text_at('Illustrative example', .5, .043, 14, grey)
}
agg_png('designs/research-bridge.png', width = 1536, height = 1024, res = 144)
draw_bridge(); dev.off()
svglite('designs/research-bridge.svg', width = 1536 / 144, height = 1024 / 144)
draw_bridge(); dev.off()
cat(sprintf('Validated %dx%d symmetric positive-definite precision, %d active entries.\n', n, n, sum(Q != 0)))
cat(sprintf('UK field mask: %d land pixels, values span 0–1; projected map aspect preserved.\n', sum(inside)))
