#!/usr/bin/env bash
#
# Run all abundance estimations
#

DATASOURCES="1971 full heltai latin"
METHODS="plus plus_minimal unique increased"
for DATASOURCE in ${DATASOURCES}; do
  for METHOD in ${METHODS}; do
  	if [[ "${METHOD}" == "plus_minimal" ]]; then
      ID=${DATASOURCE}_${METHOD}
      echo ${ID}
      python3 estimation-of-lost-books.py ../../data_raw/v03/abundance/${ID}.csv --name ${ID}
    fi
  done
done