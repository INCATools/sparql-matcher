prefix skos: <http://www.w3.org/2004/02/skos/core#>
prefix oio: <http://www.geneontology.org/formats/oboInOwl#>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix sm: <http://purl.org/sssom/meta/>
prefix st: <http://purl.org/sssom/type/>
prefix src_predicate: <http://purl.org/sssom/meta/subject_source_field>
prefix dcterms: <http://purl.org/dc/terms/>

INSERT {
  sm:predicate_id a owl:AnnotationProperty .
  [
   a st:Match ;
   sm:predicate_id owl:equivalentClasses ;
   sm:subject_id ?s ;
   sm:subject_match_field ?sp ;
   sm:object_id ?o ;
   sm:object_match_field ?op ;
   sm:match_type st:Lexical ;   # TODO - stemming etc
   sm:confidence 1.0 ;   # TODO - rules
   sm:match_string ?match_str
  ]
}
WHERE {
  ?s ?sp ?concept ;
     dcterms:source ?ss ;
     a ?sType .
  ?o ?op ?concept ;
     dcterms:source ?os ;
     a ?oType .
  ?concept a skos:Concept .


  FILTER(?s != ?o)
  FILTER(?ss != ?os)
  FILTER(isIRI(?s))
  FILTER(isIRI(?o))

  BIND(str(?concept) as ?match_str)
}
