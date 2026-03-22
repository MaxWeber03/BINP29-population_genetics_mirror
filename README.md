# Population Genetics Project: Visualizing species distribution from 16S metagenomics

## Repository
- Codeberg: https://codeberg.org/MaxWeber/BINP29-population_genetics
- GitHub Mirror: https://github.com/MaxWeber03/BINP29-population_genetics_mirror

The input data we recieved is not publicly available here for now.

### Branches
- snakemake: outdated dev branch used for snakemake implementation
- master: analysis pipeline without filtering of taxa

The results of all versions of the pipeline are not accurate, as quality control steps on the sequence reads are not included due to the scope of the project. Deduplication, chimera removal and trimming of adapters and low quality reads would be necessary to have more accurate results.

## Instructions Summary
This project is a one week project and part of BINP29 Sequencing Informatics II during the second semester of M. Sc. Bioinformatics at Lund University.
All students get different data, but some students have the same task.
My task is to visualize the species distribution from metagenomics samples of microbioms from mines (e.g. gold or silver mines).
The starting point for the project is a list of samples on a database.
The final result is supposed to be an "app", for which we can use streamlit (pyhon package, that builds app around our scripts). The implementation of this will likely not be polished as we have not developed anything into an app before and only have a short time. For submission, a 2-4 page report (paper style) and a 3-4 minute presentation are required.

### Copy of step-by-step assignment instructions
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

## Usage with snakemake

### Input files
Requires a list of samples accession numbers in 

    02_sample_list/NCBI.mine.metagenome.sampleID.txt

and a subset of that list for the samples for which krona plots should be created in

    02_sample_list/sample_selection_for_analysis.txt

Both files could have an example content like:

    SAMN11898199
    SAMN11898200
    SAMN11898201

The pipeline was tested with these three example sample IDs and the report (in taxon_filtering branch) is based on the results of these samples. For the samples given in 02_sample_list/NCBI.mine.metagenome.sampleID.txt, just the metadata is processed. The sequences are downloaded and processed to krona plots only for the samples given in 02_sample_list/sample_selection_for_analysis.txt, these samples must also included in 02_sample_list/NCBI.mine.metagenome.sampleID.txt in order to find the metadata.

### Running snakemake

To create output files run:

    snakemake --use-conda -j1

To open streamlit (not possible from remote):

    snakemake --use-conda -j1 streamlit

Using one job is suffienct as the scripts run all samples at the same time. The processing is not fully parallel in this way, but each scripts processes all samples, not just one at a time. The next time I use snakemake, each script should not loop over all samples, but process one sample at a time so parallel with snakemake becomes useable.

### Used Software and Requirements
- Python 3.13.11 was used for development and testing
    - Polars 1.38.1 for data handling
    - Pandas 2.3.3 required for plotting
    - Plotly 6.6.0 for plotting
    - Streamlit 1.55.0 for building an "app"
- Conda 25.11.1
- Snakemake 9.16.3
- Kraken2 2.17.1
- Bracken 3.0.1
- Taxonkit v0.20.0
- KronaTools 2.8.1

When executed through snakemake, only Snakemake 9.16.3 is required. The rest will be resolved internally by snakemake through conda. 
A internet connection is requried to download data, conda packages and databases. The workflow can be executed with as little as 8 GB RAM and requires about 3.2 GB of disk space. 

## To Do & Known Issues (if there was more time)
- To determine the country, only the country field works. It could be done with the coordinates as well, to make the code more robust, but including access to a DB or api to look up the countries for coordinates is out of the scope of this project
- Add preprocessing of samples (trimming, deduplication, chimera removal) instead of running classification on raw reads.
- Add support for single end reads in kraken
- Hovering does not work for Sweden, NE China and Canada on the streamlit map
- Filtering of microbioal taxa of interested is missing.
- Downloads may file on instable internet connect. Rerunning snakemake until downloads are successful usually fixes this.

## File Structure
The analysis workflow is divided into individual scripts that can be run through snakemake. When all of the data analysis is done, an "app" like script with streamlit is executed to open the results in a miniapp.

Folders:
- 01_report_presentation/ => report and presentation
- 02_sample_list/ => .txt files with all the sample IDs
- 03_metadata => the metadata files of all samples
- 04_metadata_table => tables of metadata for all samples
- 05_metadata_cleaned => a cleaned metadata in which the information of interest are extracted
- 06_plots => plots as .html, these are not the plots that are displayed in streamlit, but a preliminary exported version of them
- 07_sample_seq => fastq files of sample reads
- 08_kraken_db => silva database for kraken2
- 09_kraken_output => reports written by kraken2
- 10_bracken_output => reports written by bracken
- 11_taxonkit_db => ncbi database of taxa used by taxonkit
- 12_data_for_krona => data after preprocessing so it can be read by krona
- 13_krona_output => krona plots as .html that are read by streamlit
- envs => .yaml files for conda enviornments for snakemake

Scripts (detail see workflow section below):
- 01_retrieve_metadata.sh => script to download all metadata files
- 02_extract_metadata.py => script to extract information from the metadata and to create tables with samples and their relevant metadata
- inspect_metadata_format.R => mini script for dev to view metadata file with aligned columns in R, not necessary for the pipeline
- 03_clean_metadata.py => extracts the information of interest from the metadata
- 04_plot_distribution.py => creates plots of sample distribution
- 05_sel_samples_dl_seq.sh => downloads the fastq sequences of the samples selected in 02_sample_list/sample_selection_for_analysis.txt
- 06_kraken2.sh => runs kraken2 on the sequences to identify the taxa
- 07_bracken.sh => runs bracken on the kraken2 output to estimate the relative abundance of the taxa
- 08_data_krona.sh => parses bracken reports into a format that is readable by krona
- 09_krona_plotting.sh => creates krona plots
- 10_streamlit.py => open the plots in a small app that runs through your browser, requires local execution (not on server/remote)
- cleanup.sh => deletes all intermediate file, is not executed by snakemake, can be run manually to save disk space after analysis if finished
- Snakefile => runs pipeline through snakemake

## Workflow

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
Creates plotly charts and open them as a streamlit website. Krona plots are integrated into the website. 