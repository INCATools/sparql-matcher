prefix skos: <http://www.w3.org/2004/02/skos/core#>
prefix oio: <http://www.geneontology.org/formats/oboInOwl#>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix sm: <http://purl.org/sssom/meta/>
prefix st: <http://purl.org/sssom/type/>
prefix src_predicate: <http://purl.org/sssom/meta/subject_source_field>
prefix dcterms: <http://purl.org/dc/terms/>
prefix sh: <http://www.w3.org/ns/shacl#>

INSERT {
  ?x dcterms:source ?src
}
WHERE {
 ?x a ?xType .
 FILTER ( strStarts( str(?x), ?ns) )
 [ sh:declare
   [ sh:namespace ?ns ;
     sh:prefix ?src
   ]
 ] .
}

