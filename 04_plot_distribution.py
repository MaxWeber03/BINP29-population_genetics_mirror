 # Max Weber, BINP29 Sequencing Informatics II, March 2026
 # Since this script is expected to work as part of this project's pipline, there will be no options, input folder, and output file will be hardcoded.

 # The goal of this script is to create plots for step 2 (visualise the geographical distribution of samples (number of samples from each country)
 # and step 3 (Visualise the distribution of sequencing types (16S rRNA amplicon vs shotgun metagenome) across different geographical regions) and 
 # step 4 (Create an interactive map showing the locations where the microbiome samples were collected.)


#################
# Import modules
#################
import pandas as pd # for plotting with plotly we need the dataframe as pandas, not polars
# print(pd.__version__) # 2.3.3
import plotly.express as px
# print(plotly.__version__) # 6.6.0
import kaleido # 1.2.0, for saving plotly


#################
# Read Data
#################

metadata = pd.read_csv( 
    filepath_or_buffer = "05_metadata_cleaned/metadata_cleaned.tsv",
    sep = "\t"
)

# print(metadata)


#################
# Make histogram of samples per country
#################

histogram_countries = px.histogram(
    data_frame = metadata, # specifiy data frame
    x = "Country" # specify data to do histogram on
    )

histogram_countries.update_layout(
    xaxis_title = "Country",
    yaxis_title = "Number of Samples"
)
# histogram_countries.show()

# save
histogram_countries.write_html("06_plots/histogram_countries.html")

#################
# Make histogram of samples per country and sequencing type
#################

histogram_countries_type = px.histogram(
    data_frame = metadata, # specifiy data frame
    x = "Country", # specify data to do histogram on
    color = "Sequencing Type"
)

histogram_countries_type.update_layout(
    xaxis_title = "Country",
    yaxis_title = "Number of Samples"
)

histogram_countries_type.write_html("06_plots/histogram_countries_type.html")

#################
# Make interactive map of sampling locations
#################

map = px.scatter_map(
    data_frame = metadata,
    lat = "Latitude",
    lon = "Longitude",
    color = "Sequencing Type",
    center={'lat': 0, 'lon': 0},
    zoom=1
)

map.write_html("06_plots/map.html")