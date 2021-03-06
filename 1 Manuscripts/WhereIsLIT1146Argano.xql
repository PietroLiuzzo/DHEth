xquery version "3.1";
declare namespace t = "http://www.tei-c.org/ns/1.0";
declare namespace local = "http://local.local";
import module namespace math="http://exist-db.org/xquery/math";
import module namespace config = "https://www.betamasaheft.uni-hamburg.de/BetMas/config" at "config.xqm";
import module namespace coord = "https://www.betamasaheft.uni-hamburg.de/BetMas/coord" at "coordinates.xql";
import module namespace titles="https://www.betamasaheft.uni-hamburg.de/BetMas/titles" at "titles.xqm";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
(: store in a variable the ID of the work:)
 let $work := 'LIT1146Argano'
(: select from manuscript files those which contain a t:title with @ref='LIT1146Argano'
could have been limited to t:title inside t:msItem with //t:msItem/t:title instead of //t:title 
:)
let $mss := collection($config:data-rootMS)//t:title[contains(@ref , $work)]
for $ms in $mss
let $repo := root($ms)//t:repository
let $manuscriptName := string(root($ms)/t:TEI/@xml:id)
let $date := root($ms)//t:origDate
let $stringDate := for $d in $date
let $atts := for $att in ($d/@notBefore, $d/@notAfter, $d/@when) return string($att)
return min($atts)
let $coordinates := coord:getCoords($repo/@ref)
let $repositoryPlaceName := titles:printTitleMainID($repo/@ref)
   return
           $repositoryPlaceName || ';' || $coordinates || ';' || $manuscriptName || ';' || min($stringDate)
