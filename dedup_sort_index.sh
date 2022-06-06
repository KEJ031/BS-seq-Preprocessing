#!/bin/bash
#SBATCH --qos bbdefault
#SBATCH --ntasks 8 # request 8 cores for the job. N.B. check whether the fastq-dump can parallelise, else this is redundant and you should set to "1"
#SBATCH --nodes 1 # restrict the job to a single node. Necessary if requesting more than --ntasks=1
#SBATCH --time 1000 # this requests 2 hours, but you will need to adjust depending on runtime. Test job execution time with just a couple of input files then scale accordingly

module purge;
module load bluebear

#Check the methylation of the Chloroplast in the SE_reports to check the bisulfite conversion rate
#Sort the alignments and create and index to load into IGV

  cd $dir/workplace/data/3_mapped
FILES=data/3_mapped/*

for i in $FILES;
do
samtools sort -@4 $i -o ${i%.bam}_sorted.bam &&
samtools index ${i%.bam}_sorted.bam
done

for i in $FILES;
do
deduplicate_bismark --bam $i ;
done

for i in $FILES;
do
  samtools sort -@4 $i -o ${i%.bam}_sorted.bam &&
  samtools index ${i%.bam}_sorted.bam
done 
