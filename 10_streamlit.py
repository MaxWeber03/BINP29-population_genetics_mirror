# Script to visualize the plots into streamlit
# This script reproduces steps already done in 04_plot_distribution.py, but they will not be exported here, but instead will be shown in streamlit.

#################
# Import modules
#################

import plotly.express as px
# print(plotly.__version__) # 6.6.0
import streamlit as st
# print(st.__version__) # 1.55.0
import pandas as pd # for plotting with plotly we need the dataframe as pandas, not polars
# print(pd.__version__) # 2.3.3


#################
# Read Data
#################

metadata = pd.read_csv( 
    filepath_or_buffer = "05_metadata_cleaned/metadata_cleaned.tsv",
    sep = "\t"
)

#################
# Make histogram of samples per country and sequencing type
#################

histogram_countries_type = px.histogram(
    data_frame = metadata, # specifiy data frame
    x = "Country", # specify data to do histogram on
    color = "Sequencing Type",
    color_discrete_sequence=["#ff5733", "#33c1ff"]
)

histogram_countries_type.update_layout(
    xaxis_title = "Country",
    yaxis_title = "Number of Samples"
)

st.header("Histogram of samples by country and type")
st.plotly_chart(histogram_countries_type)

#################
# Make interactive map of sampling locations
#################

# round locations
metadata["Latitude"] = metadata["Latitude"].round(4)
metadata["Longitude"] = metadata["Longitude"].round(4)

# group samples by location to have list of samples on the map
location_group = metadata.groupby(["Latitude", "Longitude"]).agg({
    "sample_accession": list,
    "Sequencing Type": list
}).reset_index() 
# creates a df of the grouped samples, includes a list of samples and corresponding sequencing types for each location

# create hovertext from that, by adding <br> (\n in html) inbetween the samples
location_group["hover"] = location_group.apply(
    lambda row: "<br>".join(f"{s} ({t})" for s, t in zip(row["sample_accession"], row["Sequencing Type"])),
    axis=1
)

# st.write(location_group)

# map with overlapping points and color codes sample type
# map = px.scatter_map(
#    data_frame = metadata,
#    lat = "Latitude",
#    lon = "Longitude",
#    color = "Sequencing Type",
#    center={'lat': 0, 'lon': 0},
#    zoom=1,
#    color_discrete_sequence=["#ff5733", "#33c1ff"]
#)

# map with one point for all samples of the location, not color coded
map = px.scatter_map(
    location_group,
    lat="Latitude",
    lon="Longitude",
    custom_data=["hover"],
    zoom=0,
    center={'lat': 0, 'lon': 0}
)

map.update_traces(
    hovertemplate="<b>Samples at this location:</b><br>%{customdata[0]}<extra></extra>"
)

st.header("Location of samples")
st.plotly_chart(map)