#!/bin/bash
#SBATCH --qos bbdefault
#SBATCH --ntasks 8 # request 8 cores for the job. N.B. check whether the fastq-dump can parallelise, else this is redundant and you should set to "1"
#SBATCH --nodes 1 # restrict the job to a single node. Necessary if requesting more than --ntasks=1
#SBATCH --time 1000 # this requests 2 hours, but you will need to adjust depending on runtime. Test job execution time with just a couple of input files then scale accordingly

module purge;
module load bluebear
module load fastp/0.20.1-GCC-8.3.0

FILES=data/1_raw/*.fq.gz

for f in $FILES;
do
    fastp --thread 4 --cut_right  --cut_window_size 4 --cut_mean_quality 20 --length_required 40 \
    --overrepresentation_analysis \
    -i $f -o data/2_trimmed/${f_trimmed.fq.gz} \
    --html reference/qc/2_trimmed_qc/${f%.fq.gz}_fastp.html \
    --json reference/qc/2_trimmed_qc/${f%.fq.gz}_fastp.json \
    --report_title ${i%.fastq.gz} ;
  done
