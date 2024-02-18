<?php

include_once 'functions.php';
const LN = "\n";
const PHYSICAL_DESCRIPTION_SEPARATOR = ' – ';
$missing_locations = [];
$olimToLocation = initOlimToLocation();

$csvFile = 'data/rmny-1-3.lelohely.csv';
$lines = file($csvFile);
$csv = fopen('data/rmny1-3.extra.csv', 'w');
fputcsv($csv, ['01Sorszám_RMNY', '01Sorszám_RMNY', 'cities', 'olimCities']);

$prev = '';
$record = [];
$header = [];
foreach ($lines as $lineNumber => $line) {
  // echo $lineNumber, LN;

  $values = str_getcsv($line);
  if ($lineNumber == 0) {
    $header = $values;
  } else {
    if (count($header) != count($values)) {
      error_log(sprintf('error in %s line #%d: %d vs %d', $csvFile, $lineNumber, count($header), count($values)));
    }
    $record = (object)array_combine($header, $values);
    $record->externalData = false;
    $record->hypothetic = false;
    $record->appendix = false;
    $record->isReference = false;
    $record->id = $record->{'01Sorszám_RMNY'};
    // print_r($record);

    if ($record->{'13Lelöhely'} == 'NA')
      $record->{'13Lelöhely'} = '';

    $record->lines = [$record->{'13Lelöhely'}];
    if (isset($record->{'15Olim'}) && $record->{'15Olim'} != 'NA') {
      $record->lines[] = 'Olim: ' . $record->{'15Olim'};
    }
    extractLocations($record);
    // if ($record->{'13Lelöhely_count'} != $record->collectionCount)
    //  print_r($record);
    fputcsv($csv, [$record->{'01Sorszám_RMNY'}, $record->{'01Sorszám_RMNY'}, ($record->cities ?? ''), ($record->olimCities ?? '')]);
  }
}
