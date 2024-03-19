<?php
include_once 'functions.php';

const LN = "\n";
const PHYSICAL_DESCRIPTION_SEPARATOR = ' - ';

$references = implode('|', [
  'RMK', 'Caplovic', 'Sztripszky', 'VD17', 'MKsz', 'ItK', 'Gross: Kronstädter', 'Nägler', 'Knihopis', 'OSzKÉvk',
  'Seethaler', 'Stúdió Antikvárium', 'KorblVerSiebLkde', 'Knapp: Pietás', 'Borda antikvárium', 'A kolozsvári Akadémiai Könyvtár',
  'Nyelv- és Irodalomtudományi Közlemények', 'Hírnök \(Kolozsvár\)', 'ArchVerSiebLkde', 'Gesta typographorum.', 'Takács',
  'Korrespondenzblatt', 'Emlékkönyv', 'AkÉrt', 'Apponyi: Hungarica', 'Ave Tyrnavia!', 'Avram', 'Nágler', 'Nagler',
  'Gross: Kronstadter', 'Gross: Kronstádter', 'A Fővárosi Szabó Ervin Könyvtár Évkönyve', 'ErdMuz', 'V. Ecsedy: Hung. typ.',
  'Németh S. Katalin:', 'RMK-Katalógusa.', 'Régi Magyar Könyvtár-gyűjteményeinek katalógusa.', 'Glósz Miksa:',
  'Valori bibliofile din patrimoniul cultural naponal.']);

$missing_refs = [];
$missing_size = ['2652', '2680', '2692', '2702', '2743', "2773", '2925', '2950', '3027', '3336', '3394'];
$missing_locations = ['2758', '3564'];
$cities = [];
$olimToLocation = initOlimToLocation();
$olims = [];
$debug = false;
$range = ['2626', '3696'];
$id2languages = processLanguageIndex('data_raw/nyelv4.txt');

$file = $argv[1];
$lines = file($file);
$impressums = processImpressums($file);
$csv = fopen('data/rmny4.csv', 'w');
csvHeader($csv);

$prev = '';
$record = [];
foreach ($lines as $line_num => $line) {
  $line = str_replace(array("\n", "\r"), '', $line);
  if (preg_match('/^(Appendix )?(\d+)([AB])?$/', $line, $matches)) {
    if (!empty($matches[3]) && !in_array($matches[3], ['A', 'B'])) {
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
      'isReference' => false,
      'appendix' => !empty($matches[1]),
      'lines' => [],
      'genre' => '',
    ];
    // echo $record->id, ', ', (int) $record->appendix, LN;
  } else if (preg_match('/^[^ ]/', $line)) {
    if (preg_match('/(Vide|Appendix) \d+[AB]?(\(\d\)|, \d+)?$/', $line)) {
      $record->isReference = true;
    } else {
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
    }
  } else if (preg_match('/^   (.*)$/', $line, $matches)) {
    $line = $matches[1];
    if (!$record->externalData && !$record->hypothetic && !$record->appendix) {
      if ($record->lineCount == 2) {
        $record->physicalDescription = $line;
      } else if ($record->lineCount == 3) {
        if (preg_match('/('. $references . ') /', $line))
          $record->references = $line;
        else {
          // echo $line, LN;
          $record->genre = $line;
        }
      } else {
        if ($record->genre == '') {
          $record->genre = $line;
        } else {
          $record->lines[] = $line;
        }
      }
    } else {
      $record->lines[] = $line;
    }
    $record->lineCount++;
  } else if (!empty($line)) {
    echo 'other line: ', $record->id, ": '$line'", LN;
  }
}
// printOlims();

function processRecord($record) {
  global $impressums;

  extractLocations($record);
  finalizeRecord($record, $impressums);
}


/*
2758: nincs locations, sem »
impressum error: 2962 is already registered
impressum error: 2636 is already registered
impressum error: 2760 is already registered
impressum error: 2760 is already registered
impressum error: 3633 is already registered
impressum error: 3421 is already registered
impressum error: 3514 is already registered
impressum error: 3515 is already registered
impressum error: 3520 is already registered
impressum error: 3436 is already registered
impressum error: 3436 is already registered
impressum error: 3216 is already registered
impressum error: 3173 is already registered
impressum error: 3683 is already registered
impressum error: 3180 is already registered
impressum error: 3542 is already registered
impressum error: 2957 is already registered
impressum error: 3187 is already registered
 */