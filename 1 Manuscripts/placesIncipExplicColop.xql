xquery version "3.1";
declare namespace t = "http://www.tei-c.org/ns/1.0";
declare namespace local = "http://local.local";
import module namespace math="http://exist-db.org/xquery/math";
import module namespace config = "https://www.betamasaheft.uni-hamburg.de/BetMas/config" at "config.xqm";
import module namespace coord = "https://www.betamasaheft.uni-hamburg.de/BetMas/coord" at "coordinates.xql";
import module namespace titles="https://www.betamasaheft.uni-hamburg.de/BetMas/titles" at "titles.xqm";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
(: select from incipit, explicit and colophon the descendants element placeName :)
let $incipitPlaces := collection($config:data-rootMS)//t:incipit//t:placeName
let $explicitPlaces := collection($config:data-rootMS)//t:explicit//t:placeName
let $colophonPlaces := collection($config:data-rootMS)//t:colophon//t:placeName
(: put them all in one same sequence :)
let $all := ($incipitPlaces, $explicitPlaces, $colophonPlaces)
(: select repositories of the manuscripts where the placeName selected before occur :)
let $repositories := for $mss in $all let $root := root($mss) return $root//t:repository
(:merge the list of placeNames and current repositories and loop through it:)
for $place in ($all, $repositories) 
(: this local function, which is not reproduced in the example prints the canonical title :)
let $ms := replace(titles:printTitleMainID(root($place)/t:TEI/@xml:id), ',', '')
let $pl := replace(titles:printTitleMainID($place/@ref), ',', '')
(:try to get coordinates for each place in the list, using a local function which
: determines how to retrive coordinates based on the Identifier provided :)
let $getcoor := coord:getCoords($place/@ref)
let $coord := if(contains($getcoor, 'no coor')) then () else $getcoor
let $type := if($place/name()='repository') then 'current location' else 'place named in colophon/incipit/explicit'
return 
(: the query returns for each place a semi-column separated row, with 
: the name of the manuscript, the name of the place, its coordinates 
: and type, i.e. if it is a named place or a repository:)
                            concat($ms,';', $pl,';', $coord,';',$type)
