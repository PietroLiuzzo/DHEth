xquery version "3.1" ;
(:~
 : This module, initially 
 : based on the one provided in the 
 Shakespare example app in the eXist-db repository,
 : produces a XSL FO temporary object and passes it to
 : Apache FOP as extension module in eXist-db, to produce a PDF
 : @author Pietro Liuzzo <pietro.liuzzo@uni-hamburg.de'>
 :)

import module namespace config = "http://betamasaheft.eu/DHEth/config" at "config.xqm";
import module namespace console = "http://exist-db.org/xquery/console";
import module namespace http = "http://expath.org/ns/http-client";

(:the namespaces used for functions and data:)
declare namespace fo = "http://www.w3.org/1999/XSL/Format";
declare namespace xslfo = "http://exist-db.org/xquery/xslfo";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace ex = "http://www.tei-c.org/ns/Examples";
declare namespace file = "http://exist-db.org/xquery/file";
declare namespace functx = "http://www.functx.com";
(:this is a madeup namespace for the local bibliography which 
contains the HTML output of Zotero produced in generateBibliography.xql:)
declare namespace biblio = 'dheth.biblio';

(:~ The location of the Zotero Bibliography, in this case the user library of Pietro Liuzzo:)
declare variable $local:zotcollection := 'https://api.zotero.org/users/1405276/';

(:    This bibliography is generated with the script generateBibliography.xql which calls 
the Zotero main library of references for this book and collects the citations and the 
full references adjusting the handle for the references so that it has the appropriate letter.
Doing this the http calls to Zotero are done only on updating of the bibliography, not on every run of the data to produce the pdf.:)
declare variable $local:bibliography := doc('/db/apps/DHEth/data/bibliography.xml');

(:~ Configuration passed with the XSL-FO file to FOP, 
includes fonts and hyphenation specification :)
declare variable $local:fop-config :=
let $fontsDir := config:get-fonts-dir()
return
    <fop
        version="1.0">
        <hyphenation-pattern lang="en">en_GB</hyphenation-pattern>
        <hyphenation-pattern lang="de">de</hyphenation-pattern>
        <hyphenation-pattern lang="it">it</hyphenation-pattern>
        <hyphenation-pattern lang="gez">mul_ET</hyphenation-pattern>
        <strict-configuration>true</strict-configuration>
        <strict-validation>false</strict-validation>
        <base>./</base>
        <renderers>
            <renderer
                mime="application/pdf">
                <fonts>
                    {
                        if ($fontsDir) then
                            (<font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/IFAOGrec.ttf">
                                <font-triplet
                                    name="IFAOGrec"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/Cardo-Regular.ttf">
                                <font-triplet
                                    name="Cardo"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/Cardo-Bold.ttf">
                                <font-triplet
                                    name="Cardo"
                                    style="normal"
                                    weight="700"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/Cardo-Italic.ttf">
                                <font-triplet
                                    name="Cardo"
                                    style="italic"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/coranica_1145.ttf">
                                <font-triplet
                                    name="coranica"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/Scheherazade-Regular.ttf">
                                <font-triplet
                                    name="scheherazade"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/Scheherazade-Bold.ttf">
                                <font-triplet
                                    name="scheherazade"
                                    style="normal"
                                    weight="700"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/TitusCBZ.TTF">
                                <font-triplet
                                    name="Titus"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/LudolfusNormal.ttf">
                                <font-triplet
                                    name="Ludolfus"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/LudolfusBold.ttf">
                                <font-triplet
                                    name="Ludolfus"
                                    style="normal"
                                    weight="700"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/LudolfusItalic.ttf">
                                <font-triplet
                                    name="Ludolfus"
                                    style="italic"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/LudolfusBoldItalic.ttf">
                                <font-triplet
                                    name="Ludolfus"
                                    style="italic"
                                    weight="700"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSans-Regular.ttf">
                                <font-triplet
                                    name="Noto"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSans-Bold.ttf">
                                <font-triplet
                                    name="Noto"
                                    style="normal"
                                    weight="700"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSans-Italic.ttf">
                                <font-triplet
                                    name="Noto"
                                    style="italic"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSans-BoldItalic.ttf">
                                <font-triplet
                                    name="Noto"
                                    style="italic"
                                    weight="700"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansEthiopic-Regular.ttf">
                                <font-triplet
                                    name="NotoSansEthiopic"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansEthiopic-Bold.ttf">
                                <font-triplet
                                    name="NotoSansEthiopic"
                                    style="normal"
                                    weight="700"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoNaskhArabic-Regular.ttf">
                                
                                <font-triplet
                                    name="NotoNaskhArabic"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoNaskhArabic-Bold.ttf">
                                
                                <font-triplet
                                    name="NotoNaskhArabic"
                                    style="normal"
                                    weight="700"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansArmenian-Bold.ttf">
                                
                                <font-triplet
                                    name="NotoSansArmenian"
                                    style="normal"
                                    weight="700"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansArmenian-Regular.ttf">
                                
                                <font-triplet
                                    name="NotoSansArmenian"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansAvestan-Regular.ttf">
                                
                                <font-triplet
                                    name="NotoSansAvestan"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansCoptic-Regular.ttf">
                                
                                <font-triplet
                                    name="NotoSansCoptic"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansGeorgian-Regular.ttf">
                                
                                <font-triplet
                                    name="NotoSansGeorgian"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansHebrew-Regular.ttf">
                                
                                <font-triplet
                                    name="NotoSansHebrew"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansSyriacEstrangela-Regular.ttf">
                                
                                <font-triplet
                                    name="NotoSansSyriacEstrangela"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansDevanagari-Regular.ttf">
                                
                                <font-triplet
                                    name="NotoSansDevanagari"
                                    style="normal"
                                    weight="normal"/>
                            </font>,
                            <font
                                kerning="yes"
                                embed-url="file:{$fontsDir}/NotoSansDevanagari-bold.ttf">
                                
                                <font-triplet
                                    name="NotoSansDevanagari"
                                    style="normal"
                                    weight="700"/>
                            </font>
                            )
                        else
                            ()
                    }
                </fonts>
            </renderer>
        </renderers>
    </fop>
;

(:~ helper functx function, retriving the index of a node :)
declare function functx:index-of-node($nodes as node()*, $nodeToFind as node()) as xs:integer* {
    
    for $seq in (1 to count($nodes))
    return
        $seq[$nodes[$seq] is $nodeToFind]
};

(:~ helper functx function, capitalizing first letter in a string :)
declare function functx:capitalize-first($arg as xs:string?) as xs:string? {
    
    concat(upper-case(substring($arg, 1, 1)),
    substring($arg, 2))
};

(:~ helper functx function, returning the index at which a substring starts :)
declare function functx:index-of-string( $arg as xs:string?, $substring as xs:string )  as xs:integer* {

  if (contains($arg, $substring))
  then (string-length(substring-before($arg, $substring))+1,
        for $other in
           functx:index-of-string(substring-after($arg, $substring),
                               $substring)
        return
          $other +
          string-length(substring-before($arg, $substring)) +
          string-length($substring))
  else ()
 } ;

(:~ Set of functions used to produce citations and bibligraphy:)

(:~ Given a unique tag, returns the formatted reference 
according to the Hiob Ludolf Centre Style
See https://betamasaheft.github.io/bibliography/ for the style guidelines and documentation
:)
declare function fo:Zotero($ZoteroUniqueBMtag as xs:string) {
    let $xml-url := concat($local:zotcollection||'items?tag=', $ZoteroUniqueBMtag, '&amp;format=bib&amp;style=hiob-ludolf-centre-for-ethiopian-studies&amp;linkwrap=1')
    let $data := httpclient:get(xs:anyURI($xml-url), true(), <Headers/>)
    let $datawithlink := fo:tei2fo($data//div[@class = 'csl-entry'])
    return
        $datawithlink
};

(:~ given a unique tag, return the citation formatted according to the Hiob Ludolf Centre Style
See https://betamasaheft.github.io/bibliography/ for the style guidelines and documentation:)
declare function fo:zoteroCit($ZoteroUniqueBMtag as xs:string) {
fo:tei2fo($local:bibliography//biblio:citation[parent::biblio:entry[@id=$ZoteroUniqueBMtag]])
   };
            
(:~ given a Zotero Collection ID, return the full bibliography 
formatted according to the Hiob Ludolf Centre Style
See https://betamasaheft.github.io/bibliography/ for the style guidelines and documentation:)
declare function fo:zoteroBib($collectionKey){
 let $xml-url := concat($local:zotcollection||'collections/',$collectionKey,'/items?format=bib&amp;style=hiob-ludolf-centre-for-ethiopian-studies&amp;linkwrap=1')
let $data := httpclient:get(xs:anyURI($xml-url), true(), <Headers/>)
    let $datawithlink := for $bib at $p in $data//div[@class = 'csl-bib-body']//div[@class = 'csl-entry']  
    return <fo:block margin-bottom="2pt" start-indent="0.5cm" text-indent="-0.5cm">{fo:tei2fo($bib)}</fo:block>
    return
    $datawithlink
        
};

(:~ looks at the bibliography file in $local:bibliography and prints the bibliography for the
xslfo:)
declare function fo:zoteroBibfromCitation(){
let $datawithlink := for $bib at $p in $local:bibliography//biblio:entry  
    return <fo:block margin-bottom="2pt" start-indent="0.5cm" text-indent="-0.5cm" id="{$bib/@id}">[<fo:inline font-weight="bold">{
    $bib//biblio:citation//text()}</fo:inline>]  {fo:tei2fo($bib/biblio:reference/*:div)}</fo:block>
    return
    $datawithlink

};

(:~ assigns a xml:lang according to what is in the data:)
declare function fo:lang($lang as xs:string) {
    switch ($lang)
        case 'ar'
            return
                (attribute font-family {'coranica'}, attribute writing-mode {'rl'}, attribute text-align {'left'}, attribute font-size {'14pt'}, attribute line-height {'16pt'})
        case 'so'
            return
                (attribute font-family {'coranica'}, attribute writing-mode {'rl'})
        case 'aa'
            return
                (attribute font-family {'coranica'}, attribute writing-mode {'rl'})
        case 'x-oh'
            return
                (attribute font-family {'coranica'}, attribute writing-mode {'rl'})
        case 'he'
            return
                (attribute font-family {'Titus'}, attribute writing-mode {'rl'})
        case 'syr'
            return
                (attribute font-family {'Titus'}, attribute writing-mode {'rl'})
        case 'grc'
            return
                (attribute font-family {'IFAOGrec'})
        case 'cop'
            return
                attribute font-family {'Titus'}
        case 'amh'
            return
                (attribute font-family {'Ludolfus'}, attribute letter-spacing {'0.5pt'}, attribute font-size {'0.9em'})
        case 'gez'
            return
                (attribute font-family {'Ludolfus'}, attribute letter-spacing {'0.5pt'}, attribute font-size {'0.9em'})
        case 'sa'
            return
                attribute font-family {'NotoSansDevanagari'}
        default return
            attribute font-family {'Ludolfus'}
};

(:~ iterates through the nodes passed to render them in xslfo,
this is specific to what they need to be like in the desc of a figure:)
declare function fo:figDesc2fo($nodes as node()*) {
    for $node in $nodes
    return 
    typeswitch ($node)
    
 case element(tei:term)
     return
     $node/text()
     case element(tei:ref)
     return
     string($node/@target)
     case element(tei:bibl)
     return
     (
            try{fo:zoteroCit($node/tei:ptr/@target)} 
            catch * {console:log($err:description)},
            if($node/tei:citedRange) then ', ' || (switch($node/tei:citedRange/@unit) 
            case 'paragraph' return '§' case 'page' return '' default return string($node/tei:citedRange/@unit))||$node/tei:citedRange/text() else ()
            )
 case element(tei:placeName)
     return
      <fo:inline>{$node/text()}</fo:inline>
     case element(tei:persName)
     return
      <fo:inline>{$node/text()} {if($node[@type='bm']) then '(ID:'||$node/@ref||')' else ()}</fo:inline>
    
    case element()
        return
            fo:tei2fo($node/node())
    default
        return
            $node
};

(:~ iterates through the nodes passed to render them in xslfo, this is where the behaviour
in rendering the TEI of the source files is defined :)
declare function fo:tei2fo($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch ($node)
        case comment()
        return
         
         <fo:block font-family="Noto" background-color="green">Comment: {string($node)}</fo:block>
         case element(tei:label)
         return
         switch($node/@type)
         case 'change' return
         <fo:inline background-color="yellow">{fo:tei2fo($node/node())}</fo:inline>
         default return 
         <fo:inline background-color="red">{fo:tei2fo($node/node())}</fo:inline>
            case element(tei:TEI)
                return
                    <fo:block hyphenate="true">{fo:tei2fo($node/node())}</fo:block>
            case element(tei:fileDesc)
                return
                    fo:tei2fo($node/node())
            case element(tei:teiHeader)
                return
                    fo:tei2fo($node/node())
            case element(tei:text)
                return
                    fo:tei2fo($node/node())
            case element(tei:milestone)
            return 
            <fo:block hyphenate="true" page-break-after="always"/>
            case element(tei:body)
                return
                    fo:tei2fo($node/node())
                    case element(tei:ref)
                    return 
                    if($node/@cRef) then 
                       if($node/parent::tei:cit) then
                        let $wordcount := count(tokenize(string-join($node/parent::tei:cit/tei:quote[1]//text(), ' '), '\s+'))
                          return
                             if($wordcount lt 50) then
                             <fo:inline id="{string(root($node)/tei:TEI/@xml:id)}{generate-id($node)}">({$node/text()})</fo:inline>
                              else
                            <fo:block id="{string(root($node)/tei:TEI/@xml:id)}{generate-id($node)}" text-align="right" hyphenate="true">{$node/text()}</fo:block> 
                       else <fo:inline id="{string(root($node)/tei:TEI/@xml:id)}{generate-id($node)}">{$node/text()}</fo:inline>
                    else if($node/@type) then 
                    <fo:inline>{
                    switch($node/@type) 
                    case 'internal' return (
                               'page ', <fo:page-number-citation
                                ref-id="{string(root($node)/tei:TEI/@xml:id)}{string($node/@corresp)}"/>
                                )
                    case 'chapter' return 'Ch. ' || substring-after($node/@corresp, '#chapter') 
                    case 'figure' return (let $corresp := substring-after($node/@corresp, '#') 
                                                                                let $figure:= root($node)//tei:*[@xml:id=$corresp]
                                                              return  ('Fig. '   || (
                                                                                    if(contains(string(root($node)/tei:TEI/@xml:id), 'intro'))
                                                                                    then ' 0' 
                                                                                    else replace(string(root($node)/tei:TEI/@xml:id), 'chapter', ' '))
                                                                                    ||'.'||(count($figure/preceding::tei:graphic) +1) )
                    )
                    default return $node/@corresp} </fo:inline>
                   
                   else
(:     if the url is too long, add here and there              &#x200b;   and it will break there if needed  :)
                     <fo:basic-link
                            external-destination="{string($node/@target)}" hyphenate="false">&lt;{if($node/text()) then $node/text() else string($node/@target)}&gt;</fo:basic-link>
            case element(tei:emph)
                    return 
            <fo:inline
                            font-style='italic'>{$node/text()}</fo:inline>
            case element(tei:hi)
                    return 
                      if ($node/@rend = "rubric") then
                <fo:inline
                    color="red">{$node/text()}</fo:inline>
          else if ($node/@rendition) then
                    switch($node/@rendition)
                    case 'simple:italic' return
                     <fo:inline
                            font-style='italic'>{$node/text()}</fo:inline>
                    case 'simple:bold' return
                     <fo:inline
                            font-weight='bold'>{$node/text()}</fo:inline>
                   
                   case 'simple:smallcaps' return
                     <fo:inline 
                        font-variant="small-caps">{
                        let $parts := for $w in tokenize($node/text(), ' ') return $w
                           return
                (:                mock up small caps:)
                (for $p in $parts
                return
                    (<fo:inline>{upper-case(substring($p, 1, 1))}</fo:inline>,
                    <fo:inline
                        font-size="0.75em">{upper-case(substring($p, 2))}</fo:inline>,
                    if (index-of($parts, $p) = count($parts)) then
                        ()
                    else
                        ' '
                    ))}</fo:inline>
                            default return
                             <fo:inline>{$node/text()}</fo:inline>
                             else fo:tei2fo($node/node())
            case element(tei:titleStmt)
                return
                    <fo:block
                    id="{string(root($node)/tei:TEI/@xml:id)}{generate-id($node/tei:title)}"
                        font-size="12pt"
                        text-align="center"
                        font-weight='700'
                        margin-bottom="12.24pt"
                        hyphenate="true"
                        margin-top="25.2pt">{if(root($node)[starts-with(tei:TEI/@xml:id, 'chapter')]) then 'Chapter ' || substring-after(root($node)/tei:TEI/@xml:id, 'chapter') || '. ' else ()}{fo:tei2fo($node/tei:title)}</fo:block>
            
            case element(tei:note)
                return
                    let $root := root($node)
                    let $notes := $root//tei:note
                    let $n := count($node/preceding::tei:note) +1
                    return
                        <fo:footnote>
                            <fo:inline
                                font-size="7pt"
                                vertical-align="text-top">{$n}</fo:inline>
                            
                            <fo:footnote-body  text-align="justify" margin-left="0pt" text-indent="0">
                                <fo:list-block>
                                    <fo:list-item>
                                        <fo:list-item-label>
                                            <fo:block >
                                                <fo:inline
                                                    vertical-align="text-top"
                                                    font-size="9pt"
                                                >{$n}</fo:inline>
                                            </fo:block>
                                        </fo:list-item-label>
                                        <fo:list-item-body>
                                            <fo:block
                                            hyphenate="true"
                                                space-before="0.45cm"
                                                font-size="9pt"
                                                line-height="11pt"
                                                margin-left="0.45cm"
                                                >
                                                {fo:tei2fo($node/node())}
                                            </fo:block>
                                        </fo:list-item-body>
                                    </fo:list-item>
                                </fo:list-block>
                            </fo:footnote-body>
                        </fo:footnote>
                        
                        case element(tei:list)
                        return
                        if($node/@type = 'gloss') 
                        then 
(:                        This handles only the Glossary.xml list :)
                        <fo:list-block provisional-distance-between-starts="70pt" provisional-label-separation="3pt">{
                        for $term in $node/tei:item
                        let $lab := $term/tei:label/text()
                        return
                        <fo:list-item margin-bottom="5pt">
                        <fo:list-item-label end-indent="label-end()">
                        <fo:block font-weight="800" margin-right="5mm" hyphenate="false">{$lab}</fo:block>
                        </fo:list-item-label>
                         <fo:list-item-body  start-indent="body-start()">
                        <fo:block hyphenate="true">{fo:tei2fo($term/node()[name()!='label'])}
                        
                        [See pages: {
                        let $references := (collection('/db/apps/DHEth/data/chapters')//tei:term[lower-case(text()) = lower-case($lab)], collection('/db/apps/DHEth/data/front')//tei:term[lower-case(text()) = lower-case($lab)])
                        let $occs := for $occ at $p in $references
                                                let $chapterNumber :=  if(contains(string(root($occ)/tei:TEI/@xml:id), 'intro')) then ' 0' 
                else replace(string(root($occ)/tei:TEI/@xml:id), 'chapter', ' ')
                
                group by $chapterNumber
                order by $chapterNumber
                return
                  (if($chapterNumber=' 0') then 'Intro: ' else 'Chapter' || $chapterNumber || ': ',
                  for $oc at $p in $occ
                                                order by $oc
                                                          return 
                                                          (<fo:page-number-citation
                                                                                   ref-id="{string(root($oc)/tei:TEI/@xml:id)}{generate-id($oc)}{$oc/text()}"/>,
                                                                                   if($p=count($occ)) then '; ' else ', ')
                        )
                        return $occs
                        }]
                        </fo:block>
                        </fo:list-item-body>
                        </fo:list-item>
                        }
                        </fo:list-block>
                        else
(:                        if the list is inside a quotation which is displaied, then the all indentation should be moved of that measure as well, otherways it will not align properly relative to its block:)
                        let $par := if($node/ancestor::tei:quote) then 1 else ()
                        return
                        <fo:list-block 
                        provisional-distance-between-starts="6mm" 
               provisional-label-separation="6mm" 
               >
               {attribute start-indent {((0.43 * (1 +count($node/ancestor::tei:list))) + $par)  || "cm"}}
                                    {fo:tei2fo($node/node())}
                                </fo:list-block>
                
                
                case element(tei:item)
                                return
                                <fo:list-item>
                                        <fo:list-item-label end-indent="label-end()">
                                            <fo:block>
                                            {
                                
                                                <fo:inline>
                                                {
                                                (let $upperalphabet := ('A', 'B', 'C', 'D', 'E', 'F', 'G', 'J', 'K', 'L')
                                                let $loweralphabet := ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'j', 'k', 'l')
                                                let $romanUpper := ('I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X')
                                                let $romanLower := ('i', 'ii', 'iii', 'iv', 'v', 'vi', 'vii', 'viii', 'ix', 'x')
                                                let $position := count($node/preceding-sibling::tei:item) + 1
                                                return
                                                switch($node/parent::tei:list/@type)
                                                case 'ordered:upperalpha' return $upperalphabet[$position]
                                                case 'ordered:upperroman' return $romanUpper[$position]
                                                case 'ordered:loweralpha' return $loweralphabet[$position]
                                                case 'ordered:lowerroman' return $romanLower[$position]
                                                default return $position
                                                )
                                                || ')'}
                                                </fo:inline>}
                                            </fo:block>
                                        </fo:list-item-label>
                                        <fo:list-item-body start-indent="body-start()">
                                            <fo:block hyphenate="true">{
                                
                                            fo:tei2fo($node/node())
                                            }</fo:block>
                                        </fo:list-item-body>
                                    </fo:list-item>
            case element(a)
                return
                    <fo:basic-link
                        external-destination="{string($node/@href)}">{$node/text()}</fo:basic-link>
            case element(i)
                return
                    <fo:inline
                        font-style="italic">{$node/text()}</fo:inline>
            case element(biblio:i)
                return
                    <fo:inline
                        font-style="italic">{$node/text()}</fo:inline>  
            case element(tei:gap)
                
                return
                    switch ($node/@reason)
                        case 'illegible'
                            return
                                for $c in 0 to $node/@quantity
                                return
                                    <fo:inline>+</fo:inline>
                        case 'omitted'
                            return
                                <fo:inline>.....</fo:inline>
                        case 'ellipsis'
                            return
                                <fo:inline>(...)</fo:inline>
                        default return
                            <fo:inline>[- ca. {(string($node/@quantity) || ' ' || string($node/@unit))}{
                                    if (xs:integer($node/@quantity) gt 1) then
                                        's'
                                    else
                                        ()
                                } -]</fo:inline>
        case element(tei:supplied)
            return
                switch ($node/@reason)
                    case 'omitted'
                        return
                            <fo:inline>&lt;{fo:tei2fo($node/node())}&gt;</fo:inline>
                    case 'undefined'
                        return
                            <fo:inline>[{fo:tei2fo($node/node())} (?)]</fo:inline>
                    default return
                        <fo:inline>[{fo:tei2fo($node/node())}]</fo:inline>
    case element(tei:add)
        return
            fo:tei2fo($node/node())
    case element(tei:handShift)
        return
            fo:tei2fo($node/node())
   case element(tei:certainty)
        return
            <fo:inline>?</fo:inline>
(:            Yes, you found the witty-taggy thing which really ends the book! :)
    
     case element(tei:cit)
     return
(:     Francesca said: if the quotation is longer than 50 words, then it should be in the text (inline), if not should be in display (block with indentation) :)
   (  let $wordcount := count(tokenize(string-join($node/tei:quote[1]//text(), ' '), '\s+'))
    return
if( $node/parent::tei:epigraph or ($wordcount ge 50)) then
                <fo:block hyphenate="true"
                    start-indent="1cm"
                    margin-top="6.25pt"
                    margin-bottom="6.25pt">
                    {
                        if ($node/@xml:lang) then
                            fo:lang($node/@xml:lang)
                        else
                            ()
                    }
                    {fo:tei2fo($node/node())}
                </fo:block>
                else 
                <fo:inline>
                    {
                        if ($node/@xml:lang) then
                            fo:lang($node/@xml:lang)
                        else
                            ()
                    }‘{fo:tei2fo($node/tei:quote)}’{fo:tei2fo($node/node()[name() != 'quote'])}
                </fo:inline>
                )
     
    case element(tei:quote)
     return
     
      (  let $wordcount := count(tokenize(string-join($node//text(), ' '), '\s+'))
      
     return
if($wordcount ge 50) then
<fo:block hyphenate="true">
                    {
                        if ($node/@xml:lang) then
                            fo:lang($node/@xml:lang)
                        else
                            ()
                    }
                    {fo:tei2fo($node/node())}
                </fo:block>
else
                <fo:inline>
                    {
                        if ($node/@xml:lang) then
                            fo:lang($node/@xml:lang)
                        else
                            ()
                    }
                    {fo:tei2fo($node/node())}
                </fo:inline>
         )
    
    case element(tei:q)
     return
     <fo:inline>‘{fo:tei2fo($node/node())}’</fo:inline>
    
    case element(tei:date)
        return
            if ($node/@notBefore and $node/@notAfter) then
                <fo:inline>{string($node/@notBefore) || '-' || string($node/@notAfter)}</fo:inline>
            else
                if ($node/@when) then
                    <fo:inline>{string($node/@when)}</fo:inline>
                else
                    if ($node/@type = 'foundation')
                    then
                        <fo:inline>(Foundation: {$node/text()})</fo:inline>
                    else
                        $node/text()
    
    case element(tei:origDate)
        return
            (if ($node/text()) then
                <fo:inline>{$node/text()}</fo:inline>
            else
                (),
            if ($node/@notBefore and $node/@notAfter) then
                <fo:inline>{string($node/@notBefore) || '-' || string($node/@notAfter)}</fo:inline>
            else
                if ($node/@when) then
                    <fo:inline>{string($node/@when)}</fo:inline>
                
                else
                    (),
            if ($node/@evidence) then
                <fo:inline>{string($node/@evidence)}</fo:inline>
            else
                ()
            )
    case element(tei:p)
        return
                <fo:block
                    xml:lang="en"
                    hyphenate="true">{
                        if ($node/preceding-sibling::tei:p) then
                            (attribute text-indent {'0.43cm'})
                        else
                            ()
                    }{fo:tei2fo($node/node())}</fo:block>
    
    
    case element(tei:label)
        return
            <fo:block hyphenate="true">{$node/text()}</fo:block>
    
    case element(tei:l)
        return
            
            (
            <fo:inline
                vertical-align="super"
                font-size="8pt">{
                    if ($node/tei:ref) then
                        <fo:basic-link
                            external-destination="{string($node/tei:ref/@target)}">{string($node/@n)}</fo:basic-link>
                    else
                        string($node/@n)
                }</fo:inline>,
            $node/text()
            )
    
    case element(tei:listBibl)
        return
        if($node/parent::tei:p) then (
      let $bibs :=  for $b in $node/tei:bibl
        return
          try{fo:zoteroCit($b/tei:ptr/@target)} 
            catch * {console:log($err:description)}
            return string-join($bibs, ', ')
        ) 
        else
            fo:tei2fo($node/node())
    
     case element(tei:bibl) return
     if($node/parent::tei:cit or $node/parent::tei:desc) 
     then (<fo:inline>({
            try{fo:zoteroCit($node/tei:ptr/@target)} 
            catch * {console:log($err:description)}}
            {if($node/tei:citedRange) then ', ' || (switch($node/tei:citedRange/@unit) 
            case 'paragraph' return '§' case 'page' return '' default return string($node/tei:citedRange/@unit))||$node/tei:citedRange/text() else ()})</fo:inline> )
     else 
            (<fo:inline> {
            try{fo:zoteroCit($node/tei:ptr/@target)} 
            catch * {console:log($err:description || string($node/tei:ptr/@target))}}
            {if($node/tei:citedRange) then ', ' || (let $citRanges := for $cR in $node/tei:citedRange 
                                                                                                                            let $unit := switch($cR/@unit) 
                                                                                                                                                    case 'paragraph' return '§' 
                                                                                                                                                    case 'footnote' return 'n.' 
                                                                                                                                                    case 'page' return ' ' 
                                                                                                                                                    default return (string($cR/@unit) || ' ')
                                                                                                                          return concat($unit, $cR/text()) 
                                                                                     return string-join($citRanges, ' ')) 
                                                                                     else ()}</fo:inline>)
            
    
    case element(tei:figure)
    return
(:    If your image is not dispalying well, remember to take a good screenshot and modify it to 300dpi.
if it does not fit to the page set the width attribute in the source file, as that is the one used to set the viewport size to which the image is adapted
:)
    <fo:block  hyphenate="true"
    id="{string(root($node)/tei:TEI/@xml:id)}{$node/tei:graphic/@xml:id}{generate-id($node)}"
    display-align="center" 
    >
    
    {for $g in $node/tei:graphic return
   (<fo:block hyphenate="true" text-align="center" margin-top="3mm" margin-bottom="3mm" page-break-inside="avoid" page-break-after="avoid">
   <fo:external-graphic 
                src="{let $base := base-uri($node) 
                              let $lastSlash := functx:index-of-string($base, '/')[last()]
                             return substring($base, 1, $lastSlash)}{$g/@url}" 
                content-width="scale-down-to-fit"
                width="{$g/@width}"
                scaling="uniform" 
                display-align="center"/>
                </fo:block>,
                <fo:block hyphenate="true" text-align="left" margin-bottom="0.3cm" font-size="smaller" margin-left="5mm" margin-right="5mm" page-break-before="avoid">
                {
                'Fig.' || (if(contains(string(root($node)/tei:TEI/@xml:id), 'intro')) then ' 0' else replace(string(root($node)/tei:TEI/@xml:id), 'chapter', ' ')) ||'.'||(count($g/preceding::tei:graphic) +1) || ' '}{fo:tei2fo($g/tei:desc)}
                </fo:block>)
                
                }
                
  </fo:block>
    case element(tei:head)
        return
            <fo:block hyphenate="true" page-break-after="avoid"
                id="{string(root($node)/tei:TEI/@xml:id)}{generate-id($node)}">
                {
                    if ($node/parent::tei:div[@type = 'chapter']) then
                        (attribute font-weight {'700'},
                            attribute margin-top {'12.5pt'},
                        attribute margin-bottom {'6.25pt'})
                    else
                        if ($node/parent::tei:div[@type = 'section']) then
                            (attribute font-weight {'700'},
                            attribute margin-top {'12.5pt'},
                            attribute margin-bottom {'3.1pt'}
                            )
                        else
                            ()
                }
                {
                    if ($node/parent::tei:div[@type = 'section'])
                    then
                        let $section := $node/parent::tei:div[@type = 'section'][tei:head]
                        let $parents := for $parent in $section/ancestor::tei:div
                                                        order by $parent/position() descending
                                                    return
                                                      count($parent/preceding-sibling::tei:div) + 1
                        return
                            concat(
                            string-join($parents, '.'),
                            '.',
                            count($section/preceding-sibling::tei:div[@type = 'section']) + 1
                            , ' ')
                    else
(:                    div type chapter:)
                        (let $p := $node/parent::tei:div
                        return
                        concat(count($p/preceding-sibling::tei:div) + 1, ' '))
                }
                {$node/text()}
            </fo:block>
    case element(tei:div)
        return
                        <fo:block  hyphenate="true">{if($node/@xml:id) then attribute id {string(root($node)/tei:TEI/@xml:id)||'#'||string($node/@xml:id)} else ()}{fo:tei2fo($node/node())}</fo:block>
    case element(tei:ab)
        return
            if ($node/@type = 'foundation') then
                (<fo:block
                hyphenate="true"
                    font-size="1.2em"
                    space-before="2mm"
                    space-after="3mm">{functx:capitalize-first(string($node/@type))}</fo:block>,
                <fo:block hyphenate="true">{fo:tei2fo($node/node())}</fo:block>)
            
            else
                if ($node/@type = 'history') then
                    <fo:block hyphenate="true">{fo:tei2fo($node/node())}</fo:block>
                else
                    fo:tei2fo($node/node()[not(name() = 'title')])
    
    case element(tei:desc)
        return
            fo:tei2fo($node/node())
    
    case element(tei:locus)
        return
            <fo:inline>{
                    '(' || (
                    if ($node/@from and $node/@to)
                    then
                        ('ff. ' || string($node/@from) || '-' || string($node/@to))
                    else
                        if ($node/@from) then
                            ('ff. ' || string($node/@from || ' and following'))
                        else
                            if ($node/@target) then
                                let $targets := if (contains($node/@target, ' ')) then
                                    for $t in tokenize($node/@target, ' ')
                                    return
                                        ('f. ' || substring-after($t, '#'))
                                else
                                    ('f. ' || substring-after(string($node/@target), '#'))
                                
                                return
                                    string-join($targets, ', ')
                            else
                                $node/text()
                    ) || ')'
                }</fo:inline>
    
    
    
    
    case element(tei:msItem)
        return
            <fo:block
            hyphenate="true"
                id="{string(root($node)/tei:TEI/@xml:id)}{generate-id($node)}"
                font-family="Ludolfus"
                space-after="2mm">
                {
                    if ($node/parent::tei:msItem) then
                        attribute start-indent {'10mm'}
                    else
                        ()
                }
                <fo:inline
                    font-weight="bold">{string($node/@xml:id)}: {fo:tei2fo($node/tei:title)}</fo:inline>
                {fo:tei2fo($node/node()[not(name() = 'title')])}
            </fo:block>
    
    case element(tei:incipit)
        return
            <fo:block
            hyphenate="true"
                margin-left="5mm"
                id="{string(root($node)/tei:TEI/@xml:id)}{generate-id($node)}"
                font-style="italic">
                {
                    if ($node/@xml:lang) then
                        if ($node/@xml:lang) then
                            fo:lang($node/@xml:lang)
                        else
                            ()
                    else
                        ()
                }
                <fo:inline
                    font-weight="bold"
                    font-family="Ludolfus">{functx:capitalize-first(string($node/name()))}: </fo:inline>
                {fo:tei2fo($node/node())}
            </fo:block>
    case element(tei:table)
        return
        
        <fo:table  inline-progression-dimension="auto" table-layout="auto" margin-bottom="5mm" margin-top="5mm">
{if($node/@rend) then attribute  font-size{$node/@rend} else ''}
<fo:table-header>
  <fo:table-row>
  {for $column in $node/tei:row[@role='label']//tei:cell
  return
    <fo:table-cell>
      <fo:block hyphenate="true" font-weight="bold">{$column/text()}</fo:block>
    </fo:table-cell>}
  </fo:table-row>
</fo:table-header>

<fo:table-body>
  {fo:tei2fo($node/tei:row[not(@role)])}
</fo:table-body>
</fo:table>
        
        case element(tei:row)
        return
        <fo:table-row margin-bottom="3mm">{fo:tei2fo($node/tei:cell)}</fo:table-row>
        
        case element(tei:cell)
        return
        <fo:table-cell margin-right="2mm"><fo:block>{fo:tei2fo($node/node())}</fo:block></fo:table-cell>
    case element(tei:explicit)
        return
            <fo:block
            hyphenate="true"
                margin-left="5mm"
                id="{string(root($node)/tei:TEI/@xml:id)}{generate-id($node)}"
                font-style="italic">
                {
                    if ($node/@xml:lang) then
                        fo:lang($node/@xml:lang)
                    else
                        ()
                }
                <fo:inline
                    font-weight="bold"
                    font-family="Ludolfus">{functx:capitalize-first(string($node/name()))}: </fo:inline>
                {fo:tei2fo($node/node())}
            </fo:block>
    case element(tei:colophon)
        return
            <fo:block
            hyphenate="true"
                margin-left="5mm"
                id="{string(root($node)/tei:TEI/@xml:id)}{generate-id($node)}"
                font-style="italic">
                {
                    if ($node/@xml:lang) then
                        fo:lang($node/@xml:lang)
                    else
                        ()
                }
                <fo:inline
                    font-weight="bold"
                    font-family="Ludolfus">{functx:capitalize-first(string($node/name()))}: </fo:inline>
                {fo:tei2fo($node/node())}
            </fo:block>
    
    case element(tei:author)
        return
            
            let $parts := for $w in tokenize($node/text(), ' ')
            return
                $w
            return
                (:                mock up small caps:)
                (for $p in $parts
                return
                    (<fo:inline>{upper-case(substring($p, 1, 1))}</fo:inline>,
                    <fo:inline
                        font-size="0.75em">{upper-case(substring($p, 2))}</fo:inline>,
                    if (index-of($parts, $p) = count($parts)) then
                        ()
                    else
                        ' '
                    ),
                  if($node/tei:affiliation) then ', ' || $node/tei:affiliation/text() else (),  
                if ($node/following-sibling::tei:author) then
                    ', '
                else
                    ())
                (:    xsl:fo here is correct but Apache FOP does not support font-variants, this needs to be parsed and change the font size:)
    case element(tei:measure)
        return
            <fo:inline>
                {$node/text()}
                {
                    if ($node/@type) then
                        (' ' || string($node/@type))
                    else
                        ()
                }
                {
                    if ($node/@unit) then
                        (' ' || string($node/@unit))
                    else
                        ()
                }
            
            </fo:inline>
    
    case element(tei:foreign)
        return
            <fo:inline font-style="italic">
            {if($node[@xml:lang ='gez']) then (attribute hyphenate {'false'}) else ()}
                {
                    if ($node/@xml:lang) then
                        fo:lang($node/@xml:lang)
                    else
                        ()
                }
                {$node//text()}
            </fo:inline>
    
    case element(tei:roleName)
        return
            <fo:inline>
                {$node//text()}
            </fo:inline>
     case element(tei:placeName)
     return
      <fo:inline id="{string(root($node)/tei:TEI/@xml:id)}{generate-id($node)}">{$node/text()}</fo:inline>
     case element(tei:persName)
     return
      <fo:inline id="{string(root($node)/tei:TEI/@xml:id)}{generate-id($node)}">{$node/text()} {if($node[@type='bm']) then '(ID:'||$node/@ref||')' else ()}</fo:inline>
    case element(tei:relation)
        return
            ()
    case element(tei:history)
        return
            ()
    case element(tei:bindingDesc)
        return
            ()
    case element(tei:msIdentifier)
        return
            ()
    case element(tei:decoDesc)
        return
            ()
    case element(tei:collation)
        return
            ()
    case element(tei:foliation)
        return
            ()
    case element(tei:sourceDesc)
        return
            ()
    case element(tei:summary)
        return
            ()
    case element(tei:binding)
        return
            ()
    case element(tei:additions)
        return
            ()
    case element(tei:publicationStmt)
        return
            ()
    case element(tei:abstract)
        return
            ()
    case element(tei:epigraph)
        return
            <fo:block-container font-size="smaller" 
margin-left="50mm" margin-top="10mm" margin-bottom="5mm"> <fo:block>{fo:tei2fo($node/node())}</fo:block></fo:block-container>
       case element(ex:egXML)
        return      
            <fo:block white-space="pre" font-size="smaller" margin-top="3mm" margin-bottom="3mm" line-height="11.5pt">
            {$node/node()}
            </fo:block>
             case element(tei:eg)
        return      
            <fo:block hyphenate="true" white-space="pre" font-size="smaller" margin-top="3mm" margin-bottom="3mm">
            {$node/node()}
            </fo:block>
       case element(tei:term)
        return      
            (<fo:inline font-size="smaller">↗</fo:inline>,
            <fo:inline id="{string(root($node)/tei:TEI/@xml:id)}{generate-id($node)}{$node/text()}">
            {$node/node()
            }</fo:inline>)
            case element(tei:code)
        return      
            <fo:inline font-family="Noto"  font-size="smaller">
            {$node/node()}
            </fo:inline>
       case element(tei:gi)
        return      
            <fo:inline font-family="Noto" font-size="smaller">
            &lt;{$node/node()}&gt;
            </fo:inline>
            case element(tei:tag)
        return      
            <fo:inline font-family="Noto" font-size="smaller">
            &lt;{$node/node()}&gt;
            </fo:inline>
            case element(tei:att)
        return      
            <fo:inline font-family="Noto" font-size="smaller">
            @{$node/node()}
            </fo:inline>
    case element()
        return
            fo:tei2fo($node/node())
    default
        return
            $node
};

(:~ produces the table of contents and the notes for the reader:)
declare function fo:table-of-contents() {
    <fo:page-sequence
            initial-page-number="auto-odd"
        master-reference="Aethiopica-master" format="i">
         <fo:static-content
                flow-name="rest-region-before-even">
        <fo:table>
                    <fo:table-column
                        column-width="30%"/>
                    <fo:table-column
                        column-width="40%"/>
                    <fo:table-column
                        column-width="30%"/>
                    
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block
                                hyphenate="true"
                                    text-align="right"></fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block
                                    text-align="center"
                                    font-size="9pt"
                                    font-family="Ludolfus">Table of Contents</fo:block>
                            </fo:table-cell>
                            <fo:table-cell><fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="right">
                                    <fo:page-number/>
                                    </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
            <fo:static-content
                flow-name="rest-region-before-odd">
        <fo:table>
                    <fo:table-column
                        column-width="30%"/>
                    <fo:table-column
                        column-width="40%"/>
                    <fo:table-column
                        column-width="30%"/>
                    
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="left"><fo:page-number/></fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block
                                    text-align="center"
                                    font-size="9pt"
                                    font-family="Ludolfus">Table of Contents</fo:block>
                            </fo:table-cell>
                            <fo:table-cell><fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="right">
                                    
                                    </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
              <fo:static-content
                flow-name="rest-region-before-first">
        <fo:table>
                    <fo:table-column
                        column-width="30%"/>
                    <fo:table-column
                        column-width="40%"/>
                    <fo:table-column
                        column-width="30%"/>
                    
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block
                                    text-align="right"></fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block
                                    text-align="center"
                                    font-size="9pt"
                                    font-family="Ludolfus"></fo:block>
                            </fo:table-cell>
                            <fo:table-cell><fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="right"></fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
          
            <fo:static-content
                flow-name="xsl-footnote-separator">
                <fo:block space-before="5mm" space-after="5mm">
                <fo:leader leader-length="30%" rule-thickness="0pt"/>
                </fo:block>
            </fo:static-content>
            
        <fo:flow
            flow-name="xsl-region-body"
            font-family="Ludolfus">
            <fo:block-container
                font-size="12pt"
                space-before="25.2pt"
                space-after="12.24pt"
                font-family="Ludolfus" 
                font-weight="700" 
                text-align="center" 
                display-align="center"><fo:block>Digital Humanities and Ethiopian Studies</fo:block>
<fo:block>Approaching Written Artefacts with Digital Methods</fo:block></fo:block-container>
            <fo:block
                font-size="12pt"
                space-before="25.2pt"
                space-after="12.24pt"
                font-family="Ludolfus" 
                font-weight="700" 
                text-align="center" 
                display-align="center">Table of Contents</fo:block>
               { for $r in (doc('/db/apps/DHEth/data/front/acknowledgement.xml')//tei:TEI, doc('/db/apps/DHEth/data/front/intro.xml')//tei:TEI)
                    return
                        <fo:block
                            text-align-last="justify"
                            space-after="1pt"
                            font-size="10.5pt"
                            font-family="Ludolfus" 
                            margin-bottom="0.5cm">
                            <fo:inline>{ ' ' || fo:tei2fo($r//tei:titleStmt/tei:title)}</fo:inline>
                            <fo:leader
                                leader-pattern="dots"/>
                            <fo:page-number-citation
                                ref-id="{string($r/@xml:id)}{generate-id($r//tei:titleStmt/tei:title)}"/>
                            
                        </fo:block>}
                        <fo:block
                            text-align-last="justify"
                            space-after="1pt"
                            font-size="10.5pt"
                            font-family="Ludolfus" 
                            margin-bottom="0.5cm">
                            <fo:inline>Bibliography</fo:inline>
                            <fo:leader
                                leader-pattern="dots"/>
                            <fo:page-number-citation
                                ref-id="GeneralBibliography"/>
                            
                        </fo:block>
            { for $r  in collection('/db/apps/DHEth/data/chapters')//tei:TEI
                     let $n := number(substring-after($r/@xml:id, 'chapter'))
                    order by $n
                    return
                        <fo:block
                            text-align-last="justify"
                            space-after="1pt"
                            font-size="10.5pt"
                            font-family="Ludolfus" >
                            <fo:inline font-weight="800">Chapter {$n}. { ' ' || fo:tei2fo($r//tei:titleStmt/tei:title)}</fo:inline>
                            <fo:leader
                                leader-pattern="dots"/>
                            <fo:page-number-citation
                                ref-id="{string($r/@xml:id)}{generate-id($r//tei:titleStmt/tei:title)}"/>
                            
                        </fo:block>
             
            }
            <fo:block  
                            margin-top="0.5cm"/>
             { for $r  in collection('/db/apps/DHEth/data/FAQ')//tei:TEI
                     return
                        <fo:block
                            text-align-last="justify"
                            space-after="1pt"
                            font-size="10.5pt"
                            font-family="Ludolfus">
                            <fo:inline font-weight="800">{fo:tei2fo($r//tei:titleStmt/tei:title)}</fo:inline>
                            <fo:leader
                                leader-pattern="dots"/>
                            <fo:page-number-citation
                                ref-id="{string($r/@xml:id)}{generate-id($r//tei:titleStmt/tei:title)}"/>
                            
                        </fo:block>
             
            }
            <fo:block
                            text-align-last="justify"
                            space-after="1pt"
                            font-size="10.5pt"
                            font-family="Ludolfus" 
                            margin-top="0.5cm">
                            <fo:inline >Cited Passages</fo:inline>
                            <fo:leader
                                leader-pattern="dots"/>
                            <fo:page-number-citation
                                ref-id="CitedPassages"/>
                            
                        </fo:block>
            <fo:block
                            text-align-last="justify"
                            space-after="1pt"
                            font-size="10.5pt"
                            font-family="Ludolfus" >
                            <fo:inline >Index of Persons</fo:inline>
                            <fo:leader
                                leader-pattern="dots"/>
                            <fo:page-number-citation
                                ref-id="IndexPersons"/>
                            
                        </fo:block>
                        <fo:block
                            text-align-last="justify"
                            space-after="1pt"
                            font-size="10.5pt"
                            font-family="Ludolfus" 
                             page-break-after="always"
                            >
                            <fo:inline>Index of Places</fo:inline>
                            <fo:leader
                                leader-pattern="dots"/>
                            <fo:page-number-citation
                                ref-id="IndexPlaces"/>
                            
                        </fo:block>
                        <fo:block
                font-size="12pt"
                space-before="25.2pt"
                space-after="12.24pt"
                font-family="Ludolfus" 
                font-weight="700" 
                text-align="center" 
                display-align="center">Notes for the reader</fo:block>
                        <fo:block
                            text-align-last="justify"
                            space-after="1pt"
                            font-size="10.5pt"
                            font-family="Ludolfus" hyphenate="true" language="en">
                            
                            <fo:block>Terms, especially abbreviations, which are preceeded by a <fo:inline font-size="smaller">↗</fo:inline> 
                            have a short definition in the Glossary at the end of the volume. These terms do not appear also in the Index but references to the pages where they are used are provided for each in the Glossary.</fo:block>
                            
                            <fo:block>The bibliography of this book is available in Zotero at <fo:basic-link external-destination="https://www.zotero.org/pietroliuzzo/items/collectionKey/Z5MQAVPK"/>.</fo:block>
                            
                            <fo:block>The code and the visualizations associated with this book are linked directly in the text where relevant. 
                            They are all available at the following link in a website which is bound to the present volume: <fo:basic-link
                            external-destination="https://pietroliuzzo.github.io/DHEth/">https://pietroliuzzo.github.io/DHEth/</fo:basic-link>.
                        </fo:block>
                        </fo:block>
        </fo:flow>
    </fo:page-sequence>
};

(:~ produces the bookmarks for the PDF navigation :)
declare function fo:bookmarks() {
    <fo:bookmark-tree>
    { for $r in (doc('/db/apps/DHEth/data/front/acknowledgement.xml')//tei:TEI, doc('/db/apps/DHEth/data/front/intro.xml')//tei:TEI)
                    return
                    <fo:bookmark
                        internal-destination="{string($r/@xml:id)}{generate-id($r//tei:titleStmt/tei:title)}">
                        <fo:bookmark-title> {$r//tei:titleStmt/tei:title/text()}</fo:bookmark-title>
                        </fo:bookmark>
                    }
    <fo:bookmark
                        internal-destination="GeneralBibliography">
                        <fo:bookmark-title>General Bibliography</fo:bookmark-title>
                        </fo:bookmark>
      { for $r at $p in collection('/db/apps/DHEth/data/chapters')//tei:TEI 
      let $n := number(substring-after($r/@xml:id, 'chapter'))
                    order by $n
                    return
                     <fo:bookmark
                        internal-destination="{string($r/@xml:id)}{generate-id($r//tei:titleStmt/tei:title)}">
                        <fo:bookmark-title> {$r//tei:titleStmt/tei:title/text()}</fo:bookmark-title>
                        </fo:bookmark>
                        
             
            }
            { for $r at $p in collection('/db/apps/DHEth/data/FAQ')//tei:TEI 
                    return
                     <fo:bookmark
                        internal-destination="{string($r/@xml:id)}{generate-id($r//tei:titleStmt/tei:title)}">
                        <fo:bookmark-title>{$r//tei:titleStmt/tei:title/text()}</fo:bookmark-title>
                        </fo:bookmark>
                        
             
            }
       <fo:bookmark
                        internal-destination="CitedPassages">
                        <fo:bookmark-title>Cited Passages</fo:bookmark-title>
                        </fo:bookmark>
       <fo:bookmark
                        internal-destination="IndexPlaces">
                        <fo:bookmark-title>Index of Places</fo:bookmark-title>
                        </fo:bookmark>
       <fo:bookmark
                        internal-destination="IndexPersons">
                        <fo:bookmark-title>Index of Persons</fo:bookmark-title>
                        </fo:bookmark>
    </fo:bookmark-tree>
};

(:~ produces the list of figures:)
declare function fo:list-of-images() {
    <fo:page-sequence
            initial-page-number="auto-odd"
        master-reference="Aethiopica-master" format="i">
         <fo:static-content
                flow-name="rest-region-before-even">
        <fo:table>
                    <fo:table-column
                        column-width="30%"/>
                    <fo:table-column
                        column-width="40%"/>
                    <fo:table-column
                        column-width="30%"/>
                    
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block
                                    text-align="right"></fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block
                                    text-align="center"
                                    font-size="9pt"
                                    font-family="Ludolfus">List of Figures</fo:block>
                            </fo:table-cell>
                            <fo:table-cell><fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="right">
                                    <fo:page-number/>
                                    </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
            <fo:static-content
                flow-name="rest-region-before-odd">
        <fo:table>
                    <fo:table-column
                        column-width="30%"/>
                    <fo:table-column
                        column-width="40%"/>
                    <fo:table-column
                        column-width="30%"/>
                    
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="left"><fo:page-number/></fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block
                                    text-align="center"
                                    font-size="9pt"
                                    font-family="Ludolfus">List of Figures</fo:block>
                            </fo:table-cell>
                            <fo:table-cell><fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="right">
                                    
                                    </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
              <fo:static-content
                flow-name="rest-region-before-first">
        <fo:table>
                    <fo:table-column
                        column-width="30%"/>
                    <fo:table-column
                        column-width="40%"/>
                    <fo:table-column
                        column-width="30%"/>
                    
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block
                                    text-align="right"></fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block
                                    text-align="center"
                                    font-size="9pt"
                                    font-family="Ludolfus"></fo:block>
                            </fo:table-cell>
                            <fo:table-cell><fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="right"></fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
          
            <fo:static-content
                flow-name="xsl-footnote-separator">
                <fo:block space-before="5mm" space-after="5mm">
                <fo:leader leader-length="30%" rule-thickness="0pt"/>
                </fo:block>
            </fo:static-content>
            
        <fo:flow
            flow-name="xsl-region-body"
            font-family="Ludolfus">
            <fo:block
                font-size="12pt"
                space-before="25.2pt"
                space-after="12.24pt"
                font-family="Ludolfus" 
                font-weight="700" 
                text-align="center" 
                display-align="center">List of Figures</fo:block>
               { for $FC in collection('/db/apps/DHEth/data')//tei:figure
               let $chapterNumber :=  if(contains(string(root($FC)/tei:TEI/@xml:id), 'intro')) then ' 0' 
                else replace(string(root($FC)/tei:TEI/@xml:id), 'chapter', ' ')
                
                group by $chapterNumber
                order by $chapterNumber
                return
                    for $F at $p in $FC
                    order by $p
                    return
                        <fo:block
                            text-align-last="justify"
                            space-after="1pt"
                            font-size="10.5pt"
                            font-family="Ludolfus" >
                            <fo:inline font-weight="bold">
                            {
                'Fig.' || (if(contains(string(root($F)/tei:TEI/@xml:id), 'intro')) then ' 0' 
                else replace(string(root($F)/tei:TEI/@xml:id), 'chapter', ' ')) ||'.'||
                (count($F/tei:graphic/preceding::tei:graphic) +1) || ' '}</fo:inline>
                <fo:inline>{fo:figDesc2fo($F/tei:graphic/tei:desc/node())}
                </fo:inline>
                            <fo:leader
                                leader-pattern="dots"/>
                            <fo:page-number-citation
                                ref-id="{string(root($F)/tei:TEI/@xml:id)}{$F/tei:graphic/@xml:id}{generate-id($F)}"/>
                            
                        </fo:block>}
        </fo:flow>
    </fo:page-sequence>
};

(:~ produces the General Bibliography, the Bibliography of Beta maṣāḥǝft entities and the Bibliography of Pleiades entities :)
declare function fo:bibliography(){                                
<fo:page-sequence
            initial-page-number="auto-odd"
            master-reference="Aethiopica-master"  format="i">
              <fo:static-content
                flow-name="rest-region-before-even">
        <fo:table>
                    <fo:table-column
                        column-width="30%"/>
                    <fo:table-column
                        column-width="40%"/>
                    <fo:table-column
                        column-width="30%"/>
                    
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block
                                    text-align="right"></fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block
                                    text-align="center"
                                    font-size="9pt"
                                    font-family="Ludolfus">Bibliography</fo:block>
                            </fo:table-cell>
                            <fo:table-cell><fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="right">
                                    <fo:page-number/>
                                    </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
            <fo:static-content
                flow-name="rest-region-before-odd">
        <fo:table>
                    <fo:table-column
                        column-width="30%"/>
                    <fo:table-column
                        column-width="40%"/>
                    <fo:table-column
                        column-width="30%"/>
                    
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="left"><fo:page-number/></fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block
                                    text-align="center"
                                    font-size="9pt"
                                    font-family="Ludolfus">Bibliography</fo:block>
                            </fo:table-cell>
                            <fo:table-cell><fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="right">
                                    
                                    </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
              <fo:static-content
                flow-name="rest-region-before-first">
        <fo:table>
                    <fo:table-column
                        column-width="30%"/>
                    <fo:table-column
                        column-width="40%"/>
                    <fo:table-column
                        column-width="30%"/>
                    
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block
                                    text-align="right"></fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block
                                    text-align="center"
                                    font-size="9pt"
                                    font-family="Ludolfus"></fo:block>
                            </fo:table-cell>
                            <fo:table-cell><fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="right"></fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
          
            <fo:static-content
                flow-name="xsl-footnote-separator">
                <fo:block space-before="5mm" space-after="5mm">
                <fo:leader leader-length="30%" rule-thickness="0pt"/>
                </fo:block>
            </fo:static-content>
            <fo:flow
                flow-name="xsl-region-body"
                font-size="10.5pt"
                line-height="12.5pt"
                font-family="Ludolfus"
                text-align="justify"
                hyphenate="true">
                
                
                        <fo:block-container page-break-after="always">
<fo:block id="GeneralBibliography"  font-size="12pt"
                        text-align="center"
                        font-weight='700'
                        margin-bottom="12.24pt"
                        margin-top="25.2pt">Bibliography</fo:block>,
                                <fo:block line-height="11pt" font-size="9pt">{fo:zoteroBibfromCitation()}</fo:block>
                                <!--DHeth-->
                                </fo:block-container>
                                 <fo:block-container page-break-after="always">
<fo:block id="BMBibliography"  font-size="12pt"
                        text-align="center"
                        font-weight='700'
                        margin-bottom="12.24pt"
                        page-break-after="avoid"
                        margin-top="25.2pt">Beta maṣāḥǝft Entities</fo:block>,
                                <fo:block line-height="11pt" font-size="9pt" >{fo:zoteroBib('834EY7Z3')}</fo:block>

                                </fo:block-container>
                                <fo:block-container page-break-after="always">
<fo:block id="PleiadesResources"  font-size="12pt"
                        text-align="center"
                        font-weight='700'
                        margin-bottom="12.24pt"
                        page-break-after="avoid"
                        margin-top="25.2pt">Pleiades Resources</fo:block>,
                                <fo:block line-height="11pt" font-size="9pt">{fo:zoteroBib('UC73ZPJS')}</fo:block>,

</fo:block-container>
                                </fo:flow>
                                
                                
                                </fo:page-sequence>
};
               
(:~ produces the indexes:)
declare function fo:indexes(){

(:              Could have used  fo:index-page-citation-list see       https://www.antennahouse.com/antenna1/wp-content/uploads/2018/02/index-page-citation-1.pdf:)
let $all := (collection('/db/apps/DHEth/data/chapters'), collection('/db/apps/DHEth/data/front'))
return
<fo:page-sequence
            initial-page-number="auto-odd"
            master-reference="Aethiopica-Indexes">
              <fo:static-content
                flow-name="rest-region-before-even">
        <fo:table>
                    <fo:table-column
                        column-width="30%"/>
                    <fo:table-column
                        column-width="40%"/>
                    <fo:table-column
                        column-width="30%"/>
                    
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block
                                    text-align="right"></fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block
                                    text-align="center"
                                    font-size="9pt"
                                    font-family="Ludolfus">Index</fo:block>
                            </fo:table-cell>
                            <fo:table-cell><fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="right">
                                    <fo:page-number/>
                                    </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
            <fo:static-content
                flow-name="rest-region-before-odd">
        <fo:table>
                    <fo:table-column
                        column-width="30%"/>
                    <fo:table-column
                        column-width="40%"/>
                    <fo:table-column
                        column-width="30%"/>
                    
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="left"><fo:page-number/></fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block
                                    text-align="center"
                                    font-size="9pt"
                                    font-family="Ludolfus">Index</fo:block>
                            </fo:table-cell>
                            <fo:table-cell><fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="right">
                                    
                                    </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
              <fo:static-content
                flow-name="rest-region-before-first">
        <fo:table>
                    <fo:table-column
                        column-width="30%"/>
                    <fo:table-column
                        column-width="40%"/>
                    <fo:table-column
                        column-width="30%"/>
                    
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block
                                    text-align="right"></fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block
                                    text-align="center"
                                    font-size="9pt"
                                    font-family="Ludolfus"></fo:block>
                            </fo:table-cell>
                            <fo:table-cell><fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="right"></fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
          
            <fo:static-content
                flow-name="xsl-footnote-separator">
                <fo:block space-before="5mm" space-after="5mm">
                <fo:leader leader-length="30%" rule-thickness="0pt"/>
                </fo:block>
            </fo:static-content>
            <fo:flow
                flow-name="xsl-region-body"
                font-size="10.5pt"
                line-height="12.5pt"
                font-family="Ludolfus"
                text-align="justify"
                hyphenate="true">
                
                
                        <fo:block-container text-align="justify">
<fo:block id="CitedPassages" text-align="justify">{(attribute font-weight {'700'},
                        attribute margin-top {'6.25pt'},
                        attribute margin-bottom {'6.25pt'})}Cited Passages</fo:block>,
                                {for $Attestation in $all//tei:ref[@cRef]
                                let $ref := $Attestation/@cRef
                                order by $Attestation/text()
                                group by $r := $ref 
                                return 
                                  <fo:block id="{$r}" text-align="justify">{
                                  for $atts in $Attestation
                                  let $name := $atts/text()
                                  group by $name
                                  return  <fo:block text-align-last="justify">
                                  <fo:inline font-style="italic">{$name}</fo:inline><fo:leader leader-pattern="dots"/>{
                                  for $att at $p in $atts return(
                                  <fo:page-number-citation
                                 ref-id="{string(root($att)/tei:TEI/@xml:id)}{generate-id($att)}"/>, 
                                 if($p = count($Attestation)) then () else '; ')}
                                 </fo:block>
                                 }</fo:block> }
                                </fo:block-container>
                                 <fo:block-container text-align="justify">
<fo:block id="IndexPersons" text-align="justify">{(attribute font-weight {'700'},
                        attribute margin-top {'6.25pt'},
                        attribute margin-bottom {'6.25pt'})}Index of Persons</fo:block>,
                                {for $personAttestation in $all//tei:persName
                                let $ref := $personAttestation/text()
                                order by $personAttestation/text()
                                group by $r := $ref 
                                return 
                                <fo:block text-align-last="justify"><fo:inline font-style="italic">{$r}</fo:inline><fo:leader leader-pattern="dots"/>{for $att at $p in $personAttestation return  (<fo:page-number-citation
                                 ref-id="{string(root($att)/tei:TEI/@xml:id)}{generate-id($att)}"/>, if($p = count($personAttestation)) then () else '; ') }</fo:block> }
                                </fo:block-container>
                                 <fo:block-container text-align="justify">
<fo:block id="IndexPlaces" text-align="justify">{(attribute font-weight {'700'},
                        attribute margin-top {'6.25pt'},
                        attribute margin-bottom {'6.25pt'})}Index of Places</fo:block>,
                                  {for $placeAttestation in $all//tei:placeName
                                let $ref := $placeAttestation/text()
                                order by $placeAttestation/text()
                                group by $r := $ref 
                                return 
                                <fo:block text-align-last="justify"><fo:inline font-style="italic">{$r}</fo:inline><fo:leader leader-pattern="dots"/>{for $att at $p in $placeAttestation return  (<fo:page-number-citation
                                ref-id="{string(root($att)/tei:TEI/@xml:id)}{generate-id($att)}"/>, if($p = count($placeAttestation)) then () else '; ') }</fo:block> }</fo:block-container>
                                </fo:flow>
                                </fo:page-sequence>
};

(:~ declares the structure of the book and ist main features, calling the previous functions to produce the various parts to the book.:)
declare function fo:main() {  
    <fo:root 
                language="en"
                hyphenate="true"
        xmlns:fo="http://www.w3.org/1999/XSL/Format"
        xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions">
        <fo:layout-master-set>
             <fo:page-sequence-master
                master-name="Aethiopica-master">
                <fo:repeatable-page-master-alternatives>
                    <fo:conditional-page-master-reference
                        page-position="first"
                        odd-or-even="odd"
                        master-reference="Aethiopica-chapter-first-odd"/>
                    <fo:conditional-page-master-reference
                        page-position="first"
                        odd-or-even="even"
                        master-reference="Aethiopica-chapter-first-even"/>
                    <fo:conditional-page-master-reference
                        page-position="rest"
                        odd-or-even="odd"
                        master-reference="Aethiopica-chapter-rest-odd"/>
                    <fo:conditional-page-master-reference
                        page-position="rest"
                        odd-or-even="even"
                        master-reference="Aethiopica-chapter-rest-even"/>
                </fo:repeatable-page-master-alternatives>
            </fo:page-sequence-master>
             <fo:page-sequence-master master-name="Aethiopica-Indexes">
            <fo:repeatable-page-master-alternatives>
                    <fo:conditional-page-master-reference
                        page-position="first"
                        odd-or-even="odd"
                        master-reference="Aethiopica-Indexes-first-odd"/>
                    <fo:conditional-page-master-reference
                        page-position="first"
                        odd-or-even="even"
                        master-reference="Aethiopica-Indexes-first-even"/>
                    <fo:conditional-page-master-reference
                        page-position="rest"
                        odd-or-even="odd"
                        master-reference="Aethiopica-Indexes-rest-odd"/>
                    <fo:conditional-page-master-reference
                        page-position="rest"
                        odd-or-even="even"
                        master-reference="Aethiopica-Indexes-rest-even"/>
                </fo:repeatable-page-master-alternatives>
            </fo:page-sequence-master>
             <fo:simple-page-master 
             
                page-height="297mm"
                page-width="210mm"
             master-name="Aethiopica-Indexes-rest-odd" 
             margin-top="45mm"
                margin-bottom="53mm"
                margin-left="45mm"
                margin-right="45mm">
                    <fo:region-body 
                    margin-top="37.5pt"
                    margin-bottom="37.5pt" 
                    column-count="2" column-gap="10mm" />
                      <fo:region-before
                    region-name="rest-region-before-odd"
                    extent="25pt"/>
                <fo:region-after
                    region-name="rest-region-after-odd"
                    extent="12.5pt"/>
                </fo:simple-page-master>
             <fo:simple-page-master 
             
                page-height="297mm"
                page-width="210mm"
             master-name="Aethiopica-Indexes-rest-even" 
             margin-top="45mm"
                margin-bottom="53mm"
                margin-left="45mm"
                margin-right="45mm">
                    <fo:region-body 
                    margin-top="37.5pt"
                    margin-bottom="37.5pt" 
                    column-count="2" column-gap="10mm" />
                       <fo:region-before
                    region-name="rest-region-before-odd"
                    extent="25pt"/>
                <fo:region-after
                    region-name="rest-region-after-odd"
                    extent="12.5pt"/>
                </fo:simple-page-master>
             <fo:simple-page-master 
             
                page-height="297mm"
                page-width="210mm"
             master-name="Aethiopica-Indexes-first-even" 
             margin-top="45mm"
                margin-bottom="53mm"
                margin-left="45mm"
                margin-right="45mm">
                    <fo:region-body 
                    margin-top="37.5pt"
                    margin-bottom="37.5pt" 
                    column-count="2" column-gap="10mm" />
                       
                <fo:region-after
                    extent="25pt"/>
                </fo:simple-page-master>
              <fo:simple-page-master 
             
                page-height="297mm"
                page-width="210mm"
             master-name="Aethiopica-Indexes-first-odd" 
             margin-top="45mm"
                margin-bottom="53mm"
                margin-left="45mm"
                margin-right="45mm">
                    <fo:region-body 
                    margin-top="37.5pt"
                    margin-bottom="37.5pt" 
                    column-count="2" column-gap="10mm" />
                      <fo:region-before
                    region-name="rest-region-before-first"
                    extent="25pt"/>
                <fo:region-after
                    region-name="rest-region-after-first"
                    extent="12.5pt"/>
                </fo:simple-page-master>
              <fo:simple-page-master
                page-height="297mm"
                page-width="210mm"
                master-name="Aethiopica-chapter-first-odd"
                margin-top="45mm"
                margin-bottom="53mm"
                margin-left="45mm"
                margin-right="45mm">
                <fo:region-body
                    
                    margin-top="37.5pt"
                    margin-bottom="37.5pt"/>
                <fo:region-before
                    region-name="rest-region-before-first"
                    extent="25pt"/>
                <fo:region-after
                    region-name="rest-region-after-first"
                    extent="12.5pt"/>
            </fo:simple-page-master>
              <fo:simple-page-master
                page-height="297mm"
                page-width="210mm"
                master-name="Aethiopica-chapter-first-even"
                margin-top="45mm"
                margin-bottom="53mm"
                margin-left="45mm"
                margin-right="45mm">
                <fo:region-body
                    margin-top="37.5pt"
                    margin-bottom="37.5pt"/>
                <fo:region-after
                    extent="25pt"/>
            </fo:simple-page-master>
              <fo:simple-page-master
                page-height="297mm"
                page-width="210mm"
                master-name="Aethiopica-chapter-rest-odd"
                margin-top="45mm"
                margin-bottom="53mm"
                margin-left="45mm"
                margin-right="45mm">
                <fo:region-body
                    margin-top="37.5pt"
                    margin-bottom="37.5pt"/>
                <fo:region-before
                    region-name="rest-region-before-odd"
                    extent="25pt"/>
                <fo:region-after
                    region-name="rest-region-after-odd"
                    extent="12.5pt"/>
            </fo:simple-page-master>
              <fo:simple-page-master
                page-height="297mm"
                page-width="210mm"
                master-name="Aethiopica-chapter-rest-even"
                margin-top="45mm"
                margin-bottom="53mm"
                margin-left="45mm"
                margin-right="45mm">
                <fo:region-body
                    margin-top="37.5pt"
                    margin-bottom="37.5pt"/>
                <fo:region-before
                    region-name="rest-region-before-even"
                    extent="25pt"/>
                <fo:region-after
                    region-name="rest-region-after-even"
                    extent="12.5pt"/>
            </fo:simple-page-master>
        </fo:layout-master-set>
        { fo:bookmarks()}     
        {fo:table-of-contents()}
        {fo:list-of-images()}
        {for $r in (doc('/db/apps/DHEth/data/front/acknowledgement.xml')//tei:TEI, doc('/db/apps/DHEth/data/front/intro.xml')//tei:TEI)
                    return
        <fo:page-sequence
            initial-page-number="auto-odd"
            master-reference="Aethiopica-master"  format="i">
              <fo:static-content
                flow-name="rest-region-before-even">
        <fo:table>
                    <fo:table-column
                        column-width="30%"/>
                    <fo:table-column
                        column-width="40%"/>
                    <fo:table-column
                        column-width="30%"/>
                    
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block
                                    text-align="right"></fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block
                                    text-align="center"
                                    font-size="9pt"
                                    font-family="Ludolfus">{$r//tei:titleStmt/tei:title/text()}</fo:block>
                            </fo:table-cell>
                            <fo:table-cell><fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="right">
                                    <fo:page-number/>
                                    </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
            <fo:static-content
                flow-name="rest-region-before-odd">
        <fo:table>
                    <fo:table-column
                        column-width="30%"/>
                    <fo:table-column
                        column-width="40%"/>
                    <fo:table-column
                        column-width="30%"/>
                    
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="left"><fo:page-number/></fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block
                                    text-align="center"
                                    font-size="9pt"
                                    font-family="Ludolfus">{$r//tei:titleStmt/tei:title/text()}</fo:block>
                            </fo:table-cell>
                            <fo:table-cell><fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="right">
                                    
                                    </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
              <fo:static-content
                flow-name="rest-region-before-first">
        <fo:table>
                    <fo:table-column
                        column-width="30%"/>
                    <fo:table-column
                        column-width="40%"/>
                    <fo:table-column
                        column-width="30%"/>
                    
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block
                                    text-align="right"></fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block
                                    text-align="center"
                                    font-size="9pt"
                                    font-family="Ludolfus"></fo:block>
                            </fo:table-cell>
                            <fo:table-cell><fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="right"></fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
          
            <fo:static-content
                flow-name="xsl-footnote-separator">
                <fo:block space-before="5mm" space-after="5mm">
                <fo:leader leader-length="30%" rule-thickness="0pt"/>
                </fo:block>
            </fo:static-content>
            <fo:flow
                flow-name="xsl-region-body"
                font-size="10.5pt"
                line-height="12.5pt"
                font-family="Ludolfus"
                text-align="justify"
                 hyphenate="true">
                
                
                        <fo:block-container>{
                                
                                fo:tei2fo($r/node()[name() != 'abstract'])
                 
                            }</fo:block-container>
               
                
            </fo:flow>
        </fo:page-sequence> }
       
        
        {
        fo:bibliography()
        }
        {
                    for $r in collection('/db/apps/DHEth/data/chapters')//tei:TEI
                    let $n := number(substring-after($r/@xml:id, 'chapter'))
                    order by $n
                    
                    return
        <fo:page-sequence
           
            master-reference="Aethiopica-master">
            {attribute  initial-page-number{if($n=1) then (1) else "auto-odd"}}
              <fo:static-content
                flow-name="rest-region-before-even">
        <fo:table>
                    <fo:table-column
                        column-width="30%"/>
                    <fo:table-column
                        column-width="40%"/>
                    <fo:table-column
                        column-width="30%"/>
                    
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block
                                    text-align="right"></fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block
                                    text-align="center"
                                    font-size="9pt"
                                    font-family="Ludolfus">{$r//tei:titleStmt/tei:title/text()}</fo:block>
                            </fo:table-cell>
                            <fo:table-cell><fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="right">
                                    <fo:page-number/>
                                    </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
            <fo:static-content
                flow-name="rest-region-before-odd">
        <fo:table>
                    <fo:table-column
                        column-width="30%"/>
                    <fo:table-column
                        column-width="40%"/>
                    <fo:table-column
                        column-width="30%"/>
                    
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="left"><fo:page-number/></fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block
                                    text-align="center"
                                    font-size="9pt"
                                    font-family="Ludolfus">{$r//tei:titleStmt/tei:title/text()}</fo:block>
                            </fo:table-cell>
                            <fo:table-cell><fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="right">
                                    
                                    </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
              <fo:static-content
                flow-name="rest-region-before-first">
        <fo:table>
                    <fo:table-column
                        column-width="30%"/>
                    <fo:table-column
                        column-width="40%"/>
                    <fo:table-column
                        column-width="30%"/>
                    
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block
                                    text-align="right"></fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block
                                    text-align="center"
                                    font-size="9pt"
                                    font-family="Ludolfus"></fo:block>
                            </fo:table-cell>
                            <fo:table-cell><fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="right"></fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
          
            <fo:static-content
                flow-name="xsl-footnote-separator">
                <fo:block space-before="5mm" space-after="5mm">
                <fo:leader leader-length="30%" rule-thickness="0pt"/>
                </fo:block>
            </fo:static-content>
            <fo:flow
                flow-name="xsl-region-body"
                font-size="10.5pt"
                line-height="12.5pt"
                font-family="Ludolfus"
                text-align="justify"
                hyphenate="true">
                
                
                        <fo:block-container>{fo:tei2fo($r/node())}</fo:block-container>
               
                
            </fo:flow>
        </fo:page-sequence> }
        {
                    for $r in collection('/db/apps/DHEth/data/FAQ')//tei:TEI
                    
                    return
        <fo:page-sequence
            initial-page-number="auto-odd"
            master-reference="Aethiopica-master">
              <fo:static-content
                flow-name="rest-region-before-even">
        <fo:table>
                    <fo:table-column
                        column-width="30%"/>
                    <fo:table-column
                        column-width="40%"/>
                    <fo:table-column
                        column-width="30%"/>
                    
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block
                                    text-align="right"></fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block
                                    text-align="center"
                                    font-size="9pt"
                                    font-family="Ludolfus">{$r//tei:titleStmt/tei:title/text()}</fo:block>
                            </fo:table-cell>
                            <fo:table-cell><fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="right">
                                    <fo:page-number/>
                                    </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
            <fo:static-content
                flow-name="rest-region-before-odd">
        <fo:table>
                    <fo:table-column
                        column-width="30%"/>
                    <fo:table-column
                        column-width="40%"/>
                    <fo:table-column
                        column-width="30%"/>
                    
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="left"><fo:page-number/></fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block
                                    text-align="center"
                                    font-size="9pt"
                                    font-family="Ludolfus">{$r//tei:titleStmt/tei:title/text()}</fo:block>
                            </fo:table-cell>
                            <fo:table-cell><fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="right">
                                    
                                    </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
              <fo:static-content
                flow-name="rest-region-before-first">
        <fo:table>
                    <fo:table-column
                        column-width="30%"/>
                    <fo:table-column
                        column-width="40%"/>
                    <fo:table-column
                        column-width="30%"/>
                    
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell>
                                <fo:block
                                    text-align="right"></fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block
                                    text-align="center"
                                    font-size="9pt"
                                    font-family="Ludolfus"></fo:block>
                            </fo:table-cell>
                            <fo:table-cell><fo:block
                                    font-size="9pt"
                                    font-family="Ludolfus"
                                    text-align="right"></fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:static-content>
          
            <fo:static-content
                flow-name="xsl-footnote-separator">
                <fo:block space-before="5mm" space-after="5mm">
                <fo:leader leader-length="30%" rule-thickness="0pt"/>
                </fo:block>
            </fo:static-content>
            <fo:flow
                flow-name="xsl-region-body"
                font-size="10.5pt"
                line-height="12.5pt"
                font-family="Ludolfus"
                text-align="justify"
                hyphenate="true">
                        <fo:block-container>{fo:tei2fo($r/node())}</fo:block-container>
               </fo:flow>
        </fo:page-sequence> }
       {fo:indexes()}
       </fo:root>
};

(:here fo:main() is called to produce the xslfo which is passed to the function render of the xslfo module
to produce the PDF and the result is streamed so that pointing the browser to this module, the
Xquery is run and the result produced and sent for download:)
let $pdf := xslfo:render(fo:main(), "application/pdf", (), $local:fop-config)
return
    response:stream-binary($pdf, "media-type=application/pdf", "DHEth.pdf")
