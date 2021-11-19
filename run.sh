#pathway enrichment analysis

#remove the KO that sum is 0
#perl -MList::Util=sum -lane'$.==1 && print ; $.==1 && next; sum(@F[1..$#F]) == 0 && next; print ' KO.rela.xls > non-zero-KO.rela.xls
Rscript caculate_reporter_score.R --group group.list --abund non-zero-KO.rela.xls --type pathway --outdir pathway
Rscript plot_reporter.score.R pathway/reporter_score.xls pathway/

#module enrichment analysis
Rscript caculate_reporter_score.R --group group.list --abund non-zero-KO.rela.xls --type module --outdir module
Rscript plot_reporter.score.R module/reporter_score.xls module/
