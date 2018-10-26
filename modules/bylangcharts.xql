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

declare function local:indexKeys($dataset, $datasetname, $vocabulary, $element){
let $languagesSelector := if($datasetname = 'Ethio' or $datasetname = 'ISicily' or $datasetname = 'trismegistos' ) then distinct-values($dataset/ancestor::t:TEI//t:language/@ident) else distinct-values($dataset/ancestor::t:TEI//t:div[@type='edition']/@xml:lang)
let $languages := for $lang in $languagesSelector
                           return if($lang='en' or $lang='it' or $lang='de') then () else $lang
let $headings := ('languages', $languages)
let $head:='["'||string-join($headings, '","') ||'"]'
let $selector := '$dataset/ancestor::t:TEI//t:' || $element || '/@ref'
let $selection := util:eval($selector)
let $items := for $item in distinct-values($selection)
                             let $start := if(starts-with($item, 'http:')) then replace($item, 'http:', 'https:') else $item

                            let $M := doc(concat($config:data-root, '/EAGLEvoc/eagle-vocabulary-',$vocabulary,'.rdf'))//skos:Concept[@rdf:about = $start]
                            let $Mlabel := $M/skos:prefLabel/text()
                            return map{'label':= $Mlabel, 'uri' := $item}
let $rows := for $item in $items
                         let $counts := for $lang in $languages
                                                       let $selector := if($datasetname = 'Ethio' or $datasetname = 'ISicily' or $datasetname = 'trismegistos' ) 
                                                       then '$dataset/ancestor::t:TEI[descendant::t:' || $element || '[@ref=$item("uri")]][descendant::t:language[@ident = $lang]]' else 
                                                       '$dataset/ancestor::t:TEI[descendant::t:' || $element || '[@ref=$item("uri")]][descendant::t:div[@type="edition"][@xml:lang = $lang]]'
                                                       let $selection := util:eval($selector)
                                                        return
                                                        count($selection)
                        
                        return
                       '["' || $item('label') ||'",'|| string-join($counts, ',') || ']'
 let $data := ($head,$rows)
 
return
'[' || string-join($data, ',') || ']'
};
        
declare function local:chart($name, $datasetname, $table){
<div xmlns="http://www.w3.org/1999/xhtml">
<script xmlns="http://www.w3.org/1999/xhtml" type="text/javascript">
      {'google.charts.load("current", {packages:["corechart"]});
        google.charts.setOnLoadCallback(drawChart);
        function drawChart() {
          var data = google.visualization.arrayToDataTable(' ||
          $table
         || ");

          var options = {
            title: '"||$name||" by language "||$datasetname||"',
       isStacked: true,
          height: 300,
          legend: {position: 'top', maxLines: 3},
          vAxis: {minValue: 0}
      };

          var chart = new google.visualization.ColumnChart(document.getElementById('"||$name||"byLang_"||$datasetname||"'));
          chart.draw(data, options);
        }"

        }

      </script>
      <div class="col-md-3" xmlns="http://www.w3.org/1999/xhtml" id="{$name}byLang_{$datasetname}" style="height:500px;"/>
      </div>
};
        
let $EAGLE300to700 := collection(concat($config:data-root, '/EAGLE'))//t:origDate[@notBefore-custom ge 0300][@notAfter-custom le 0700]
let $AGP300to700 := collection(concat($config:data-root, '/EAGLE/AGP'))//t:origDate[@notBefore-custom ge 0300][@notAfter-custom le 0700]
let $Ausonius300to700 := collection(concat($config:data-root, '/EAGLE/AUSONIUS'))//t:origDate[@notBefore-custom ge 0300][@notAfter-custom le 0700]
let $BSR300to700 := collection(concat($config:data-root, '/EAGLE/BSR'))//t:origDate[@notBefore-custom ge 0300][@notAfter-custom le 0700]
let $EDB300to700 := collection(concat($config:data-root, '/EAGLE/EDB'))//t:origDate[@notBefore-custom ge 0300][@notAfter-custom le 0700]
let $EDH300to700 := collection(concat($config:data-root, '/EAGLE/edh'))//t:origDate[@notBefore-custom ge 0300][@notAfter-custom le 0700]
let $EDR300to700 := collection(concat($config:data-root, '/EAGLE/EDR'))//t:origDate[@notBefore-custom ge 0300][@notAfter-custom le 0700]
let $LSA300to700 := collection(concat($config:data-root, '/EAGLE/LSA'))//t:origDate[@notBefore-custom ge 0300][@notAfter-custom le 0700]
let $RIB300to700 := collection(concat($config:data-root, '/EAGLE/RIB'))//t:origDate[@notBefore-custom ge 0300][@notAfter-custom le 0700]
let $ISicily300to700 := collection(concat($config:data-root, '/ISicily'))//t:origDate[@notBefore-custom ge 0300][@notAfter-custom le 0700]
let $TM300to700 := collection(concat($config:data-root, '/trismegistos'))//t:origDate[@notBefore-custom ge 0300][@notAfter-custom le 0700]
let $AshLI300to700 := (
collection(concat($config:data-root, '/EAGLE/AshLI'))//t:origDate[xs:integer(@notBefore) ge 0300][xs:integer(@notAfter) le 0700],

collection(concat($config:data-root, '/EAGLE/AshLI'))//t:origDate[xs:integer(@when) ge 0300][xs:integer(@when) le 0700]
)
let $Ethio300to700 := collection(concat($config:data-root, '/Ethiopic'))//t:origDate

return
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous"></link>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    </head>
 <body>
    {
for $datasetname in ('Ethio','ISicily','EAGLE','BSR','EDB','EDH','EDR','LSA','RIB', 'Ausonius', 'AshLI','trismegistos')
let $dataset := switch($datasetname)
case 'EAGLE' return $EAGLE300to700
case 'Ausonius' return $Ausonius300to700
case 'ISicily' return $ISicily300to700
case 'AshLI' return $AshLI300to700
case 'BSR' return $BSR300to700
case 'EDB' return $EDB300to700
case 'EDH' return $EDH300to700
case 'EDR' return $EDR300to700
case 'LSA' return $LSA300to700
case 'RIB' return $RIB300to700
case 'ISicily' return $ISicily300to700
case 'trismegistos' return $TM300to700
default return $Ethio300to700
return
<div class="col-md-12">
<p class="lead">{$datasetname} (total inscriptions 300 to 700 CE: {count($dataset)})</p>
{(

let $table := local:indexKeys($dataset, $datasetname,'material','material')
return
local:chart('material', $datasetname, $table)
,
let $table := local:indexKeys($dataset, $datasetname,'object-type','objectType')
return
local:chart('objectType', $datasetname, $table),
let $table := local:indexKeys($dataset, $datasetname,'writing','rs[@type="execution"]')
return
local:chart('execution', $datasetname, $table),
let $table := local:indexKeys($dataset, $datasetname,'type-of-inscription','term')
return
local:chart('type', $datasetname, $table)
)}</div>}
  </body>
</html>
        

