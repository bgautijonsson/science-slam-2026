# Science Slam visual draft. Run Rscript make-visuals.R from this directory.
# Illustrative GEV densities and Hessian sparsity patterns, not research data.
library(grid)
library(ragg)
library(svglite)

bg <- "#faf9f9"; ink <- "#182e48"; blue <- "#397ca8"
muted <- "#617080"; pale <- "#e5e9ee"; grey <- "#aeb7c1"
font <- "Lato"
dir.create("figures", showWarnings = FALSE)
checks <- list()

txt <- function(label, x, y, size=22, colour=ink, face="plain", just="left") {
  gp <- gpar(fontfamily=font, fontsize=size, col=colour, fontface=face, lineheight=1.18)
  g <- textGrob(label, x=x, y=y, just=just, gp=gp)
  w <- convertWidth(grobWidth(g), "npc", valueOnly=TRUE)
  h <- convertHeight(grobHeight(g), "npc", valueOnly=TRUE)
  left <- if(just=="left") x else if(just=="right") x-w else x-w/2
  if (left < -0.001 || left+w > 1.001 || y-h/2 < -0.001 || y+h/2 > 1.001)
    stop("Text exceeds canvas: ", label)
  grid.draw(g)
}
line <- function(x, y, colour=ink, width=1.5, dash="solid")
  grid.lines(x, y, gp=gpar(col=colour, lwd=width, lty=dash))
rect <- function(x,y,w,h,fill,stroke=NA,width=1) grid.rect(x,y,w,h,gp=gpar(fill=fill,col=stroke,lwd=width))
canvas <- function(title, eyebrow=NULL) {
  grid.newpage(); rect(.5,.5,1,1,bg)
  if(!is.null(eyebrow)) txt(eyebrow,.06,.95,11,muted)
  txt(title,.06,.865,29,face="bold")
}
save_slide <- function(name, draw) {
  ragg::agg_png(file.path("figures",paste0(name,".png")),width=1536,height=1024,res=144)
  draw(); dev.off()
  svglite::svglite(file.path("figures",paste0(name,".svg")),width=1536/144,height=1024/144)
  draw(); dev.off()
  checks[[name]] <<- "PNG and SVG drawn; all text bounding boxes inside canvas"
}

dgev <- function(x, mu, sigma, xi) {
  z <- (x-mu)/sigma
  if (abs(xi)<1e-8) return(exp(-z-exp(-z))/sigma)
  t <- 1+xi*z
  ans <- rep(0,length(x)); ok <- t>0
  ans[ok] <- exp(-(1+1/xi)*log(t[ok])-t[ok]^(-1/xi))/sigma
  ans
}
# Independently check each plotted density integrates to one over its support.
cases <- list(c(45,12,.1),c(65,12,.1),c(45,22,.1),c(45,12,.45))
for(p in cases) {
  val <- integrate(function(x) dgev(x,p[1],p[2],p[3]),
                   lower=p[1]-p[2]/p[3],upper=Inf,subdivisions=2000,rel.tol=1e-10)$value
  stopifnot(abs(val-1)<1e-5)
}

draw_gev <- function(reveal) {
  canvas("Three numbers describe the extremes", "ONE STATION")
  titles <- c("Level","Spread","Tail")
  subtitles <- c("Rough size","How much they vary","The rarest extremes")
  xx <- seq(-10,190,length.out=800)
  for(i in seq_len(reveal)) {
    cx <- c(.205,.5,.795)[i]; left <- cx-.125; bottom <- .35
    txt(titles[i],cx,.71,26,face="bold",just="centre")
    txt(subtitles[i],cx,.64,15,muted,just="centre")
    yy <- dgev(xx,45,12,.1); p <- cases[[i+1]]
    changed <- dgev(xx,p[1],p[2],p[3])
    mapx <- left+(xx+10)/200*.25
    mapy <- function(y) bottom+y/.035*.235
    line(c(left,left+.25),c(bottom,bottom),grey,1)
    line(mapx,mapy(yy),grey,2.2,"dashed")
    if(i==3) {
      take <- xx>=95
      grid.polygon(c(mapx[take][1],mapx[take],tail(mapx,1)),
                   c(bottom,mapy(changed[take]),bottom),gp=gpar(fill="#c8dce9",col=NA))
    }
    line(mapx,mapy(changed),ink,2.7)
    if(i==1) {
      grid.lines(c(left+.067,left+.091),c(.31,.31),arrow=arrow(length=unit(.07,"inches")),gp=gpar(col=blue,lwd=2))
    } else if(i==2) {
      grid.lines(c(left+.045,left+.135),c(.31,.31),arrow=arrow(ends="both",length=unit(.07,"inches")),gp=gpar(col=blue,lwd=2))
    } else {
      txt("rarer, larger",left+.153,.31,12,blue,just="centre")
    }
    txt("Annual maximum rainfall",cx,.25,12,muted,just="centre")
  }
  txt("How big can a year's heaviest rainfall get?",.06,.12,17,ink)
  txt("Illustrative GEV curves",.94,.055,10,muted,just="right")
}
for(i in 1:3) save_slide(paste0("gev-",i),function() draw_gev(i))

station_row <- function(y, name, labels=TRUE) {
  txt(paste("Station",name),.13,y,21,face="bold")
  for(j in 1:3) {
    x <- c(.49,.67,.85)[j]
    grid.circle(x,y,r=.031,gp=gpar(fill=ink,col=NA))
    txt(c("L","S","T")[j],x,y,18,"white",face="bold",just="centre")
    if(labels) txt(c("Level","Spread","Tail")[j],x,y-.069,15,muted,just="centre")
  }
}
save_slide("stations",function(){
  canvas("Three stations. Nine quantities to estimate.")
  station_row(.69,"A"); station_row(.46,"B"); station_row(.23,"C")
})

# Relative exponential likelihood at rate 1: a toy uncertainty illustration.
# The negative log-likelihood Hessian there equals n. Both lines peak at one.
save_slide("uncertainty",function(){
  canvas("How sure are we about an estimate?", "NOW: UNCERTAINTY ABOUT A PARAMETER")
  txt("Rainfall values",.06,.745,15,muted)
  txt("→",.24,.745,22,blue)
  txt("Possible values of a parameter",.285,.745,17,blue,face="bold")
  x <- seq(.01,3.5,length.out=600)
  for(i in 1:2) {
    n <- c(30,3)[i]; left <- c(.10,.56)[i]; bottom <- .275
    likelihood <- exp(n*(log(x)-x+1)); approx <- exp(-n*(x-1)^2/2)
    mapx <- left+x/3.5*.34; mapy <- function(y) bottom+y*.28
    txt(c("Pinned down","Room for doubt")[i],left+.17,.63,22,face="bold",just="centre")
    line(c(left,left+.34),c(bottom,bottom),grey,1)
    line(mapx,mapy(likelihood),ink,2.5)
    line(mapx,mapy(approx),blue,2.5,"dashed")
    txt("Possible parameter value",left+.17,.225,13,muted,just="centre")
  }
  line(c(.1,.15),c(.14,.14),ink,2.5); txt("Likelihood",.17,.14,14)
  line(c(.45,.50),c(.14,.14),blue,2.5,"dashed"); txt("Normal approximation",.52,.14,14)
  txt("The Hessian records curvature near the peak.",.06,.06,17,face="bold")
})

# Schematic 9x9 patterns, ordered station then Level/Spread/Tail.
# Values below form SPD precision examples solely to check the patterns can
# represent proper Gaussian approximations. Colour encodes structure, not sign.
station <- rep(1:3,each=3)
types <- c("separate","within","between")
for(kind in types) {
  M <- diag(9)*2
  same <- outer(station,station,"==")
  adjacent <- abs(outer(station,station,"-"))==1
  if(kind!="separate") M[same & row(M)!=col(M)] <- .3
  if(kind=="between") M[adjacent] <- -.10
  stopifnot(max(abs(M-t(M)))==0,min(eigen(M,symmetric=TRUE)$values)>0)
}
draw_matrix <- function(stage, comparison=FALSE) {
  titles <- c("Treat every estimate separately", "Keep the links within each station", "Keep the links between stations too")
  canvas(titles[stage],"THE SAME NINE QUANTITIES")
  left <- .495; top <- .725; cell <- .044; cell_y <- cell*1536/1024
  stopifnot(abs(cell*1536-cell_y*1024)<1e-10)
  centers <- left+(0:8+.5)*cell
  yy <- top-(0:8+.5)*cell_y
  for(i in 1:9) for(j in 1:9) {
    colour <- pale
    if(i==j) colour <- ink
    if(stage>=2 && station[i]==station[j]) colour <- ink
    if(stage==3 && abs(station[i]-station[j])==1) colour <- blue
    rect(centers[j],yy[i],cell*.89,cell_y*.89,colour)
  }
  for(s in 1:3) {
    x <- mean(centers[((s-1)*3+1):(s*3)])
    y <- mean(yy[((s-1)*3+1):(s*3)])
    txt(paste("Station",LETTERS[s]),x,.796,14,face="bold",just="centre")
    txt(paste("Station",LETTERS[s]),.418,y,15,face="bold",just="right")
    line(c(left+(s-1)*3*cell,left+s*3*cell),c(.777,.777),grey,.8)
    line(c(.441,.441),c(top-(s-1)*3*cell_y,top-s*3*cell_y),grey,.8)
  }
  for(i in 1:9) {
    txt(c("L","S","T")[(i-1)%%3+1],centers[i],.751,12,muted,just="centre")
    txt(c("L","S","T")[(i-1)%%3+1],.473,yy[i],12,muted,just="centre")
  }
  for(k in c(3,6)) {
    line(rep(left+k*cell,2),c(top,top-9*cell_y),bg,4)
    line(c(left,left+9*cell),rep(top-k*cell_y,2),bg,4)
  }
  words <- c("Ignore the\nconnections.","Three estimates\nfitted together\nat each station.","Rainfall links\nstations.\nTheir estimates\nare linked too.")
  txt(words[stage],.06,.54,18,if(stage==3) blue else ink)
  txt("Level · Spread · Tail",.06,.16,15,muted)
  txt("Schematic likelihood Hessian",.94,.032,10,muted,just="right")
  if(stage==3) { rect(.507,.095,.014,.021,blue); txt("Added links between stations",.53,.095,12,blue) }
}
for(i in 1:3) save_slide(paste0("hessian-",i),function() draw_matrix(i))

save_slide("payoff",function(){
  canvas("One storm can affect several stations.")
  # One shared weather system, shown as an outline over all three stations.
  grid.roundrect(.5,.57,.76,.27,r=unit(.08,"npc"),gp=gpar(col=grey,fill=NA,lwd=2))
  txt("Same storm",.5,.6,26,face="bold",just="centre")
  for(i in 1:3) {
    x <- c(.23,.5,.77)[i]
    for(dx in c(-.04,0,.04)) line(c(x+dx,x+dx-.01),c(.47,.41),blue,1.6)
    grid.circle(x,.30,r=.034,gp=gpar(fill=ink,col=NA))
    txt(LETTERS[i],x,.30,18,"white",face="bold",just="centre")
    txt(paste("Station",LETTERS[i]),x,.22,17,just="centre")
  }
  txt("Our uncertainty needs to reflect those connections.",.5,.10,21,face="bold",just="centre")
})
save_slide("ending",function(){
  canvas("The Hessian wasn't the enemy.")
  txt("Assuming independence\nwas the enemy.",.06,.49,38,face="bold")
})

# A comparison sheet for checking all three patterns together.
ragg::agg_png("figures/ladder-overview.png",width=2304,height=800,res=144)
grid.newpage(); rect(.5,.5,1,1,bg)
for(stage in 1:3) {
  pushViewport(viewport(x=(stage-.5)/3,y=.5,width=1/3,height=1))
  txt(c("1  Separate estimates","2  Within each station","3  Between stations too")[stage],.08,.91,19,face="bold")
  left <- .19; top <- .76; cw <- .07; ch <- cw*768/800
  for(i in 1:9) for(j in 1:9) {
    colour <- pale
    if(i==j || (stage>=2 && station[i]==station[j])) colour <- ink
    if(stage==3 && abs(station[i]-station[j])==1) colour <- blue
    rect(left+(j-.5)*cw,top-(i-.5)*ch,cw*.89,ch*.89,colour)
  }
  for(s in 1:3) {
    txt(LETTERS[s],left+(s*3-1.5)*cw,.82,15,face="bold",just="centre")
    txt(LETTERS[s],.12,top-(s*3-1.5)*ch,15,face="bold",just="centre")
  }
  popViewport()
}
dev.off()
writeLines(c("Verified GEV density integrals: all four within 1e-5 of one.",
             "Verified three numerical pattern examples: symmetric and positive definite.",
             unlist(Map(function(k,v) paste(k, v, sep=": "),names(checks),checks))),
           stdout())
