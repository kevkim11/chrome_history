# Plot your Chrome History
# 

library(ggplot2)
library(dplyr)

Sys.setlocale("LC_TIME", "en_US")

a = read.table("my_history.csv",sep = ",",header = TRUE)
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

a = a %>% group_by(web,month) %>% mutate(
  mfilter = length(web) > 0.03*nm,
  wfilter = length(web) > 0.03*nw
)

b = a
b[!b$mfilter,]$web <- "other"
b$web <- factor(b$web,levels=unique(b$web),ordered = TRUE)
month_plot <- ggplot(data = b,aes(x = month,fill=web)) + 
  geom_bar()

c = a
c[!c$mfilter,]$web <- "other"
c$wkd <- factor(c$wkd,levels=c("Monday","Tuesday", "Wednesday", "Thursday", "Friday", "Saturday","Sunday"),ordered = TRUE)
c$web <- factor(c$web,levels=unique(c$web),ordered = TRUE)

week_day_plot <- ggplot(data = c,aes(x = wkd,fill=web,color = web)) + 
  geom_bar() 

unif.theme <- theme(
  panel.background = element_rect(fill = "white"),
  panel.grid.major.y = element_line(colour = "gray"),
  axis.line.y = element_line(color = "black"),
  axis.ticks = element_blank(),
  axis.title = element_blank(),
  axis.text = element_text(color = "black"),
  axis.text.x = element_text(size = rel(1.5)),
  legend.title = element_blank(),
  legend.text = element_text(size = rel(1.2))
) 

colors <- scale_color_brewer(palette = "Spectral",direction = -1) 
fill <- scale_fill_brewer(palette = "Spectral",direction = -1)


month_plot + unif.theme + colors + fill
week_day_plot + unif.theme + colors + fill

