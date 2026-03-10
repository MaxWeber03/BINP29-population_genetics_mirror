# Bash script to retrieve meta data from NCBI based on the sample list
# sample list 02_sample_list/NCBI.mine.metagenome.sampleID.txt

# make directory to store the meta data
mkdir 03_metadata

# loop over the sampleID and curl meta data
#cat 02_sample_list/NCBI.mine.metagenome.sampleID.txt | \
#    while read line; do
#        curl -o 03_metadata/$line.tsv "https://www.ebi.ac.uk/ena/portal/api/search?result=read_run&query=sample_accession=$line&fields=all&format=tsv"
#    done
# execution time:  6:35 min, 712 successful downloads

# make this faster with parallel downloading through xargs

cat 02_sample_list/NCBI.mine.metagenome.sampleID.txt | \
    xargs -P 500 -I {} \
    curl --connect-timeout 15 -sS -o 03_metadata/{}.tsv "https://www.ebi.ac.uk/ena/portal/api/search?result=read_run&query=sample_accession={}&fields=all&format=tsv"

# execution time reduced to: 56 seconds, 711 successful downloads
# => the error is always SSL_ERROR_ZERO_RETURN in connection to www.ebi.ac.uk:443
# connection to the server seems unstable, the number of successfully downloaded files varies around 709-714. At the end, the process is waiting for a response until timing out. This especially slow, if not done in parallel.

# xargs:
# -P number of parallel executions
# {} is like the variable in the previous version. xarg reads each line of stdin as one version of {}
# -sS makes curl silent except errors
# --connect-timeout 15 gives curl a maximum of 15 seconds without server response before timing out

# In testing, running curl on everything twice lead to a higher number of files successfully downloaded. The number did not furter increase with three runs.
# So I will run it a second time
cat 02_sample_list/NCBI.mine.metagenome.sampleID.txt | \
    xargs -P 500 -I {} \
    curl --connect-timeout 15 -sS -o 03_metadata/{}.tsv "https://www.ebi.ac.uk/ena/portal/api/search?result=read_run&query=sample_accession={}&fields=all&format=tsv"

# Extract sample ID, location, sequencing type (16S vs. Shotgut)
# My goal here is to extract the information and feed it into one table for plotting/analysis in Python/R => one sample per row, one variable per column, tidy format

# get the information line wise
# cat  03_metadata/SAMN24475639 | sed 's/\t/\n/g' | nl -ba
# nl adds line numbers to all lines (including empty ones)

# The extraction will be done in python with polars, thats supposed to be very fast/efficient due to polars' multihtreading and memory management

# make directory for meta data table
mkdir 04_metadata_table
mkdir 05_metadata_cleaned
mkdir 06_static_plots


