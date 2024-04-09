library(shiny)
library(tidyverse)
library(scatterpie)
source('functions.R')

foreign_cities <- c(
  'Velence', 'Amszterdam', 'Frankfurt am Main', 'Bázel', 'Lyon', 'Krakkó',
  'Utrecht', 'Leiden', 'Heidelberg', 'Nürnberg', 'Prága', 'Graz', 'Jena',
  'Wittenberg', 'Berlin', 'Bréma', 'Rostock', 'Yverdon', 'Róma', 'Oppenheim',
  'London', 'Bologna', 'Zürich', 'Herborn', 'Franeker', 'Tübingen', 'Gdansk',
  'Párizs', 'Ulm', 'Lipcse', 'Wroclaw', 'Olmütz', 'Strassburg', 'Hanau',
  'Amsterdam', 'Antwerpen', 'Brüsszel', 'Königsberg')
selected_countries <- c('Hungary', 'Slovakia', 'Romania', 'Austria', 'Slovenia', 'Croatia', 'Serbia')

df <- read_rds('data/rmny-1-5.rds')
year_min <- min(df$x_nyomtatasi_ev)
year_max <- max(df$x_nyomtatasi_ev)

ui <- navbarPage(
    "1472-1685 (RMNY 1-5.)",
    tabPanel(
      "Ívszám",
      fluidPage(
        fluidRow(
          column(3,
            sliderInput("tab1_limit", label = "ívszám", min = 1, max = 100, value = c(5, 10),
                  step = 1, width = '100%'),
            p(
              style="font-size: 80%; color: grey",
              "a csúszkát a 100-as értékre állítva kikapcsoljuk a felső határt"),
            sliderInput("tab1_top", label = "a megjelenítendő városok száma",
                  min = 1, max = 40, value = 12, step = 1, width = '100%'),
          ),
          column(9, plotOutput("tab1_ivszam", height = 600)
        )
      )
    )
  ),
  tabPanel(
    "Ívszám/év",
    fluidPage(
      fluidRow(
        column(
          3,
          sliderInput("tab2_limit", label = "ívszám", min = 1, max = 100, value = c(5, 10),
                           step = 1, width = '100%'),
          sliderInput("tab2_ev", label = "nyomtatás éve", min = year_min, max = year_max,
                      value = c(year_min, year_max),
                      step = 1, width = '100%'),
          p(
            style="font-size: 80%; color: grey",
            "a csúszkát a maximáliss értékre állítva kikapcsoljuk a felső határt"),
          sliderInput("tab2_top", label = "a megjelenítendő városok száma",
                           min = 1, max = 40, value = 12, step = 1, width = '100%'),
          radioButtons("tab2_visualisation", "vizualizáció", choices = c("grafikon", "térkép"))
        ),
        column(
          9, 
          plotOutput("tab2_ivszam", height = 600)
        )
      )
    )
  ),
  tabPanel(
    "Fennmaradás aránya",
    fluidPage(
      fluidRow(
        column(
          3,
          sliderInput("tab3_ev", label = "nyomtatás éve", min = year_min, max = year_max,
                      value = c(year_min, year_max),
                      step = 1, width = '100%'),
          radioButtons("tab3_country", label = "mai ország", choices = c('mind', selected_countries)),
        ),
        column(
          9, 
          plotOutput("tab3_map", height = 600)
        )
      )
    )
  ),
  tabPanel(
    "Eloszlások",
    fluidPage(
      fluidRow(
        column(
          3,
          sliderInput("tab4_ev", label = "nyomtatás éve", min = year_min, max = year_max,
                      value = c(year_min, year_max),
                      step = 1, width = '100%'),
          radioButtons(
            "tab4_type",
            label = "eloszlás",
            choices = c('nyelv', 'formátum', 'nyomtatás helye', 'méret', 'műfaj')),
        ),
        column(
          9, 
          plotOutput("tab4_image", height = 600)
        )
      )
    )
  ),
  tabPanel(
    "A kutatásról",
    fluidPage(
        h1("Mennyi nyom nélkül eltűnt régi magyar nyomtatvány lehet?", style="color: maroon"),
        p("Farkas Gábor Farkas–Káldos János–Király Péter"),
        h2("Bevezetés", style="color: maroon"),
        p("A művelődéstörténet, a könyvtörténet, a bibliográfia és könyvtári katalógus határterületén járunk. A könyvtáros azokkal az objektumokkal foglalkozik, amelyek az általa kezelt gyűjteményben vannak. A bibliográfus az egyre táguló, növekvő Gutenberg-galaxis valamely idő és térbeli metszetét vizsgálja. A könyvtörténész pedig szélesebb gazdasági, társadalmi összefüggések között vizsgálja a 'könyv' jelenséget. Mindegyik terület jelentős felismerésekkel és adattárakkal gazdagította ismereteinket arról, hogy milyen is volt a kora újkori magyar könyves kultúra és abból mi maradt ránk, az utókorra. Célunk, hogy Arnold Esch alapkérdését – hogyan viszonyul a történelmi gondolkozás és kutatás nemcsak a fennmaradt dokumentumokhoz és forrásokhoz, hanem az egykor létezők összességéhez – a 15-17. századi magyar nyomtatványok számbavételének eddigi eredményeire alkalmazzuk."),
        p("A 15. századi Európa tizennyolc országában indult el a könyvkiadás, több mint kétszáz város büszkélkedhetett rövidebb-hosszabb ideig műhellyel, harmincezer címet ismernek a bibliográfiák, amiből közel félmillió példányt tartanak számon világszerte. A könyvtörténészek az elmúlt évtizedekben többször megkísérelték megbecsülni azon ősnyomtatványok számát statisztikai elemzésekkel, amelyek elpusztultak és nem ismerünk róluk egyetlenegy adatot sem. A feltételezett szám igen magas lett: mintegy húszezer kiadványt, többnyire alkalmi kiadványokat, évkönyveket, búcsúcédulákat, latin nyelvtanokat, hírlapokat nyomtathattak ezidőtájt a kontinensen, amelyekről nem maradt semmilyen emlékünk. Mégha ijesztően soknak is gondoljuk ezt a számot – hiszen a 15. századi nyomtatványok negyven százalékáról beszélünk – mindenképpen figyelemre méltó, hogy milyen korlátok közé vannak szorítva ismereteink a korai nyomdászattörténettel kapcsolatban. Ilyen korlát a számba veendő nyomtatványok és példányok számának növekedése, amivel szemben a bibliográfiai feltártság mélységének csökkenése áll: az ősnyomtatványok feltárása és számbavétele a legrégebben és legmódszeresebben végzett munka (GW, ISTC, CIH), míg a 16-17 században Európában kiadott nyomdatermékekről már nincs ilyen alapos és módszeres nyilvántartás, a manufakturális nyomtatvány előállítás időszakának utolsó két évszázadáról pedig még egyenetlenebb az eredmény. További korlát, hogy rengeteg a példányból nem ismert, vagy csak egyetlen példányban illetve csonkán fennmaradt nyomtatvány – mely tényezők jelentősen befolyásolják a bibliográfiai számbavétel részletezettségét, adatainak pontosságát. Ezen felül mind a levéltári jellegű történelmi forrásanyag, mind ennek feltártsága időben és térben egyaránt egyenetlen eloszlású, ami gátolja például a nyomtaványok életciklusához így vagy úgy hozzájáruló személyek (szerzők, nyomdászok, kereskedők, mecénások, olvasók) és intézmények (nyomdák, könyvgyűjtemények) történetének megismerését."),
        p("A Régi Magyarországi Nyomtatványok (RMNY) szerint jóval több mint ötezer nyomtatvány jelent meg 1700-ig. A 2023 őszén megjelent V. (1671-1685) kötetben leírt utolsó tételszám: 4628. Az RMNY-hez kapcsolódó kutatásokban és áttekintésekben is többször említik a bibliográfusok a nyom nélkül eltűnt kiadványokat. Hervay Ferenc 1966-ban még így fogalmazott: „Hogy milyen veszteséget jelentenek művelődéstörténetünk számára a nyom nélkül eltűnt művek, azt hozzávetőlegesen sem tudjuk megállapítani.” Az RMNY korábban megjelent négy kötete alapján adott részletes elemzést a hiányról Heltai János: „A magyarországi nyomdatermelésnek tehát mintegy ötödéről részben a bibliográfiai hagyomány, részben következtetések alapján van tudomásunk.” A csak forráshivatkozásból ismert hetvennyolc 16. századi RMNY-tételt, illetve a tévesen feltételezett nyomtatványokat Bánfi Szilvia elemezte. P. Vásárhelyi Judit áttekintette az 1473 és 1670 közötti nemzeti bibliográfiát. „2012-ben megjelent a Régi Magyarországi Nyomtatványok IV. kötete. Így a részben vagy egészben magyar nyelven, illetve a történelmi Magyarország területén bármely nyelven megjelent nyomtatványokról a kezdetektől, azaz 1473-tól egészen 1670-ig áttekintésünk van. Az utolsó tétel sorszáma: 3696. Az utolsó appendix, azaz a tévesen feltételezett nyomtatványok helyreigazítását leíró tétel sorszáma: 271. Az RMNy-be nem csak a példányból ismeretes nyomtatványok kerülnek be, hanem < > jel közé téve olyan példányból nem ismeretes kiadványok is szerepelnek, amelynek egykori létezését megbízható adatokkal, vagy hitelt érdemlő következtetéssel bizonyítani lehet. S olyan nyomtatványokat is leírunk - » « idézőjelek között – amelyek címét korabeli forrás, vagy éppen Szabó Károly őrizte meg, aki még látott példányt belőlük, de az mára már nem maradt fenn. Ez utóbbiak száma elég magas: mintegy egyötödét teszi ki a teljes bibliográfiának.”"),
        p("A források számbavétele, a szakirodalom és a bibliográfiai feltártság alapján lehetségesnek, indokoltnak és fontosnak tartjuk a régi magyarországi nyomtatványokkal kapcsolatban elvégezni a statisztikai vizsgálatot, amely alapján képet kapunk azoknak a hiányzó kiadványok valószínű számáról, amelyekről eddig nem is feltételeztük, hogy léteztek. Ezzel rekonstruálható lenne a régi magyarországi nyomtatványok teljes halmazának valószínű nagysága."),
        h2("Kutatási kérdések", style="color: maroon"),
        tags$ul(
          tags$li("A rendelkezésre álló adatok alapján és a szakirodalom által ajánlott módszertant követve megbecsülhető-e, hogy mennyi nyom nélkül eltűnt régi magyar kiadvány lehetett?"),
          tags$li("A megjelenés ideje, helye, nyomdásza, nyelve, mérete, terjedelme illetve egyéb fizikai vagy művelődéstörténetileg számba vehető tulajdonságai alapján mely dokumentumcsoportok esetében lehet az eltűnés esélyének különbségeiről beszélni, és ha kimutathatóak ilyen különbségek, mi lehet ezeknek a magyarázata?"),
          tags$li("Mik lehetnek a nyomtatványokban szereplő művek túlélési esélyei?")
        ),
        h2("Módszertan, nemzetközi kutatási helyzetkép", style="color: maroon"),
        p("Adams és Barker nagy hatású könyvtörténeti modeljük középpontjában a könyv életciklusának öt fő eseménye áll: kiadás, gyártás, terjesztés, fogadtatás és a túlélés. Jelen kutatás ez utóbbi könyvtörténeti paradigma keretein belül kísérletet tesz a veszteségek és a túlélést befolyásoló tényezők hatásfokának statisztikai alapú becslésére. Az alábbiakban annak a kutatásnak a főbb vonatkozásait vázoljuk fel, amellyel reményeink szerint ez a cél elérhető. Adams és Baker a könyv fennmaradása tekintetében három periódussal számol, amelyekben különféle tényezők befolyásolják a túlélést. Az első a könyv létrehozása és elsődleges fogadtatása, a második a könyv intenzív vagy akár bármilyen használat alól kivont pihenő időszaka, a harmadik pedig vágyott tárgyként való felfedezése – saját vagy a benne szereplő szövegek jogán. A fennmaradás legfőbb tényezői a könyv fizikai tulajdonságai, mérete és népszerűsége – ezek azonban nem mindig korrelálnak, sokban függnek a könyv egyéb tulajdonságaitól, illetve külső tényezőktől melyek mások és mások az életciklus egyes szakaszaiban (például az őrző intézmény körülményei sokkal jelentősebb befolyásoló tényezők a középső szakaszban, mint a másik kettőben). A szerzők számos fontos kutatási témát és ötletet vetnek fel (pl. megkülönböztetve a művek és a nyomtatványok túlélését), valamint ráirányítják a figyelmet a témának a könyvtörténeten belül kiemelt helyére, de empirikus kutatást maguk nem folytattak."),
        p("A szakirodalomban tudomásunk szerint először Ernst Consentius vetette fel azt az ötletet 1932-ben, hogy ha az ősnyomtatványokat a megmaradt példányaik számossága szerint rendezve ábrázolnánk (az első oszlop reprezentálná az unikális nyomtaványok számát – jelenleg a nemzetközi ősnyomtatvány-katalógus, az ISTC szerint alig valamivel több, mint 8000 ősnyomtatványból csak egy példányt ismerünk köz- és egyházi gyűjteményekből –, a második a két példányban megmaradtak és így tovább), akkor az így kapott görbébe alapján ki tudjuk következtetni a “nulla példányban megmaradt” vagyis elveszett kiadások számát. Ezt az ötletet azonban sem ő, sem mások nem valósították meg addig, amíg az egyetlen lehetőség a kivitelezésére az volt, hogy a kutató manuálisan csinál statisztikát az ősnyomtatvány-katalógusok alapján. Viszont egy más területen, nevezetesen a biodiverzitás becslésében (a könyvekez képest kisebb mintákkal lehet számolni) Ronald Fisher hasonló következtetésre jutott, sőt konkrét számítási módszert is javasolt. A könyvek esetében tulajdonképpen a számítógépes adatbázisok lehetőségei teremtették meg az ilyen kutatások tényleges lehetőségét. Leo Egghe és Goran Proot 2008-ban egy speciális dokumentumtípus, a flandriai jezsuita drámák túlélési arányait vizsgálták és Fisher alapján javasoltak egy képletet, ami csak az unikális és a két példányban megmaradt kiadványok számát használta paraméterként. Sajnos ez a megközelítés más dokumentumtípus, például az ősnyomtatványok esetében nem járható, mivel ezt a csoportot csakúgy, mint fennmaradásának lehetséges tényezőit más ismérvek jellemzik, mint az általuk vizsgált, sok szempontból egységes csoport. A legfontosabb különbség az, hogy az ősnyomtatványok – és valószínűleg a XVI-XVII. századi könyvek esetében az egyes kiadványok példányainak fennmaradását olyan tényezők tették lehetővé, melyek nem függetlenek egymástól. Például meg lehet figyelni, hogy a nagy alakú (folio), vastagabb (Biblia) könyvek több példányban maradtak fenn – lévén tulajdonosaik értékesebbnek gondolták. A skála másik oldalán vannak a pamfletek, búcsúcédulák, kalendáriumok és a hírlapok, melyeket kevésbé őriztek meg, vagy az iskolai könyvek (rövidebb terjedelmű latin nyelvtanok: pl. Donatus), melyek pedig a használat során mentek tönkre. Jonathan Green valamint munkatársai, Frank McIntyre és Paul Needham 2010-ben rájöttek, hogy az adatok által kirajzolt görbe úgynevezett negatív binomiális eloszlást mutat, ami több különböző, Poisson-eloszlást mutató alcsoport közös eredője. Az alcsoportokat a fent említett tulajdonságok (méret, ívszám, nyelv, régió, nyomdász stb.) alapján lehet kijelölni. A megközelítésnek van két figyelemre méltó feltétele, 1) a kiadványok átlagos példányszáma eléri a 150-et, amit – extrém esetek kivételével – feltételezni lehet, 2) mivel a “nulla példányszámú” kiadványok becslésének felső határértéke a modellben kivételesen nagy lehet, az alapján, hogy adott nyomdász körülbelül mennyi éves kapacitással termelhet, bevezettek egy maximális értéket, ami csökkentette ezt. Egghe és Proot javaslatát azonban csak a dokumentumok bizonyos körében lehet használni. Legutóbb Mike Kestemont és Folgert Karsdorp 2020-as tanulmányában a közép-holland nyelvű lovagi epika kéziratos hagyományát vizsgálva vetett össze három eljárást: Egghe és Proot képletét, a régészetben hasonló céllal használt Jackknife algoritmust, és a biodiverzitásban újabban használt, Anne Chao által javasolt Chao1 algoritmust. A szerzők érvként felhozzák, hogy szemben az ősnyomtatványokkal feltehetjük, hogy egy-egy mű jóval kevesebb példányban létezett, mint az ősnyomtatványok kiadványai, tehát Green-ék első feltétele nem teljesül."),
        p("Horváth Iván a magyar nyelvű irodalmi írásbeliség kezdeteinek kijelölésére – szintén feltételezve elveszett műveket –, a hiszterézisgörbe alkalmazását veti fel, bár konkrét matematikai számítások nélkül. A görbe tulajdonsága, hogy egy null pontról lassú, majd urgásszerű növekedéssel viszonylag rövid idő, kevesebb mint egy évszázad alatt eljut a „telítettség” fázisába, ami után nincs számottevő növekedés. A görbe arra figyelmeztet, hogy a könyvek tekintetében is számolnunk kell az idő-tényezővel, különösen a korszak kezdetén."),
        p("Összességében tehát négy-öt számítási mód is a rendelkezésünkre áll ahhoz, hogy egy becslést a magyar anyagon elvégezzünk."),
        p("Végül meg kell említeni a Falk Eisermann által „sötét anyagnak” nevezett csoportot, amiről a könyvtörténetnek van valamilyen bizonytalan tudása vagy feltételezése. Ezt példázza a Kulcsár Péter által felvetett dilemma: „A Manlius-Farkas-féle tipográfiából 1584 és 1635 között 18 kalendáriumnak maradt fogható nyoma. A szerkesztők «mint a naptársorozat többi tagja alapján feltételezhető» kiadványt felvesznek sorszámmal ellátott, valós nyomtatványként még kilencet azokból a közbülső esztendőkből, amelyekből effélének híre sincs. Nem sok ez az 50%-os többlet?”. A kutatás során megvizsgáljuk, hogy a statisztikai modell paramétereként figyelembe tudjuk-e venni a bizonytalan tételekről szóló információkat, illetve, hogy egyáltalán rendelkezésünkre állnak-e ilyen adatok szignifikáns arányban."),
        h2("Adatforrások", style="color: maroon"),
        p("Milyen adatok kellenének egy ilyen munkához és mi áll ebből rendelkezésre?"),
        p("Ahogy láttuk az egyes képletek paraméterei eltérnek egymástól, vagyis eltérő adatokat kell hozzájuk összegyűjteni. A legfontosabb kiinduló lépés a magyarországi nyomtatványok bibliográfiai azonosítója (RMNY vagy RMK szám) és ezek ma is meglévő példányszám adatainak összegyűjtése. Továbbá, ha a Green által javasolt, és a dokumentum-csoporthoz leginkább illeszkedő eljárást alkalmazzuk, akkor a kiadványok egyéb tulajdonságai is: nyomdahely, időpont, nyomdász, nyelv, méret, terjedelem, esetleg szerző és egységesített cím."),
        p("A lehetséges adatforrások a következők:"),
        tags$ul(
          tags$li("Régi Magyar Nyomtatványok sorozat kötetei (I-V. kötet). Ezek közül az első háromból 20 évvel ezelőtt készült adatbázis. Az utolsó két kötet PDF formátumban, esetleg MS Word fájlokban állnak rendelkezésre. Jogtulajdonos az OSZK."),
          tags$li("OSZK katalógus. Ez csak a Széchényi Könyvtár gondozásában lévő kötetek adatait tartalmazza, illetve néhány esetben a máshol őrzött kiadványok mikrofilmes, fénymásolt, vagy digitális másolatainak az adatait is. HUNMARC formátumban elérhető, Király Péter 2022-ben megkapta kutatási célra."),
          tags$li("Muzeális Könyvtári Dokumentumok Nyilvántartása adatbázis (MKDNY). Jelen pillanatban csak teszt adatok érhetők el. Az adatok az OSZK és a közreműködő könyvtárak birtokában vannak, feltehetőleg HUNMARC vagy MARC21 formátumban."),
          tags$li("Eruditio és MOKKA-R adatbázis. Az adatok feltöltöttsége részben ismert, de olyan részei is lehetnek az adatbázisnak, amelyekről nem rendelkezünk ismeretekkel. Jogtulajdonos az OSZK, az adatbázis működtetője a szegedi egyetem. Az adatok PostgreSQL adatbázisban és XML-ben vannak tárolva."),
          tags$li("Az RMNY példány-nyilvántartása elérhető az OSZK cédulakatalógusában. Szerencsére alapesetben a kutatás számára a lelőhely tulajdonságai lényegtelenek, pusztán a példányok számossága érdekes."),
          tags$li("Az RMNY-S tételeket a szakirodalom, illetve az OSZK ún. “betanított RMNY” példányai alapján használjuk.")
        ),
        h2("Köszönetnyilvánítás", style="color: maroon"),
        p("Jelen kutatás elsősorban a Régi Magyarországi Nyomtatványok sorozat mindenkori szerzői és szerkesztői munkájára épül."),
        h2("Irodalom", style="color: maroon"),
        tags$ul(
          tags$li("Thomas R. Adams – Nicolas Barker: A new model for the study of the book. = Nicolas Barker, ed. A Potencie of Life: Books in Society. The Clark Lectures, 1986-1987. (The British Library Studies in the History of the Book.) London: British Library, 1993. vi, 206 pp. (ISBN 0-7123-0287-5) pp. 5-43."),
          tags$li("Bánfi Szilvia: Negyven év „adalékirodalma” az RMNY S(upplementum) tételeiben In: Sylvae typographicae 2012, i. m., 125, 130."),
          tags$li("Borsa Gedeon, A XVI. századi magyarországi könyvnyomtatás részmérlege, = Magyar Könyvszemle (1973). pp. 249–266. ill. Borsa Gedeon: Könyvtörténeti írások, I. A hazai nyomdászat 15–17. század; OSZK, 1998.; https://mek.oszk.hu/03300/03301/html/bgkvti_1/bgki0144.htm "),
          tags$li("Leo Egghe – Goran Proot: The estimation of the number of lost multi-copy documents: A new type of informetrics theory = Journal of Informetrics 1 (2007) 257–268. https://doi.org/10.1016/j.joi.2007.02.003"),
          tags$li("Falk Eisermann: The Gutenberg Galaxy’s Dark Matter. Lost Incunabula, and Ways to Retrieve Them. In Lost Books i.m. 2016. pp. 29-54. https://doi.org/10.1163/9789004311824_003"),
          tags$li("Alan B. Farmer: Lost Books: The Dark Matter of the Early Modern English Book Trade - Alan B. Farmer előadása - 2023.12.01 - Harry Ransom Center"),
          tags$li("Jonathan Green – Frank McIntyre – Paul Needham: The Shape of Incunable Survival and Statistical Estimation of Lost Editions. = The Papers of the Bibliographical Society of America , Vol. 105, No. 2 (June 2011), pp. 141-175. https://doi.org/10.1086/680773"),
          tags$li("Jonathan Green – Frank McIntyre: Lost Incunable Editions. Closing in on an Estimate. In Lost Books, i.m. 2016. pp. 55-72. https://doi.org/10.1163/9789004311824_004"),
          tags$li("Jonathan Green: Databases, Book Survival, and Early Printing = Wolfenbütteler Notizen zur Buchgeschichte, 2015."),
          tags$li("Heltai János: Lölki okulár In: Sylvae typographicae 2012, i. m., 59."),
          tags$li("Hervay Ferenc: A XV–XVI. századi magyarországi könyvnyomtatás számokban = Magyar Könyvszemle, 82(1966), 64. https://epa.oszk.hu/00000/00021/00262/pdf/MKSZ_EPA00021_1966_82_01_063-082.pdf"),
          tags$li("Horváth Iván: Magyar versek: mi veszett el? = Csörsz Rumen István (szerk.) Ghesaurus : Tanulmányok Szentmártoni Szabó Géza hatvanadik születésnapjára. Bp. : rec.iti, az MTA Irodalomtudományi Intézetének recenziós portálja (2010) 664 p. pp. 83-98. http://plone.iti.mta.hu/rec.iti/Members/szerk/ghesaurus-1/HorvathIvan-Ghesaurus.pdf"),
          tags$li("Daniel Kaufman: Measuring Archaeological Diversity: An Application of the Jackknife Technique = American Antiquity 63.1 (1998), pp. 73–85. https://www.researchgate.net/publication/271816276"),
          tags$li("Mike Kestemont – Folgert Karsdorp: Estimating the Loss of Medieval Literature with an Unseen Species Model from Ecodiversity = CHR 2020: Workshop on Computational Humanities Research, November 18–20, 2020, Amsterdam, The Netherlands. pp. 44-55. https://ceur-ws.org/Vol-2723/short10.pdf"),
          tags$li("Mike Kestemont – Folgert Karsdorp – Elisabeth de Bruijn – Matthew Driscoll – Katarzyna A. Kapitan – Pádraig Ó Macháin – Daniel Sawyer – Remco Sleiderink – Anne Chao: Forgotten books: The application of unseen species models to the survival of culture. = Science, 2022, 375 (6582),  https://doi.org/10.1126/science.abl7655"),
          tags$li("Kulcsár Péter: Régi Magyarországi Nyomtatványok I—II. (Recenzió) = Irodalomtörténeti közlemények, 1984. (88. évf.) 5-6. sz. pp. 733-736. https://epa.oszk.hu/00000/00001/00338/pdf/itk00001_1984_05-06_733-749.pdf"),
          tags$li("Lost Books. Reconstructing the Print World of Pre-Industrial Europe. Eds. Flavia Bruni – Andrew Pettegree. Leiden, Brill, 2016. https://doi.org/10.1163/9789004311824"),
          tags$li("P. Vásárhelyi Judit: Új lehetőségek a régi magyarországi nyomtatványok bibliográfiai feltárásában. https://eke.hu/sites/default/files/csatolmanyok/szakmai_mapok/2017._oktober_2._regi_konyves_szakmai_nap_a_fovarosi_szabo_ervin_konyvtarban/pvasarhelyi-uj_lehetosegek.pdf"),
          tags$li("Goran Proot – Leo Egghe: Estimating Editions on the Basis of Survivals: Printed Programmes of Jesuit Plays in the \"Provincia Flandro-Belgica\" before 1773, with a Note on the \"Book Historical Law\". = The Papers of the Bibliographical Society of America, Vol. 102, No. 2 (JUNE 2008), pp. 149-174. https://doi.org/10.1086/pbsa.102.2.24293733"),
          tags$li("Goran Proot: Survival Factors of Seventeenth-Century Hand-Press Books Published in the Southern Netherlands: The Importance of Sheet Counts, Sammelbände and the Role of Institutional Collections. = Lost Books, i.m., 2016. pp. 160-201. https://doi.org/10.1163/9789004311824_009"),
          tags$li("Sylvae typographicae: tanulmányok a régi magyarországi nyomtatványok 4. kötetének (1656–1670) megjelenése alkalmából, szerk. P. Vásárhelyi Judit, Bp., Argumentum, 2012 (A Magyar Könyvszemle és a MOKKA-R Egyesület Füzetei, 5)")
        ),
        h2("Adatbázisok", style="color: maroon"),
        tags$ul(
          tags$li("Incunabula Short Title Catalogue (ISTC). https://data.cerl.org/istc/_search (hozzáférés: 2023-09-01)"),
          tags$li("Gesamtkatalog der Wiegendrucke (GW). https://www.gesamtkatalogderwiegendrucke.de/GWEN.xhtml (hozzáférés: 2023-09-01)"),
          tags$li("Verzeichnis der im deutschen Sprachbereich erschienenen Drucke des 16. Jahrhunderts (VD 16) https://www.bsb-muenchen.de/sammlungen/historische-drucke/recherche/vd-16/ (hozzáférés: 2023-09-01)"),
          tags$li("Verzeichnis der im deutschen Sprachraum erschienenen Drucke des 17. Jahrhunderts (VD 17) https://www.bib-bvb.de/impressum (hozzáférés: 2023-09-01)"),
          tags$li("Font Zsuzsa, H. Hubert Gabriella, Herner János, Horváth Iván, Szőnyi Etelka, Vadai István: Répertoire de la poésie hongroise ancienne (RPHA). A régi magyar vers leltára a kezdetektől 1600-ig. 7.4. kiadás. Szerk. Horváth Andor, H. Hubert Gabriella, Seláf Levente. 1979-2023. https://f-book.com/rpha/v7/index.php (hozzáférés: 2023-09-01)")
        )
    )
  ),
)

server <- function(input, output, session) {
  output$tab1_ivszam <- renderPlot({
    min <- input$tab1_limit[1]
    max <- input$tab1_limit[2]
    max <- ifelse(max == 100, Inf, max)
    top <- input$tab1_top
    
    df2 <- df %>% 
      select(x_nyomtatasi_hely, ivszam) %>% 
      filter(!is.na(x_nyomtatasi_hely)) %>% 
      filter(!(x_nyomtatasi_hely %in% foreign_cities)) %>% 
      filter(ivszam >= min & ivszam <= max)
    
    top12 <- df2 %>% 
      group_by(x_nyomtatasi_hely) %>% 
      summarise(
        db = n(),
        iv = sum(ivszam, na.rm = TRUE)
      ) %>% 
      arrange(desc(iv)) %>% 
      head(n = top) %>% 
      select(x_nyomtatasi_hely)

    hely <- factor(top12$x_nyomtatasi_hely, levels = top12$x_nyomtatasi_hely)
    
    df3 <- df2 %>% 
      right_join(top12, join_by(x_nyomtatasi_hely)) %>%
      mutate(hely = factor(x_nyomtatasi_hely, levels = hely))
    
    img <- df3 %>% 
      ggplot(aes(x = ivszam)) +
        geom_histogram(bin = 30, color = 'cornflowerblue') +
        facet_wrap(~hely) +
        # scale_x_sqrt() +
        # scale_y_sqrt() +
        theme_bw() +
        labs(
          title = paste0('A top ', top, ', adott ívszámú nyomtatványt előállító város'),
          subtitle = paste0('ívszám: ', min, '-', ifelse(max == Inf, '', max)),
          x = 'ívszám',
          y = 'nyomtatványszám'
        )
    img
  })
  
  output$tab2_ivszam <- renderPlot({
    print("renderPlot")
    min <- input$tab2_limit[1]
    max <- input$tab2_limit[2]
    max <- ifelse(max == 100, Inf, max)
    min_year <- input$tab2_ev[1]
    max_year <- input$tab2_ev[2]
    visualization <- input$tab2_visualisation
    top <- input$tab2_top
    top <- ifelse(top == 40 && visualization == 'térkép', Inf, top)
    
    print(sprintf("visualization: %s", visualization))
    
    df2 <- df %>% 
      select(x_nyomtatasi_ev, x_nyomtatasi_hely, ivszam) %>% 
      filter(!is.na(x_nyomtatasi_hely)) %>% 
      filter(!(x_nyomtatasi_hely %in% foreign_cities)) %>% 
      filter(ivszam >= min & ivszam <= max) %>% 
      filter(x_nyomtatasi_ev >= min_year & x_nyomtatasi_ev <= max_year)
      
    print(dim(df2))
    
    top12 <- df2 %>% 
      group_by(x_nyomtatasi_hely) %>% 
      summarise(
        db = n(),
        iv = sum(ivszam, na.rm = TRUE)
      ) %>% 
      arrange(desc(iv)) %>% 
      head(n = top) %>% 
      select(x_nyomtatasi_hely)
    
    hely <- factor(top12$x_nyomtatasi_hely, levels = top12$x_nyomtatasi_hely)
    
    df3 <- df2 %>% 
      right_join(top12, join_by(x_nyomtatasi_hely)) %>%
      mutate(
        ido = as.numeric(x_nyomtatasi_ev),
        hely = factor(x_nyomtatasi_hely, levels = hely)) %>% 
      group_by(hely, ido) %>% 
      summarise(
        ivszam = sum(ivszam, na.rm = TRUE),
        .groups = 'drop'
      )
    
    if (visualization == 'grafikon') {
      img <- df3 %>%
        ggplot(aes(y = ivszam, x = ido)) +
        geom_point(color = 'cornflowerblue', alpha = 0.8) +
        facet_wrap(~hely) +
        theme_bw() +
        labs(
          title = paste0('A top ', top, ', adott ívszámú nyomtatványt előállító város'),
          subtitle = paste0(
            'ívszám: ', min, '-', ifelse(max == Inf, '', max),
            ', évkör: ', min_year, '-', max_year
          ),
          x = 'év',
          y = 'évi összes ívszám'
        )
    } else if (visualization == 'térkép') {
      # hely    ido ivszam
      print(dim(df3))
      print(head(df3, n = 20))
      coords <- read_csv(paste0('data/coord.csv'))
      synonyms <- read_csv(paste0('data/place-synonyms-normalized.csv'))
      geodf <- df3 %>% 
        left_join(synonyms, by = c("hely" = "original")) %>% 
        select(-factor) %>% 
        mutate(normalized = ifelse(is.na(normalized), hely, normalized)) %>% 
        filter(!is.na(normalized)) %>% 
        left_join(coords, by = c("normalized" = "city")) %>% 
        filter(!is.na(geoid)) %>% 
        filter(!is.na(ido)) %>%
        mutate(year = as.numeric(ido)) %>% 
        filter(!is.na(ido)) %>%
        select(ido, hely, ivszam, country, lat, long) %>% 
        group_by(hely) %>% 
        summarise(ivszam = sum(ivszam), lat=lat, long = long, .groups = "drop") %>% 
        distinct()
      print(dim(geodf))
      print(geodf, n = Inf)
      
      map.europe <- map_data("world")
      geodf %>% 
        filter(is.na(long))
      maxcount <- max(geodf$ivszam)
      
      minx <- min(geodf$long) - 0.1
      maxx <- max(geodf$long) + 0.1
      miny <- min(geodf$lat) - 0.1
      maxy <- max(geodf$lat) + 0.1
      
      print(paste(minx, maxx, miny, maxy))
      
      basemap <- ggplot() +
        geom_polygon(
          data = map.europe,
          aes(x = long, y = lat, group = group),
          fill = '#ffffff',
          colour = '#999999'
        ) +
        coord_cartesian(xlim = c(minx, maxx), ylim = c(miny, maxy)) +
        theme(
          # legend.position = 'none',
          axis.title = element_blank(),
          axis.ticks = element_blank(),
          axis.text = element_blank(),
          legend.title = element_text(size=rel(0.5)), 
          legend.text = element_text(size=rel(0.5))
        )
      
      img <- basemap +
        geom_point(
          data = geodf,
          aes(x = long, y = lat, size = ivszam),
          color = "red",
          alpha = .8) +
        geom_text(
          data = geodf,
          mapping = aes(x = long, y = lat, label = hely),
          nudge_y = -0.1,
          size = 5
        ) +
        scale_size_continuous(limits = c(1, maxcount), name = 'nr.') +
        labs(
          title = paste0(ifelse(top == Inf, 'Az összes', paste('A top', top)), ', adott ívszámú nyomtatványt előállító város'),
          subtitle = paste0(
            'ívszám: ', min, '-', ifelse(max == Inf, '', max),
            ', évkör: ', min_year, '-', max_year
          ),
        )
    }
    
    img
  })
  
  output$tab3_map <- renderPlot({
    min_year <- input$tab3_ev[1]
    max_year <- input$tab3_ev[2]
    selected_country <- input$tab3_country
    if (selected_country == 'mind') {
      selected_country <- selected_countries
    }

    coords <- read_csv('data/coord.csv')
    coords_hu <- read_csv('data/coord.hu.csv')
    synonyms <- read_csv('data/place-synonyms-normalized.csv')
    
    df2 <- df %>% 
      select(id, x_nyomtatasi_ev, x_nyomtatasi_hely, x_letezo_peldanyok_szorodasa, x_letezett_peldanyok_szorodasa) %>% 
      filter(x_nyomtatasi_ev >= min_year & x_nyomtatasi_ev <= max_year)

    libraries <- df2 %>%
      select(id, x_letezo_peldanyok_szorodasa) %>% 
      rename(current = x_letezo_peldanyok_szorodasa) %>% 
      filter(!is.na(current)) %>% 
      separate_longer_delim(current, ", ") %>% 
      separate(current, c('current', 'count'), '=') %>% 
      left_join(synonyms, by = c("current" = "original")) %>% 
      select(-factor) %>% 
      mutate(current = ifelse(is.na(normalized), current, normalized)) %>% 
      select(-normalized)
    # print(head(libraries))
    
    olim <- df2 %>%
      select(id, x_letezett_peldanyok_szorodasa) %>% 
      rename(olim = x_letezett_peldanyok_szorodasa) %>% 
      filter(!is.na(olim)) %>% 
      separate_longer_delim(olim, ", ") %>% 
      left_join(synonyms, by = c("olim" = "original")) %>% 
      select(-factor) %>% 
      mutate(olim = ifelse(is.na(normalized), olim, normalized)) %>% 
      select(-normalized)
    # print(head(olim))
    
    pub_normalized <- df2 %>% 
      select(id, x_nyomtatasi_hely) %>% 
      left_join(synonyms, by = c("x_nyomtatasi_hely" = "original")) %>% 
      select(-factor) %>% 
      mutate(x_nyomtatasi_hely = ifelse(is.na(normalized), x_nyomtatasi_hely, normalized)) %>% 
      select(-normalized)
    # print(head(pub_normalized))
    
    local <- pub_normalized %>% 
      full_join(libraries, join_by(id)) %>% 
      mutate(same = x_nyomtatasi_hely == current)
    # print(head(local))
    
    locally_saved <- local %>% 
      filter(same == TRUE) %>% 
      group_by(x_nyomtatasi_hely) %>% 
      summarise(n = n(), .groups = 'drop')
    # print(head(locally_saved))
    
    pub_by_place <- pub_normalized %>% 
      group_by(x_nyomtatasi_hely) %>% 
      summarise(n = n(), .groups = 'drop')
    # print(head(pub_by_place))
    
    
    final <- pub_by_place %>% 
      left_join(locally_saved, join_by(x_nyomtatasi_hely)) %>% 
      rename(all = n.x, locally_saved = n.y) %>% 
      mutate(
        locally_saved = ifelse(is.na(locally_saved), 0, locally_saved),
        saved = locally_saved / all * 100,
        lost = 100-saved
      ) %>% 
      arrange(desc(saved)) %>% 
      left_join(coords, by = c("x_nyomtatasi_hely" = "city")) %>% 
      filter(!is.na(geoid)) %>% 
      filter(country %in% selected_country) %>% 
      select(-c(geoid, name, country)) %>% 
      left_join(coords_hu, by = c('x_nyomtatasi_hely' = 'city')) %>% 
      mutate(x_nyomtatasi_hely = ifelse(is.na(hu), x_nyomtatasi_hely, hu)) %>% 
      select(-hu)
    # print(head(final))
    
    minx <- min(final$long) - 0.2
    maxx <- max(final$long) + 0.2
    miny <- min(final$lat) - 0.2
    maxy <- max(final$lat) + 0.2
    
    map.europe <- map_data("world")
    basemap <- ggplot() +
      geom_polygon(
        data = map.europe,
        aes(x = long, y = lat, group = group),
        fill = '#ffffff',
        colour = '#999999'
      ) +
      coord_cartesian(xlim = c(minx, maxx), ylim = c(miny, maxy)) +
      theme(
        legend.position = 'none',
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        # legend.title = element_text(size=rel(0.5)), 
        # legend.text = element_text(size=rel(0.5))
      )
    
    ggplot() +
      geom_polygon(
        data = map.europe,
        aes(x = long, y = lat, group = group),
        fill = '#ffffff',
        colour = '#999999'
      ) + 
      coord_map(xlim = c(minx, maxx), ylim = c(miny, maxy)) +
      geom_scatterpie(
        aes(x=long, y=lat, group=x_nyomtatasi_hely, r=log2(all)/20),
        data=final,
        alpha = 0.4,
        cols=c('saved', 'lost'),
        color=NA
      ) +
      geom_text(
        data = final,
        mapping = aes(x = long, y = lat, label = x_nyomtatasi_hely),
        nudge_y = -0.1,
        size = 3
      ) +
      geom_text(
        data = final,
        mapping = aes(x = long, y = lat, label = paste0('(', all, ')')),
        color = '#666666',
        nudge_y = -0.25,
        size = 3
      ) +
      geom_scatterpie_legend(
        radius = log2(final$all)/20, 
        x = 16.5, y = 46,
        labeller=function(x) 2^(x*20)) +
      labs(
        title='Milyen arányban találhatók meg helyi gyűjteményben az itt nyomtatott kiadványok?',
        subtitle = paste0('évkör: ', min_year, '-', max_year),
        caption = 'A diagramok mérete kiadványszám log2 értékét tükrözi, ezért a\nkiadványszámok tényleges aránya nagyobb a diagrammokénál'
      ) +
      scale_fill_discrete(name = 'megtalálható?', 
                          labels = c('igen', 'nem')) +
      theme(
        # legend.position = 'none',
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        # legend.title = element_text(size=rel(0.5)), 
        # legend.text = element_text(size=rel(0.5))
      )
    
  })
  
  output$tab4_image <- renderPlot({
    min_year <- input$tab4_ev[1]
    max_year <- input$tab4_ev[2]
    max_year <- ifelse(max_year == 100, Inf, max_year)
    type <- input$tab4_type
    limit <- 50

    df2 <- df %>% 
      filter(x_teruleti_hungarikum == TRUE) %>% 
      filter(x_nyomtatasi_ev >= min_year & x_nyomtatasi_ev <= max_year)
    
    if (type == 'nyelv') {
      get_distribution_by_language(df2, limit)
    } else if (type == 'formátum') {
      get_distribution_by_format(df2, limit)
    } else if (type == 'nyomtatás helye') {
      get_distribution_by_city(df2, limit)
    } else if (type == 'méret') {
      get_distribution_by_size(df2, limit)
    } else if (type == 'műfaj') {
      get_distribution_by_genre(df2, limit)
    }
  })
}

shinyApp(ui, server)
