#!/bin/bash -l
set -e
set -u 

module load Anaconda3/2020.07 
conda activate qiime2-2021.8

# Import Silva 132 99 sequences -> qiime artifact
qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path 'rep_set/rep_set_16S_only/99/silva_132_99_16S.fna' \
  --output-path S132_99_sequences.qza

# Import 7-lvl taxonomy -> qiime artifact
qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat \
  --input-path 'taxonomy/16S_only/99/majority_taxonomy_7_levels.txt' \
  --output-path reference_taxonomy.qza

# Extract reference reads for V3-V4 region
# 341f: CCTACGGGNGGCWGCAG
# 806r: GACTACHVGGGTATCTAATCC
qiime feature-classifier extract-reads \
  --i-sequences S132_99_sequences.qza \
  --p-f-primer CCTACGGGNGGCWGCAG \
  --p-r-primer GACTACHVGGGTATCTAATCC \
  --o-reads reference_reads.qza

# Train naive bayes classifier
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads reference_reads.qza \
  --i-reference-taxonomy reference_taxonomy.qza \
  --o-classifier S132_v3v4_for_qiime2-2021.10.qza
  
# Test classifier
## https://docs.qiime2.org/2020.2/tutorials/feature-classifier/#
qiime feature-classifier classify-sklearn \
  --i-classifier S132_v3v4_for_qiime2-2021.10.qza \
  --i-reads rep-seqs.qza \
  --o-classification taxonomy.qza

qiime metadata tabulate \
  --m-input-file taxonomy.qza \
  --o-visualization taxonomy.qzv
  
conda deactivate
