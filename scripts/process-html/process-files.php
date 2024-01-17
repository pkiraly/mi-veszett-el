<?php
define('LN', "\n");
// define('ROOT', '/media/pkiraly/external/doku/arcanum_szovegtar/content/f_konyveszet/ermk');
// define('ROOT', '/media/pkiraly/external/doku/arcanum_szovegtar/content/f_konyveszet/ermk');

$output = 'rmny.json';
if (file_exists($output))
  unlink($output);

$xml = simplexml_load_file('ermk.xml');
foreach ($xml->{'content-collection'}->document as $key => $volume) {
  $title = $volume->attributes()['title'];
  if (preg_match('/^RMNY/', $title)) {
  	$volumeId = $volume->attributes()['id'];
    printf('%s (%s)' . LN, $title, $volumeId);
    foreach ($volume->children() as $chapter) {
      if ($chapter->attributes()['title'] == 'Régi magyarországi nyomtatványok') {
        foreach ($chapter->children() as $item) {
          $itemId = $item->attributes()['id'];
          // echo $item->attributes()['title'], LN;
          $location = str_replace(
          	'D:/_sites/anacleto/f_konyveszet/',
          	'', // '/media/pkiraly/external/doku/arcanum_szovegtar/content/',
            str_replace(
              '\\',
              '/',
              $item->attributes()['location']
            )
          );
          shell_exec("iconv -f ISO-8859-2 $location -t UTF-8 -o content.utf8.txt");
          shell_exec("php process-file.php $itemId content.utf8.txt >> $output");
        }
      }
    }
  }
}
