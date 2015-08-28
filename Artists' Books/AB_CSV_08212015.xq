xquery version "3.1";
 
declare namespace marc="http://www.loc.gov/MARC21/slim";

let $records := fn:collection("artistsbk")//marc:collection/marc:record

let $csv :=
  element recordset{
    for $individual in $records
    
    (: TITLE :)
   
    let $maintitle := $individual/marc:datafield[@tag='245']/marc:subfield[@code='a']/text()
    let $subtitle := $individual/marc:datafield[@tag='245']/marc:subfield[@code='b']/text()

    let $title := fn:string-join(($maintitle,$subtitle)," ")
    
    
   (: AUTHOR :)
   
   let $name := $individual/marc:datafield[@tag='100']/marc:subfield[@code='a']/text()
   let $nametitle :=$individual/marc:datafield[@tag='100']/marc:subfield[@code='c']/text()
   let $namefuller := $individual/marc:datafield[@tag='100']/marc:subfield[@code='q']/text()
   let $pdate := $individual/marc:datafield[@tag='100']/marc:subfield[@code='d']/text()
   let $pauthor := fn:string-join(($name, $nametitle, $namefuller, $pdate), " ")
   
   let $cauthor := $individual/marc:datafield[@tag='110']/marc:subfield[@code='a']/text()
   let $author := 
     if ($name)
     then $pauthor
    else $cauthor
    
   (: PUBLISHER :)
   let $aacrpub := $individual/marc:datafield[@tag='260']/marc:subfield[@code='b']/text()
   let $rdapub := $individual/marc:datafield[@tag='264']/marc:subfield[@code='b']/text()
   let $publisher :=
     if ($rdapub)
     then $rdapub
   else $aacrpub
  
   
  (: PUB LOCATION :)
  
    let $header := $individual/marc:controlfield[@tag='008']/text()
    let $publoc := fn:substring($header,16,3)
    where $publoc = ("alu", "aru", "dcu", "deu", "flu", "gau", "kyu", "lau", "mdu", "msu", "oku", "ncu", "scu", "tnu", "txu", "vau", "wvu", "xx ")
  
   (: PUB DATE :)
   let $aacrpubdate := $individual/marc:datafield[@tag='260']/marc:subfield[@code='c']/text()
   let $rdapubdate := $individual/marc:datafield[@tag='264']/marc:subfield[@code='c']/text()
     let $pubdate :=
       if ($aacrpubdate)
       then $aacrpubdate
       else $rdapubdate[1]
   
   (: FORMAT :)
   let $extent :=$individual/marc:datafield[@tag='300']/marc:subfield[@code='a']/text()
   let $ill :=$individual/marc:datafield[@tag='300']/marc:subfield[@code='b']/text()
   let $format := string-join(($extent, $ill), " ")
     
   (: PERSONAL CONTRIBUTORS :)
   let $all := $individual/marc:datafield[@tag='700']
   let $pcontributor :=
     for $each in $all
     let $pcontribname := $each/marc:subfield[@code='a']/text()
     let $pcontribnametitle := $each/marc:subfield[@code='c']/text()
     let $pcontribnamefuller := $each/marc:subfield[@code='q']/text()
     let $pcontribdate := $each/marc:subfield[@code='d']/text()
     return  fn:string-join(($pcontribname, $pcontribnametitle, $pcontribnamefuller, $pcontribdate), " ")
     
   
   (: CORPORATE CONTRIBUTORS :)
   let $corpcontributor := $individual/marc:datafield[@tag='710']/marc:subfield[@code='a']/text()
   
  
   (: GENRE TERMS :)
   let $genreall := $individual/marc:datafield[@tag='655']
   let $genre :=
     for $genreeach in $genreall
     let $genremain := $genreeach/marc:subfield[@code='a']/text()
     let $genresub := $genreeach/marc:subfield[@code='x']/text()
     let $genregeog := $genreeach/marc:subfield[@code='z']/text()
     return fn:string-join (($genremain, $genresub, $genregeog), "--")
   
  
   (: LOCATION :)
   let $localinfo := $individual/marc:datafield[@tag='999']
   let $location :=
     for $eachcallno in $localinfo
     let $callno := $eachcallno/marc:subfield[@code='a']/text()
     let $coll := $eachcallno/marc:subfield[@code='l']/text()
     return fn:string-join(($coll, $callno), " ")

   
   return element record {
     element title {$title},
     element author {$author},
     element pub_loc {$publoc},
     element publisher {$publisher},
     element date {$pubdate},
     element format {$format},
     element contrib_personal {$pcontributor},
     element contrib_corporate {$corpcontributor},
     element genre {$genre},
     element location {$location}
    }
  }
  let $serialize := csv:serialize ($csv, map { 'header': true(), 'separator':'comma'})
 return $serialize