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
    $record->collectionCount,
    ($record->olim ?? ''),
    $record->olimCount,
    ($record->facsimile ?? false),
    ($record->kollacio ?? ''), ($record->terjedelem ?? ''), ($record->formatum ?? ''), ($record->konyvdisz ?? ''),
    ($record->references ?? ''), ($record->genre ?? ''),
    (isset($record->impressum) ? $record->impressum->year : ''),
    (isset($record->impressum) ? $record->impressum->location : ''),
    (isset($record->impressum) ? $record->impressum->printer : ''),
    ($record->cities ?? ''),
  ];
  fputcsv($csv, $cells);

  // echo json_encode($record, JSON_UNESCAPED_UNICODE), LN;
}

function csvHeader($csv) {
  $cells = [
    '01Sorszám', 'externalData', 'hypothetic', 'appendix', '03Cím',
    'collections', 'collectionCount', 'olim', 'olimCount', 'facsimile',
    '07Kolláció', '08Terjedelem', '09Formátum', '10Könyvdísz',
    '11Forrás', '12Tárgy',
    '01xIdö', '01xHely', '06xNyomda',
    'cities'
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

/**
 * @param $record
 * @param $matches
 * @return mixed
 */
function extractLocations($record) {
  global $missing_locations, $cities;

  $record->facsimile = false;
  $record->olim = '';
  $record->olimCount = 0;
  $record->collections = '';
  $record->collectionCount = 0;
  if (!$record->externalData && !$record->hypothetic && !$record->appendix) {
    $lineCount = count($record->lines);
    if ($lineCount == 0) {
      if ($record->title != 'Vacat!')
        print_r($record);
    } else {
      $collections = array_pop($record->lines);
      if ($collections == 'Editio facsimile') {
        $collections = array_pop($record->lines);
        $record->facsimile = true;
      }

      if (preg_match('/^Olim: (.*?)$/', $collections, $matches)) {
        $record->olim = $matches[1];
        $record->olimCount = count(explode(' - ', $record->olim));
        $collections = array_pop($record->lines);
      }
      if (!in_array($record->id, $missing_locations)) {
        $record->collections = $collections;
        $record->collections = preg_replace('/^Gyûjteményben: /', '', $record->collections);

        $collections = explode(' - ', $record->collections);
        if (preg_match('/In (\d+) bibliothecis (\d+) expl./', $collections[0], $matches)) {
          $record->libraryCount = $matches[1];
          $record->collectionCount = $matches[2];
        } else {
          $record->collectionCount = count($collections);
          $count = 0;
          $cities = [];
          foreach ($collections as $collection) {
            $collection = preg_replace('/^\([12\-]+\): /', '', $collection);
            if (preg_match('/^(Dolný Kubín|Alba Iulia|Târgu Mureş|Valasské Mezirící|Liptovský Mikuláš|Niznij Novgorod|Odorheiu Secuiesc|Satu Mare|Sfántu Gheorghe|Spišská Nová Ves|[^ ]+) (.*)/', $collection, $matches)) {
              $city = $matches[1];
              if (!in_array($city, $cities))
                $cities[] = $city;
              $libraries = $matches[2];
              $libraries = preg_replace('/ \([^()]+\)/', '', $libraries);
              $libraries = preg_replace('/ \[[\d\-]+\]/', '', $libraries);
              $libraries = preg_replace('/(\d)\*/', "$1", $libraries);
              if (preg_match('/ (cop\. partim|cop\.|cop\. \d)$/', $libraries))
                continue;

              if (preg_match('/(Lugossy József)/', $libraries))
                error_log('ERROR @' . $record->id . ': ' . $record->collections . ' --> "' . $libraries . '"');

              if (preg_match('/(( \d)+)$/', $libraries, $matches)) {
                $numbers = $matches[1];
                // error_log($numbers . ' -> ' . strlen($numbers) / 2);
                $count += strlen($numbers) / 2;
              } else {
                $count++;
              }
              /*
              if ($city == 'Bp.')
                error_log($record->id . ': ' . $record->collections);
              if (!isset($cities[$city])) {
                error_log($city);
                $cities[$city] = 0;
              }
              $cities[$city]++;
              */
            }
            // error_log($collection);
          }
          $record->collectionCount = $count;
          error_log($record->collections . ' --> ' . $record->collectionCount);
          $record->cities = implode(", ", $cities);
        }
      }
    }
  }
}
