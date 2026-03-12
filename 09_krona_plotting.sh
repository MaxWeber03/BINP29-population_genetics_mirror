# THis script takes the files from 12_data_for_krona/ and creates krona plots from them.

# Install krona with conda
# conda create -n krona -c bioconda
conda activate krona
# conda install krona=2.8.1

# Check version
ktImportText
# KronaTools 2.8.1 - ktImportText

mkdir 13_krona_output

# run ktImportText
for sample in 12_data_for_krona/*.tsv; do

    # extract sample name
    sample_name=$(basename "$sample" .tsv)
    
    # run ktImportText to create Krona plots
    ktImportText \
        -o  ./13_krona_output/$sample_name.html \
        -n 'all' \
        $sample
        
done