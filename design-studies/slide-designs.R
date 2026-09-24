# Station and matrix figures used by the Science Slam deck.
# Run from this directory with Rscript slide-designs.R.
library(grid)
library(ragg)
library(svglite)
# Explicit registration also works when the macOS font catalogue is unavailable
# to a sandboxed R process; otherwise Lato can silently become a fallback font.
lato_dir <- path.expand("~/Library/Fonts")
lato_files <- file.path(lato_dir, paste0("Lato-", c("Regular", "Bold", "Italic", "BoldItalic"), ".ttf"))
if (all(file.exists(lato_files))) {
  systemfonts::register_font("Lato", plain = lato_files[1], bold = lato_files[2],
                            italic = lato_files[3], bolditalic = lato_files[4])
}
stopifnot(grepl("Lato", basename(systemfonts::match_fonts("Lato")$path), ignore.case = TRUE))
dir.create("designs",showWarnings=FALSE)
paper <- "#f8f6f0"; ink <- "#20272d"; faint <- "#e5e3dd"
grey <- "#7e858b"; blue <- "#347eab"
tx <- function(s,x,y,size=24,col=ink,face="plain",just="left") {
  g <- textGrob(s,x,y,just=just,gp=gpar(fontfamily="Lato",fontsize=size,col=col,fontface=face,lineheight=1.05))
  w <- convertWidth(grobWidth(g),"npc",valueOnly=TRUE)
  h <- convertHeight(grobHeight(g),"npc",valueOnly=TRUE)
  l <- if(just=="left") x else if(just=="right") x-w else x-w/2
  stopifnot(l>=0,l+w<=1,y-h/2>=0,y+h/2<=1)
  grid.draw(g)
}
ln <- function(x,y,col=ink,lwd=2,lty="solid") grid.lines(x,y,gp=gpar(col=col,lwd=lwd,lty=lty))
box <- function(x,y,w,h,col) grid.rect(x,y,w,h,gp=gpar(fill=col,col=NA))
base <- function() { grid.newpage(); box(.5,.5,1,1,paper) }
save <- function(name,draw) {
  agg_png(paste0("designs/",name,".png"),width=1536,height=1024,res=144); draw(); dev.off()
  svglite(paste0("designs/",name,".svg"),width=1536/144,height=1024/144); draw(); dev.off()
}
dgev <- function(x,mu,sigma,xi) {
  a <- 1+xi*(x-mu)/sigma; out <- rep(0,length(x)); ok <- a>0
  out[ok] <- exp(-(1+1/xi)*log(a[ok])-a[ok]^(-1/xi))/sigma; out
}
# Same reference and axes in every panel. Only one parameter changes at a time.
reference <- c(45,12,.1)
station_pars <- list(c(65,12,.1),c(45,22,.1),c(45,12,.45))
for(p in c(list(reference),station_pars)) {
  lower <- p[1]-p[2]/p[3]
  mass <- integrate(function(x)dgev(x,p[1],p[2],p[3]),lower,Inf,
                    subdivisions=2000,rel.tol=1e-10)$value
  stopifnot(abs(mass-1)<1e-5)
}
stopifnot(all(vapply(seq_along(station_pars),function(i) {
  changed <- which(station_pars[[i]]!=reference)
  identical(changed,as.integer(i))
},logical(1))))
station_labels <- c("Higher level","More spread","Heavier tail")
draw_stations <- function(stage) {
  base(); tx("Three imaginary places.",.06,.92,34,face="bold")
  x <- seq(-10,190,length.out=1200)
  for(i in seq_len(stage)) {
    mid <- c(.205,.5,.795)[i]; left <- mid-.12
    tx(paste("Station",LETTERS[i]),mid,.748,24,face="bold",just="centre")
    tx(station_labels[i],mid,.691,20,just="centre")
    original <- dgev(x,reference[1],reference[2],reference[3])
    p <- station_pars[[i]]; yy <- dgev(x,p[1],p[2],p[3])
    xx <- left+(x+10)/200*.24
    ln(c(left,left+.24),c(.405,.405),grey,1)
    if(i==3) {
      ok <- x>=95
      grid.polygon(c(xx[ok][1],xx[ok],tail(xx,1)),
                   c(.405,.405+yy[ok]/.035*.235,.405),
                   gp=gpar(fill="#bfc4c5",col=NA))
    }
    ln(xx,.405+original/.035*.235,grey,1.8,"dashed")
    ln(xx,.405+yy/.035*.235,ink,2.8)
    tx("Rainfall amount",mid,.368,14,grey,just="centre")
    for(j in 1:3) {
      cx <- mid+(j-2)*.066
      grid.circle(cx,.28,r=unit(.027,"npc"),
                  gp=gpar(fill=if(j==i)ink else paper,col=ink,lwd=1.7))
      tx(c("L","S","T")[j],cx,.28,16,if(j==i)paper else ink,"bold","centre")
      tx(c("Level","Spread","Tail")[j],cx,.224,12,grey,just="centre")
    }
  }
}
for(i in 1:3) save(paste0("stations-",i),function()draw_stations(i))
save("three-settings",function()draw_stations(3))
# Invented annual maxima: one bar per year, with a common rainfall scale.
# These records illustrate the estimation step; they are not fitted research data.
station_records <- list(
  c(51, 65, 58, 73, 56, 82, 64, 60, 77, 53, 68, 72, 62, 87),
  c(32, 57, 41, 81, 29, 65, 47, 91, 36, 53, 75, 39, 61, 48),
  c(35, 42, 31, 49, 37, 44, 61, 33, 40, 107, 46, 36, 55, 39)
)
stopifnot(length(station_records) == 3L,
          all(lengths(station_records) == 14L),
          all(unlist(station_records) > 0),
          all(unlist(station_records) < 120))
# Schematic positions on separate parameter scales, not numerical GEV fits.
# The range is fixed down each column so station estimates can be compared.
estimate_positions <- rbind(c(.82, .26, .20),
                            c(.37, .83, .36),
                            c(.24, .42, .82))
stopifnot(all(estimate_positions > 0 & estimate_positions < 1),
          identical(apply(estimate_positions, 2, which.max), 1:3),
          all(apply(estimate_positions, 2, function(x) length(unique(x))) == 3))
save("station-tokens",function(){
  base(); tx("Three stations. Nine estimates.",.06,.92,34,face="bold")
  tx("Wettest hour of each year",.40,.80,18,grey,just="centre")
  token_x <- c(.70,.81,.92)
  for(j in 1:3) {
    tx(c("Level","Spread","Tail")[j],token_x[j],.80,18,grey,just="centre")
  }
  for(i in 1:3) {
    y <- c(.65,.42,.19)[i]
    tx(paste("Station",LETTERS[i]),.06,y,25,face="bold")
    x <- seq(.27,.53,length.out=length(station_records[[i]]))
    baseline <- y-.065
    heights <- station_records[[i]]/120*.15
    stopifnot(all(x-.005 >= .26), all(x+.005 <= .54),
              baseline >= 0, all(baseline+heights <= 1))
    ln(c(.257,.543),rep(baseline,2),grey,1)
    for(k in seq_along(x)) {
      box(x[k],baseline+heights[k]/2,.009,heights[k],ink)
    }
    grid.lines(c(.57,.63),c(y,y),
               arrow=arrow(length=unit(.09,"inches"),type="open"),
               gp=gpar(col=grey,lwd=1.8))
    for(j in 1:3) {
      left <- token_x[j]-.043
      right <- token_x[j]+.043
      ln(c(left,right),c(y,y),"#b7bdbe",1.6)
      for(tick in seq(left,right,length.out=5)) {
        ln(c(tick,tick),c(y-.009,y+.009),"#b7bdbe",1.1)
      }
      estimate_x <- left+(right-left)*estimate_positions[i,j]
      stopifnot(estimate_x > left, estimate_x < right, left >= 0, right <= 1)
      grid.circle(estimate_x,y,r=unit(5.5,"pt"),
                  gp=gpar(fill=ink,col=paper,lwd=1.5))
    }
  }
})
# Fixed illustrative precision values. All three stages share the same entries;
# only the retained links change. Strict diagonal dominance gives a valid SPD
# precision at every stage (the corresponding log-likelihood Hessian is -Q).
matrix_stations <- rep(1:3, each = 3)
Q_full <- matrix(0, 9, 9)
within_weights <- list(c(.55, .38, .72), c(.82, .46, .61), c(.41, .77, .59))
for (station in 1:3) {
  ids <- (station - 1) * 3 + 1:3
  pairs <- combn(ids, 2)
  for (k in 1:3) {
    Q_full[pairs[1, k], pairs[2, k]] <- -within_weights[[station]][k]
    Q_full[pairs[2, k], pairs[1, k]] <- -within_weights[[station]][k]
  }
}
Q_full[1:3, 4:6] <- -matrix(c(.35, .13, .24, .22, .42, .18, .29, .17, .31), 3, byrow = TRUE)
Q_full[4:6, 7:9] <- -matrix(c(.23, .36, .14, .19, .28, .40, .32, .16, .26), 3, byrow = TRUE)
Q_full[4:6, 1:3] <- t(Q_full[1:3, 4:6])
Q_full[7:9, 4:6] <- t(Q_full[4:6, 7:9])
diag(Q_full) <- rowSums(abs(Q_full)) + c(.7, 1.1, .8, .6, .9, 1.2, .75, 1, .65)
matrix_masks <- list(diag(9) == 1,
                     outer(matrix_stations, matrix_stations, "=="),
                     abs(outer(matrix_stations, matrix_stations, "-")) <= 1)
precision_stages <- lapply(matrix_masks, function(mask) Q_full * mask)
cell_alpha <- .18 + .82 * sqrt(abs(Q_full) / max(abs(Q_full)))
stopifnot(identical(Q_full, t(Q_full)), identical(cell_alpha, t(cell_alpha)),
          all(vapply(precision_stages, function(q) min(eigen(q, symmetric = TRUE)$values) > 0, logical(1))),
          identical(vapply(precision_stages, function(q) sum(q != 0), integer(1)), c(9L, 27L, 63L)))

# Nine people stand for nine estimates; enclosures stand for stations.
# Between-station bridges join entire groups, corresponding to whole blocks.
draw_person <- function(x, y, label) {
  grid.circle(x, y + .026, r = unit(5.2, "pt"), gp = gpar(fill = ink, col = NA))
  grid.roundrect(x, y + .001, width = .018, height = .031,
                 r = unit(3, "pt"), gp = gpar(fill = ink, col = NA))
  ln(x + c(-.004, -.008), y + c(-.009, -.03), ink, 3.2)
  ln(x + c(.004, .008), y + c(-.009, -.03), ink, 3.2)
  tx(label, x, y - .052, 13, grey, just = "centre")
}
draw_people <- function(stage, centres) {
  group_x <- .235
  if (stage == 3) for (i in 1:2) {
    ln(rep(group_x, 2), c(centres[i] - .081, centres[i + 1] + .081), blue, 3)
  }
  for (station in 1:3) {
    cy <- centres[station]
    grid.roundrect(group_x, cy, width = .27, height = .162,
                   r = unit(9, "pt"), gp = gpar(fill = paper, col = "#cfcec8", lwd = 1.1))
    tx(LETTERS[station], .065, cy, 20, face = "bold", just = "centre")
    px <- group_x + c(-.078, 0, .078)
    py <- cy + c(-.010, .026, -.010)
    if (stage >= 2) {
      pairs <- combn(1:3, 2)
      for (k in 1:3) ln(px[pairs[, k]], py[pairs[, k]] + .009, "#a0a5a3", 1.8)
    }
    for (person in 1:3) draw_person(px[person], py[person], c("L", "S", "T")[person])
  }
  tx("One person = one estimate", group_x, .10, 14, grey, just = "centre")
}

draw_matrix <- function(stage) {
  base()
  # The live slide supplies the recurring meme header; keep diagrams full size.
  pushViewport(viewport(x = 0, y = -.045, just = c("left", "bottom"), clip = "off"))
  x0 <- .53; top <- .755; cw <- .045; ch <- cw * 1536 / 1024
  stopifnot(abs(cw * 1536 - ch * 1024) < 1e-10)
  block_centres <- top - (c(1, 2, 3) * 3 - 1.5) * ch
  draw_people(stage, block_centres)
  for (i in 1:9) for (j in 1:9) {
    fill <- "#eeece6"
    if (matrix_masks[[stage]][i, j]) {
      colour <- if (matrix_stations[i] != matrix_stations[j]) blue else ink
      fill <- adjustcolor(colour, alpha.f = cell_alpha[i, j])
    }
    box(x0 + (j - .5) * cw, top - (i - .5) * ch, cw * .88, ch * .88, fill)
  }
  # Square brackets and repeated row/column ordering make the matrix explicit.
  bottom <- top - 9 * ch
  for (side in c(-1, 1)) {
    edge <- if (side < 0) x0 - .009 else x0 + 9 * cw + .009
    inner <- edge - side * .008
    ln(c(inner, edge, edge, inner), c(top, top, bottom, bottom), ink, 1.8)
  }
  for (i in 1:9) {
    tx(c("L", "S", "T")[(i - 1) %% 3 + 1], x0 + (i - .5) * cw, .79, 13, grey, just = "centre")
    tx(c("L", "S", "T")[(i - 1) %% 3 + 1], x0 - .028, top - (i - .5) * ch, 13, grey, just = "centre")
  }
  for (station in 1:3) {
    tx(LETTERS[station], x0 + (station * 3 - 1.5) * cw, .842, 18, face = "bold", just = "centre")
    tx(LETTERS[station], x0 - .064, block_centres[station], 18, face = "bold", just = "centre")
  }
  tx("Illustrative magnitudes", x0 + 4.5 * cw, .10, 14, grey, just = "centre")
  popViewport()
}
for(i in 1:3) save(paste0("matrix-",i),function()draw_matrix(i))

# Contact sheet: a visual overview of the intended design continuity.
agg_png("designs/contact-sheet.png",width=2400,height=1068,res=144)
grid.newpage();box(.5,.5,1,1,paper)
imgs <- c("three-settings","station-tokens","matrix-1","matrix-2","matrix-3")
for(i in seq_along(imgs)) {
  col <- (i-1)%%3; row <- (i-1)%/%3
  image_w <- .321; image_h <- image_w*2400/(1536/1024)/1068
  stopifnot(abs(image_w*2400/(image_h*1068)-1.5)<1e-10)
  grid.raster(png::readPNG(paste0("designs/",imgs[i],".png")),
              x=(col+.5)/3,y=1-(row+.5)/2,width=image_w,height=image_h,interpolate=TRUE)
}
pushViewport(viewport(x=5/6,y=.25,width=1/3,height=.5))
tx("The reveal",.09,.67,33,face="bold")
tx("Keep the grid still.\nAdd the connections.\nGive the joke a pause.",.09,.42,22)
tx("One accent colour. One job.",.09,.15,16,blue)
popViewport();dev.off()
cat("Verified: fictional-station GEV densities integrate to one; exactly one parameter changes per station; PNG/SVG exports and text bounds checked; matrix cells are square.\n")
