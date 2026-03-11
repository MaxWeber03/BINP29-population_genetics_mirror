# This script will run parse the output data from 07_bracken.sh into a readable format for krona.
# For that the taxon id from the bracken output is looked up in NBCI with taxonkit to find the full taxonomy of each taxon. 
# This is then parsed into a list with the relative abundance for plotting with krona

# Install bracken with conda
# conda create -n taxonkit -c bioconda
conda activate taxonkit
# conda install taxonkit=0.20.0

# Check version
taxonkit version
# taxonkit v0.20.0

mkdir 11_taxonkit_db
mkdir 12_data_for_krona

# Download taxonomy database into 11_taxonkit_db
curl -o 11_taxonkit_db/taxdump.tar.gz ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
cd 11_taxonkit_db/
tar -xvzf taxdump.tar.gz
rm taxdump.tar.gz
cd ..

# test taxonkit
# echo 61483 | taxonkit lineage --data-dir 11_taxonkit_db/ 
# based on the taxon id, taxonkit gives arbitrary species that have nothing to do with the species given in the output of krona
# echo Brucella | taxonkit name2taxid --data-dir 11_taxonkit_db/ | awk {'print $2'} | taxonkit lineage --data-dir 11_taxonkit_db/ 
# This works!

# run it on all the output files
for file in 10_bracken_output/*.bracken_output; do
    # get basename of the files to extract the sample name
    file_name=$(basename "$file" .bracken_output)

    # read columns from bracken output, create two new files cotaining one column each
    awk '{print $7}' $file > "12_data_for_krona/${file_name}_col1"
    head -n 1 "$file" | awk '{print $1}' > "12_data_for_krona/${file_name}_col2"
    tail -n +2 "$file" | awk '{print $1}' | taxonkit name2taxid --data-dir 11_taxonkit_db/ | awk {'print $2'} | taxonkit lineage --data-dir 11_taxonkit_db/ >> "12_data_for_krona/${file_name}_col2"

    # put the two column together into one new file
    paste "12_data_for_krona/${file_name}_col1" "12_data_for_krona/${file_name}_col2" > "12_data_for_krona/${file_name}.temp.tsv"

    # remove the temp files
    rm "12_data_for_krona/${file_name}_col1"
    rm "12_data_for_krona/${file_name}_col2"

    # remove all rows with no taxonomy (nothing found)
    awk '{if($2 != "") print}' "12_data_for_krona/${file_name}.temp.tsv" > "12_data_for_krona/${file_name}.tsv"
    rm "12_data_for_krona/${file_name}.temp.tsv"
done