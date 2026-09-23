# Design studies for the Science Slam. No changes to the live slide deck.
# Run from this directory with Rscript slide-designs.R.
library(grid)
library(ragg)
library(svglite)
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
knob <- function(x,y,angle,letter,r=.054) {
  grid.circle(x,y,r=unit(r,"npc"),gp=gpar(fill=paper,col=ink,lwd=2.4))
  # The circle radius is relative to the smaller device dimension.
  ln(c(x,x+cos(angle)*r*.69*1024/1536),c(y,y+sin(angle)*r*.69),ink,3)
  grid.circle(x,y,r=unit(.007,"npc"),gp=gpar(fill=ink,col=NA))
  tx(letter,x,y-.085,15,ink,"bold","centre")
}
save("three-settings",function(){
  base(); tx("Three settings for the extremes.",.06,.90,34,face="bold")
  x <- seq(-10,190,length.out=900)
  pars <- list(c(65,12,.1),c(45,22,.1),c(45,12,.45))
  for(i in 1:3) {
    mid <- c(.205,.5,.795)[i]; left <- mid-.12
    tx(c("Level","Spread","Tail")[i],mid,.73,27,face="bold",just="centre")
    original <- dgev(x,45,12,.1); p <- pars[[i]]; yy <- dgev(x,p[1],p[2],p[3])
    xx <- left+(x+10)/200*.24
    ln(c(left,left+.24),c(.44,.44),grey,1)
    ln(xx,.44+original/.035*.19,"#b7b9b9",1.5,"dashed")
    if(i==3) {
      ok <- x>=95
      grid.polygon(c(xx[ok][1],xx[ok],tail(xx,1)),c(.44,.44+yy[ok]/.035*.19,.44),gp=gpar(fill=faint,col=NA))
    }
    ln(xx,.44+yy/.035*.19,ink,2.8)
    knob(mid,.30,c(.8,2.0,.4)[i],c("L","S","T")[i])
  }
  tx("One station. Three numbers to estimate.",.06,.085,19,grey)
})
save("station-tokens",function(){
  base();tx("Every station gets the same three.",.06,.90,34,face="bold")
  for(i in 1:3) {
    y <- c(.70,.45,.20)[i]
    tx(paste("Station",LETTERS[i]),.08,y,25,face="bold")
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
  tx("A, B, C = stations",.06,.12,14,grey)
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
cat("Verified: five design studies exported as PNG and SVG; text bounds checked; matrix cells are square.\n")
