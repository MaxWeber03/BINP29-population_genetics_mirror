 # Max Weber, BINP29 Sequencing Informatics II, March 2026
 # Since this script is expected to work as part of this project's pipline, there will be no options, input folder, and output file will be hardcoded.

 # The goal of this script is to clean up the meta data of the previous step to only contain the information we are interested in, in the form of new columns.
 # The previous format holds information in the columns:
 # sample_accession	fastq_ftp	location	country	experiment_title	study_title
 # This will be changed to
 # sample_accession	fastq_ftp country sequencing_type

# The problem is, that we need to know if a sample is 16S or shotgun sequenced, and from which country it originates from for plotting the distribution of these variables.
# There are no clear field for this in the raw meta data. location and country hold these information, but they need to be extracted. Lookup of the coordinates is in theory possible,
# but complicated. Code to start this is provied as comments, but not finished due to time restrictions
# 16S vs shotgun is often given in the title, but also needs to be extracted.

# The input will be the prefiltered 04_metadata_table/extracted_metadata_no_NA.tsv table, which was filtered to contain all the necessary information in the previous step.
# Therefore, this script here mainly reformats the information, so that the resulting table can be quickly used for plotting downstream.

#################
# Import modules
#################

import polars as pl
# import geopandas as gpd # 1.1.3


#################
# Read metadata
#################
metadata = pl.read_csv( 
    source = "04_metadata_table/extracted_metadata_no_NA.tsv",
    has_header = True, # file has a header line
    separator = "\t"
)

#################
# Extract country
#################

# The country is given in the "country" column, followed a state/city in the country. We are only interested in the country.
# If the coordinates are also given, we can trace the coordinates back to the country, to confirm that the country is correct.

metadata = metadata.with_columns(
    # use regex to match anything before a : in the country column, put the information into the new columns
    (pl.col("country").str.extract(r"^(.*):")).alias("country_extracted")
)

# Convert coordinates to country to double check the country and make the code more robust, in case coordiantes are there but no country
# does not work because external api or database is required to look up the countries, which is out of the scope of this project.
# However, we keep the conversion of the coordinates, since it might be useful downstream.

metadata = metadata.with_columns(  
    # convert coordinates from N/W to Decimal degrees
    # currently the coordnates are given as lat in degrees with decimal, and N/S notation and long with decimal and E/W
    # this needs be converted to two different column in  degrees with decimal and - for s and w
    # first make two columns for lat and long

    # capture everything until including N or S (so the latitude)
    (pl.col("location").str.extract(r"(.*?[NS])")).alias("lat_raw"),
    # capture everything after N or S until including E or W (so the  longitude)
    (pl.col("location").str.extract(r"[NS](.*?[EW])")).alias("long_raw")
).drop("location", "country") # drop no longer needed columns

# next, we can turn lat_raw & long_raw into decimal degrees with +/- instead of NS/EW
metadata = metadata.with_columns(
    # get number part of the lat
    pl.col("lat_raw")
        .str.extract(r"(\d+\.?\d*)")
        .cast(pl.Float64)
        .alias("lat_num"),
    # now we have just the number in a column, as a float, not string

    # do the same for long
    pl.col("long_raw")
        .str.extract(r"(\d+\.?\d*)")
        .cast(pl.Float64)
        .alias("long_num")
)

# to access these new columns we need to reopen the df
metadata = metadata.with_columns(
    # now find out if the full string for N or S, and add that to the sign to the float
    # for lat
    pl.when(
        pl.col("lat_raw").str.ends_with("S")
        ).then(
            -pl.col("lat_num")
            ).otherwise(pl.col("lat_num")).alias("lat_clean"),

    # do the same for long
    pl.when(
    pl.col("long_raw").str.ends_with("W")
    ).then(
        -pl.col("long_num")
        ).otherwise(pl.col("long_num")).alias("long_clean")
).drop("lat_num", "long_num", "lat_raw", "long_raw") # drop no longer needed columns

# the part of finding the countries that does not work:
'''

# to look up the coordinates we need to load a world map from geopandas
world = gpd.read_file(gpd.datasets.get_path("naturalearth_lowres"))[
    ["iso_a3", "geometry"]
]


# convert out data frame to geopandas
metadata_geopanda = metadata.to_pandas()
metadata_geopanda = gpd.GeoDataFrame(
    gdf,
    geometry=gpd.points_from_xy(gdf.long_clean, gdf.lat_clean),
    crs="EPSG:4326"
)

# find countries from coordinates
joined = gpd.sjoin(gdf, world, how="left", predicate="within")

# bring it back to polars
metadata = pl.from_pandas(joined.drop(columns="geometry"))
'''

# Extract sequencing type (16S vs Shotgut)
metadata = metadata.with_columns(
    pl.when(

    # find 16S in experiment title or study title
        (pl.col("experiment_title").str.contains("(?i)16S") | pl.col("study_title").str.contains("(?i)16S"))
        ).then(pl.lit("16S"))

     #find shotgun
    .when(
        (pl.col("experiment_title").str.contains("(?i)shotgun") | pl.col("study_title").str.contains("(?i)shotgun"))
        ).then(pl.lit("Shotgun")).alias("sequencing_type")

).drop("experiment_title", "study_title") # drop no longer needed columns

# rename columns
metadata = metadata.rename({"country_extracted": "Country","sequencing_type":"Sequencing Type", "lat_clean":"Latitude", "long_clean":"Longitude"})

# write to a file
metadata.write_csv(
    file = "05_metadata_cleaned/metadata_cleaned.tsv",
    include_header = True,
    separator = "\t"
)