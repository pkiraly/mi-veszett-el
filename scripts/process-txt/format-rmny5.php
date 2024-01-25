<?php

const LN = "\n";

$file = $argv[1];
$lines = file($file);

$pageNr = 63;
foreach ($lines as $line_num => $line) {
  $line = str_replace(array("\n", "\r"), '', $line);

  if ($line == $pageNr) {
    $pageNr++;
  } else {
    echo $line, LN;
  }

}
