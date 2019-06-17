xquery version "3.1";
declare namespace t="http://www.tei-c.org/ns/1.0";
import module namespace titles="https://www.betamasaheft.uni-hamburg.de/BetMas/titles" at "xmldb:exist:///db/apps/BetMas/modules/titles.xqm";
import module namespace coord="https://www.betamasaheft.uni-hamburg.de/BetMas/coord" at "xmldb:exist:///db/apps/BetMas/modules/coordinates.xqm";
import module namespace config="https://www.betamasaheft.uni-hamburg.de/BetMas/config" at "xmldb:exist:///db/apps/BetMas/modules/config.xqm";
import module namespace http = "http://expath.org/ns/http-client";

let $bm := 
   let $work := 'LIT2384Taamme'
   let $mss := collection($config:data-rootMS)//t:title[contains(@ref , $work)]
   for $ms in $mss
       let $repo := root($ms)//t:repository
       let $id := string(root($ms)/t:TEI/@xml:id)
       let $manuscriptName := titles:printTitleMainID($id)
       let $date := root($ms)//t:origDate
       let $stringDate := for $d in $date
       let $atts := for $att in ($d/@notBefore, $d/@notAfter, $d/@when) return string($att)
                        return min($atts)
     let $repositoryPlaceName := titles:printTitleMainID($repo/@ref)
     return
             $repositoryPlaceName || ';' || $manuscriptName || ';' || min($stringDate) || '; Beta maṣāḥǝft'


let $europeana := 
    let $apiroot := 'https://www.europeana.eu/api/v2/search.json'   
    let $parameters :=  '?query=Miracles+Mary&amp;wskey=dDdg8VwbV&amp;rows=100'
    let $apirequest := $apiroot || $parameters
    let $apiresponse := httpclient:get(xs:anyURI($apirequest), true(), <Headers/>)
    let $response := util:base64-decode($apiresponse) 
    let $parse-response := parse-json($response)
    for $item in $parse-response?items?*
    let $manuscriptName : = normalize-space(replace($item?title, ';', ', '))
    let $type := $item?type
    let $link := $item?link
    let $apiresponseRecord := httpclient:get(xs:anyURI($link), true(), <Headers/>)
    let $responseRecord := util:base64-decode($apiresponseRecord) 
    let $parse-responseRecord := parse-json($responseRecord)
    let $dataProvider := $item?dataProvider
    let $repoPlaceName := $parse-responseRecord?object?proxies?*?dctermsProvenance?*
    let $repositoryPN := if(count($repoPlaceName) gt 0) then $repoPlaceName else $dataProvider
    let $repositoryPlaceName := normalize-space(replace($repositoryPN, ';', ', '))
    let $dcTermsCreated := $parse-responseRecord?object?proxies?*?dctermsCreated?def?*
    let $dcDate := $parse-responseRecord?object?proxies?*?dcDate?def?*
    let $stringDate := ($dcDate,$dcTermsCreated)
    return
    $repositoryPlaceName || ';' || $manuscriptName|| ';' || string-join($stringDate, ' ') || '; Europeana ' || $type
             
             return
             ($bm, $europeana)