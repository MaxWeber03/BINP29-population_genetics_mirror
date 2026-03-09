# Simple R script to open an individual metadata file to inspect the format with columns matching
metadata = read.table("/home/max/OneDrive/Uni/Master_Lund/2._Semester/BINP29_Sequencing_Informatics_II/06_population_genetics/03_metadata/SAMN44053421.tsv", 
           header = TRUE, sep = "\t")
View(metadata)