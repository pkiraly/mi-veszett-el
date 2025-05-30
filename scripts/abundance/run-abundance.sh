#!/usr/bin/env bash
#
# Run all abundance estimations
#

python3 estimation-of-lost-books.py ../../data_raw/v02/abundance-brewer.csv --name brewer
python3 estimation-of-lost-books.py ../../data_raw/v02/abundance-latin.csv --name latin
python3 estimation-of-lost-books.py ../../data_raw/v02/abundance-random.csv --name random
python3 estimation-of-lost-books.py ../../data_raw/v02/abundance-full.csv --name full

echo DONE
