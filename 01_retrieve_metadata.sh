# Bash script to retrieve meta data from NCBI based on the sample list
# sample list 02_sample_list/NCBI.mine.metagenome.sampleID.txt

# make directory to store the meta data
mkdir 03_metadata

# loop over the sampleID and curl meta data
cat 02_sample_list/NCBI.mine.metagenome.sampleID.txt | \
    while read line; do
        curl -o 03_metadata/$line.tsv "https://www.ebi.ac.uk/ena/portal/api/search?result=read_run&query=sample_accession=$line&fields=all&format=tsv"
    done

# Extract sample ID, location, sequencing type (16S vs. Shotgut)
# My goal here is to extract the information and feed it into one table for plotting/analysis in Python/R => one sample per row, one variable per column, tidy format

# get the information line wise
# cat  03_metadata/SAMN24475639 | sed 's/\t/\n/g' | nl -ba
# nl adds line numbers to all lines (including empty ones)

# The extraction will be done in python with polars, thats supposed to be very fast/efficient due to polars' multihtreading and memory management

# make directory for meta data table
mkdir 04_metadata_table


