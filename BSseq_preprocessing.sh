#!/bin/bash

################################################################################
#  Preprocessing for BSseq raw reads
################################################################################
# create a workplace ie. your working directory.

###### in workplace
mkdir -p data
mkdir -p data/1_raw
mkdir -p data/2_trimmed
mkdir -p data/2_mapped
mkdir -p data/3_dedup_sorted
mkdir -p data/4_methylation_call

mkdir -p reference

mkdir -p qc
mkdir -p qc/1_raw_qc
mkdir -p qc/2_trimmed_qc
mkdir -p qc/reports

set -e  # this ensures that the script fails if any of the commands result in an error


###############################################################################
# 1. quality check raw reads
###############################################################################

# check quality using fastqc
fastqc -o qc/1_raw_qc/ data/1_raw/*.fastq.gz

# Condense reports with MultiQC
multiqc --filename qc/1_raw/fastqc_raw_multiqc qc/1_raw

###############################################################################
# 2. Trimming raw reads
###############################################################################
source trim-bs.sh

#Condense fastp reports with MultiQC

multiqc --filename qc/2_trimmed/fastp_multiqc 2_trimmed

###############################################################################
# 3. Quality check trimmed reads
###############################################################################

fastqc -o /qc/2_trimmed_qc/ data/2_trimmed/*_trimmed.fq.gz

multiqc --filename qc/2_trimmed_qc/fastqc_trimmed_multiqc 2_trimmed

###############################################################################
# 4. Align reads (Bismark)
###############################################################################

source align.sh

# check the alignments in IGV

###############################################################################
# 5. Deduplication, sort and index
###############################################################################

source dedup_sort_index.sh



###############################################################################
# 6. Methylation extracion - call files (CX files)
###############################################################################

# we can take the alignments in .bam format and extract the methylation statistics for each cytosine.
# This is done by Bismark’s auxilary program bismark_methylation_extractor and produces a table with
# all the cytosines in the genome as rows and chr, position, meth, unmeth & context as columns.


# this will creates a lot of intermediate files so be sure to have at least 15 GB of free space in you computer.
# The rm command should remove some unnecesary outputs

source cx_call.sh

###############################################################################
# 7. Bismark stats.
###############################################################################

# bismarl reports will all be stored in data/3_mapped.
# We will run these report tools and clean up the directories

cd $dir/workplace/data/3_mapped
  bismark2report



# Move CX_reports to a different folder in data
  cd $dir/workplace/data/3_mapped
  mkdir ../4_CX_reports
  for i in *.CX_report.txt*; do
    mv $i ../4_CX_reports/${i/_trimmed_bismark_bt2.deduplicated/}
  done

# Move qa reports to qa folder
  cd $dir/workplace/data/3_mapped
  mv *_report*  ../../qc/reports/
  mv *M-bias*   ../../qc/reports/
  mv *summary*  ../../qc/reports/

# and finally make Multiqc reports of bismark

  cd $dir/workplace/qc/reports
  multiqc --filename bismark_multiqc .
