# Install metaphlan

#conda create -n metaphlan -c bioconda
conda activate metaphlan
#conda install bioconda::metaphlan

# Verify Version
metaphlan --version
# MetaPhlAn version 4.2.4 (21 Oct 2025)

# run metaphlan
metaphlan \
    --input_type fastq \