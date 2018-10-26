xquery version "3.1";


import module namespace config="http://epi.comp/config" at "config.xqm";

declare namespace t = "http://www.tei-c.org/ns/1.0";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace rdf ="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare variable $local:range-lookup := 
    (
        function-lookup(xs:QName("range:index-keys-for-field"), 4),
        function-lookup(xs:QName("range:index-keys-for-field"), 3)
    )[1];

        
let $EAGLE300to700 := collection(concat($config:data-root, '/EAGLE'))//t:origDate[@notBefore-custom ge 0300][@notAfter-custom le 0700]
let $ISicily300to700 := collection(concat($config:data-root, '/ISicily'))//t:origDate[@notBefore-custom ge 0300][@notAfter-custom le 0700]
let $TM300to700 := collection(concat($config:data-root, '/trismegistos'))//t:origDate[@notBefore-custom ge 0300][@notAfter-custom le 0700]
let $Ethio300to700 := collection(concat($config:data-root, '/Ethiopic'))//t:origDate

return

 <table class="table table-responsive">
{
(
<row role='label'>

<cell>material and object</cell>
<cell>inscriptions</cell>
<cell>EAGLE</cell>
<cell>ISicily</cell>
<cell>Trismegistos</cell>
</row>,

for $i in $Ethio300to700/ancestor::t:TEI[descendant::t:material[@ref]][descendant::t:objectType[@ref]]
let $root := root($i)
let $m := $root//t:material/@ref
let $o := $root//t:objectType/@ref
let $Mlabel := doc(concat($config:data-root, '/EAGLEvoc/eagle-vocabulary-material.rdf'))//skos:Concept[@rdf:about = $m]/skos:prefLabel/text()
let $Olabel :=doc(concat($config:data-root, '/EAGLEvoc/eagle-vocabulary-object-type.rdf'))//skos:Concept[@rdf:about = $o]/skos:prefLabel/text()
let $label := concat($Mlabel, ' ', $Olabel)
let $mS := replace($m, 'https:', 'http:')
let $oS := replace($o, 'https:', 'http:')

let $sameEAGLE := $EAGLE300to700/ancestor::t:TEI[descendant::t:material[@ref=$mS]][descendant::t:objectType[@ref=$oS]]
let $countSEAGLE := count($sameEAGLE)
let $sameIsicily := $ISicily300to700/ancestor::t:TEI[descendant::t:material[@ref=$m]][descendant::t:objectType[@ref=$o]]
let $countSisicily := count($sameIsicily)
let $sameTrismegistos := $TM300to700/ancestor::t:TEI[descendant::t:material[@ref=$m]][descendant::t:objectType[@ref=$o]]
let $countSTrismegistos := count($sameTrismegistos)
group by $label
return
if(contains($label, 'ignoratur')) then () else
<row>
<cell>{$label}</cell>
<cell>{count($i) || ': (', let $ids :=for $ins in $i let $root := root($ins) return $root//t:msIdentifier/t:idno/text() return string-join($ids, '; '), ')'}</cell>
<cell>{distinct-values($countSEAGLE)}</cell>
<cell>{distinct-values($countSisicily)}</cell>
<cell>{distinct-values($countSTrismegistos)}</cell>
</row>
)}
</table>

