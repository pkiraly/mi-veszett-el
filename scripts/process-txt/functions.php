<?php

/**
 * @param $record
 * @param array $impressums
 * @return array
 */
function finalizeRecord($record, array $impressums) {
  global $csv;

  if (isset($record->physicalDescription)) {
    processPhysicalDescription($record);
  }
  if (isset($impressums[$record->id])) {
    $impressum = $impressums[$record->id];
    unset($impressum->id);
    $record->impressum = $impressum;
  } else {
    echo $record->id, LN;
  }
  unset($record->lines);
  unset($record->lineCount);
  $cells = [
    $record->id, $record->externalData, $record->hypothetic, $record->appendix, $record->title,
    ($record->collections ?? ''),
    ($record->kollacio ?? ''), ($record->terjedelem ?? ''), ($record->formatum ?? ''), ($record->konyvdisz ?? ''),
    ($record->references ?? ''), ($record->genre ?? ''),
    (isset($record->impressum) ? $record->impressum->year : ''),
    (isset($record->impressum) ? $record->impressum->location : ''),
    (isset($record->impressum) ? $record->impressum->printer : '')
  ];
  fputcsv($csv, $cells);

  // echo json_encode($record, JSON_UNESCAPED_UNICODE), LN;
}

function csvHeader($csv) {
  $cells = [
    '01Sorszám', 'externalData', 'hypothetic', 'appendix', '03Cím',
    'collections',
    '07Kolláció', '08Terjedelem', '09Formátum', '10Könyvdísz',
    '11Forrás', '12Tárgy',
    '01xIdö', '01xHely', '06xNyomda'
  ];

  fputcsv($csv, $cells);
}

function cleanLocation($text) {
  return preg_replace('/ \(.*?\)$/', '', $text);
}

function processPhysicalDescription($record) {
  global $missing_size;

  $record->kollacio = '';
  $record->konyvdisz = '';
  $record->formatum = '';
  $record->terjedelem = '';


  $parts = explode(PHYSICAL_DESCRIPTION_SEPARATOR, $record->physicalDescription);
  if (count($parts) == 1) {
    $record->kollacio = $parts[0];
  } else if (count($parts) == 2) {
    $record->kollacio = $parts[0];
    if (in_array($record->id, $missing_size))
      $record->konyvdisz = $parts[1];
    else
      $record->formatum = $parts[1];
    if (isset($record->formatum)) {
      if (preg_match('/Init/', $record->formatum))
        error_log('error: ' . $record->id . ': ' . $record->physicalDescription);
    }
  } else if (count($parts) == 3) {
    $record->kollacio = $parts[0];
    $record->formatum = $parts[1];
    $record->konyvdisz = $parts[2];
    if (isset($record->formatum)) {
      if (preg_match('/init/', $record->formatum))
        error_log('error: ' . $record->id . ': ' . $record->physicalDescription);
    }
  }

  if (isset($record->kollacio)) {
    $parts = explode(' = ', $record->kollacio);
    if (count($parts) != 2) {
      $record->terjedelem = $record->kollacio;
      unset($record->kollacio);
    } else {
      $record->kollacio = $parts[0];
      $record->terjedelem = $parts[1];
    }
  }

  if (isset($record->formatum)) {
    // error_log($record->formatum);
    if (preg_match('/Orn/', $record->formatum)) {
      error_log($record->physicalDescription . ": " .  $record->formatum);
    }
  }

  if (isset($record->konyvdisz)) {
    // error_log($record->konyvdisz);
    if (preg_match('/°/', $record->konyvdisz)) {
      error_log('physicalDescription: ' . $record->physicalDescription);
    }
  }
}

function processImpressums($bibliographicFile): array {
  $locationsFile = sprintf('data_raw/nyomda%d.txt', preg_match('/-04/', $bibliographicFile) ? 4 : 5);
  $lines = file($locationsFile);
  $place = '';
  $printer = '';
  $impressums = [];
  foreach ($lines as $lineNum => $line) {
    $line = str_replace(array("\n", "\r"), '', $line);
    if ($line == '') {
      $place = '';
    } else {
      if ($place == '') {
        $record = (object)['location' => cleanLocation($line), 'printer' => ''];
        $place = $line;
      } else if (preg_match('/^(\d{4}(?: előtt)?): (.*)/', $line, $matches)) {
        // print_r($matches);
        $year = $matches[1];
        $refs = $matches[2];
        while (preg_match('/(\([^),]+),/', $refs))
          $refs = preg_replace('/(\([^),]+),/', "$1;", $refs);
        $items = explode(', ', $refs);
        foreach ($items as $item) {
          if (preg_match('/^(\d+[AB]?)( .*)?$/', $item, $matches)) {
            if (!isset($record->printer))
              echo 'no printer: ', $lineNum, ' - ', $line, LN;
            $rec = (object)[
              'id' => $matches[1],
              'year' => $year,
              'location' => $record->location,
              'printer' => $record->printer,
            ];
            if (!empty($matches[2]))
              $rec->alt = $matches[2];
            if (isset($impressums[$rec->id]))
              error_log('impressum error: ' . $rec->id . ' is already registered');
            $impressums[$rec->id] = $rec;
          } else {
            echo 'not match: ', $item, LN;
          }
        }
      } else {
        $record->printer = $line;
      }
    }
  }
  ksort($impressums);
  return $impressums;
}
