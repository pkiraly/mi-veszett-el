<?php
const LN = "\n";
$references = implode('|', [
  'RMK', 'Caplovic', 'Sztripszky', 'VD17', 'MKsz', 'ItK', 'Gross: Kronstädter', 'Nägler', 'Knihopis', 'OSzKÉvk',
  'Seethaler', 'Stúdió Antikvárium', 'KorblVerSiebLkde', 'Knapp: Pietás', 'Borda antikvárium', 'A kolozsvári Akadémiai Könyvtár',
  'Nyelv- és Irodalomtudományi Közlemények', 'Hírnök \(Kolozsvár\)', 'ArchVerSiebLkde', 'Gesta typographorum.', 'Takács',
  'Korrespondenzblatt', 'Emlékkönyv']);

$file = '/home/pkiraly/Documents/mi-veszett-el/RMNY-04_v05.txt';

$lines = file($file);

$prev = '';
$record = [];
$lineCount = 0;
foreach ($lines as $line_num => $line) {
  $line = str_replace(array("\n", "\r"), '', $line);
  if (preg_match('/^(Appendix )?(\d+)(.*?)$/', $line, $matches)) {
    if (!empty($matches[3]) && $matches[3] != 'A') {
      echo $prev, LN;
      echo urlencode($matches[3]);
      print_r($matches);
    }
    if (!empty($record))
      processRecord($record);
    $prev = $line;
    $record = (object)[
      'id' => $line,
      'lineCount' => 1,
      'externalData' => false,
      'hypothetic' => false,
      'appendix' => !empty($matches[1]),
      'lines' => []
    ];
    // echo $record->id, ', ', (int) $record->appendix, LN;
  } else if (preg_match('/^[^ ]/', $line)) {
    if ($record->lineCount == 1) {
      $record->title = $line;
      $chr = mb_substr($line, 0, 1);
      if ($chr == '»') {
        $record->externalData = true;
      } else if ($chr == '<') {
        $record->hypothetic = true;
      }
      // echo $record->id, ': ', $chr, LN;
    } else {
      echo 'wrong title line: ', $line, LN;
    }
    $record->lineCount++;
  } else if (preg_match('/^     (.*)$/', $line, $matches)) {
    $line = $matches[1];
    if (!$record->externalData && !$record->hypothetic && !$record->appendix) {
      if ($record->lineCount == 2) {
        $record->physicalDescription = $line;
      } else if ($record->lineCount == 3) {
        if (preg_match('/('. $references . ') /', $line))
          $record->references = $line;
        else
          $record->genre = $line;
      } else
        $record->lines[] = $line;
    } else {
      $record->lines[] = $line;
    }
    $record->lineCount++;
  } else if (!empty($line)) {
    echo 'other line: ', $record->id, ": '$line'", LN;
  }
}

function processRecord($record) {
  if (!$record->externalData && !$record->hypothetic && !$record->appendix) {
    $lineCount = count($record->lines);
    if ($lineCount == 0) {
      // print_r($record);
    } else {
      // echo $lineCount, LN;
      $collections = $record->lines[$lineCount - 1];
      if ($collections == 'Editio facsimile')
        $collections = $record->lines[$lineCount - 2];
      else if (preg_match('/^Olim: /', $collections)) {
        $record->olim = $collections;
        if ($lineCount > 1)
          $collections = $record->lines[$lineCount - 2];
      }
      echo $record->id, ': ', $collections, LN;
    }
  }
}