<?php
const LN = "\n";
const TB = "\t";

$file = __DIR__ . '/../../data_raw/nyelv4.txt';
$range = ['2626', '3696'];
// $range = ['3697', '4628'];

$lines = file($file);
$id2languages = [];
$normal = TRUE;
foreach ($lines as $line_num => $line) {
  $line = trim($line);
  if ($line == '---') {
    $normal = FALSE;
    continue;
  }
  if (preg_match('/3772/', $line))
    echo 'ERROR: ', $line, LN;
  processLine($line_num, $line);
}
ksort($id2languages);
foreach ($id2languages as $id => $languages) {
  echo $id, ': ', join(' - ', $languages), LN;
}

function processLine($line_num, $line): void {
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