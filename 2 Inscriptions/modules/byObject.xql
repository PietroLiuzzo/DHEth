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
let $objects := distinct-values($dataset/ancestor::t:TEI//t:objectType/@ref)
let $objectLabels := for $m in $objects return  doc(concat($config:data-root, '/EAGLEvoc/eagle-vocabulary-object-type.rdf'))//skos:Concept[@rdf:about = $m]/skos:prefLabel/text()
let $headings := ('objects', $objectLabels)
let $head:='["'||string-join($headings, '","') ||'"]'
let $selector := '$dataset/ancestor::t:TEI//t:' || $element || '/@ref'
let $selection := util:eval($selector)
let $items := for $item in distinct-values($selection)
                             let $start := if(starts-with($item, 'http:')) then replace($item, 'http:', 'https:') else $item

                            let $M := doc(concat($config:data-root, '/EAGLEvoc/eagle-vocabulary-',$vocabulary,'.rdf'))//skos:Concept[@rdf:about = $start]
                            let $Mlabel := $M/skos:prefLabel/text()
                            return map{'label':= $Mlabel, 'uri' := $item}
let $rows := for $item in $items
                         let $counts := for $obj in $objects
                                                       let $selector :=  '$dataset/ancestor::t:TEI[descendant::t:' || $element || '[@ref=$item("uri")]][descendant::t:objectType[@ref=$obj]]'
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
            title: '"||$name||" by object type "||$datasetname||"',
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
      <div class="col-md-12" xmlns="http://www.w3.org/1999/xhtml" id="{$name}byLang_{$datasetname}" style="height:500px;"/>
      </div>
};
        
let $EAGLE300to700 := collection(concat($config:data-root, '/EAGLE'))//t:origDate[@notBefore-custom ge 0300][@notAfter-custom le 0700]
let $ISicily300to700 := collection(concat($config:data-root, '/ISicily'))//t:origDate[@notBefore-custom ge 0300][@notAfter-custom le 0700]
let $TM300to700 := collection(concat($config:data-root, '/trismegistos'))//t:origDate[@notBefore-custom ge 0300][@notAfter-custom le 0700]
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
for $datasetname in ('EAGLE', 'trismegistos', 'ISicily', 'Ethio')
let $dataset := switch($datasetname)
case 'EAGLE' return $EAGLE300to700
case 'ISicily' return $ISicily300to700
case 'trismegistos' return $TM300to700
default return $Ethio300to700
return
<div class="col-md-12">
<p class="lead">{$datasetname} (total inscriptions 300 to 700 CE: {count($dataset)})</p>
{(

let $table := local:indexKeys($dataset, $datasetname,'material','material')
return
local:chart('material', $datasetname, $table),
let $table := local:indexKeys($dataset, $datasetname,'writing','rs[@type="execution"]')
return
local:chart('execution', $datasetname, $table),
let $table := local:indexKeys($dataset, $datasetname,'type-of-inscription','term')
return
local:chart('type', $datasetname, $table)
)}</div>}
  </body>
</html>
        

