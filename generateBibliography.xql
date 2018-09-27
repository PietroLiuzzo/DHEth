xquery version "3.1";
declare namespace f = "http://fidal.parser";
declare namespace t = "http://www.tei-c.org/ns/1.0";
declare namespace s = "http://www.w3.org/2005/xpath-functions";
declare namespace functx = "http://www.functx.com";
declare namespace k = "http://www.opengis.net/kml/2.2";

import module namespace http = "http://expath.org/ns/http-client";

declare function local:zot($c) {
    let $xml-url-formattedBiblio := concat('https://api.zotero.org/users/1405276/items?tag=', $c, '&amp;format=bib&amp;style=hiob-ludolf-centre-for-ethiopian-studies&amp;linkwrap=1')
    let $data := httpclient:get(xs:anyURI($xml-url-formattedBiblio), true(), <Headers/>)
    let $datawithlink := $data//div[@class = 'csl-entry']
    return
        $datawithlink
};

let $citations := distinct-values(collection('/db/apps/DHEth/data')//t:bibl/t:ptr/@target)
let $bibliography :=
<bibliography xmlns="dheth.biblio"><total>{count($citations)}</total>
    <entries>{
            for $c in $citations
            let $shortCit :=
            let $xml-url := concat('https://api.zotero.org/users/1405276/items?&amp;tag=', $c, '&amp;include=citation&amp;style=hiob-ludolf-centre-for-ethiopian-studies')
            let $req :=
            <http:request
                http-version="1.1"
                href="{xs:anyURI($xml-url)}"
                method="GET">
            </http:request>
            
            let $zoteroApiResponse := http:send-request($req)[2]
            let $decodedzoteroApiResponse := util:base64-decode($zoteroApiResponse)
            let $parseedZoteroApiResponse := parse-json($decodedzoteroApiResponse)
            let $replaced := replace($parseedZoteroApiResponse?*?citation, '&lt;span&gt;', '') => replace('&lt;/span&gt;', '')
            return
                $replaced
                
                
                group by $shortCit
                order by $shortCit
            return
(:            <entry>{$shortCit}</entry>:)
                if ($shortCit = '' or $shortCit = ' ') then
                    for $sameCit in $c
                    return
                        <entry
                            id="{$sameCit}">
                            <citation>EMPTY! WRONG POINTER!</citation>
                            <reference>{local:zot($sameCit)}</reference>
                        </entry>
                else
                    if (count($c) gt 1) then
                        for $sameCit at $p in $c
                        let $letters := ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'l', 'm', 'n', 'o')
                        return
                            <entry
                                id="{$sameCit}">
                                <citation>{$shortCit}{$letters[$p]}</citation>
                                <reference>{local:zot($sameCit)}</reference>
                            </entry>
                    else
                      for $sameCit in $c
                    return
                        <entry
                            id="{$sameCit}">
                            <citation>{$shortCit}</citation>
                            <reference>{local:zot($sameCit)}</reference>
                        </entry>
        }
    </entries>
</bibliography>



return
    
   xmldb:store('/db/apps/DHEth/data', 'bibliography.xml', $bibliography)
   
   
(:   NEEDS POSTPROCESSING: THE ZOTERO OUTPUT as ESCAPED HTML

replace &lt;i&gt; and &lt;/i&gt; with proper tags:)