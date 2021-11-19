#args <- commandArgs(T)
#length(args) == 
library(optparse)
option_list <- list(
  make_option(c("--group"), action="store", type="character", default=NULL, help="Input the group.list"),
  make_option(c("--abund"), action="store", type="character", default=NULL, help="Input the Unigenes.relative.ko.xls, no detailed information"),
  make_option(c("--type"), action="store", default='module', type="character", help="Enrichment type module or pathway, default is module"),
  make_option(c("--outdir"), action="store", default="./", type="character", help="The output dirctory, default is ./")
)  
opt <- parse_args(OptionParser(usage="%prog [options] file\n", option_list=option_list))

path_get <- function(){
	res <- list()
	allargs <- commandArgs(trailingOnly = FALSE)
	scr.name <- sub('--file=', '', allargs[grepl('--file=', allargs)])
	abs_path <- normalizePath(scr.name)
	res$scr.path <- dirname(abs_path)
	res$scr.name <- scr.name
	return(res)
}

Repsc <- paste(path_get()$scr.path, "src/ReporterScore.R", sep="/")
if(file.exists(Repsc)){
	source(Repsc)
}else{
	cat("NO ", Repsc, 'exists, check please!\n')
	quit()
}


if(is.na(file.info(opt$outdir)$isdir)) dir.create(opt$outdir, recursive = TRUE)

internal_list <- ifelse(opt$type == 'module', paste0(path_get()$scr.path, "/list/module_stat_KO.xls"), paste0(path_get()$scr.path,"/list/path_stat_KO.xls"))
module_list <- read.table(internal_list, stringsAsFactors = F, sep = '\t', header = T, quote = "")

group <- read.table(opt$group, sep = '\t', header = F)

kodt <- read.table(opt$abund, sep = '\t', row.names = 1, header = T)
kodt$Detail_info <- NULL
kodt <- as.data.frame(t(kodt))
kodt$Group <- group$V2[match(rownames(kodt), group$V1)]
kodt$Others <- NULL
unique_group <- levels(kodt$Group)
comp_groups <- as.data.frame(combn(unique_group, 2), stringsAsFactors = F)
colnames(comp_groups) <- paste0('vs', seq_len(ncol(comp_groups)))

outfile1 = paste0(opt$outdir, "/stat.ko.res.xls")
outfile2 = paste0(opt$outdir, "/reporter_score.xls")

if(file.exists(outfile1)){
	stat.ko.res <- read.table(outfile1, sep="\t", header = T)
}else{
	stat.ko.res <- StatKOAttributes(kodt = kodt, vs_group = comp_groups$vs1)
}
#stat.ko.res <- read.table(outfile1, sep="\t", header = T)
#stat.ko.res <- StatKOAttributes(kodt = kodt, vs_group = comp_groups$vs1)

final_rep_score <- ReporterScoreCaculate(modulelist = module_list, KOstat = stat.ko.res)

write.table(stat.ko.res, file = outfile1, quote = F, row.names = F, sep = '\t')
write.table(final_rep_score, file = outfile2, quote = F, row.names = F, sep = '\t')
cat("######DONE######")
