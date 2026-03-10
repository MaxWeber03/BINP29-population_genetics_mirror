# Select 3 16S samples from sweden
# For simplicity the sample to be used for analysis with metaphlan are hardcoded into 02_sample_list/sample_selection_for_analysis.txt
# A more extensive list of samples can be used by adding sampled to that file. 

# The sequences for these samples must be downloaded for the analyis with metaphlan
mkdir 07_sample_seq

# to download the sequences, we can loop over the list of samples, then extract the link from the 
# metadata table with awk, extract the filename from link, and download the file with curl
# This is done twice, once for each link (fwd/rev).
cat 02_sample_list/sample_selection_for_analysis.txt | \
    while read line; do
        link1=$(grep $line 05_metadata_cleaned/metadata_cleaned.tsv | awk {'print $2'})
        filename1=$(basename "$link1")
        curl -o "07_sample_seq/$filename1" "$link1"

        link2=$(grep $line 05_metadata_cleaned/metadata_cleaned.tsv | awk {'print $3'})
        filename2=$(basename "$link2")
        curl -o "07_sample_seq/$filename2" "$link2"
done

echo "Download of sequences finished"

gunzip 07_sample_seq/*.gz

echo "Decompression finished"


