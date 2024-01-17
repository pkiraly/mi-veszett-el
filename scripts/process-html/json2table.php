<?php

$fp = fopen('rmny.csv', 'w');
$fields = ['id', '01Sorszám', '01Sorszám_RMNY', '01xHely', '01xIdö', '02Szerzö', '03Cím', '04Hely', '05Idö', '06Nyomda', '07Kolláció', '08Terjedelem', '09Formátum', '10Könyvdísz', '11Forrás', '12Tárgy', '14Facsimile', '16Nyelv', '13Lelöhely', '13Lelöhely_count', '15Olim', '15Olim_count'];
fputcsv($fp, $fields);
$stat = [];
$handle = fopen("rmny.json", "r");
if ($handle) {
  while (($line = fgets($handle)) !== false) {
    $data = json_decode($line);
    $vars = get_object_vars($data);
    if (count($vars) > 3) {
      foreach (array_keys($vars) as $key) {
        if ($key == '') {
          print_r($data);
        }
        if (!isset($stat[$key]))
          $stat[$key] = 0;
        $stat[$key]++;
      }
      $row = [];
      foreach ($fields as $key) {
        if (property_exists($data, $key)) {
          if (is_array($data->{$key}))
          	$row[] = implode(' – ', $data->{$key});
          else
          	$row[] = $data->{$key};
        } else 
          $row[] = '';
      }
      fputcsv($fp, $row);
    }
  }
  fclose($handle);
}
fclose($fp);

print_r($stat);



