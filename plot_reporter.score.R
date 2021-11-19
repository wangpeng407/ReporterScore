args <- commandArgs(T)
if(length(args) != 2){
  cat('Rscript plot_reporter.score.R reporter_score.xls outdir\n')
  quit()
}
library(ggplot2)
dt <- read.table(args[1], sep = '\t', header = T)
dt2 <- dt[abs(dt$ReporterScore) >= 1.6, ]
dt2 <- dt2[complete.cases(dt2), ]
dt2$Group <- ifelse(dt2$ReporterScore > 0, 'P', 'N')
dt2$name <- paste0(dt2$Description, ' (', dt2$ID, ')')
p <- 
  ggplot(dt2, aes(reorder(name, ReporterScore), ReporterScore, fill = Group)) + 
  geom_bar(stat = 'identity', position='dodge')+
  geom_hline(yintercept = 1.6, linetype = 2)+
  geom_hline(yintercept = -1.6, linetype = 2)+
  scale_fill_manual(values=c('#008B45', '#EE2C2C')) +
  coord_flip()+
  theme_light()+
  theme(
	legend.position = "none",
    axis.title.y=element_blank(),
    axis.text.x = element_text(colour='black',size=10, angle = 90, hjust = 1)
  )
ggsave(filename = paste0(args[2], '/reporter_score.pdf'),height = nrow(dt2)/6, width = 15, limitsize=FALSE)
