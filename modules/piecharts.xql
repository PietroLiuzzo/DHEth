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

declare function local:indexKeys($dataset, $datasetname, $vocabulary, $indexName){
let $start := if(($vocabulary = 'writing') and ($datasetname != 'Ethio')) then 'http://www.eagle-network.eu/voc/writing/' else ()
return
$dataset/$local:range-lookup($indexName, $start,
        function($key, $count) {
        let $K := replace($key, 'http:', 'https:')
        let $name := doc(concat($config:data-root, '/EAGLEvoc/eagle-vocabulary-',$vocabulary,'.rdf'))//skos:Concept[@rdf:about = $K]
        let $N := $name/skos:prefLabel/text()
        return
         '["' ||  $N || '", ' ||  $count[2] || ']'
        }, 1000)
        };
        
declare function local:chart($name, $datasetname, $table){
<div xmlns="http://www.w3.org/1999/xhtml">
<script xmlns="http://www.w3.org/1999/xhtml" type="text/javascript">
      {'google.charts.load("current", {packages:["corechart"]});
        google.charts.setOnLoadCallback(drawChart);
        function drawChart() {
          var data = google.visualization.arrayToDataTable(' ||
          $table
         || "]);

          var options = {
            title: '"||$name||" breakdown for "||$datasetname||"'
          };

          var chart = new google.visualization.PieChart(document.getElementById('"||$name||"pie_"||$datasetname||"'));
          chart.draw(data, options);
        }"

        }

      </script>
      <div   class="col-md-3" xmlns="http://www.w3.org/1999/xhtml" id="{$name}pie_{$datasetname}" style="height:500px;"/>
      </div>
      
};
        
let $EAGLE300to700 := collection(concat($config:data-root, '/EAGLE'))//t:origDate[@notBefore-custom gt 0300][@notAfter-custom lt 0700]
let $AGP300to700 := collection(concat($config:data-root, '/EAGLE/AGP'))//t:origDate[@notBefore-custom gt 0300][@notAfter-custom lt 0700]
let $Ausonius300to700 := collection(concat($config:data-root, '/EAGLE/AUSONIUS'))//t:origDate[@notBefore-custom gt 0300][@notAfter-custom lt 0700]
let $BSR300to700 := collection(concat($config:data-root, '/EAGLE/BSR'))//t:origDate[@notBefore-custom gt 0300][@notAfter-custom lt 0700]
let $EDB300to700 := collection(concat($config:data-root, '/EAGLE/EDB'))//t:origDate[@notBefore-custom gt 0300][@notAfter-custom lt 0700]
let $EDR300to700 := collection(concat($config:data-root, '/EAGLE/EDR'))//t:origDate[@notBefore-custom gt 0300][@notAfter-custom lt 0700]
let $EDH300to700 := collection(concat($config:data-root, '/EAGLE/edh'))//t:origDate[@notBefore-custom gt 0300][@notAfter-custom lt 0700]
let $LSA300to700 := collection(concat($config:data-root, '/EAGLE/LSA'))//t:origDate[@notBefore-custom gt 0300][@notAfter-custom lt 0700]
let $RIB300to700 := collection(concat($config:data-root, '/EAGLE/RIB'))//t:origDate[@notBefore-custom gt 0300][@notAfter-custom lt 0700]
let $ISicily300to700 := collection(concat($config:data-root, '/ISicily'))//t:origDate[@notBefore-custom gt 0300][@notAfter-custom lt 0700]
let $AshLI300to700 := (
collection(concat($config:data-root, '/EAGLE/AshLI'))//t:origDate[xs:integer(@notBefore) gt 0300][xs:integer(@notAfter) lt 0700],

collection(concat($config:data-root, '/EAGLE/AshLI'))//t:origDate[xs:integer(@when) gt 0300][xs:integer(@when) lt 0700]
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
for $datasetname in ('Ethio','ISicily','EAGLE','BSR','EDB','EDH','EDR','LSA','RIB', 'Ausonius', 'AshLI')
let $dataset := switch($datasetname)
case 'EAGLE' return $EAGLE300to700
case 'Ausonius' return $Ausonius300to700
case 'ISicily' return $ISicily300to700
case 'AGP' return $AGP300to700
case 'BSR' return $BSR300to700
case 'EDH' return $EDH300to700
case 'EDB' return $EDB300to700
case 'EDR' return $EDR300to700
case 'LSA' return $LSA300to700
case 'AshLI' return $AshLI300to700
case 'RIB' return $RIB300to700
case 'ISicily' return $ISicily300to700
default return $Ethio300to700
return
<div class="col-md-12">
<p class="lead">{$datasetname} (total inscriptions 300 to 700 CE: {count($dataset)})</p>
{(
let $rows :=( '[["material","quantity"]',
local:indexKeys($dataset, $datasetname,'material','materialRef'))
let $table := string-join($rows, ',
')
return
local:chart('material', $datasetname, $table)
,
let $rows :=('[["object type","quantity"]',
local:indexKeys($dataset, $datasetname,'object-type','objRef'))
let $table := string-join($rows, ',
')
return
local:chart('objectType', $datasetname, $table),
let $rows :=('[["execution tecnique","quantity"]',
local:indexKeys($dataset, $datasetname,'writing','rsRef'))
let $table := string-join($rows, ',
')
return
local:chart('execution', $datasetname, $table),
let $rows :=('[["type of inscription","quantity"]',
local:indexKeys($dataset, $datasetname,'type-of-inscription','termRef'))
let $table := string-join($rows, ',
')
return
local:chart('type', $datasetname, $table)
)}</div>}
  </body>
</html>
        

