<?php
const LN = "\n";
$references = implode('|', [
  'RMK', 'Caplovic', 'Čaplovič', 'Sztripszky', 'VD17', 'MKsz', 'ItK', 'Gross: Kronstädter', 'Nägler', 'Knihopis', 'OSzKÉvk',
  'Seethaler', 'Stúdió Antikvárium', 'KorblVerSiebLkde', 'Knapp: Pietás', 'Borda antikvárium', 'A kolozsvári Akadémiai Könyvtár',
  'Nyelv- és Irodalomtudományi Közlemények', 'Hírnök \(Kolozsvár\)', 'ArchVerSiebLkde', 'Gesta typographorum.', 'Takács',
  'Korrespondenzblatt', 'Emlékkönyv', 'AkÉrt', 'Apponyi: Hungarica', 'Ave Tyrnavia!', 'Avram', 'Nágler', 'Nagler',
  'Gross: Kronstadter', 'Gross: Kronstádter', 'A Fővárosi Szabó Ervin Könyvtár Évkönyve', 'ErdMuz', 'V. Ecsedy: Hung. typ.',
  'Németh S. Katalin:', 'RMK-Katalógusa.', 'Régi Magyar Könyvtár-gyűjteményeinek katalógusa.', 'Glósz Miksa:',
  'Valori bibliofile din patrimoniul cultural', 'A Központi Antikvárium 150. aukciója.',
  'A Tiszántúli Református Egyházkerületi Nagykönyvtár RMK-katalógusa.', 'RMK II', 'A csíksomlyói ferences nyomda']);

$missing_refs = [
  '3766', '3811', '3852', '3854', '3862', '3864', '3866', '3879', '3881A', '3901', '3930', '3940', '3946A', '3954',
  '4031', '4035A', '4054', '4080A', '4130', '4163', '4171', '4215', '4225', '4246', '4256', '4299', '4306', '4330',
  '4330A', '4333', '4340', '4350', '4355', '4392', '4414A', '4434', '4453', '4511', '4539', '4544', '4553', '4570'];

$missing_size = ['3938', '3961', '4173', '4176', '4240', '4469', '4570'];

$file = $argv[1];
$lines = file($file);
$locations = processLocations($file);

$prev = '';
$record = [];
foreach ($lines as $line_num => $line) {
  $line = str_replace(array("\n", "\r"), '', $line);
  if ($line == '') {
    if (!empty($record)) {
      processRecord($record);
      unset($record);
    }
  }
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
      'appendix' => !empty($matches[1]),
      'lines' => []
    ];
    // echo $record->id, ', ', (int) $record->appendix, LN;
  } else if (preg_match('/^[^ ]/', $line)) {
    if (preg_match('/(Vide|Appendix) \d+[AB]?(\(\d\)|, \d+)?$/', $line) && !isset($record)) {
      // if (isset($record->lineCount))
      //   error_log('lineCount: ' . $record->lineCount);
      $record = (object)['isReference' => true];
    } else {
      if (!isset($record)) {
        error_log('missing record: ' . $line_num);
        error_log('missing record: ' . $line);
      }
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
        // echo 'wrong title line: ', $line, LN;
        if (!$record->externalData && !$record->hypothetic && !$record->appendix) {
          if ($record->lineCount == 2) {
            $record->physicalDescription = $line;
          } else if ($record->lineCount == 3 && !in_array($record->id, $missing_refs)) {
            if (preg_match('/('. $references . ') /', $line)) {
              $record->references = $line;
            } else {
              // echo $line, LN;
              error_log('not a reference: ' . $line);
              error_log('isReference: ' . (int) $record->isReference);
              // error_log($references);
              // $record->genre = $line;
            }
          } else
            $record->lines[] = $line;
        } else {
          $record->lines[] = $line;
        }
      }
      $record->lineCount++;
    }
  } else if (preg_match('/^   (.*)$/', $line, $matches)) {
    // $line = $matches[1];
    // $record->lineCount++;
  } else if (!empty($line)) {
    echo 'other line: ', $record->id, ": '$line'", LN;
  }
}

function processRecord($record) {
  global $locations;
  if (!isset($record->id)) {
    return;
  }
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
      $record->collections = $collections;
      // echo $record->id, ': ', $collections, LN;
      $parts = explode(' – ', $record->lines[0], 2);
      if (count($parts) == 2) {
        $record->genre = $parts[0];
      } else {
        error_log('missing - : ' . $record->lines[0]);
      }
    }
  }
  if (isset($record->physicalDescription)) {
    processPhysicalDescription($record);
  }
  if (isset($locations[$record->id])) {
    $location = $locations[$record->id];
    unset($location->id);
    $record->location = $location;
  } else {
    echo $record->id, LN;
  }
  unset($record->lines);
  unset($record->lineCount);
  echo json_encode($record,  JSON_UNESCAPED_UNICODE), LN;
}

function processPhysicalDescription($record) {
  global $missing_size;

  $parts = explode(' – ', $record->physicalDescription);
  if (count($parts) == 1) {
    $record->folios = $parts[0];
  } else if (count($parts) == 2) {
    $record->folios = $parts[0];
    if (in_array($record->id, $missing_size))
      $record->illustration = $parts[1];
    else
      $record->size = $parts[1];
    if (isset($record->size)) {
      if (preg_match('/Init/', $record->size))
        error_log('error: ' . $record->id . ': ' . $record->physicalDescription);
    }
  } else if (count($parts) == 3) {
    $record->folios = $parts[0];
    // if (in_array($record->id, $missing_size))
    //  $record->illustration = $parts[1];
    //else
    $record->size = $parts[1];
    $record->illustration = $parts[2];
    if (isset($record->size)) {
      if (preg_match('/init/', $record->size))
        error_log('error: ' . $record->id . ': ' . $record->physicalDescription);
    }
  }

  if (isset($record->illustration)) {
    error_log($record->illustration);
    // if (preg_match('/°/', $record->illustration))
    //   error_log('error: ' . $record->id . ': ' . $record->physicalDescription);
  }
}

function processLocations($bibliographicFile) {
  $locationsFile = sprintf('data_raw/nyomda%d.txt', preg_match('/-04/', $bibliographicFile) ? 4 : 5);
  $lines = file($locationsFile);
  $place = '';
  $printer = '';
  $locations = [];
  foreach ($lines as $lineNum => $line) {
    $line = str_replace(array("\n", "\r"), '', $line);
    if ($line == '') {
      $place = '';
    } else {
      if ($place == '') {
        $record = (object)['location' => cleanLocation($line), 'printer' => ''];
        $place = $line;
      } else if (preg_match('/^(\d{4}): (.*)/', $line, $matches)) {
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
            $locations[$rec->id] = $rec;
          } else {
            echo 'not match: ', $item, LN;
          }
        }
      } else {
        $record->printer = $line;
      }
    }
  }
  ksort($locations);
  return $locations;
}

function cleanLocation($text) {
  return preg_replace('/ \(.*?\)$/', '', $text);
}