#!/usr/bin/env bash
#
# Run all abundance estimations
#

DATASOURCES="s1 s2 heltai latin"
METHODS="basis plus plus_minimal unique increased"
for DATASOURCE in ${DATASOURCES}; do
  for METHOD in ${METHODS}; do
  	# if [[ "${METHOD}" == "plus_minimal" ]]; then
      ID=${DATASOURCE}_${METHOD}
      echo ${ID}
      python3 estimation-of-lost-books.py ../../data_raw/v04/abundance/${ID}.csv --name ${ID}
    # fi
  done
done