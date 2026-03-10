 # Max Weber, BINP29 Sequencing Informatics II, March 2026
 # Since this script is expected to work as part of this project's pipline, there will be no options, input folder, and output file will be hardcoded.

 # The goal of this script is to create static plots for step 2 (visualise the geographical distribution of samples (number of samples from each country)
 # and step 3 (Visualise the distribution of sequencing types (16S rRNA amplicon vs shotgun metagenome) across different geographical regions).
 # In a preliminary step, information will be extracted 

#################
# Import modules
#################
import pandas as pd # for plotting with plotly we need the dataframe as pandas, not polars
# print(pd.__version__) # 2.3.3
import plotly
# print(plotly.__version__) #6.6.0

#################
# Read Data
#################