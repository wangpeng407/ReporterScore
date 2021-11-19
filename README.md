- Description:

  This analysis tool was develeped for KEGG enrichment analysis according to the published article **"Dynamics and Stabilization of the Human Gut Microbiome during the First Year of Life"**.

- Dependencies of R packages 

  optparse, ggplot2

- For pathway enrichment caculation:

  ```Rscript caculate_reporter_score.R --group group.list --abund KO.rela.xls --type pathway --outdir pathway```

- For module enrichment caculation:

  ```Rscript caculate_reporter_score.R --group group.list --abund KO.rela.xls --type module --outdir module```  

  This command will generate two files "stat.ko.res.xls" and "reporter_score.xls". More result interprations, please see the published article.

- Visualization:

  ```Rscript plot_reporter.score.R pathway/reporter_score.xls pathway/```

  ```Rscript plot_reporter.score.R module/reporter_score.xls module/```

