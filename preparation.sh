#!/usr/bin/env bash
# - - - - - - - - - - - - - - - - -
# RMNY data preparation
# - - - - - - - - - - - - - - - - -

# extract data from RMNY 4. to CSV
# data_raw/RMNY-04_v06.txt --> data/rmny4.csv
php scripts/process-txt/read-rmny.php data_raw/RMNY-04_v06.txt > 04-b.json 2>error4.txt

# extract data from RMNY 5. to CSV
# data_raw/nyelv5.txt --> data/rmny5.csv
php scripts/process-txt/read-rmny5.php data_raw/RMNy5.txt > 05-b.json 2> error5.txt

# export current and past location info from RMNY 1-3. 
# data/rmny-1-3.v2.2024-02-12.csv --> data/rmny-1-3.lelohely.csv
Rscript scripts/process-txt/export-lelohely.R

# create a list of current and past locations from location string
# data/rmny-1-3.lelohely.csv --> data/rmny-1-3.lelohely2cities.csv
php scripts/process-txt/cities-for-1-3.php > error3.txt

# import current and past location list to RMNY 1-3. 
# data/rmny-1-3.v2.2024-02-12.csv, data/rmny-1-3.lelohely2cities.csv --> data/rmny-1-3.with-cities.csv
Rscript scripts/process-txt/import-lelohely.R

# add pagination columns to all volumes
# data/rmny-1-3.with-cities.csv --> data/rmny-1-3.with-cities.with-ivszam.csv
# data/rmny4.csv                --> data/rmny4.with-ivszam.csv
# data/rmny5.csv                --> data/rmny5.with-ivszam.csv
Rscript scripts/process-txt/pagination.R

# unite all volumes
# data/rmny-1-3.with-cities.with-ivszam.csv, data/rmny4.with-ivszam.csv, data/rmny5.with-ivszam.csv --> data/rmny-1-5.csv
Rscript scripts/process-txt/unite-1-5.R