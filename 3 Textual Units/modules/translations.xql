xquery version "3.1";
declare namespace t = "http://www.tei-c.org/ns/1.0";
declare namespace local = "http://local.local";
import module namespace math="http://exist-db.org/xquery/math";
import module namespace config = "https://www.betamasaheft.uni-hamburg.de/BetMas/config" at "config.xqm";
import module namespace titles="https://www.betamasaheft.uni-hamburg.de/BetMas/titles" at "titles.xqm";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";

declare variable $local:Periods := doc(concat($config:data-rootA, '/taxonomy.xml'))//t:category[t:desc='Periods']//t:category/t:catDesc ;

declare function local:printTitle($id){  if (starts-with($id, 'SdC:')) then 'La Synthaxe du Codex ' || substring-after($id, 'SdC:' )
     (: hack to avoid the bad usage of # at the end of an id like <title type="complete" ref="LIT2317Senodo#"
     : xml:lang="gez"> :) 
     else if (ends-with($id, '#')) then
        titles:printTitleMainID(substring-before($id, '#'))
    (: another hack for things like ref="#" :) else if ($id = '#') then
                         <span class="label label-warning">{ 'no item yet with id' || $id }</span>
    else if ($id = '') then
                        <span class="label label-warning">{ 'no id' }</span>
    (: if the id has a subid, than split it :) else if (contains($id, '#')) then
        let $mainID := substring-before($id, '#')
        let $SUBid := substring-after($id, '#')
        let $node := collection($config:data-root)//id($mainID)
        return
        if (starts-with($SUBid, 't'))
    then
        (let $subtitles:=$node//t:title[contains(@corresp, $SUBid)]
        let $subtitlemain := $subtitles[@type = 'main']/text()
        let $subtitlenorm := $subtitles[@type = 'normalized']/text()
        let $tit := $node//t:title[@xml:id = $SUBid]
        return
            if ($subtitlemain)
            then
                $subtitlemain
            else
                if ($subtitlenorm)
                then
                    $subtitlenorm
                else
                    $tit/text()
                    )
                    else
        let $subtitle :=   if( starts-with($SUBid, 'tr')) then 'transformation ' ||  $SUBid
else if( starts-with($SUBid, 'Uni')) then $SUBid 

else titles:printSubtitle($node, $SUBid)
        return
            (titles:printTitleMainID($mainID)|| ', '||$subtitle)
    (: if not, procede to main title printing :) else
        titles:printTitleMainID($id)};

declare function local:nodefromid($S){let $nodeS := if( contains($S,'#')) 
          then
            let $mainID := substring-before($S, '#')
            let $anchor := substring-after($S, '#')
            let $file :=collection($config:data-root)//id($mainID)
            return 
            $file//id($anchor)
            else collection($config:data-root)//id($S)
return $nodeS};

let $relationsNames := ('saws:isVersionOf','saws:isVersionInAnotherLanguageOf')
let $relations := collection($config:data-root)//t:relation[@name=$relationsNames]
let $relinfo := for $r in $relations
let $S := string($r/@active)
let $nodeS := local:nodefromid($S)
let $nodeSLang := if($nodeS/name() = 'title') then string($nodeS/@xml:lang) else 'gez'
let $nodeSPeriod := root($nodeS)//t:term[@key=$local:Periods]/@key/string()
let $rootS := root($nodeS)
let $O := string($r/@passive)
let $nodeO := local:nodefromid($O)
let $nodeOLang := if($nodeO[name() = 'title']) then string($nodeO/@xml:lang) else 'gez'
let $nodeOPeriod := root($nodeO)//t:term[@key=$local:Periods]/@key/string()
let $rootO := root($nodeO)
let $subject := local:printTitle($S) => replace(',', '') => replace('\n', ' ')
let $predicate := string($r/@name)
let $object := local:printTitle($O) => replace(',', '') => replace('\n', ' ')

return
<rel>
<sub><label>{if($subject = '') then 'Not available' else $subject}</label><id>{$S}</id></sub>
<subLang>{if($nodeSLang = '') then 'Not available' else $nodeSLang}</subLang>
<subPer>{ if (count($nodeSPeriod) gt 1) then string-join($nodeSPeriod, ' ')   else if(string-length($nodeSPeriod) eq 0) then 'Not available' else $nodeSPeriod}</subPer>
<pred>{$predicate}</pred>
<obj><label>{if($object= '') then 'Not available' else $object}</label><id>{$O}</id></obj>
<objLang>{if($nodeOLang = '') then 'Not available' else $nodeOLang}</objLang>
<objPer>{ if (count($nodeOPeriod) gt 1) then string-join($nodeOPeriod, ' ') else if($nodeOPeriod = '') then 'Not available'  else $nodeOPeriod}</objPer>
</rel>

let $langs :=($relinfo//subLang, $relinfo//objLang)
let $filterlang := 'ar'
let $filterbyperiod := $relinfo[subPer[.!=''] or objPer[.!='']]
let $filterbylanguage := $relinfo[subLang[.=$filterlang] or objLang[.=$filterlang]]

let $worksnodes:= 
let $subjandobj := ($relinfo//sub/id, $relinfo//obj/id)
for $node in distinct-values($subjandobj)
let $pickfirst := ($relinfo//id[.=$node])[1]
let $id:= $pickfirst/text()
let $label:= $pickfirst/preceding-sibling::label/text()
return map{'id' := $id, 'label' := $label, 'color' := 'blue'}

let $languagenodes := 
for $lang in distinct-values($langs)
return map{'id' := $lang, 'label' := $lang, 'color' := 'red'}

let $periodnodes := 
let $periods :=($relinfo//subPer, $relinfo//objPer)
for $period in distinct-values($periods)
return if($period = '') then map{'id' := 'Not_Specified', 'label' := 'Not_Specified' , 'color' := 'green'} else map{'id' := $period, 'label' := $period , 'color' := 'green'}

let $nodes := ($worksnodes, $languagenodes, $periodnodes)

let $work-workEdges :=
for $rel in $relinfo
return map{'from' := $rel/sub/id/text(), 'to' := $rel/obj/id/text(), 'label' :=$rel/pred/text() , 'font' := map {'align' := 'middle'}}

let $work-langEdges := 
for $rel in $relinfo
return (map{'from' := $rel/sub/id/text(), 'to' := $rel/subLang/text(), 'label' :='language' , 'font' := map {'align' := 'middle'}},
map{'from' := $rel/obj/id/text(), 'to' := $rel/objLang/text(), 'label' :='language' , 'font' := map {'align' := 'middle'}})

let $work-periodEdges := 
for $rel in $relinfo
return (map{'from' := $rel/sub/id/text(), 'to' := if($rel/subPer/text()='') then 'Not_Specified' else $rel/subPer/text(), 'label' :='period' , 'font' := map {'align' := 'middle'}},
map{'from' := $rel/obj/id/text(), 'to' := if($rel/objPer/text()='') then 'Not_Specified' else $rel/objPer/text(), 'label' :='period' , 'font' := map {'align' := 'middle'}})


let $edges := ($work-workEdges, $work-langEdges, $work-periodEdges)


return
map {'nodes' := $nodes,
'edges' := $edges
}
