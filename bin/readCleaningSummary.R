#!/usr/bin/env R

library(readr)
reads<-read.delim("bbduk_stats.txt",header=FALSE)
colnames(reads)<-c('Sample','Category','NumberReads')
head(reads)

samples<-sort(unique(reads$Sample))

library(reshape2)

reads2<-dcast(reads, Sample ~ Category, value.var = "NumberReads")
head(reads2)
subset <- reads2[-1]

percentage_matrix <- apply(subset, 2, function(x) 100*x / subset$InputReads)

write.table(reads2, file = "read_cleaning_results.txt",quote=FALSE,sep="\t")

