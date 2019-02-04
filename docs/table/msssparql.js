$(document).on('ready', function () {

var SNAPquery = " SELECT DISTINCT ?manuscript ?patron ?relation ?ruler \
    WHERE{ \
      ?annotation a bm:patron ; \
oa:hasTarget ?manuscript ; \
oa:hasBody ?patron . \
?manuscript a bm:mss . \
?patron snap:hasBond ?bondName . \
?bondName rdf:type ?relation ; \
snap:bond-with ?ruler . \
?ruler snap:occupation 'Emperor' . \
}"

var tablediv = $("#sparqlTable")

var apicall = 'http://betamasaheft.eu/api/SPARQL/json?query=' + encodeURIComponent(query)

    $.getJSON(apicall, function (sparqlresult) {
    //console.log(sparqlresult)

               //console.log(table)
       var results = sparqlresult.results.bindings
       var reslength = results.length
       console.log(reslength)
       var table = $('<table class="table table-responsive"><thead><tr><th>Manuscript</th><th>Patron</th><th>Relation</th><th>Ruler</th></tr></thead><tbody></tbody></table>')

            $(results).each(function(i){
                   var row = "<tr><td><b>" + ""
                              + "</b></td><td>" +
                              "" + "</td></tr>";
                   table.append(row)
               }

tablediv.append(table)
      })

});
