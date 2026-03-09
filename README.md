# Population Genetics Project: Visualizing species distribution from 16S metagenomics

Respository:
- Codeberg: https://codeberg.org/MaxWeber/BINP29-population_genetics
- GitHub Mirror: https://github.com/MaxWeber03/BINP29-population_genetics_mirror

The input data we recieved is not publicly available here.

## Used Software & Versions
- Streamlit 1.55.0 (python package)
- Python 3.13.11 was used for development and testing
- Conda 25.11.1


## To Do & Known Issues (if there was more time)
- TBD

## Instructions Summary
This project is a one week project and part of BINP29 Sequencing Informatics II during the second semester of M. Sc. Bioinformatics at Lund University.
All students get different data, but some students have the same task.
My task is to visualize the species distribution from metagenomics samples of microbioms from mines (e.g. gold or silver mines).
The starting point for the project is a list of samples on NCBI.
The final result is supposed to be an "app", for which we can use streamlit (pyhon package, that builds app around our scripts). The implementation of this will likely not be polished as we have not developed anything into an app before and only have a short time. For submission, a 2-4 page report (paper style) and a 3-4 minute presentation are required.

### Copy of step-by-step instructions
Visualising the Skin Microbiome - Objective: Explore publicly available skin microbiome datasets and visualise their geographical distribution and microbial composition.

1. You will be provided with a list of NCBI skin microbiome metagenome Bio-project IDs.
2. Extract metadata and visualise the geographical distribution of samples (number of samples from each country).
3. Visualise the distribution of sequencing types (16S rRNA amplicon vs shotgun metagenome) across different geographical regions.
4. Create an interactive map showing the locations where the microbiome samples were collected.
5. Select three 16S samples and three shotgun metagenome samples from Sweden.
6. Analyse and visualise the distribution of microbial species. If possible, attempt strain-level profiling.
7. Generate Krona plots to visualise the microbial composition of these samples.
8. Integrate this with the interactive map so that clicking on a sample location in Sweden opens the Krona plot showing its microbiome composition (this will be done for only the three samples).

Reference:
- MetaPhlAn - https://doi.org/10.1038/s41587-023-01688-w.
- Krona plot - https://ondovb.github.io/portfolio/01-krona



### Meeting Monday 09/03 - Outline and Overview: Notes
- all students of our group get different metagenomics data, but develope the same pipeline/app
1. fetch meta data from ncbi (curl + link)
    - curl "https://www.ebi.ac.uk/ena/portal/api/search?result=read_run&query=sample_accession=SAMEA121737266&fields=all&format=tsv"
    - Sample ID can be replaced in the link
    - get column numbers in NCBI metadata: cat A.txt | head -n2 | sed 's/\t/\n/g' | nl -ba
2. visualise distrubution => histogram of samples countries or map
    - metadata contains link to fasta and coordinates
3. distribution of 16S vs shotgun
    - grouped barplot with sequencing type and country
4. interactive map => interactive is optional, could link to plot, plot only for the three selected samples
5. take 3 samples from from 16S rRNA (the files are reads, so lot of stuff in each sample), retrieve fasta files
6. use metaphlan 4 through conda, alternative would be kraken
    - visualize species distribution based on the fasta files
    - x species, y abundance
7. make interactive plots with kraken
8. integrate the plots into an interactive version of step 4

I will work on mining data & 16S => kraken works with 16S => silva db
In this meeting we were explictily told that making the map interactive is optional if we have time at the end, and not a rigid requirement.
