# Design studies for the Science Slam. No changes to the live slide deck.
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
  ln(c(.065,.11),c(.845,.845),grey,2,"dashed")
  tx("Same reference",.12,.845,16,grey)
  ln(c(.39,.435),c(.845,.845),ink,2.8)
  tx("Fictional station",.445,.845,16,ink)
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
  tx("Wettest hour of each year.",.06,.105,20,face="bold")
  tx("One parameter changed from the reference at each station.",.06,.055,15,grey)
}
for(i in 1:3) save(paste0("stations-",i),function()draw_stations(i))
save("three-settings",function()draw_stations(3))
save("station-tokens",function(){
  base();tx("Now estimate all three at every station.",.06,.90,31,face="bold")
  for(i in 1:3) {
    y <- c(.70,.45,.20)[i]
    tx(paste("Station",LETTERS[i]),.08,y,25,face="bold")
    tx(station_labels[i],.08,y-.065,15,grey)
    for(j in 1:3) {
      x <- c(.47,.65,.83)[j]
      grid.circle(x,y,r=unit(.048,"npc"),gp=gpar(fill=paper,col=ink,lwd=2))
      tx(c("L","S","T")[j],x,y,23,face="bold",just="centre")
      tx(c("Level","Spread","Tail")[j],x,y-.082,15,grey,just="centre")
    }
  }
})
draw_matrix <- function(stage) {
  base(); tx("Same nine estimates. More connections.",.06,.92,29,face="bold")
  tx(c("Each\nestimate.","Within\nstations.","Between\nstations.")[stage],.06,.53,34,if(stage==3)blue else ink,"bold")
  x0 <- .43; top <- .755; cw <- .048; ch <- cw*1536/1024
  stopifnot(abs(cw*1536-ch*1024)<1e-10)
  stations <- rep(1:3,each=3)
  for(i in 1:9) for(j in 1:9) {
    fill <- faint
    if(i==j || (stage>=2 && stations[i]==stations[j])) fill <- ink
    if(stage==3 && abs(stations[i]-stations[j])==1) fill <- blue
    box(x0+(j-.5)*cw,top-(i-.5)*ch,cw*.88,ch*.88,fill)
  }
  for(i in 1:9) {
    tx(c("L","S","T")[(i-1)%%3+1],x0+(i-.5)*cw,.79,13,grey,just="centre")
    tx(c("L","S","T")[(i-1)%%3+1],.407,top-(i-.5)*ch,13,grey,just="centre")
  }
  for(s in 1:3) {
    tx(LETTERS[s],x0+(s*3-1.5)*cw,.842,18,face="bold",just="centre")
    tx(LETTERS[s],.361,top-(s*3-1.5)*ch,18,face="bold",just="centre")
  }
  tx("A, B, C = fictional stations",.06,.12,14,grey)
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
