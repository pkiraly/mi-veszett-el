<?php declare(strict_types=1);

include_once __DIR__ . '/../process-txt/functions.php';

use PHPUnit\Framework\TestCase;

const LN = "\n";
const PHYSICAL_DESCRIPTION_SEPARATOR = ' – ';
$missing_locations = [];
$olimToLocation = [];
$debug = true;

class ExtractLocationsTest extends TestCase {

  public function testGreetsWithName(): void {
    global $olimToLocation, $missing_locations, $debug;
    $olimToLocation = initOlimToLocation();
    $missing_locations = [];
    $debug = true;

    $this->assertSame(261, count($olimToLocation));

    /*

    $record = $this->createRecord('Budapest Nat  – Budapest Ref  – Budapest Univ   – Dej OFM  (← Călugăreni OFM) – Firenze Nat  – Spišské Podhradie ');
    extractLocations($record);
    $this->assertSame('Budapest=4, Dej=1, Firenze=1, Spišské Podhradie=1', $record->cities);
    $this->assertSame(7, $record->collectionCount);
    $this->assertSame('Budapest Nat 1 – Budapest Ref 2 – Budapest Univ 1 1 – Dej OFM 1 (← Călugăreni OFM) – Firenze Nat 1 – Spišské Podhradie 1', $record->collections);

    $record = $this->createRecord('Budapest Nat  + cop. digit.');
    extractLocations($record);
    $this->assertSame('Budapest=1', $record->cities);
    $this->assertSame(1, $record->collectionCount);
    $this->assertSame('Budapest Nat 2 + cop. digit.', $record->collections);

    $record = $this->createRecord('In 33 bibliothecis 50 expl. – Bratislava Univ – Budapest Acad, Nat, Univ – Cluj-Napoca Acad, Univ – Košice Scient – Subotica Dioec – Szeged Univ – Užhorod Univ');
    extractLocations($record);
    $this->assertSame('Bratislava=1, Budapest=3, Cluj-Napoca=2, Košice=1, Subotica=1, Szeged=1, Užhorod=1', $record->cities);
    $this->assertSame(50, $record->collectionCount);

    $record = $this->createRecord('Braşov Arch 1 1 – Braşov Ev 1 – Budapest Nat 1 – Cluj-Napoca Acad 1 – Cluj-Napoca Univ 1 – Sibiu Arch 1 – Sibiu Mus 1 1 1 1 – Sighişoara 1 1');
    extractLocations($record);
    $this->assertSame('Braşov=3, Budapest=1, Cluj-Napoca=2, Sibiu=5, Sighişoara=2', $record->cities);
    $this->assertSame(13, $record->collectionCount);

    $record = $this->createRecord('Budapest Nat phot. partim (Wolfenbüttel) – Budapest Univ 1 – Wolfenbüttel 1 1');
    extractLocations($record);
    $this->assertSame('Budapest=1, Wolfenbüttel=2', $record->cities);
    $this->assertSame(3, $record->collectionCount);

    $record = $this->createRecord('Budapest Nat phot. – Sighişoara 4');
    extractLocations($record);
    $this->assertSame('Sighişoara=1', $record->cities);
    $this->assertSame(1, $record->collectionCount);

    $record = $this->createRecord('Budapest Acad 1 1 – Budapest Nat 1 – Budapest Ref 1 – Cluj-Napoca Acad II 2* – Cluj-Napoca Univ O O – Sárospatak Ref 2');
    extractLocations($record);
    $this->assertSame('Budapest=4, Cluj-Napoca=3, Sárospatak=1', $record->cities);
    $this->assertSame(8, $record->collectionCount);

    $record = $this->createRecord('Csíki Székely Múzeum, Csíksomlyói Ferences Gyűjtemény');
    extractLocations($record);
    $this->assertSame('Csíkszereda=1', $record->cities);
    $this->assertSame(1, $record->collectionCount);

    // $record = $this->createRecord('Budapest Nat phot. (Kraków, Praha) — Kraków Univ 4* — Praha Strahov 4');
    $record = $this->createRecord('Budapest Nat phot. (Kraków, Praha) – Kraków Univ 4* – Praha Strahov 4');
    extractLocations($record);
    $this->assertSame('Kraków=1, Praha=1', $record->cities);
    $this->assertSame(2, $record->collectionCount);

    $record = $this->createRecord('Bratislava Acad 2 – Bratislava Univ 2 – Budapest Acad 1 – Budapest Nat 1 – Liptovský Mikuláš O O – Martin MS 1 2* – Praha Mus O');
    extractLocations($record);
    $this->assertSame('Bratislava=2, Budapest=2, Liptovský Mikuláš=2, Martin=2, Praha=1', $record->cities);
    $this->assertSame(9, $record->collectionCount);

    $record = $this->createRecord('Budapest Acad 1 („D” variáns) – Budapest Civ 1 („A” variáns) – Budapest Nat 1 1 („A” variáns) 1 („B” variáns) + cop. partim (London) – London BL 1 („E” variáns) – Martin MS 2 („A” variáns) 1 („C” variáns) – Praha Strahov 1 – Trnava Soc 1 („A” variáns)');
    extractLocations($record);
    $this->assertSame('Budapest=5, London=1, Martin=2, Praha=1, Trnava=1', $record->cities);
    $this->assertSame(10, $record->collectionCount);

    $record = $this->createRecord('Bratislava Acad 2 – Budapest Acad 2 facs. suppl. 3* facs. suppl. – Budapest Nat 2 facs. suppl. 2 3 (Szeged, francisc.) – Budapest Univ 1 – Cluj Univ 4* – London BM 2 (Nagy István) – Sárospatak Ref 2 – Wien Nat 1');
    extractLocations($record);
    $this->assertSame('Bratislava=1, Budapest=6, Cluj=1, London=1, Sárospatak=1, Wien=1', $record->cities);
    $this->assertSame(11, $record->collectionCount);

    $record = $this->createRecord('Bratislava MS 2* (Alsósebes) – Budapest Acad 3 – Budapest Nat 2 + phot. suppl. (Bratislava MS) 4');
    extractLocations($record);
    $this->assertSame('Bratislava=1, Budapest=3', $record->cities);
    $this->assertSame(4, $record->collectionCount);

    $record = $this->createRecord('Budapest Acad 2 (Debrecen ref. coll.) – Budapest Nat 2 4* – Debrecen Ref 1 – Debrecen Univ 2* (Szilágyi István) – Csíki Székely Múzeum, Csíksomlyói Ferences Gyűjtemény 1');
    extractLocations($record);
    $this->assertSame('Budapest=3, Debrecen=2, Csíkszereda=1', $record->cities);
    $this->assertSame(6, $record->collectionCount);

    $record = $this->createRecord('Budapest Acad 1 1 – Budapest Nat 1 1 – Budapest Univ 1 – Cluj Univ 1 (RMK III 725) – ’s-Gravenhage Reg 1 – Leiden Univ 1 – London BM 1 1 – München Nat 1 – Székesfehérvár Dioec 1 – Tîrgu Mureş 1 – Washington Congr 1 – Wien Nat 1 – etc.');
    extractLocations($record);
    $this->assertSame('Budapest=5, Cluj=1, ’s-Gravenhage=1, Leiden=1, London=2, München=1, Székesfehérvár=1, Tîrgu Mureş=1, Washington=1, Wien=1', $record->cities);
    $this->assertSame(15, $record->collectionCount);

    $record = $this->createRecord('Alba Iulia 2* 2 – Bratislava Acad 1 – Bratislava Capit 4 – Bratislava Univ 1 О – Budapest Acad 2 2 2 4 – Budapest Ev 2 – Budapest Nat 2* 2* 4 – Budapest Ref 1 1 (Nagykőrös, lyc.) 2* 2 – Budapest Univ 1 – Cluj Acad II 2* 3* 3 3 4 – Cluj Acad III 3 3 4 – Cluj Univ 1 1 – Debrecen Ref 2 – Debrecen Univ 2 – Jasov MS 2 – Kalocsa Dioec 3* – Kecskemét Ref 2 – København Reg 1 – Košice Scient 2 – Olomouc Univ 3* – Oponice 1 1 1 4 – Prešov Scient 2 – Rožnava Ev 2 – Sabinov 4 – Sárospatak Cath – Sárospatak Ref 2* 2* – Szeged Civ 2 – Tîrgu Mureş 2* 3 – Topoľčianky 2* – Vizsoly Ref 2 – Wien Nat 3');
    extractLocations($record);
    $this->assertSame('Alba Iulia=2, Bratislava=4, Budapest=13, Cluj=10, Debrecen=2, Jasov=1, Kalocsa=1, Kecskemét=1, København=1, Košice=1, Olomouc=1, Oponice=4, Prešov=1, Rožnava=1, Sabinov=1, Sárospatak=3, Szeged=1, Tîrgu Mureş=2, Topoľčianky=1, Vizsoly=1, Wien=1', $record->cities);
    $this->assertSame(15, $record->collectionCount);
    */

    $record = $this->createRecord('Budapest Nat 4* 4* + 9 expl. 4 – Debrecen Ref 4* – Debrecen Univ 4*');
    extractLocations($record);
    $this->assertSame('Alba Iulia=2, Bratislava=4, Budapest=13, Cluj=10, Debrecen=2, Jasov=1, Kalocsa=1, Kecskemét=1, København=1, Košice=1, Olomouc=1, Oponice=4, Prešov=1, Rožnava=1, Sabinov=1, Sárospatak=3, Szeged=1, Tîrgu Mureş=2, Topoľčianky=1, Vizsoly=1, Wien=1', $record->cities);
    $this->assertSame(15, $record->collectionCount);
  }


  private function createRecord($line) {
    return (object)[
      'externalData' => false,
      'hypothetic' => false,
      'appendix' => false,
      'isReference' => false,
      'id' => '3718',
      'lines' => [$line]
    ];
  }
}