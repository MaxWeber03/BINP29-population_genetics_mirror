# This script will run bracken on the kraken output. 

# Install bracken with conda
# conda create -n bracken -c bioconda
conda activate bracken
# conda install bracken=3.1

# Check version
bracken -v
# Bracken v3.0.1 => does not match what is given my conda, but I will go with 3.0.1 then

mkdir 10_bracken_db
mkdir 11_bracken_output

# make bracken db
bracken-build --help


# run bracken
while read line; do
    
    bracken \
        -d 08_kraken_db/SILVA_138_2_k2db \
        -i 09_kraken_output/${line}_report.kreport2 \
        -o 11_bracken_output/${line}_bracken_output \
        -w 11_bracken_output/${line}_bracken_report \
        -r 

        --threads 8 \
        --output 09_kraken_output/$line \
        --paired \
        --use-names \
        --report 09_kraken_output/${line}_report.kreport2 \
        "07_sample_seq/${line}_1.fastq" "07_sample_seq/${line}_2.fastq"

done < 02_sample_list/sample_selection_for_analysis.txt