# Snakefile
use_conda = True

# Tell snakemake where the samples for the krona plots are
SAMPLES_KRONA = [line.strip() for line in open("02_sample_list/sample_selection_for_analysis.txt") if line.strip()]
# this reads the samples line by line, but ignores empty lines through if line.stip()

# Tell snakemake where all samples are
SAMPLES_ALL = [line.strip() for line in open("02_sample_list/NCBI.mine.metagenome.sampleID.txt") if line.strip()]

# In the end we need to have the files for streamlit, launch streamlit, but we also want to have plots in 06_plots/
# To check if all files are there before launchign streamit we can use a flag file. It is only created if all files exist. 
# Streamlit is only launched we have those files

# That means the ultimate goal is to launch streamlit
# But we also want the files.
# So we will create the files in rule all, but add rule streamlit, that launches streamlit and does not create files
# The streamlit rule will trigger rule all if the files are not there

# rule all contains all the files we want at the end
rule all:
    input:
        expand("13_krona_output/{samples_krona}.html", samples_krona=SAMPLES_KRONA),
        "13_krona_output/sample_path.tsv",
        "05_metadata_cleaned/metadata_cleaned.tsv",
        "06_plots/histogram_countries_type.html",
        "06_plots/histogram_countries.html",
        "06_plots/map.html"

# run krona
rule krona:
    # tell it which conda env to use
    conda: "envs/krona.yaml"
    input:
        expand("12_data_for_krona/{samples_krona}.tsv", samples_krona=SAMPLES_KRONA),
        "02_sample_list/sample_selection_for_analysis.txt"
    output:
        expand("13_krona_output/{samples_krona}.html", samples_krona=SAMPLES_KRONA),
        "13_krona_output/sample_path.tsv"
    shell:
        "bash 09_krona_plotting.sh"

# run data preparation for krona with taxonkit
rule taxonkit:
    # tell it which conda env to use
    conda: "envs/taxonkit.yaml"
    input:
        expand("10_bracken_output/{samples_krona}.bracken_output", samples_krona=SAMPLES_KRONA)
    output:
        expand("12_data_for_krona/{samples_krona}.tsv", samples_krona=SAMPLES_KRONA)
    shell:
        "bash 08_data_krona.sh"

# run bracken
rule bracken:
    # tell it which conda env to use
    conda: "envs/bracken.yaml"
    input:
        expand("09_kraken_output/{samples_krona}_report.kreport2", samples_krona=SAMPLES_KRONA)
    output:
        expand("10_bracken_output/{samples_krona}.bracken_output", samples_krona=SAMPLES_KRONA)
    shell:
        "bash 07_bracken.sh"

# run kraken
rule kraken:
    # tell it which conda env to use
    conda: "envs/kraken2.yaml"
    input:
        expand("07_sample_seq/{samples_krona}_1.fastq", samples_krona=SAMPLES_KRONA),
        expand("07_sample_seq/{samples_krona}_2.fastq", samples_krona=SAMPLES_KRONA)
    output:
        expand("09_kraken_output/{samples_krona}_report.kreport2", samples_krona=SAMPLES_KRONA)
    shell:
        "bash 06_kraken2.sh"

# download the sequences
rule seq_download:
    input:
        "02_sample_list/sample_selection_for_analysis.txt",
        "05_metadata_cleaned/metadata_cleaned.tsv"
    output:
        expand("07_sample_seq/{samples_krona}_1.fastq", samples_krona=SAMPLES_KRONA),
        expand("07_sample_seq/{samples_krona}_2.fastq", samples_krona=SAMPLES_KRONA)
    shell:
        "bash 05_sel_samples_dl_seq.sh"

# create plots outside of streamlit
rule plotting:
    conda: "envs/python_scripts.yaml"
    input:
        "05_metadata_cleaned/metadata_cleaned.tsv"
    output:
        "06_plots/histogram_countries_type.html",
        "06_plots/histogram_countries.html",
        "06_plots/map.html"
    shell:
        "python3 04_plot_distribution.py"

# clean the metadata
rule clean_metadata:
    conda: "envs/python_scripts.yaml"
    input:
        "04_metadata_table/extracted_metadata_no_NA.tsv"
    output:
        "05_metadata_cleaned/metadata_cleaned.tsv"
    shell:
        "python3 03_clean_metadata.py"

# extract the metadata
rule extract_metadata:
    conda: "envs/python_scripts.yaml"
    input:
        expand("03_metadata/{sample_all}.tsv", sample_all = SAMPLES_ALL) 
    output:
        "04_metadata_table/extracted_metadata_no_NA.tsv"
    shell:
        "python3 02_extract_metadata.py"

# retrieve metadata
rule retrieve_metadata:
    input:
        "02_sample_list/NCBI.mine.metagenome.sampleID.txt"
    output:
        expand("03_metadata/{sample_all}.tsv", sample_all = SAMPLES_ALL)
    shell:
        "bash 01_retrieve_metadata.sh"

# rule streamlit to launch streamlit
rule streamlit:
    conda: "envs/python_scripts.yaml"
    input: 
        expand("13_krona_output/{samples_krona}.html", samples_krona=SAMPLES_KRONA),
        "13_krona_output/sample_path.tsv",
        "05_metadata_cleaned/metadata_cleaned.tsv",
        "06_plots/histogram_countries_type.html",
        "06_plots/histogram_countries.html",
        "06_plots/map.html"
    shell:
        "streamlit run 10_streamlit.py"