 # Max Weber, BINP29 Sequencing Informatics II, March 2026
 
 # The goal of this script is to read the metadata files from 03_metadata/, extract information and print a table with the collected information. 
 # For this task the package polars will be used, it is supposed to fast and efficient in the handling of multicore and memory.
 # Filtering into different output files is done in this script:
    # - file with all samples
    # - file with samples missing 16S/Shotgun Information, or missing location
    # - files with all necessary information
    # - files with all necessary information that are only 16S

# Create list of unsuccesful downloads

 # Since this script is expected to work as part of this project's pipline, there will be no options, input folder, and output file will be hardcoded.abs

#################
# Import modules
#################

# to install, run in terminal: pip install polars
import polars as pl
# to check version, run in terminal: pip show polars
# 1.38.1

#################
# Extract Metadata from all files
#################

#  Polars uses lazy loading, it does not read all the data, and then handles it, it decides what it needs to do first,
# and only reads and handles the necessary bits => files are only reads when the results are collected

metadata = pl.scan_csv( # pl.scan works lazy, it only executes when collect() is run
    source = "./03_metadata/*.tsv", # use global pattern to catch all tsv of the folder
    has_header = True, # every file has a header line
    separator = "\t"
)
# the scheme of the headers is infered by polars, the headers should all be the same. If they mismatch, i expect an error
# metadata is now a LazyFrame

# from the the scan of metadata (the Lazy Frame object) we can now select the columns of interest:
metadata = metadata.select([
    "sample_accession",
    "fastq_ftp",
    "location",
    "country",
    "experiment_title",
    "study_title"
]).collect() # collect actually reads the files

# print(type(metadata))
# We now have a polars Dataframe with all samples, that we can use to write into a new file
metadata.write_csv(
    file = "04_metadata_table/extracted_metadata_all_samples.tsv",
    include_header = True,
    separator = "\t"
)

# since the number of meta data tables here is small (700), there may not be huge difference between this and e.g. pandas. But if the list of files would be bigger, then this way should be considerably faster, as only the columns of interested are read, instead of all columns

# If the columns mismatch, this script will fail with "schema lengths differ"!

#################
# Filter samples based on the available metadata
#################


# Next, we can filter to exclude samples with missing information
metadata_no_NA = metadata.filter(
    # make sure sample ID exists
    (pl.col("sample_accession").is_not_null()) &

    # make sure fastq link exists
    (pl.col("fastq_ftp").is_not_null()) &

    # filter so that country or location is not None (one of them exists)
    ((pl.col("location").is_not_null()) | (pl.col("country").is_not_null())) &

    # and filter that shotgun or 16S is written somewhere in experiment_title or study_title
    ((pl.col("experiment_title").str.contains("(?i)16S|(?i)shotgun")) | 
    (pl.col("study_title").str.contains("(?i)16S|(?i)shotgun")))
    
    # (?i) makes the regex expression case insensitive
)

# save metadata_no_NA as file
metadata_no_NA.write_csv(
    file = "04_metadata_table/extracted_metadata_no_NA.tsv",
    include_header = True,
    separator = "\t"
)

# incomplete data (to document which samples are skipped): write the inverse of metadata_no_NA to a new file
metadata_incomplete = metadata.filter(
    # make sure sample ID exists
    ~( # inverse the filter
        (pl.col("sample_accession").is_not_null()) &

    # make sure fastq link exists
    (pl.col("fastq_ftp").is_not_null()) &

    # filter so that country or location is not None (one of them exists)
    ((pl.col("location").is_not_null()) | (pl.col("country").is_not_null())) &

    # and filter that shotgun or 16S is written somewhere in experiment_title or study_title
    ((pl.col("experiment_title").str.contains("(?i)16S|(?i)shotgun")) | 
    (pl.col("study_title").str.contains("(?i)16S|(?i)shotgun")))
    )
)

# write to a file
metadata_incomplete.write_csv(
    file = "04_metadata_table/extracted_metadata_incomplete.tsv",
    include_header = True,
    separator = "\t"
)

# Select only the 16S samples for the downstream analysis
metadata_16S = metadata_no_NA.filter(


    # filter for 16S
    ((pl.col("experiment_title").str.contains("(?i)16S")) | 
    (pl.col("study_title").str.contains("(?i)16S")))
    
    # (?i) makes the regex expression case insensitive
)

# write to a file
metadata_16S.write_csv(
    file = "04_metadata_table/extracted_metadata_16S.tsv",
    include_header = True,
    separator = "\t"
)

#################
# create list of unsuccesful downloads
#################

# turn sample ID column into set for fast lookup
sample_id_metadata = set(metadata["sample_accession"])

# read the samples that should be downloaded
with open ("02_sample_list/NCBI.mine.metagenome.sampleID.txt") as sample:
    samples_download = [line.strip() for line in sample]

# compare, save the ones that are missing in the metadata
samples_download_failure = [sample for sample in samples_download if sample not in sample_id_metadata]
    # loops over all samples in samples_download and if it is not in sample_id_metadata it saved it
# save to file


try: # Try to create the file (x), if it does already exist (FileExistsError), do it with write (w)
    with open("04_metadata_table/samples_download_failure", "x") as line:
        for sample in samples_download_failure:
            line.write(f"{sample}\n")

except FileExistsError:
    with open("04_metadata_table/samples_download_failure", "w") as line:
        for sample in samples_download_failure:
            line.write(f"{sample}\n")

    # same again but with "w" instead of "x" in case the file already exists







