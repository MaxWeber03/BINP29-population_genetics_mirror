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

map = px.scatter_map(
    data_frame = metadata,
    lat = "Latitude",
    lon = "Longitude",
    color = "Sequencing Type",
    center={'lat': 0, 'lon': 0},
    zoom=1,
    color_discrete_sequence=["#ff5733", "#33c1ff"]
)

st.header("Location of samples")
st.plotly_chart(map)