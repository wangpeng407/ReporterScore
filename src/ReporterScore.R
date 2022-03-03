StatKOAttributes <- function(kodt, vs_group){
  #1 rownames are samples, colnames are varibles or KOs
  #2 for kodt, the last column must be groups
  #3 vs_group = c('A', 'B')
  t1 <- Sys.time()
  all.KOs <- colnames(kodt)[-ncol(kodt)]
  if(!all(vs_group %in% kodt$Group))
    stop(vs_group, "not in ", kodt$Group)
  g1 <- vs_group[1]
  g2 <- vs_group[2]
  s <- 1
  res.dt1 <- c()
  for(i in seq_len(length(all.KOs))){
    kn <- all.KOs[i]
    val1 <- kodt[kodt$Group %in% g1, ][, i]
    val2 <- kodt[kodt$Group %in% g2, ][, i]
    r <- rank(val1, val2)
	n.x <- as.double(length(val1))
    n.y <- as.double(length(val2))
	exact <- (n.x < 50) && (n.y < 50)
    TIES <- (length(r) != length(unique(r)))
    if(!(exact && TIES)){
      pval <- t.test(val1, val2)$p.value/2
      resinfo <- paste0(s, ": Ties exists or exact is false in ", kn, ", using t.test insead!")
      cat(resinfo, "\n")
      s <- s + 1
    }else{
      pval <- wilcox.test(val1, val2)$p.value/2
    }
	# mean1 sd1 mean2 sd2 diff_mean pvalue
    tmp <- c(mean(val1), sd(val1), mean(val2), sd(val2), mean(val1) - mean(val2), pval)
    res.dt1 <- rbind(res.dt1, tmp)
  }
  res.dt <- as.data.frame(res.dt1)
  rownames(res.dt) <- NULL
  res.dt <- data.frame(KO_id = all.KOs, res.dt, stringsAsFactors = F)
  colnames(res.dt) <- c('KO_id',
                        paste0('avg_', g1),
                        paste0('sd_', g1),
                        paste0('avg_', g2),
                        paste0('sd_', g2),
                        'diff_mean', 'p.value')
  res.dt$q.value <- p.adjust(res.dt$p.value, method = 'BH')
  res.dt$sign <- ifelse(res.dt$diff_mean < 0, -1, 1)
  res.dt$type <- ifelse(res.dt$diff_mean < 0, paste0(g1, '-Depleted'), paste0(g1,'-Enriched'))
  zs <- qnorm(res.dt$q.value)
  res.dt$Z_score <- ifelse( zs > 8.209536, 8.209536, zs)
  res.dt$Z_score <- ifelse(res.dt$sign < 0, -res.dt$Z_score, res.dt$Z_score)
  t2 <- Sys.time()
  deltat <- sprintf("%.3f", t2 - t1)
  resinfo <- paste0('Compared groups: ', g1, ' and ', g2, "\n",
                    'Total KO number: ', length(all.KOs), "\n",
                    'Time use: ', deltat, attr(deltat, 'units'), "\n")
  cat(resinfo)
  return(res.dt)
}


ReporterScoreCaculate <- function(modulelist, KOstat){
  t1 <- Sys.time()
  random_mean_sd_from_vec <- function(vec, Knum, perm = 1000){
    temp <- c()
    for(i in 1:perm){
      set.seed(i * (Knum + 1))
      temp.val <- sum(sample(vec, Knum))/sqrt(Knum)
      temp <- c(temp, temp.val)
    }
    res <- c(mean(temp), sd(temp))
    return(res)
  }

  modules <- modulelist$id
  reporterScores <- c()
  for(i in seq_len(length(modules))){
    # i <- 1
    mn <- modulelist$id[i]
    z <- KOstat$Z_score[KOstat$KO_id %in% strsplit(modulelist$KOs[i], ',')[[1]]]
    KOnum <- modulelist$K_num[i]
	clean.KO <- KOstat$Z_score[!is.na(KOstat$Z_score)]
	KOnum <- ifelse(length(clean.KO) >= KOnum, KOnum, length(clean.KO))
    mean_sd <- random_mean_sd_from_vec(clean.KO, KOnum, 1000)
    MEAN <- mean_sd[1]
    SD <- mean_sd[2]
    reporter_score <- (sum(z) / sqrt(KOnum) - MEAN)/SD
    reporterScores <- c(reporterScores, reporter_score)
  }
  reporter_res <- data.frame(ID = modules,
                             ReporterScore = reporterScores,
                             Description = module_list$Description)
  t2 <- Sys.time()
  deltat <- sprintf("%.3f", t2 - t1)
  resinfo <- paste0('ID number: ', length(modules), "\n",
                    'Time use: ', deltat, attr(deltat, 'units'), '\n')
  cat(resinfo)
  return(reporter_res)
}


path_get <- function(){
	res <- list()
	allargs <- commandArgs(trailingOnly = FALSE)
	scr.name <- sub('--file=', '', allargs[grepl('--file=', allargs)])
	abs_path <- normalizePath(scr.name)
	res$scr.path <- dirname(abs_path)
	res$scr.name <- scr.name
	return(res)
}
