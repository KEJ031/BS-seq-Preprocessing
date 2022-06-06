#!/bin/bash
#SBATCH --qos bbdefault
#SBATCH --ntasks 8 # request 8 cores for the job. N.B. check whether the fastq-dump can parallelise, else this is redundant and you should set to "1"
#SBATCH --nodes 1 # restrict the job to a single node. Necessary if requesting more than --ntasks=1
#SBATCH --time 1000 # this requests 2 hours, but you will need to adjust depending on runtime. Test job execution time with just a couple of input files then scale accordingly

module purge;
module load bluebear


FILES=data/3_mapped/*

for i in $FILES;
do
  (bismark_methylation_extractor --cytosine_report --CX_context --cutoff 3 \
    --genome_folder reference/* $i &&
  rm C??_*O?_${i%.bam}.txt ${i%.bam}.bedGraph.gz ${i%.bam}.bismark.cov.gz ${i%.bam}*.png) ;
done
