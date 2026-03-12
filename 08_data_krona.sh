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
# Could be made optional, but it does not take long to download the db, and this way we make sure it is correct/not corrupted
curl -o 11_taxonkit_db/taxdump.tar.gz ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
cd 11_taxonkit_db/
tar -xvzf taxdump.tar.gz
rm taxdump.tar.gz
cd ..

echo "Finished DB Download"

# test taxonkit
# echo 61483 | taxonkit lineage --data-dir 11_taxonkit_db/ 
# based on the taxon id, taxonkit gives arbitrary species that have nothing to do with the species given in the output of krona
# echo Brucella | taxonkit name2taxid --data-dir 11_taxonkit_db/ | awk {'print $2'} | taxonkit lineage --data-dir 11_taxonkit_db/ 
# This works!

# run it on all the output files
for file in 10_bracken_output/*.bracken_output; do
    # get basename of the files to extract the sample name
    file_name=$(basename "$file" .bracken_output)

    # read columns from bracken output, skip header, only keep column 7 for rel abundance and col 1 for taxon name
    # then run taxonkit, first find taxonit, then find lineage for that ID
    grep -v ^name $file \
    | awk -F'\t' 'BEGIN { OFS="\t" } {print $1, $7}' \
    | taxonkit name2taxid --data-dir 11_taxonkit_db/ \
            | awk -F'\t' 'BEGIN { OFS="\t" } {if ($3 != "") print $3, $2}' | \
            taxonkit lineage --data-dir 11_taxonkit_db/ \
            | awk -F'\t' 'BEGIN { OFS="\t" } {print $2, $3}' \
            | sed 's/;/\t/g' \
            > "12_data_for_krona/${file_name}.tsv"

    # | tee  /dev/stderr \ can be inserted for debugging
    # taxonkit name2taxid returns taxonname, abundance and taxonid
    # we then filter the rows that have found a taxonid ($3 exists), and continue with col 3 and 2, taxonid and abundance
    # this is goes through taxonkit lineage, which outputs taxonid, abundance and lineage
    # we keep abundance and lineage
    # before writing to the file, ; is replaced with \t in order to have the correct delimiter in the lineage

  done