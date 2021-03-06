# Plot your Chrome History
#

suppressPackageStartupMessages(library("optparse"))
option_list = list(
  make_option(c("-f", "--file"), action="store", default=NULL, type='character',
              help="filename with the db"),
  make_option(c("-t", "--thresh"), action="store", default=0.03, type='character',
              help="threshold for the other category"),
  make_option(c("-o", "--out"), action="store", default="chrome_hist.pdf", 
              type='character',
              help="the output file"),
  make_option(c("-w", "--week"), action="store_true", default=TRUE, 
              type='character',
              help="For the week days plot"),
  make_option(c("-m", "--month"), action="store_false", dest = "week", 
              type='character',
              help="For the moth plot"),
  make_option(c("-v", "--verbose"), action="store_true", default=FALSE,
              help="Should the program print extra stuff out? [default %default]")
)


opt = parse_args(OptionParser(option_list=option_list))


if (opt$v) {
  print(opt)
  library("RSQLite")
  library(ggplot2)
  library(dplyr)
  library(RColorBrewer)
} else{
  suppressPackageStartupMessages(library("RSQLite"))
  suppressPackageStartupMessages(library(ggplot2))
  suppressPackageStartupMessages(library(dplyr))
  suppressPackageStartupMessages(library(RColorBrewer))
}


# to avoid lunes martes ...
Sys.setlocale("LC_TIME", "en_US")


# conecting to the db
if (opt$v) {cat("conecting to the db...\n")}
con <- dbConnect(RSQLite::SQLite(), opt$file)

query <- "SELECT datetime(last_visit_time/1000000-11644473600,'unixepoch','localtime'),url FROM urls ORDER BY last_visit_time DESC;"

a = dbGetQuery(con,query)

if (opt$v) {dbDisconnect(con)} else {suppressWarnings(dbDisconnect(con))}
if (opt$v) {cat("Discoconected from the db...\n")}

colnames(a) <- c("date","web")
a$date <- as.Date(a$date)
a$web <- as.character(a$web)
a  <- filter(a,date > as.Date("2016-01-01"))

a$web <- apply(a,1,function(x){
  unlist(strsplit(x[2],"/"))[3]
  })

a$month <- format(a$date,"%Y-%m")
a$wkd <- weekdays(a$date)
a = a %>% group_by(month) %>% mutate(
  nm = n()
)
a = a %>% group_by(wkd) %>% mutate(
  nw = n()
)

if (opt$v) {
  cat("Cut-off set in ..")
  print(as.numeric(opt$thresh))}


a = a %>% group_by(web,month) %>% mutate(
  mfilter = length(web) > as.numeric(opt$thresh) * nm,
  wfilter = length(web) > as.numeric(opt$thresh) * nw
)

if (opt$v) {cat("Processing finished\n")}

if (opt$v) {cat("Plotting...")}
if(opt$w){
  c = a
  c[!c$wfilter,]$web <- "other"
  c$wkd <- factor(c$wkd,levels=c("Monday","Tuesday", "Wednesday", "Thursday", "Friday", "Saturday","Sunday"),ordered = TRUE)
  webs <- c %>% group_by(web) %>% summarise(
    n = n()
  )
  webs <- webs[order(webs$n,decreasing = TRUE),]
  c$web <- factor(c$web,levels=webs$web,ordered = TRUE)
  week_day_plot <- ggplot(data = c,aes(x = wkd,fill=web,color = web)) +
    geom_bar()
  ncolors <- length(unique(c$web))
} else {
  b = a
  b[!b$mfilter,]$web <- "other"
  webs <- b %>% group_by(web) %>% summarise(
    n = n()
  )
  webs <- webs[order(webs$n,decreasing = TRUE),]
  b$web <- factor(b$web,levels=webs$web,ordered = TRUE)
  month_plot <- ggplot(data = b,aes(x = month,fill=web)) +
    geom_bar()
  ncolors <- length(unique(b$web))
}


unif.theme <- theme(
  panel.background = element_rect(fill = "white"),
  panel.grid.major.y = element_line(colour = "gray"),
  panel.grid.major.x = element_blank(),
  axis.line.y = element_line(color = "black"),
  axis.ticks = element_blank(),
  axis.title = element_blank(),
  axis.text = element_text(color = "black"),
  axis.text.x = element_text(size = rel(1.5)),
  legend.title = element_blank(),
  legend.text = element_text(size = rel(1.2))
)

if(ncolors <= 11){
  colors <- brewer.pal(n = ncolors,"Spectral")
} else {
  colors.tmp <- brewer.pal(n = 11,"Spectral")
  colfunc <- colorRampPalette(colors.tmp)
  colors <- colfunc(ncolors)
}
color <- scale_color_manual(values = rev(colors))
fill <- scale_fill_manual(values = rev(colors))


if(opt$w){
  fp <- week_day_plot + unif.theme + color + fill
} else {
  fp <- month_plot + unif.theme + color + fill
}

if (opt$v) {cat("saving the output...")}
ggsave(filename = opt$out,
       plot = fp,
       device = "pdf",
       height = 5, 
       width = 11, 
       units = "in")


