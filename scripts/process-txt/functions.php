<?php

$languages = ['más nyelven' => 'egyéb',
  'magyar vers idegen nyelvű műben' => 'magyar;idegen nyelv',
  'magyar szövegek nem magyar nyelvű műben' => 'magyar;idegen nyelv',
  'latin ismeretlen' => 'latin;ismeretlen', 'görög-keleti, románul' => 'román',
  'magyarul és latinul' => 'magyar;latin', 'latinul, latin és német versekkel' => 'latin;német',
  'németül, latin verssel' => 'német;latin', 'németül, német és latin versekkel' => 'német;latin',
  // 4
  'latin–német–magyar-biblikus cseh' => 'latin;német;magyar;biblikus cseh',
  'latin–biblikus cseh–magyar–német' => 'latin;biblikus cseh;magyar;német',
  'latin–cseh–magyar–német' => 'latin;cseh;magyar;német',  'latin–görög–magyar–német' => 'latin;görög;magyar;német',
  'magyar–görög–latin–német' => 'magyar;görög;latin;német',  'latin–magyar–német–cseh' => 'latin;magyar;német;cseh',
  // 3
  'latin–német-magyar' => 'latin;német;magyar', 'latin–magyar-német' => 'latin;magyar;német',
  'magyar–latin–német' => 'magyar;latin;német', 'latin–cseh–német' => 'latin;cseh;német',
  'latin–magyar–német' => 'latin;magyar;német', 'latin–magyar–biblikus cseh' => 'latin;magyar;biblikus cseh',
  'latin–német–cseh' => 'latin;német;cseh',
  // 2
  'német-latin' => 'német;latin', 'latin-német' => 'latin-német', 'latin–német' => 'latin;német',
  'latin-magyar' => 'latin;magyar', 'magyar–latin' => 'magyar;latin',
  'magyar-latin' => 'magyar;latin', 'latin–biblikus cseh' => 'latin;biblikus cseh', 'latin–görög' => 'latin;görög',
  'latin–magyar' => 'latin;magyar', 'latin-magyar' => 'latin;magyar', 'magyar–német' => 'magyar;német',
  'latin-német' => 'latin;német', 'latin–lengyel' => 'latin;lengyel',
  // 1
  'magyarul' => 'magyar', 'magyar' => 'magyar', 'latin' => 'latin',
  'latinul' => 'latin', 'német' => 'német', 'szlovákul' => 'szlovák',
  'biblikus cseh nyelven' => 'biblikus cseh', 'biblikus cseh' => 'biblikus cseh',
  'cseh nyelven' => 'cseh', 'cseh' => 'cseh',
  'franciául' => 'francia', 'francia' => 'francia',
  'hollandul' => 'holland', 'holland' => 'holland',
  'románul' => 'román', 'román' => 'román', 'szász' => 'szász', 'szlovák' => 'szlovák',
  'görög' => 'görög', 'angolul' => 'angol', 'olasz' => 'olasz', 'héber' => 'héber', 'angol' => 'angol',
  'lengyel' => 'lengyel', 'szír' => 'szír', 'több nyelven' => 'több nyelven', 'fríz' => 'fríz',
  'horvát' => 'horvát', 'lett' => 'lett', 'orosz' => 'orosz', 'plattdeutsch' => 'plattdeutsch',
  'svéd' => 'svéd', 'szlovén' => 'szlovén', 'dán' => 'dán'
];
$languagesRegex = '/\\b(' . join('|', array_keys($languages)) . ')\\b/';

/**
 * @param $record
 * @param array $impressums
 * @return array
 */
function finalizeRecord($record, array $impressums) {
  global $csv, $id2languages;

  if ($record->isReference || (isset($record->title) && $record->title == 'Vacat!'))
    return;

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
  if (isset($id2languages[$record->id])) {
    sort($id2languages[$record->id]);
    $record->languages = join('; ', $id2languages[$record->id]);
  }
  unset($record->lines);
  unset($record->lineCount);
  if (preg_match('/^(\d+)(.*?)$/', $record->id, $matches)) {
    $record->rmnyId = $matches[1];
    $record->rmnyIdS = $matches[2];
  } else if (preg_match('/^Appendix (\d+)(.*?)$/', $record->id, $matches)) {
    $record->rmnyId = $matches[1];
    $record->rmnyIdS = $matches[2];
  } else {
    error_log('WRONG id: ' . $record->id);
  }

  $cells = [
    $record->id, $record->rmnyId, $record->rmnyIdS,
    $record->externalData, $record->hypothetic, $record->appendix,
    ($record->title ?? ''),
    (isset($record->impressum) ? $record->impressum->year : ''),
    (isset($record->impressum) ? $record->impressum->location : ''),
    (isset($record->impressum) ? $record->impressum->printer : ''),
    '',
    ($record->kollacio ?? ''), ($record->terjedelem ?? ''), ($record->formatum ?? ''), ($record->konyvdisz ?? ''),
    ($record->references ?? ''),
    ($record->genre ?? ''),
    ($record->facsimile ?? false),
    ($record->languages ?? ''),
    ($record->collections ?? ''), $record->collectionCount, ($record->cities ?? ''),
    ($record->olim ?? ''), $record->olimCount, ($record->olimCities ?? '')
  ];
  fputcsv($csv, $cells);

  // echo json_encode($record, JSON_UNESCAPED_UNICODE), LN;
}

function csvHeader($csv) {
  $cells = [
    '01Sorszám', '01Sorszám_RMNY', '01Sorszám_RMNY-S',
    'externalData', 'hypothetic', 'appendix', '03Cím',
    '01xIdö', '01xHely', '06xNyomda',
    '06Nyomda',
    '07Kolláció', '08Terjedelem', '09Formátum', '10Könyvdísz',
    '11Forrás', '12Tárgy',
    '14Facsimile',
    '16Nyelv',
    '13Lelöhely', '13Lelöhely_count', 'cities',
    '15Olim', '15Olim_count', 'olimCities'
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
            /*
            if (isset($impressums[$rec->id]))
              error_log('impressum error: ' . $rec->id . ' is already registered');
            */
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
  global $missing_locations, $cities, $olims, $olimToLocation, $debug;

  $record->facsimile = false;
  $record->olim = '';
  $record->olimCount = 0;
  $record->collections = '';
  $record->collectionCount = 0;
  if ($record->isReference)
    return;
  if (!isset($record->externalData) || !isset($record->hypothetic) || !isset($record->appendix)) {
    error_log('no externalData or hypothetic or appendix');
    print_r($record);
  } else {
    if (!$record->externalData && !$record->hypothetic && !$record->appendix && !$record->isReference) {
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

          $currentOlims = explode(PHYSICAL_DESCRIPTION_SEPARATOR, $record->olim);
          $record->olimCount = count($currentOlims);
          $collections = array_pop($record->lines);
          $olimCities = [];
          foreach ($currentOlims as $olimOrig) {
            if ($olimOrig == '')
              continue;
            $olim = preg_replace('/ \([^()]+\)/', '', $olimOrig);
            if (isset($olimToLocation[$olim]))
              $olimCities[] = $olimToLocation[$olim];
            else {
              error_log('missing resolution @ ' . $record->id . ": '" . $olimOrig . "'");
              error_log('   ' . $record->olim);
            }
            $olim = $olimToLocation[$olim] ?? $olim;
            if (!isset($olims[$olim]))
              $olims[$olim] = 0;
            $olims[$olim]++;
          }
          $record->olimCities = implode(', ', $olimCities);
        }

        if (!in_array($record->id, $missing_locations)) {
          $collections = str_replace(
            ['', '', '', '', '', '', '', ''],
            ['0',  '1',  '1', '2', '2',  '3',  '3', '4'], $collections);
          // error_log($collections);
          $record->collections = $collections;
          $record->collections = preg_replace('/^Gyûjteményben: /', '', $record->collections);

          $collections = explode(PHYSICAL_DESCRIPTION_SEPARATOR, $record->collections);
          #                       In 16 bibliothecis 24 exp.
          #                       In 32 bibiothecis 47 expl.
          if (preg_match('/In (\d+) bibliothecis (\d+) expl./', $collections[0], $matches)) {
            $record->libraryCount = $matches[1];
            $record->collectionCount = (int) $matches[2];
            array_shift($collections);
            $overwriteCount = false;
          } else {
            $overwriteCount = true;
          }
          if ($overwriteCount)
            $record->collectionCount = count($collections);
          $count = 0;
          $cities = [];
          foreach ($collections as $collection) {
            if ($collection == 'In multis bibliothecis multa expl.' ||
                $collection == 'In permultis bibliothecis multa expl.' ||
                $collection == 'In multis bibliothecis permulta expl.' ||
                $collection == 'etc.'
            )
              continue;
            if ($collection == 'In 30 bibliothecis multa expl.') {
              $count = 30;
              continue;
            }
            $collection = preg_replace('/^\([12\-]+\): /', '', $collection);
            if (preg_match('/^(New Haven|New York|Den Haag|Banská Štiavnica|Banská Bystrica|Dolný Kubín|Alba Iulia|Tîrgu Mureș|Tîrgu Mureş|Târgu Mureş|Târgu Mureș|Valasské Mezirící|Liptovský Mikuláš|Niznij Novgorod|Nižnij Novgorod|Odorheiu Secuiesc|Satu Mare|Sfántu Gheorghe|Sfântu Gheorghe|Spišská Nová Ves|Spišské Podhradie|Miercurea Ciuc|Csíki Székely Múzeum, Csíksomlyói Ferences Gyűjtemény|[^ ]+) ?(.*)/', $collection, $matches)) {
              $city = $matches[1];
              if ($city == 'Csíki Székely Múzeum, Csíksomlyói Ferences Gyűjtemény')
                $city = 'Csíkszereda';
              $libraries = $matches[2];
              if (in_array($city, ['Cf.', 'Acad,', 'A-variáns:', '[1]', 'Den', 'imádságoskönyv:'. 'In ', 'Inst',
                'Liptovsky', 'Miercurea', 'New', 'Nižnij', 'Olim', 'Sfântu', 'Spisská', 'Spišské', 'Târgu', '–']))
                error_log('ERROR: ' . $record->collections . ' => "' . $city . '"');
              // error_log($record->id . ': ' . $city);
              if (!isset($cities[$city]))
                $cities[$city] = 0;

              while (preg_match('/ ?\([^()]+\)/', $libraries)) {
                // error_log('before ' . $libraries);
                $libraries = preg_replace('/ ?\([^()]+\)/', '', $libraries);
                // error_log('after ' . $libraries);
              }
              $libraries = preg_replace('/ \[[\d\-]+\]/', '', $libraries);
              $libraries = preg_replace('/ \+ cop\. digit\./', '', $libraries);
              $libraries = preg_replace('/ \+ cop\. partim/', '', $libraries);
              $libraries = preg_replace('/ \+ cop\.$/', '', $libraries);
              $libraries = preg_replace('/ \+ phot\.$/', '', $libraries);
              $libraries = preg_replace('/ \+ phot\. suppl\./', '', $libraries);
              $libraries = preg_replace('/ \+ phot\. partim suppl\.$/', '', $libraries);
              $libraries = preg_replace('/ facs\. suppl\./', '', $libraries);
              $libraries = preg_replace('/ phot\. suppl\./', '', $libraries);
              $libraries = preg_replace('/([\dО])(\*|\?|\?\?)/', "$1", $libraries);
              $libraries = preg_replace('/^(\d|O|О)/', " $1", $libraries);
              if ($debug)
                error_log($libraries);

              if (preg_match('/ (cop\. partim|cop\.|cop\. \d|cop\. digit\. partim|cop\. digit\.|phot\.|phot\.\?|phot\. partim)$/', $libraries))
                continue;

              // if (preg_match('/(Lugossy József)/', $libraries))
              //   error_log('ERROR @' . $record->id . ': ' . $record->collections . ' --> "' . $libraries . '"');
              if (preg_match('/, /', $libraries)) {
                $lcount = count(explode(', ', $libraries));
              } else {
                if (preg_match('/(( [\dOО])+)$/u', $libraries, $matches)) {
                  $lcount = mb_strlen($matches[1]) / 2;
                } else {
                  $lcount = 1;
                }
              }
              if ($debug)
                error_log(' -> ' . $lcount);
              $count += $lcount;
              $cities[$city] += $lcount;
            }
          }

          if ($overwriteCount)
            $record->collectionCount = $count;
          // error_log($record->collections . " => " . $count);
          $formattedCities = [];
          foreach ($cities as $city => $count)
            if ($count > 0)
              $formattedCities[] = $city . '=' . $count;
          $record->cities = implode(", ", $formattedCities);
        }
      }
    }
  }
}

function processLanguageIndex($languageFile): array {
  global $id2languages;

  $id2languages = [];
  $lines = file($languageFile);
  foreach ($lines as $line_num => $line) {
    $line = trim($line);
    if ($line == '---') {
      $normal = FALSE;
      continue;
    }
    processLanguageLine($line_num, $line);
  }
  return $id2languages;
}

function processLanguageLine($line_num, $line): void {
  global $languages, $languagesRegex, $id2languages, $range;
  $detected = FALSE;
  if (preg_match($languagesRegex, $line, $matches)) {
    $detected = explode(';', $languages[$matches[1]]);
    if (!preg_match('/-/', $matches[1])) {
      $languagesRegex2 = '/-\\b(' . join('|', array_keys($languages)) . ')\\b/';
      if (preg_match($languagesRegex2, $line)) {
        echo 'x2] ', $line_num, ": '$line'", LN;
      }
    }
  } else {
    echo 'x0] ', $line_num, ": '$line'", LN;
  }
  $ids = extractNumbers($line_num, $line);
  // echo $line, LN;
  // echo TB, join(' - ', $detected), ' = ', join(' - ', $ids), LN;
  foreach ($ids as $id) {
    if ($id < $range[0] || $id > $range[1])
      echo 'ERROR: ', $id, LN;
    if (!isset($id2languages[$id]))
      $id2languages[$id] = [];
    foreach ($detected as $lang) {
      if (!in_array($lang, $id2languages[$id]))
        $id2languages[$id][] = $lang;
    }
  }
}

function extractNumbers($line_num, $line): array {
  $ids = [];
  if (preg_match_all('/(\d{4}[A-Z]?)/', $line, $matches)) {
    $ids = $matches[1];
  }
  return $ids;
}

function printOlims() {
  global $olims;
  arsort($olims);
  foreach ($olims as $olim => $count) {
    error_log(sprintf('%s: %d', $olim, $count));
  }
}

function initOlimToLocation() {
  return [
    'a debreczeni városi nyomda irodája' => 'Debrecen',
    'A nagyenyedi ref. coll. ktárában gr. Bethlen Kata könyvei közt.' => 'Nagyenyed',
    'Abaúj-Torna megye levéltára' => 'Kassa',
    'Akad (Budapest)' => 'Budapest',
    'Akad' => 'Budapest',
    'Akad. (Budapest)' => 'Budapest',
    'Akad.' => 'Budapest',
    'Alsósebes, franc, zárda' => 'Alsósebes',
    'Appony, MS Zay' => 'Appony',
    'Arad, főgimn.' => 'Arad',
    'Athos, Chilandar' => 'Hilandar',
    'B. Radvánszky-könyvtárban Radványban' => 'Radvány',
    'Radvány, b. Radvánszky ktárban' => 'Radvány',
    'Balázsfalván Cipariu Timotheus könyvtárában' => 'Balázsfalva',
    'Berlin' => 'Berlin',
    'Berlin, Nat' => 'Berlin',
    'Berlin, Univ. Inst.' => 'Berlin',
    'Besztercebányai káptalan' => 'Besztercebánya',
    'besztercebányai püsp. ktárban Szent-Kereszten' => 'Besztercebánya',
    'Besztercebányai ev. algymn.' => 'Besztercebánya',
    'Besztercebányai ev. algimn.' => 'Besztercebánya',
    'Besztercebánya ev. algymn.' => 'Besztercebánya',
    'Besztercebánya, ev. algymn.' => 'Besztercebánya',
    'Bethlen, Bethlen Pálné' => 'Bethlen',
    'Betlér' => 'Betlér',
    'Betlér, Nádasdy' => 'Betlér',
    'Betlér, Nádasdy-könyvtár' => 'Betlér',
    'B. Apor László ktárában Bécsben' => 'Bécs',
    'Bibliotheca Musaei Nat. Hung. Budapestini (Zelliger: Pantheon 1676/4)' => 'Budapest',
    'Bibliotheca Musaei Nat. Hung. Budapestini' => 'Budapest',
    'Budapest, Nat.' => 'Budapest',
    'Blaj, Moldovan I. M.' => 'Blaj',
    'Brassai ev. gymn.' => 'Brassó',
    'Brassó, Bonifație Pitiș pópa' => 'Brassó',
    'Brassó, ev. gymn.' => 'Brassó',
    'Brassai ev. Gymn.' => 'Brassó',
    'Brassó, Biserica Sf. Nicolae' => 'Brassó',
    'Brassó, ev. gimn.' => 'Brassó',
    'Brassó, ev. gymn.' => 'Brassó',
    'Brassó, ev. gimn. (expl. 2.)' => 'Brassó',
    'Brassó, ev. gimn. (Gross, Kronstädter 196)' => 'Brassó',
    'Bratislava Acad' => 'Bratislava',
    'Braunsberg, Bibliothek der Akademie' => 'Braunsberg',
    'Budapest Acad' => 'Budapest',
    'Budapest, Akad.' => 'Budapest',
    'Budapest, Egyetem' => 'Budapest',
    'Budapest, Egyetemi Könyvtár' => 'Budapest',
    'Budapest Borda Antikvárium ' => 'Budapest',
    'Budapest Papnövelde' => 'Budapest',
    'Budapest, Közp. papnövelde' => 'Budapest',
    'Budapest, Központi papnövelde' => 'Budapest',
    'Budapest, MNM levéltára' => 'Budapest',
    'Budapest, Nat. 4' => 'Budapest',
    'Budapest, Dobrovszky Ágost' => 'Budapest',
    'Budapest, Jankovich Miklós' => 'Budapest',
    'Budapest, Kornfeld Móric.' => 'Budapest',
    'Budapest ref. coll.' => 'Budapest',
    'Budapest, ref.' => 'Budapest',
    'Budapest, ref. coll.' => 'Budapest',
    'Budapest, ref. koll.' => 'Budapest',
    'Budapest, Természettudományi társulat ktára' => 'Budapest',
    'Budapest Univ' => 'Budapest',
    'Budapest, papnöv.' => 'Budapest',
    '(Budapest) Nagy István' => 'Budapest',
    'Budapest, Nagy István' => 'Budapest',
    'Budapest, Kornfeld Móric' => 'Budapest',
    'Cornides Dániel könyvtárában' => 'Budapest',
    'Cornides Dániel könyvtára' => 'Budapest',
    'Bucureşti Acad.' => 'Bucureşti',
    'Bucureşti, Acad.' => 'Bucureşti',
    'Csetneken, a gömöri ev. esp. ktárában' => 'Csetnek',
    'Csetnek gömöri ev. esp.' => 'Csetnek',
    'Csetnek, gömöri ev. esp.' => 'Csetnek',
    'Csornai convent.' => 'Csorna',
    'Csép, közbirtokossági levéltár' => 'Csép',
    'Csiksomlyó, fr. zárda' => 'Csíksomlyó',
    'Csíksomlyó, francisc.' => 'Csíksomlyó',
    'Csurgó, ref. gymn.' => 'Csurgó',
    'Cieszyn, K. ev. sboru.' => 'Cieszyn',
    'Csernyivci, Univ' => 'Chernivtsi',
    'Debrecen Lugossy József' => 'Debrecen',
    'Debreceni ref. coll., Lugossy József' => 'Debrecen',
    'Debrecen, Lugossy József' => 'Debrecen',
    'Lugossy József Debrecen' => 'Debrecen',
    'Debreceni r. cath. gymn.' => 'Debrecen',
    'Debreczeni r.c. gymn.' => 'Debrecen',
    'Debreczeni ref. coll.' => 'Debrecen',
    'Debrecen ref. coll.' => 'Debrecen',
    'Debreceni ref. coll.' => 'Debrecen',
    'Debreczeni rkat.gymn.' => 'Debrecen',
    'Debreczeni r. cath. lyc.' => 'Debrecen',
    'Debrecen Ref coll' => 'Debrecen',
    'Debrecen, ref.' => 'Debrecen',
    'Debrecen, ref. coll.' => 'Debrecen',
    'Debrecen Univ (ld. Confessio 1979: 85)' => 'Debrecen',
    'Debrecen Univ' => 'Debrecen',
    'Debreczeni r. cath. lyc.' => 'Debrecen',
    'Debreczeni r.cath. gymn.' => 'Debrecen',
    'Dániel Gábornál Vargyason' => 'Vargyas',
    'Dézs, franc. zárda' => 'Dés',
    'Dolny Kubín, Caplovicova k.' => 'Alsókubin',
    'Durham káptalani könyvtár' => 'Durham',
    'Egri érs. lyc.' => 'Eger',
    'Eger' => 'Eger',
    'Eger érseki könyvtár' => 'Eger',
    'Eger, érs. lyc.' => 'Eger',
    'Eger, érseki' => 'Eger',
    'Eger, érseki lyceum' => 'Eger',
    'Eger, érseki könyvtár' => 'Eger',
    'Egyetem (= Budapest Univ)' => 'Budapest',
    'Egyetem' => 'Budapest',
    'Eperjes ev. koll.' => 'Eperjes',
    'Eperjesi franc. z.' => 'Eperjes',
    'Eperjes, ev.' => 'Eperjes',
    'Eperjes, ev. coll.' => 'Eperjes',
    'Erdélyi Múzeum (A- és B-variáns)' => 'Kolozsvár',
    'Erdélyi Múzeum' => 'Kolozsvár',
    'Erdélyi Múzeum könyvtára' => 'Kolozsvár',
    'Kolozsvár, Erd. Mus.' => 'Kolozsvár',
    'Kolozsvár, Erdélyi Múzeum' => 'Kolozsvár',
    'Kolozsvár, franc. zárda' => 'Kolozsvár',
    'Kolozsvár, minor. zárda' => 'Kolozsvár',
    'Erd. ev. egyházker.' => 'Kolozsvár',
    'Erdő-Szádán gr. Degenfeld Pálnál' => 'Erdőszáda',
    'Erdőszáda, Degenfeld Pál' => 'Erdőszáda',
    'Esztergom Dioec' => 'Esztergom',
    'Esztergom, Dioec.' => 'Esztergom',
    'Esztergom, Simor' => 'Esztergom',
    'Esztergom' => 'Esztergom',
    'Fălciu, Muzeul Pr. V. Ursăcescu din Olteneşti.' => 'Fălciu',
    'Franz Xaver Dressler (vide Türk: i. m. 116)' => 'Szeben',
    'Franz Xaver Dressler' => 'Szeben',
    'Fáy könyvtárban Tibold-Daróczon' => 'Tibolddaróc',
    'Fáy-ktár Tibold-Daróczon' => 'Tibolddaróc',
    'Fáy-ktárban Tibold-Daróczon' => 'Tibolddaróc',
    'Fáy-könyvtár Tibold-Daróczon' => 'Tibolddaróc',
    'Fáy-könyvtárban Tibold-Darócon' => 'Tibolddaróc',
    'Fáy-könyvtárban Tibold-Daróczon' => 'Tibolddaróc',
    'Tibolddaróc, Fáy' => 'Tibolddaróc',
    'Tibolddaróc, Fáy Alajos' => 'Tibolddaróc',
    'Firenze, Nat' => 'Firenze',
    'Galgóczi franc. zárda' => 'Galgóc',
    'Géresi Kálmánnál Debreczenben' => 'Debrecen',
    'Gotha, Scient' => 'Gotha',
    'Gr. Degenfeld Pál' => 'Erdőszáda',
    'Gr. Toldalagi Victornál Koronkán' => 'Koronka',
    'gr. Toldalagi Victornál' => 'Koronka',
    'Gy.-fv. Batthyány ktár' => 'Gyulafehérvár',
    'Gyulafehérvár, Batthyany-könyvtár' => 'Gyulafehérvár',
    'Gyulafehérvár, Batthyány' => 'Gyulafehérvár',
    'Gyulafehérvár, seminarium 2 expl.' => 'Gyulafehérvár',
    'Gyöngyös' => 'Gyöngyös',
    'Győr, Papnövelde' => 'Győr',
    'Gömöri ref. esp.' => 'Rozsnyó',
    'Gömör, ref. esp.' => 'Rozsnyó',
    'H.-m.-vásárhelyi gymn.' => 'Hódmezővásárhely',
    'Hód-mezõ-vásárhelyi ref. gymn.' => 'Hódmezővásárhely',
    'Halasi ref. gymn.' => 'Kiskunhalas',
    'Halle Univ (← Berlin Univ Inst ← Halle Univ)' => 'Halle|Berlin',
    'Halle Univ' => 'Halle',
    'Harkov, Museum' => 'Harkov',
    'Herepei János' => 'Kolozsvár',
    'Hosszufaluban gr. Teleki ktárban' => 'Hosszufalu',
    'Háromszéki Cserey Muzeum' => 'Sepsiszentgyörgy',
    'Háromszéki Cserey-Muz.' => 'Sepsiszentgyörgy',
    'Háromszéki Cserey-Muzeum' => 'Sepsiszentgyörgy',
    '(Sepsiszentgyörgy) Háromszéki Cserey-Muz' => 'Sepsiszentgyörgy',
    'Székely Múz.' => 'Sepsiszentgyörgy',
    'Sepsiszentgyörgy Cserey-Múzeum' => 'Sepsiszentgyörgy',
    'Sepsiszentgyörgy, Cserey Múzeum.' => 'Sepsiszentgyörgy',
    'Sepsiszentgyörgy, Mus' => 'Sepsiszentgyörgy',
    'Sepsiszentgyörgy, Székely Múz.' => 'Sepsiszentgyörgy',
    'Kalocsa' => 'Kalocsa',
    'Kassai jogakad.' => 'Kassa',
    'Kassa, jogakad.' => 'Kassa',
    'Kassa, Városi Levéltár' => 'Kassa',
    'Kassai püsp.' => 'Kassa',
    'Kassa Püspöki könyvtár' => 'Kassa',
    'Kecskeméti ref. coll.' => 'Kecskemét',
    'Kecskemét, ref. coll.' => 'Kecskemét',
    'Kecskemét, Városi Könyvtár' => 'Kecskemét',
    'Kecskemét, Városi könyvtár' => 'Kecskemét',
    'Keszthely' => 'Keszthely',
    'Keszthely, a Festetics-ktárban' => 'Keszthely',
    'Kiskunhalas, ref. gymn.' => 'Kiskunhalas',
    'Kismarton Eszterházy' => 'Kismarton',
    'Kismarton, Eszterházy-könyvtár' => 'Kismarton',
    'Kismarton, Eszterházy' => 'Kismarton',
    'Kismarton, franc. zárda' => 'Kismarton',
    'Kolozsvár minor. zárda' => 'Kolozsvár',
    'Kolozsvári minor. zárda' => 'Kolozsvár',
    'Kolozsvár, Erd. Muz.' => 'Kolozsvár',
    'Kolozsvár, Erdélyi Múzeum.' => 'Kolozsvár',
    'Kolozsvár, r. cath. lyc.' => 'Kolozsvár',
    'Kolozsvár, ref. coll.' => 'Kolozsvár',
    'Kolozsvár, róm. kat. lyc.' => 'Kolozsvár',
    'Kolozsvár, Simén Domokos' => 'Kolozsvár',
    'Kolozsvár, unit. coll.' => 'Kolozsvár',
    'Kolozsvár, unit. coll. kvtárában' => 'Kolozsvár',
    'Kolozsvár, unitár. coll.' => 'Kolozsvár',
    'Kolozsvári ref. coll.' => 'Kolozsvár',
    'Komáromi ref. egyh.' => 'Komárom',
    'Komáromi ref. egyház' => 'Komárom',
    'Koncz József tanárnál Maros-Vásárhelyt' => 'Marosvásárhely',
    'Koncz József tanárnál M-vásárhelyt' => 'Marosvásárhely',
    'Koncz József, Marosvásárhely' => 'Marosvásárhely',
    'Koronka, Toldalagi Viktor' => 'Koronka',
    'Kremnica OFM ' => 'Kremnica',
    'Kremnica frant. k.' => 'Kremnica',
    'Késmárki ev. lyc.' => 'Késmárk',
    'Késmárk ev. lyc.' => 'Késmárk',
    'Késmárk, ev. lyc.' => 'Késmárk',
    'Körmend, Batthyany' => 'Körmend',
    'Körmend, Batthyány' => 'Körmend',
    'Kraków' => 'Kraków',
    'Kunszentmiklós, ref. gimn.' => 'Kunszentmiklós',
    'Kunszentmiklós, ref. gymn.' => 'Kunszentmiklós',
    'Lengyel, Apponyi Sándor' => 'Lengyel',
    'Leipzig, Albert Fidelis Butsch' => 'Leipzig',
    'Lemberg, Univ.' => 'Lemberg',
    'Levoça Ev' => 'Levoča',
    'Levoča Ev' => 'Levoča',
    'Levoča ev.' => 'Levoča',
    'Levoča Ev.' => 'Levoča',
    'Levoča Ev. cirk. k.' => 'Levoča',
    'Levoča Ev Cirk. k.' => 'Levoča',
    'London, BM' => 'London',
    'Losonci főgymn.' => 'Losonc',
    'Losonczi főgymn.' => 'Losonc',
    'Losonczi fõgymn' => 'Losonc',
    'Losonczi fõgymn.' => 'Losonc',
    'Losonc, főgymn.' => 'Losonc',
    'Losonc, Sacher Imre' => 'Losonc',
    'Lugossy József könyvtárában' => 'Debrecen',
    'Lugossy Józsefnél Debrecenben' => 'Debrecen',
    'Lugossy Józsefnél Debreczenben' => 'Debrecen',
    'Lugossy Józsefnél Debreczenben.' => 'Debrecen',
    'Lugossy Józsefnél' => 'Debrecen',
    'Lőcsén Bosnyák-ktár.' => 'Lőcse',
    'Lőcse' => 'Lőcse',
    'Lőcse, Ev. cirk. k.' => 'Lőcse',
    'Lőcse, ev. gymn.' => 'Lőcse',
    'Malacky, františ.' => 'Malacky',
    'M-szigeti ref. lyc.' => 'Máramarossziget',
    'M. szigeti ref. lyc.' => 'Máramarossziget',
    'M.-szigeti ref. lyc.' => 'Máramarossziget',
    'M.szigeti ref. gymn.' => 'Máramarossziget',
    'M.szigeti ref. lyc.' => 'Máramarossziget',
    'M.szigeti ref.lyc.' => 'Máramarossziget',
    'Máramarossziget ref. lyc.' => 'Máramarossziget',
    'Máramarossziget Szilágyi István' => 'Máramarossziget',
    'Máramarossziget, ref. lyc.' => 'Máramarossziget',
    'Máramarossziget, Szilágyi István' => 'Máramarossziget',
    'Mármarossziget, r. kath. gymn.' => 'Máramarossziget',
    'Mármarossziget, ref. lyc.' => 'Máramarossziget',
    'Mszigeti ref. lyc.' => 'Máramarossziget',
    'Marosszentkirály, Ráduly Sámuel' => 'Marosszentkirály',
    'M.v.Teleki ktár' => 'Marosvásárhely',
    'Marosvásárhely Teleki Téka' => 'Marosvásárhely',
    'Marosvásárhely Teleki' => 'Marosvásárhely',
    'Marosvásárhely Teleki ktár' => 'Marosvásárhely',
    'Marosvásárhely Teleki-ktárban' => 'Marosvásárhely',
    'Marosvásárhely, Teleki' => 'Marosvásárhely',
    'Marosvásárhely, Koncz József' => 'Marosvásárhely',
    'Marosvásárhely Koncz József' => 'Marosvásárhely',
    'Marosvásárhely, ref. koll' => 'Marosvásárhely',
    'Marosvásárhely, ref. coll.' => 'Marosvásárhely',
    'Marosvásárhely, franc. kolostor' => 'Marosvásárhely',
    'Marosvásárhely, franc. zárda' => 'Marosvásárhely',
    'Marosvásárhely, plébánia' => 'Marosvásárhely',
    'Marosvásárhely, Teleki kvt.' => 'Marosvásárhely',
    'A marosvásárhelyi Teleki-ktárban' => 'Marosvásárhely',
    'Maros-Vásárhelyen a gr. Teleki család levéltárában' => 'Marosvásárhely',
    'Marosvásárhelyen a gr. Teleki család levéltárában *' => 'Marosvásárhely',
    'M.-Vásárhelyen a gr. Teleki-család levéltárában XXIV. czim 3287. sz. a. (2 utolsó levele hij.)' => 'Marosvásárhely',
    'M.-Vásárhelyen a gr. Teleki-család levéltárában XXIV. czim 3287. sz. a.' => 'Marosvásárhely',
    'Martin Nat * (C-variáns)' => 'Martin',
    'Martin Nat *' => 'Martin',
    'Martin Nat' => 'Martin',
    'Medgyesi franc. z.' => 'Medgyes',
    'Medgyes, ev. gymn.' => 'Medgyes',
    'Mihályfalva, Filep Elek' => 'Mihályfalva',
    'Mikeszásza, Radák Adám levéltára' => 'Mikeszásza',
    'Mikháza, franc. zárda' => 'Mikháza',
    'Miskolc ref. gimn.' => 'Miskolc',
    'Miskolci ref. gymn.' => 'Miskolc',
    'Miskolczi minor. rend.' => 'Miskolc',
    'Miskolc minor. rend.' => 'Miskolc',
    'Miskolc, minor. rend.' => 'Miskolc',
    'Miskolc, minorita rend' => 'Miskolc',
    'Miskolc, ev.' => 'Miskolc',
    'Miskolczi ref. gymn.' => 'Miskolc',
    'Miskolc, ref. gymn.' => 'Miskolc',
    'Muz' => 'Budapest',
    'n-enyedi ref. coll. ktárában gr. Bethlen Kata könyvei között.' => 'Nagyenyed',
    'Nagyenyed minor. zárda' => 'Nagyenyed',
    'Nagyenyed, ref. coll.' => 'Nagyenyed',
    'N.-enyedi minor. zárda' => 'Nagykőrös',
    'n.-enyedi ref. coll. ktárában gr. Bethlen Kata könyvei között' => 'Nagyenyed',
    'n.-enyedi ref. coll. ktárában, gr. Bethlen Kata könyvei közt' => 'Nagyenyed',
    'N.-kőrösi ref. lyc.' => 'Nagykőrös',
    'N.váradi püsp.' => 'Nagyvárad',
    'Nagy István könyvtára' => 'Budapest', // ?
    'Nagy István' => 'Budapest', // ?
    'Nagy-enyedi ref. coll. ktárában gr. Bethlen Kata könyvei közt.' => 'Nagyenyed',
    'Nagykőrösi ref.lyc.' => 'Nagykőrös',
    'Nagykőrös, ref. lyc.' => 'Nagykőrös',
    'N-kőrösi ref. lyc.' => 'Nagykőrös',
    'Nagykőrös, ref. főgymn.' => 'Nagykőrös',
    'N.körösi ref. lyc.' => 'Nagykőrös',
    'N.kőrösi ref. lyc.' => 'Nagykőrös',
    'Nagyszeben, Arch' => 'Nagyszeben',
    'Nagyszeben, erdélyi evangélikus egyházkerület' => 'Nagyszeben',
    'Nagyszeben, ev. gimn.' => 'Nagyszeben',
    'Nagyszombati r. c. gymn.' => 'Nagyszombat',
    'Nagyőr (Nehre, Strážký, SK), Czóbel István könyvtára ← Mednyánszky könyvtár' => 'Nagyőr',
    'Nagyőr, Czóbel István könyvtára ← Mednyánszky könyvtár' => 'Nagyőr',
    'Néhre, Mednyánszky Alajos' => 'Nagyőr',
    'Néhre, Szepesben b. Mednyánszky ktárában.' => 'Nagyőr',
    'Nyitra' => 'Nyitra',
    'Nyitra, Egyházmegyei ktár.' => 'Nyitra',
    'Nyitra, k. rend.' => 'Nyitra',
    'Nyitrai k. rend.' => 'Nyitra',
    'Nyitrai k. rend' => 'Nyitra',
    'Nyitrai kegyes r.ház' => 'Nyitra',
    'Nyitrai püsp.' => 'Nyitra',
    'Nyitrai e. m.' => 'Nyitra',
    'Némethy Lajos' => 'Esztergom',
    'Németújvári fr. z.' => 'Németújvár',
    'Németújvár, franc. zárda' => 'Németújvár',
    'Pannonhalma' => 'Pannonhalma',
    'Pannonhalma, apátság' => 'Pannonhalma',
    'Pesti franc. z.' => 'Budapest',
    'Pesti k.rend' => 'Budapest',
    'Pesti hittud. kar.' => 'Budapest',
    'Pesti ref. coll.' => 'Budapest',
    'Pécs' => 'Pécs',
    'Pozsony r. cath. lyceum' => 'Pozsony',
    'Pozsonyi ev. lyc.' => 'Pozsony',
    'Pozsonyi kir. kath. főgymnasium' => 'Pozsony',
    'Pozsonyi r. c. gymn.' => 'Pozsony',
    'Pozsonyi r. cath. gymn.' => 'Pozsony',
    'Pozsonyi r. cath. gymnasium' => 'Pozsony',
    'Pozsonyi r.c. gymn.' => 'Pozsony',
    'Pozsony MS' => 'Pozsony',
    'Pozsony, franc. zárda' => 'Pozsony',
    'Pozsony, Káptalan' => 'Pozsony',
    'Pozsony, Univ' => 'Pozsony',
    'Pozsony ÚK SAV' => 'Pozsony',
    'Pozsony, Ján Čaplovič cop.' => 'Pozsony',
    'Pozsony MS → Martin MS' => 'Pozsony',
    'Árpád Oszvald, Bratislava' => 'Pozsony',
    'Pápai franc. z.' => 'Pápa',
    'Pápai ref. coll.' => 'Pápa',
    'Pápa, franc. kolostor' => 'Pápa',
    'Pápa, ref. coll.' => 'Pápa',
    'Praha Acad' => 'Praha',
    'Praha, Nat' => 'Praha',
    'Privigye, kegyes r. ház.' => 'Privigye',
    'Prónay-könyvtár, Acsa' => 'Acsa',
    'Ráth György' => 'Budapest',
    'Budapest, Ráth György' => 'Budapest',
    'Ráth Gy.' => 'Budapest',
    'Rima-Szombaton, a kis-honti ev. esp. ktárában' => 'Rimaszombat',
    'Rimaszombati prot. gymn.' => 'Rimaszombat',
    'Rimaszombat gömöri ref. esperesség' => 'Rimaszombat',
    'Rimaszombat, kishonti ev. esperesség' => 'Rimaszombat',
    'Rosnyai franc. z.' => 'Rozsnyó',
    'Rosnyai káptalan' => 'Rozsnyó',
    'Rosnyón a gömöri ev. esp. ktárában' => 'Rozsnyó',
    'Rosnyón és Csetneken a gömöri ev. esp. ktárában' => 'Rozsnyó|Csetnek',
    'Rozsnyón és Csetneken a gömöri ev. esp. ktárában' => 'Rozsnyó|Csetnek',
    'Rozsnyó, a gömöri ev. esp. könyvtárában' => 'Rozsnyó',
    'Rozsnyó, franc. zárda' => 'Rozsnyó',
    'Rozsnyó, gömöri ev. esp.' => 'Rozsnyó',
    'Rozsnyó, gömöri ref. esperesség' => 'Rozsnyó',
    'Révész K.' => 'Debrecen',
    'Révész Kálmánnál Debrecenben' => 'Debrecen',
    'Révész Kálmánnál Debreczenben' => 'Debrecen',
    'Révész Kálmánnál' => 'Debrecen',
    'Salzburg, Studienbibliothek' => 'Salzburg',
    'S.-pataki ref. coll.' => 'Sárospatak',
    'Sárospatak Ref koll' => 'Sárospatak',
    'Sárospatak Ref' => 'Sárospatak',
    'Sárospataki ref. koll.' => 'Sárospatak',
    'Sárospatak, ref. coll.' => 'Sárospatak',
    'Sárospatak ref. coll.' => 'Sárospatak',
    'Sajókaza, Radvánszky' => 'Sajókaza',
    'Schlauch Lőrinc' => 'Szatmárnémeti',
    'Szatmárnémeti Schlauch Lőrinc' => 'Szatmárnémeti',
    'Szatmárnémeti, püsp.' => 'Szatmárnémeti',
    'Szatmárnémeti, püspökség' => 'Szatmárnémeti',
    'Szatmárnémeti, Schlauch Lőrinc' => 'Szatmárnémeti',
    'Szatmárnémeti, Schlauch Lőrinc.' => 'Szatmárnémeti',
    'Schlauch Lőrinc.' => 'Szatmárnémeti',
    'Segesvári ev. gymn.' => 'Segesvár',
    'Segesvár ev. gymn. (ép.)' => 'Segesvár',
    'Segesvár ev. gymn.' => 'Segesvár',
    'Segesvár, ev. gymn.' => 'Segesvár',
    'Sibiu Arch' => 'Sibiu',
    'Sibiu Astra' => 'Sibiu',
    'Sibiu Mus' => 'Sibiu',
    'Sibiu, Univ' => 'Sibiu',
    'Teutsch D. Györgynél Szebenben' => 'Sibiu',
    'Teutsch D. Gy.' => 'Sibiu',
    'Soproni városi levéltár' => 'Sopron',
    'Frank Ferencnél Sopronban' => 'Sopron',
    'Sopron ev. lyc.' => 'Sopron',
    'Sopron, ev. lyc.' => 'Sopron',
    'Spišská Nová Ves Ev' => 'Spišská Nová Ves',
    'Sz.-antali franc.z.' => 'Szentantal',
    'Sz.–antali franc. z.' => 'Szentantal',
    'Szent-antali franc, zárda' => 'Szentantal',
    'Szent-antali franc.' => 'Szentantal',
    'Sz.-keresztúri unitár. gymn. ktárában' => 'Székelykeresztúr',
    'Sz.-keresztúri unitár. gymn.' => 'Székelykeresztúr',
    'Székelykeresztúr, unitár. gymn.' => 'Székelykeresztúr',
    'Székelykeresztúr, unit. gymn.' => 'Székelykeresztúr',
    'Sz.-udvarhelyi ref. coll. czimlapja hij.' => 'Székelyudvarhely',
    'Székelyudvarhelyi ref. koll.' => 'Székelyudvarhely',
    'Sz.keresztúri unitár. gymn.' => 'Székelykeresztúr',
    'Sz.udvarhelyi ref. coll.' => 'Székelyudvarhely',
    'Székelyudvarhely, ref. coll.' => 'Székelyudvarhely',
    'Székelyudvarhely, ref. koll.' => 'Székelyudvarhely',
    'Szarvas, ev. gymn.' => 'Szarvas',
    'Szathmár, ref. gymn.' => 'Szatmár',
    'Szatmári egyházmegye' => 'Szatmár',
    'Szathmári püsp. ktárában' => 'Szatmár',
    'Szathmári püsp.' => 'Szatmár',
    'Szathmári ref. gymn.' => 'Szatmár',
    'Szatmári püsp.' => 'Szatmár',
    'Szeben Bruckenthal Museum' => 'Szeben',
    'Nagyszeben Bruckenthal Muz.' => 'Szeben',
    'Nagyszeben, ev. gymn.' => 'Szeben',
    'Nagyszeben, Muz' => 'Szeben',
    'Nagyszeben, Sigerus Vilmos' => 'Szeben',
    'Nagyszeben, Szász nemz. levéltár' => 'Szeben',
    'szebeni ev. gymn. könyvtárában' => 'Szeben',
    'Szebeni ev. gymn.' => 'Szeben',
    'Szeben Bruckenthal-Muz.' => 'Szeben',
    'Szeben, ev. gimn.' => 'Szeben',
    'Szebeni Bruckenthal-ktár' => 'Szeben',
    'Szebeni ev. gimn.' => 'Szeben',
    'Szeged, franc. zárda' => 'Szeged',
    'Szeged, kegyesrendi ház' => 'Szeged',
    'Szeged, Kegyesrendi ház' => 'Szeged',
    'Szeged, minor. zárda' => 'Szeged',
    'Szentpétervár, Császári Könyvtár' => 'Szentpétervár',
    'Szepesi káptalan' => 'Szepesváralja',
    'Szepesváraljai seminarium, Pozsonyi római kat. gimn.' => 'Szepesváralja',
    'Szepesváralja, káptalan' => 'Szepesváralja',
    'Szilágyi Istvánnál M-Szigeten' => 'Máramarossziget',
    'Szilágyi Istvánnál M.szigeten' => 'Máramarossziget',
    'Szilágyi Istvánnál' => 'Máramarossziget',
    'Szilágyi István Máramarossziget' => 'Máramarossziget',
    'Szilágyi Sándornál Budapest' => 'Budapest',
    'Szilágyi Sándornál Budapesten' => 'Budapest',
    'Szilágyi Sándornál' => 'Budapest',
    'Budapest, Szilágyi Sándor' => 'Budapest',
    'Budapest, Széll Farkas' => 'Budapest',
    'Szászrégen, Kraus M.' => 'Szászrégen',
    'Szászvárosi ref. gymn.' => 'Szászváros',
    'Szászváros, ref. gimn.' => 'Szászváros',
    'Szászváros, ref. gymn.' => 'Szászváros',
    'Székelyudvarhelyi ferencrendi kolostor könyvtára' => 'Székelyudvarhely',
    'Szombathely, dominic. zárda' => 'Szombathely',
    'Szombathely, franc. zárda' => 'Szombathely',
    'Szombathely, francisc. zárda' => 'Szombathely',
    'Szombathely, papnövelde' => 'Szombathely',
    'Szombathely, seminar.' => 'Szombathely',
    'Szöllősy Antal ref. lelkésznél Makón.' => 'Makó',
    'Sárospatak Ref  → Nižnij Novgorod' => 'Sárospatak',
    'Sárospataki ref. coll.' => 'Sárospatak',
    'Sárospatak' => 'Sárospatak',
    'Sátoralja-újhelyi k. rend' => 'Sátoraljaújhely',
    'Sátoraljaújhely, k. rendi ház' => 'Sátoraljaújhely',
    'Temesvári papnövelde' => 'Temesvár',
    'Természettud. Társulat ktára' => 'Budapest',
    'Természettud. társulat könyvtárában Budapesten.' => 'Budapest',
    'Toldy Ferenc ktára' => 'Budapest',
    'Toldy Ferencz ktárában' => 'Budapest',
    'Toldy F. ktárában' => 'Budapest',
    'Budapest, Toldy Ferenc' => 'Budapest',
    'Budapest, Ágoston József' => 'Budapest',
    'Tordai Unitár. gymn.' => 'Torda',
    'Torda unit. gymn.' => 'Torda',
    'Torda, unit. egyh.' => 'Torda',
    'Torda, unit. gymn.' => 'Torda',
    'Torda, unitár. gymn.' => 'Torda',
    'Tordai unitár. gymn.' => 'Torda',
    'Târgu Mureş' => 'Târgu Mureş',
    'Trencsén, „Archív Braneckého”' => 'Trencsén',
    'Turócszentmárton, MS' => 'Turócszentmárton',
    'Turócszentmárton, Muzeálna slovenská spoločnost’' => 'Turócszentmárton',
    'Ungvár, Bibl. episcopală.' => 'Ungvár',
    'Varjú Elemér' => 'Budapest',
    'Véghely Dezsőnél Veszprémben' => 'Veszprém',
    'Véghely Dezsõnél Veszprémben' => 'Veszprém',
    'Wien, Franz Trau' => 'Wien',
    'Wien, Schotten-Bibliothek' => 'Wien',
    'Wilno' => 'Vilnius',
    'Zágráb, érs. ktár' => 'Zágráb',
    'Zágráb, érsekség' => 'Zágráb',
    'Zágráb, érs.' => 'Zágráb',
    'Zirc' => 'Zirc',
    'Zircz' => 'Zirc',
    'Zsibón a b. Wesselényi-ktárban' => 'Zsibó',
    'Zsibón a Vesselényi ktárban' => 'Zsibó',
    'Zágrábi káptalan, Pozsonyi Cath. gymn.' => 'Zágráb',
  ];
}
