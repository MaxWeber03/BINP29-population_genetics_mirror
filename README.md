# Population Genetics Project: Visualizing species distribution from 16S metagenomics

## Overview
Respository:
- Codeberg: https://codeberg.org/MaxWeber/BINP29-population_genetics
- GitHub Mirror: https://github.com/MaxWeber03/BINP29-population_genetics_mirror

The input data we recieved is not publicly available here.

### Used Software & Versions
- Python 3.13.11 was used for development and testing
    - Polars 1.38.1 for data handling
    - Pandas 2.3.3 required for plotting
    - Plotly 6.6.0 for plotting
    - Streamlit 1.55.0 for building an "app"
- Conda 25.11.1
- Kraken2 2.17.1
- Bracken 3.0.1
- Taxonkit v0.20.0
- KronaTools 2.8.1

### To Do & Known Issues (if there was more time)
- To determine the country, only the country works. It could be done with the coordinates as well, to make the code more robust, but including access to a DB or api to look up the countries for coordinates is out of the scope of this project
- Make Snakemake Workflow
- Add preprocessing of samples (trimming, deduplication, chimera removal) instead of running classification on raw reads.
- Add support for single end samples in kraken

### File Structure
The analysis workflow is divided into individual scripts (connecting them with snakemake would be nice, but we do not have the time for it). When all of the data analysis is done, an "app" like script with streamlit can be executed to open the results in a miniapp.

Folders:
- 01_report_presentation/ => holds report and presentation
- 02_sample_list/ => holds a .txt file with all the sample IDs
- 03_metadata => holds the metadata files of all samples
- 04_metadata_table => holds tables of metadata for all samples

Scripts (detail see workflow section below):
- 01_retrieve_metadata.sh => script to download all metadata files
- 02_extract_metadata.py => script to extract information from the metadata and to create tables with samples and their relevant metadata
- inspect_metadata_format.R => mini script for dev to view metadata file with aligned columns in R, not necessary for the pipeline

## Instructions Summary
This project is a one week project and part of BINP29 Sequencing Informatics II during the second semester of M. Sc. Bioinformatics at Lund University.
All students get different data, but some students have the same task.
My task is to visualize the species distribution from metagenomics samples of microbioms from mines (e.g. gold or silver mines).
The starting point for the project is a list of samples on a database.
The final result is supposed to be an "app", for which we can use streamlit (pyhon package, that builds app around our scripts). The implementation of this will likely not be polished as we have not developed anything into an app before and only have a short time. For submission, a 2-4 page report (paper style) and a 3-4 minute presentation are required.

### Copy of step-by-step instructions
"Visualising the Skin Microbiome - Objective: Explore publicly available skin microbiome datasets and visualise their geographical distribution and microbial composition.

1. You will be provided with a list of NCBI skin microbiome metagenome Bio-project IDs.
2. Extract metadata and visualise the geographical distribution of samples (number of samples from each country).
3. Visualise the distribution of sequencing types (16S rRNA amplicon vs shotgun metagenome) across different geographical regions.
4. Create an interactive map showing the locations where the microbiome samples were collected.
5. Select three 16S samples and three shotgun metagenome samples from Sweden.
6. Analyse and visualise the distribution of microbial species. If possible, attempt strain-level profiling.
7. Generate Krona plots to visualise the microbial composition of these samples.
8. Integrate this with the interactive map so that clicking on a sample location in Sweden opens the Krona plot showing its microbiome composition (this will be done for only the three samples).

Reference:
- Krona plot - https://ondovb.github.io/portfolio/01-krona"


### Meeting Monday 09/03 - Outline and Overview: Notes
- all students of our group get different metagenomics data, but develope the same pipeline/app
- I will work on mining data & 16S => kraken works with 16S => silva db, do not use metaphlan
- In this meeting we were explictily told that making the map interactive is optional if we have time at the end, and not a rigid requirement.

Steps:
1. fetch meta data from db (curl + link)
    - curl "https://www.ebi.ac.uk/ena/portal/api/search?result=read_run&query=sample_accession=SAMEA121737266&fields=all&format=tsv"
    - Sample ID can be replaced in the link
    - get column numbers in db metadata: cat A.txt | head -n2 | sed 's/\t/\n/g' | nl -ba
2. visualise distrubution => histogram of samples countries or map
    - metadata contains link to fasta and coordinates
3. distribution of 16S vs shotgun
    - grouped barplot with sequencing type and country
4. interactive map => interactive is optional, could link to plot, plot only for the three selected samples
5. take 3 samples from from 16S rRNA (the files are reads, so lot of stuff in each sample), retrieve fasta files
6. use kraken2 through conda (since I am working on 16S, would be Metaphlan for shotgun)
    - visualize species distribution based on the fasta files
    - x species, y abundance
7. make interactive plots with kraken
8. integrate the plots into an interactive version of step 4

## Workflow

At the start, a list of samples is given (02_sample_list/NCBI.mine.metagenome.sampleID.txt).

### 01_retrieve_metadata.sh
Bash script that loops over the sample IDs in 02_sample_list/NCBI.mine.metagenome.sampleID.txt, downloads the metadata as .tsv and saves the metadata in 03_metadata/. This process with just curl takes a long time, eventhough neither the CPU or the network are used at full capactiy, because each small file waits on responses from the server. To speed the process up, parallel downloading through xargs with curl is used instead. It does cut down the waiting time by minutes in testing. This script also sets up the empty folders for the python scripts (could be done in python too, but faster here).

### 02_extract_metadata.py
Python script using polars that collects specific columns from all metadata.tsv files of the previous step (from 03_metadata/). The samples are filtered based on data completeness, if information on 16S/Shotgun or the location is missing, the sample will be removed from further analysis. The output of this step are 4 tables in 04_metadata_table:

- extracted_metadata_all_samples.tsv => contains the extracted metadata of all samples
- extracted_metadata_no_NA.tsv => contains the samples that have the required metadata
- extracted_metadata_incomplete.tsv => contains the samples that do not have the required metadata
- extracted_metadata_16S.tsv => contains all complete samples that use 16S

### 03_clean_metadata.py
Python script to extract the necessary data (sample_accession,	fastq_ftp, country, sequencing_type) from the original columns of the metadata (sample_accession,	fastq_ftp,	location,	country,	experiment_title,	study_title). Outputs the clean metadata table into 05_metadata_cleaned/metadata_cleaned.tsv.

### 04_plot_distribution.py
Uses pandas and plotly to create plots of the sample distribution for country and sequencing type. The outputs plots into 06_plots, and takes 05_metadata_cleaned/metadata_cleaned.tsv as an input.
Generates three files in total:
- 06_plots/histogram_countries_type.html => Interactive histogram of the type of sequencing per country
- 06_plots/histogram_countries.html => Interactive histogram of the number of samples per country (Sequencing type is ignored)
- 06_plots/map.html => Interactive map showning the sampling sites as dots, differentiates between 16S and Shotgun. 

### 05_sel_samples_dl_seq.sh
Download selected samples as fastq, unzip the samples. These sequences are the ones that will be classified with Kraken2. A list of selected sequences is read from 02_sample_list/sample_selection_for_analysis.txt.

### Placeholder - Sequences Preprocessing
Before running Kraken2, preprocessing of the sequences in necessary (including trimming of adapters, deduplication, removal of low quality reads and chimera removal). This is not possible to do withhin the scope of this project, so Kraken2 will be run on the raw data instead. This will obviously cause results/plots that do not represent reality. However, the point of the project is for us to learn how do built interactive plots and integrate them into a small app interface. To complete the whole pipeline, the preprocessing steps would need to be added later. 

### 06_kraken2.sh
Script that runs kraken2 to identify the taxonomic groups (to genus levels) in the samples. Also downloads the silva database required for kraken2. Runs on the sample listed in 02_sample_list/sample_selection_for_analysis.txt and on the sequences given in 07_sample_seq/.

### 07_bracken.sh
Script that runs bracken on the kraken2 outputs to add information about relative abundance to the taxonomic groups.

### 08_data_krona.sh
Script that extracts the taxon name from the bracken output, finds the full taxonomy for that name, and writes the full taxonomy into a file together with the relative abundance in the sample. Uses taxonkit v0.20.0. Outputs are .tsv in 12_data_for_krona that are used to create krona plots.

### 09_krona_plotting.sh
Script that creates krona plot based on the preformatted data of 08_data_krona.sh. Reads data from 12_data_for_krona and writes .html files for the plots with sample names into 13_krona_output. Uses KronaTools 2.8.1. This script also creates 13_krona_output/sample_path.tsv which links the the sample names to the relative filepath of the krona plot.

### 10_streamlit.py
Creatly plotly charts and open them as a streamlit website.