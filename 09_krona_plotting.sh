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

# For showing the krona plots, a relation between the samples and the filepath could be useful
rm 13_krona_output/sample_path.tsv # remove the file if it remains from previous runs

for krona_plot in 13_krona_output/*.html; do
    sample_name=$(basename "$krona_plot" .html)
    # these are the same samples has were given in 02_sample_list/sample_selection_for_analysis.txt
    # Let us verify that(grep -q gives 0 or 1)
    if ! grep -q $sample_name 02_sample_list/sample_selection_for_analysis.txt; then
        echo "Error: The Krona Plot does not match any input sample name"
        else
        echo "Krona plot for $sample_name was successfully created."
    fi

    # now create a file with sample name and relative plot path
    echo -e "$sample_name\t$krona_plot" >> 13_krona_output/sample_path.tsv
done