xquery version "3.1";
declare namespace t = "http://www.tei-c.org/ns/1.0";
declare namespace local = "http://local.local";
import module namespace math="http://exist-db.org/xquery/math";
import module namespace config = "https://www.betamasaheft.uni-hamburg.de/BetMas/config" at "config.xqm";
import module namespace coord = "https://www.betamasaheft.uni-hamburg.de/BetMas/coord" at "coordinates.xqm";
import module namespace titles="https://www.betamasaheft.uni-hamburg.de/BetMas/titles" at "titles.xqm";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
(: select from incipit, explicit and colophon the descendants element placeName :)
 let $incipitPlaces := $config:collection-rootMS//t:incipit//t:placeName
 let $explicitPlaces := $config:collection-rootMS//t:explicit//t:placeName
let $colophonPlaces := $config:collection-rootMS//t:colophon//t:placeName
(: put them all in one same sequence :)
let $all := ($incipitPlaces, $explicitPlaces, $colophonPlaces)
(: select repositories of the manuscripts where the placeName selected before occur :)
let $repositories := for $mss in $all 
                                let $root := root($mss)/t:TEI 
(:we need to group, otherways we would have the same repository for each placeName attested.:)
                                            group by $R := $root  
                                          return $R//t:repository(:merge the list of placeNames and current repositories and loop through it:)
for $place in ($all, $repositories)
      let $manuscriptName := string(root($place)/t:TEI/@xml:id)
 (: this local function, which is not reproduced in the example prints the canonical title :)
      let $repositoryPlaceName := replace(titles:printTitleMainID($place/@ref), ',', '')
(:try to get coordinates for each place in the list, using a local function which
: determines how to retrive coordinates based on the Identifier provided :)
let $getcoordinates := coord:getCoords($place/@ref)
   let $coordinates := if(contains($getcoordinates, 'no coor')) then () else $getcoordinates
   let $type := if($place/name()='repository')
   then 'current location' else
                              'place named in colophon/incipit/explicit'
(: the query returns for each place a semi-column separated row, with 
: the name of the manuscript, the name of the place, its coordinates 
: and type, i.e. if it is a named place or a repository:)
return
       concat($manuscriptName,';', $repositoryPlaceName,';', $coordinates,';',$type)

