<?php
define('LN', "\n");

$id = $argv[1];
$filename = $argv[2];
$content = file_get_contents($filename);

// $content = iconv('ISO-8859-2', 'UTF-8', $content);

$replacement = [
  '<font face="\'Symbol\'">&#172;</font>' => '←',
  '<font face="\'Symbol\',serif">&#172;</font>' => '←',
  '<font face="\'Webdings\',serif">¯</span></font>' => 'Ż</span>',
  '<font face="\'Webdings\',serif">¯</font>' => 'Ż',

  '&#150;' => '–',
  '&nbsp;' => ' ',
  '&#132;' => '„',
  '&#148;' => '”',
  '&#133;' => '…',
  '&#146;' => '’',
  '&#139;' => '‹',
  '&#155;' => '›',
  '&#171;' => '«',
  '&#187;' => '»',
  '&#174;' => '®',
  '&#182;' => '¶',
  '&#134;' => '†',
  '&#145;' => '‘',
  '&#189;' => '½',
  '&#183;' => '·',
  '&#172;' => '¬',

  '&#224;' => 'à',
  '&#248;' => 'ø',
  '&#232;' => 'è',
  '&#242;' => 'ò',
  '&#229;' => 'å',
  '&#255;' => 'ÿ',
  '&#241;' => 'ñ',
  '&#239;' => 'ï',
  '&#245;' => 'õ',
  '&#154;' => 'š',
];

$libs = [
  'Debrecen Univ', 'Debrecen Ref', 'Cluj-Napoca Acad', 'Kežmarok MS', 'Sárospatak Ref', 'Târgu Mureş', 'Budapest Nat', 'Kremnica Ev', 
  'Levoča Ev', 'Martin MS', 'Praha Nat', 'Sighişoara', 'Bratislava Univ', 'London BL', 'Zagreb Univ', 'Tîrgu Mureş', 'Košice Scient',
  'Alba Iulia', 'Bratislava Acad', 'London Nat', 'Szeged Univ', 'Cluj-Napoca Univ', 'Esztergom Dioec', 'Sopron Ev', 'Braşov Arch',
  'Bratislava Paed', 'München Nat', 'Aiud', 'Sibiu Mus', 'Csurgó', 'Pannonhalma', 'Pápa Ref', 'Berlin Univ Inst', 'Pécs Univ', 'Gyöngyös',
  'Szeged Civ', 'Cambridge Univ', 'Užgorod Univ', 'Pécs Dioec', 'Firenze', 'Sfântu Gheorge Gymn', 'Wien Univ', 'Spišská Nová Ves Ev',
  'Košice Mus', 'Wien Nat', 'Roma Acad', 'Târgu Mureş (Székelykeresztúr)', 'Odorhei', 'Washington Congr', 'Kecskemét Ref', 'Oradea Mus',
  'Târgu-Mureş', 'Nitra Dioec', 'Sfântu Gheorghe Gymn', 'Eger Dioec', 'Gdańsk Acad', 'Göttingen Univ', 'Hajdúnánás Gymn', 'Heidelberg Univ',
  'Jasov MS', 'Kalocsa Dioec', 'Kežmarok Ev', 'Kraków Univ', 'Liptovský Mikuláš', 'New York Publ', 'Oradea Comit', 'Paris Nat',
  'Praha Strahov', 'Praha Univ', 'Arad Arch', 'Banská Bystrica Arch', 'Braşov Ev', 'Brno Univ', 'Sibiu Civ', 'Szeged Paed',
  'Székesfehérvár Dioec', 'Székesfehérvár Mus', 'Warszava Univ', 'Halle Univ', 'Oxford Bodleiana', 'Galaţi Civ', 'Leningrad Nat', 'Moskva Nat',
  'Eichstätt Nat', 'Budapest Univ', 'Kraków Czartoryski', 'Leipzig Univ', 'Berlin Nat', 'Cluj Univ', 'Bratislava Comit', 'Budapest Acad',
  'Olomouc Univ', 'Praha Mus', 'Prešov Scient', 'Győr Semin', 'London BM', 'Sibiu Ev', 'Halle Hung', 'Cluj Acad I', 'Cluj-Napoca Acad II',
  'Cluj-Napoca Acad III', 'Dolný Kubín', 'Bucureşti Acad', 'Budapest Piar', 'Budapest Gergely', 'Cluj Theol Ref', 'Dolný Kubín MS',
  'Budapest Acad Lingu', 'Budapest Zsámár József', 'Keszthely', 'Nižnij Novgorod', 'Wolfenbüttel', 'Prešov Ev', 'Bratislava MS',
  'Budapest Ev', 'Cluj Acad III', 'Budapest Arch', 'Sibiu Arch', 'Cluj Acad II', 'Budapest Ref', 'Bratislava Capit', 'Stockholm Reg',
  'Budapest Ev (Sopron)', 'Budapest Semin', 'Cambridge King', 'Kraków SJ', 'Strängnäs', 'Braşov Orthod', 'Cluj-Napoca Acad I',
  'Güssing OFM', 'Mediaş Ev', 'Budapest Civ', 'Graz OFM', 'Košice Dioec', 'Miskolc Scient', 'Warszawa Univ', 'Zalău', 'Kremnica MS',
  'Wrocław Univ', 'Bratislava Capit', 'Cluj–Napoca Acad', 'Eisenstadt Eszterházy', 'Gotha Nat', 'Győr Dioec', 'Iaşi Civ', 'Leipzig DB',
  'Liptovský Mikuláš Ev', 'Olomouc Scient', 'Sibiu Metrop', 'Szeged Univ Lit', 'Veszprém Dioec', 'Debrecen Ref Arch', 'Levoča Arch',
  'Ljubljana Semin', 'Oponice MS', 'Revúca Ev', 'Stuttgart', 'Zirc', 'Bratislava Boris Bálent', 'Budapest Paed', 'Bytča Arch',
  'Cambridge/USA Univ', 'Cluj-Napoca', 'Debrecen Com', 'Sighişioara', 'Agnita Mus', 'Alba Julia', 'Amberg', 'Aţel Ev', 'Augsburg Civ',
  'Banská Bystrica Arch (Radvány)', 'Basel Univ', 'Beograd Mus Orthod', 'Berlin', 'Berlin Univ, Inst', 'Bern Civ', 'Betliar',
  'Bp. Univ', 'Braşov Comit', 'Braşov, Ev', 'Bratislava Mus', 'Brno Can Aug', 'Brno O. M. Cap.', 'Brzotin Arch', 'Bucureşti Arch',
  'Budapest Borda Antikvárium', 'Budapest Borda Antiquarium', 'Budapest, Endrey Walter', 'Budapest Ev Arch', 'Budapest Hist Medic',
  'Budapest Mus.', 'Budapest Parl', 'Budapest Unit', 'Budapest Univ Jus Rom', 'Cambridge Sussex', 'Chicago Newberry', 'Cluj Acad',
  'Cluj Acad (Blaj, Archiep.)', 'Cluj Mus', 'Cluj Napoca', 'Cluj-Napoca Theol Prot', 'Cluj-Napoca Theol Ref', 'Cluj–Napoca Univ',
  'Cluj Theol Ref.', 'Cluj Univ (Révai Pál)', 'Csurgó Gymn', 'Dabas Szokody Gyula', 'Debrecen Mus', 'Erlangen Univ', 'Esztergom OFM',
  'Esztergom Simor', 'Graz Landesarchiv', 'Graz Landesbibliothek', 'Gundelsheim', 'Güssing Batthyány Arch', 'Hajdúböszörmény Gymn',
  'Halle Hung.', 'Hódmezővásárhely Gymn', 'Iaşi Univ', 'kalocsa Dioec', 'Kalocsa Dioec.', 'Kecskemét Piar', 'Kežmarok', 'Kistarcsa, Kende György',
  'Klosterneuburg', 'Kraków Acad', 'Kraków Script', 'Leeuwarden Civ', 'Levoča Mus', 'Levsča Ev', 'London Wellcome', 'Madrid Nat',
  'Martin Ms', 'Mediaş', 'Melk', 'Miercurea Ciuc', 'Milano Ambrosiana', 'Miskolc Ev', 'Miskolc Földes gymn.', 'Nagykálló Gymn', 'Nitra Arch',
  'Nové Mesto nad Váhom Cath', 'Nyírkáta Oláh Béla', 'Oxford Christ Church', 'Pápa', 'Pápa Ref.', 'Pavia Univ', 'Plzeň', 'Poznań Civ',
  'Praha Acad', 'Praha Hus', 'Prešov', 'Providence/R. I. Univ', 'Regensburg Dioec', 'Rein', 'Roma Arch Vat', 'Roma Vat', 'Šamorín Arch',
  'Satu Mare Bibl Jud', 'Schwaz', 'Sfîntu-Gheorghe Gymn', 'Sheffield Univ', 'Sighişioara', 'Sighişoara Civ', 'Sofija Nat', 'Sopron Arch',
  'Sopron Berzsenyi gymn.', 'Spišská Nova Ves MS', 'Spišská Nová Ves MS', 'Strasbourg Nat', 'Szarvas Gymn', 'Szombathely Dioec', 'Tisovec',
  'Tokaj Mus', 'Toulouse Univ', 'Trenčín Arch', 'Trenčin MS', 'Trnava Soc', 'Trnava Spolok Sv. Vojtecha', 'Užhorod Univ', 'Varaždin OFM Cap',
  'Veszprémi Dioec', 'Wien Michael Krieg', 'Wien SJ', 'Wittenberg Ev', 'Wrocław Ossol', 'Zagreb OFM', 'Zagreb SJ', 'Zălau', 'Zwickau',
  'Banská Štiavnica Mus', 'Eger Semin', 'Göttweig', 'Graz Univ', 'Greifswald Univ', 'Jena Univ', 'Kecskemét Arch', 'Leiden Univ',
  'Linz Studienbibl', 'Martin', 'Meadville Allegheny', 'Miercurea Ciuc Mus', 'Nitra Agr', 'Nové Mesto nad Váhom Mus', 'Rajhrad OSB',
  'Rožnava Capit', 'Sibiu Ev Arch', 'Stuttgart Nat', 'Szeged Univ Lit Hung', 'Zalau', 'Bardejov Mus', 'Braşov Civ', 'Bratislava Civ',
  'Bratislava Pedag', 'Bucureşti Nat', 'Budapest Endrei Walter', 'København Reg', 'Sofija Mus Orthod', 'Wrocław Ossolinaeum',
  'Kraków Arch', 'Miskolc Arch', 'Firenze Nat', 'Radvaň Arch', 'Plovdiv Nat', 'Genève Mus Ref', 'Budapest OFM', 'Warszawa Nat',
  'Trnava Arch', 'Roma Nat', 'Venezia Nat', 'Montbrison Civ', 'Paris Arsenal', 'Płock Semin', 'Gyöngyös Nat', 'Poznań Univ',
  'Cluj Arch', 'Budapest Csillag István', 'Cambridge, USA Univ', 'Napoli Nat', 'Legnica Templ', 'Moszkva Lit', 'Bratislava Arch',
  'Buchlov', 'Praha OSA', 'Cluj', 'Napoca Univ', 'Napoca Acad', 'Banská Bystrica Arch Radvaň', 'Valašské Meziříčí Mus', 'Zürich',
  "L'viv Acad", 'Budapest Hist Med', 'Tranava Arch', 'Szécsény Cath', '’s-Gravenhage Reg'
];
$doubles = [
  'Debrecen Ref, Univ', 'Cluj-Napoca Acad, Univ', 'Cluj-Napoca: Acad, Univ', 'Budapest Acad, Nat', 'Levoča Arch, Ev', 'Szeged Civ, Univ',
  'Budapest: Acad, Nat', 'Szeged Civ, Paed', 'Szeged Paed, Univ', 'Sibiu Metrop, Mus', 'Cluj-Napoca Acad, Theol Prot', 'Cluj-Napoca: Acad. Univ',
  'Debrecen Ref., Univ', 'Bucureşti Acad, Univ', 'Chicago Newberry, Univ', 'Budapest Nat, Univ'
];
$triples = [
  'Budapest Acad, Nat, Univ', 'Budapest Nat, Ref, Univ', 'Budapest: Acad, Nat, Univ', 'Budapest Acad, Nat, Ref', 'Budapest: Acad, Nat, Ref',
  'Cluj-Napoca Acad, Prot Theol, Univ', 
];
$quads = [
  'Budapest Acad, Nat, Ref, Univ', 'Budapest: Acad, Nat, Ref, Univ', 'Budapest Acad, Ev, Nat, Ref', 'Budapest Acad, Ev, Nat, Univ',
  'Budapest Acad, Nat, Ref, Univ', 'Budapest Acad, Nat, Ev, Univ', 'Budapest Acad, Acad Lingu, Nat, Univ'
];
$quints = ['Budapest Acad, Civ, Ev, Nat, Univ'];

$content = str_replace(array_keys($replacement), array_values($replacement), $content);
$content = preg_replace('/<!-- (.*?) -->/', '', $content);
if (preg_match('/(&.{4,8};)/', $content, $matches)) {
  error_log(json_encode($matches));
}

# echo $content;

# if (preg_match_all('/<span class="([^"]+)" type="field" title="[^"]+">(.*?)<\/span>/', $content, $matches)) {
#   print_r($matches);
#   $data = [];
#   for ($i = 0; $i < count($matches[0]); $i++) {
#     $data[$matches[1][$i]] = $matches[2][$i];
#   }
#   print_r($data);
# }

$text = $content;
$found = false;
$data = ['id' => $id];
$value = null;
$current = null;
$currents = [];
while (preg_match('/^(.*?)(<span class="([^"]+)" type="field" title="[^"]+">|<\/span>)((?:.|\n)*)$/m', $text, $matches)) {
  if ($matches[3] == '') {
    $value = ($matches[1] != '') ? $matches[1] : $value;
    $key = array_pop($currents);
    if (isset($data[$key])) {
      if (is_string($data[$key])) {
        $data[$key] = [$data[$key], $value];
      } else {
        $data[$key][] = $value;
      }
    } else {
      $data[$key] = $value;
    }

  } else {
    $currents[] = $matches[3];
  }
  $text = $matches[4];
}

foreach (['07Kolláció', '09Formátum'] as $key) {
  if (isset($data[$key])) {
    $data[$key] = preg_replace('/<((font|sup) [^>]+|\/(font|sup))>/', '', $data[$key]);
    $data[$key] = preg_replace('/<img [^>]+>/', '', $data[$key]);
  }
}

foreach (['01Sorszám', '01Sorszám_RMNY', '11Forrás', '13Lelöhely', '15Olim'] as $key) {
  if (isset($data[$key])) {
    if (is_array($data[$key])) {
      foreach ($data[$key] as $i => $value) {
        $data[$key][$i] = preg_replace('/<(a [^>]+|\/a)>/', '', $data[$key][$i]);
        $data[$key][$i] = preg_replace('/<\/?i>/', '', $data[$key][$i]);
        $data[$key][$i] = preg_replace('/<((font|sup) [^>]+|\/(font|sup))>/', '', $data[$key][$i]);
      }
    } else {
      $data[$key] = preg_replace('/<(a [^>]+|\/a)>/', '', $data[$key]);
      $data[$key] = preg_replace('/<\/?i>/', '', $data[$key]);
      $data[$key] = preg_replace('/<((font|sup) [^>]+|\/(font|sup))>/', '', $data[$key]);
    }
  }
}

$have_ex = false;
if (isset($data['13Lelöhely'])) {
  $origLelo = $data['13Lelöhely'];
  if (is_array($data['13Lelöhely'])) {
    if (count($data['13Lelöhely']) != 2) {
      error_log($id . ' strange 13Lelöhely');
      error_log(json_encode($data['13Lelöhely']));
      array_shift($data['13Lelöhely']);
      // error_log(json_encode($data['13Lelöhely']));
    }
    if (!isset($data['15Olim'])) {
      error_log($id . ' olim is missing');
      error_log(json_encode($data['13Lelöhely']));
      $data['13Lelöhely'] = $data['13Lelöhely'][0] . ' – ' . $data['13Lelöhely'][1];
    } else if ($data['13Lelöhely'][1] != $data['15Olim']) {
      error_log($id . ' olim is different');
      error_log(json_encode($data['13Lelöhely']));
      error_log(json_encode($data['15Olim']));
    } else {
      $data['13Lelöhely'] = $data['13Lelöhely'][0];
    }
  } else {
    if (preg_match('/^Olim: /', $data['13Lelöhely'])) {
      if ($data['13Lelöhely'] != $data['15Olim']) {
        error_log($id . ' olim is different');
        error_log(json_encode($data['13Lelöhely']));
        error_log(json_encode($data['15Olim']));
      } else {
        $data['13Lelöhely'] = '';
      }
    }
  }
  if (is_array($data['13Lelöhely'])) {
    error_log($id . ' is still an array: ' . json_encode($data['13Lelöhely']));
  } else {
    $data['13Lelöhely'] = preg_replace('/([^ ])–/', "$1 –", $data['13Lelöhely']);
    $data['13Lelöhely'] = preg_replace('/–([^ ])/', "– $1", $data['13Lelöhely']);
    $data['13Lelöhely'] = str_replace('Ev 1 Martin', 'Ev 1 – Martin', $data['13Lelöhely']);
    $data['13Lelöhely'] = str_replace('Budapest Acad 1 Budapest Nat', 'Budapest Acad 1 – Budapest Nat', $data['13Lelöhely']);
    $data['13Lelöhely'] = explode(' – ', $data['13Lelöhely']);
    $count = 0;
    foreach ($data['13Lelöhely'] as $item) {
      if (empty($item) || $item == '') {
        // error_log(json_encode($origLelo));
      } else {
        if (preg_match('/^(.+?)(( (\d|O) ?[\*\?]?( \((RMK II 277|Szeged, franc. zárda|Keszthely, Festetics|Pozsony, franc. zárda|Csorna|Székelykeresztúr|Kolozsvár r. cath. lyc.|Bucureşti|Lugossy József|Nemz. Múz.|Szeged, francisc.|Szeben, ev. gymn.|[AB]-var.|Nyitra|6 expl.|Torda|← Csorna)\))?)+)( \(.*?\)| [AB] variáns| \([AB] variáns\)| „[AB]” variáns|( [\+=])? „bb”| \+ phot.( partim)? suppl(\.|et)( \([^)]+\))?)?$/', $item, $matches)) {
          $count += extract_counts($matches[2]);
          if (!in_array($matches[1], $libs)) {
            error_log('unknown lib (1): ' . $matches[1] . ' -- ' . $item);
          }
        } else if (preg_match('/^(.+) (\d+) expl\.$/', $item, $matches)) {
          $count += (int)$matches[2];
          $have_ex = true;
          // if (!in_array($matches[1], $libs)) {
          //   error_log('unknown lib: ' . $matches[1]);
          // }
        } else if (preg_match('/^(.*) \([AB] variáns\)$/', $item, $matches)) {
          $count += 1;
          if (!in_array($matches[1], $libs)) {
            error_log('unknown lib (2): ' . $matches[1] . ' -- ' . $item);
          }
        } else if (preg_match('/ phot$/', $item)) {
          // skip
        } else if (preg_match('/ phot\.?( (\(.*?\)|partim))?$/', $item)) {
          // skip
        } else if (preg_match('/ cop\.?( \(.*?\))?$/', $item)) {
          // skip
        } else if ($item == 'etc.' || $item == 'etc') {
          $count += 1;
        } else if (in_array($item, $libs)) {
          $count += 1;
        } else if (in_array($item, $doubles)) {
          $count += 2;
        } else if (in_array($item, $triples)) {
          $count += 3;
        } else if (in_array($item, $quads)) {
          $count += 4;
        } else if (in_array($item, $quints)) {
          $count += 5;
        } else {
          error_log('unparsed item: ' . $item);
          // error_log(json_encode($origLelo));
          $count += 1;
        }
      }
    }
    // if ($have_ex)
    //  error_log($id . " --> " . $count . " " . json_encode($data['13Lelöhely']));
    $data['13Lelöhely_count'] = $count;
  }
} else {
  $data['13Lelöhely_count'] = 0;
}

if (isset($data['15Olim'])) {
  if (is_array($data['15Olim'])) {
    error_log($id . ' olim is an array');
    error_log(json_encode($data['15Olim']));
  } else {
    if (preg_match('/^Olim: /', $data['15Olim'])) {
      $data['15Olim'] = preg_replace('/^Olim: /', '', $data['15Olim']);
    } else {
      error_log($id . ' no "Olim: " prefix: ' . $data['15Olim']);
    }
    $data['15Olim'] = explode(' – ', $data['15Olim']);
    $data['15Olim_count'] = count($data['15Olim']);
  }
} else {
  $data['15Olim_count'] = 0;
}

echo json_encode($data), LN;

function extract_counts($text) {
  $text = str_replace(' (RMK II 277)', '', $text);
  $text = str_replace(' (6 expl.)', '', $text);

  if (preg_match_all('/(\d|O)/', $text, $matches)) {
    return count($matches[0]);
  }
}