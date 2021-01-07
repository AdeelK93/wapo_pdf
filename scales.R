#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly=TRUE)
magW <- args[1]
magH <- args[2]

con <- file("stdin")
tocRaw <- readLines(con, warn = F)
close(con)

toc <- jsonlite::fromJSON(sub(");","",sub("tocCallback(","",tocRaw,fixed=T,useBytes=T),fixed=T,useBytes=T))
# page scales for API
cat(floor(pmin(100 * 1728 / toc$Pages$Width, 100 * 3024 / toc$Pages$Height)))
cat(";")
# pages to exclude
cat(pmin(
  # ads
  sapply(toc$Pages$Articles,length),
  # sports
  sapply(toc$Pages$PageName,function(x) as.numeric(substr(x,1,1)!="D")),
  # obituaries
  sapply(toc$Pages$SectionName,function(x) as.numeric(x!="DEATH NOTICE"))
))
cat("\n")
