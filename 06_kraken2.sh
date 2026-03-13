# This script will run kraken2 on the raw sequences. This is not the correct way, as preprocessing (trimming, deduplication, chimera removal) would be necessary. However, that is out of scope for this project.

# Install kraken2 with conda
# conda create -n kraken2 -c bioconda
# conda activate kraken2
# conda install kraken2=2.17.1

# Confirm version
kraken2 --version
# Kraken version 2.17.1  
# kraken2 --help


# Prepare silva db for kraken
mkdir 08_kraken_db
mkdir 09_kraken_output

curl -o 08_kraken_db/SILVA_138_2_k2db.tgz https://ftp.arb-silva.de/release_138.2/Kraken2/2.1.6/SSU/SILVA_138_2_k2db.tgz

cd 08_kraken_db
# unpack
tar -xvzf SILVA_138_2_k2db.tgz
# remove archive
rm SILVA_138_2_k2db.tgz
cd ..


# run kraken2

# loop over the samples
while read line; do
    
    kraken2 \
        --db 08_kraken_db/SILVA_138_2_k2db \
        --threads 8 \
        --output 09_kraken_output/$line \
        --paired \
        --use-names \
        --report-zero-counts \
        --report-minimizer-data \
        --report 09_kraken_output/${line}_report.kreport2 \
        "07_sample_seq/${line}_1.fastq" "07_sample_seq/${line}_2.fastq"

done < 02_sample_list/sample_selection_for_analysis.txt

# loops over all samples as $line, use 8 threads, input has paired ends, use scientific names
# We can run this locally in ram, since the database is small (tested on Surface Pro 8 with 8 GB RAM)
