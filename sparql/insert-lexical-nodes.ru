prefix skos: <http://www.w3.org/2004/02/skos/core#>
prefix oio: <http://www.geneontology.org/formats/oboInOwl#>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix sssom: <http://purl.org/sssom/meta/>
prefix src_predicate: <http://purl.org/sssom/meta/subject_source_field>
prefix iao_alternative_term: <http://purl.obolibrary.org/obo/IAO_0000118>
prefix iao_definition: <http://purl.obolibrary.org/obo/IAO_0000115>
prefix prov: <http://www.w3.org/ns/prov#>
       
INSERT {

   # -- Declarations --
   # (required for OWLAPI)
   skos:hiddenLabel a owl:AnnotationProperty .
   rdfs:seeAlso a owl:AnnotationProperty .
   src_predicate: a owl:AnnotationProperty .
   prov:wasGeneratedBy a owl:ObjectProperty .
   prov:wasAttributedTo a owl:ObjectProperty .
   prov:wasAssociatedWith a owl:ObjectProperty .
   prov:wasDerivedFrm a owl:AnnotationProperty .

  # -- Main Generated Triple --
  # connects an entity with a concept node,
  # where the concept node is a normalized form of one
  # of the literal annotations
  ?entity ?normalizedProperty ?conceptNode .

  # -- Inject concept node ---
  ?conceptNode a skos:Concept ;
       rdfs:label ?lit ;
       prov:wasDerivedFrom ?entity ;
       prov:wasGeneratedBy ?activity ;
       prov:wasAttributedTo ?agent .
       
  # -- Reification ---
  [rdf:type owl:Axiom ;
   owl:annotatedSource ?entity ;
   owl:annotatedProperty ?normalizedProperty ;
   owl:annotatedTarget ?conceptNode ;
   skos:hiddenLabel ?lit ;
   src_predicate: ?origProperty
  ] .

  # -- Provenance --
  ?activity a prov:Activity ;
      rdfs:label "Execution of sparql-matcher"@en ;
      prov:startedAtTime ?now ;
      prov:endedAtTime ?now ;
      prov:wasAssociatedWith ?agent ;
      rdfs:comment "hello" .

}
WHERE {
  # -- Main Source Triple --
  ?entity ?origProperty ?lit .
  FILTER isLiteral(?lit) .

  ## -- String Normalization --
  BIND( uri( concat("token:",
                    encode_for_uri(
                       replace(lcase(?lit),
                               "[^a-z0-9]",
                               "-"))))
        AS ?conceptNode )

  # -- Predicate Normalization --
  VALUES (?origProperty ?normalizedProperty) {
     (rdfs:label skos:prefLabel)
     (skos:prefLabel skos:prefLabel)
     
     (iao_alternative_term: skos:relatedMatch)
     
     (oio:hasExactSynonym skos:exactMatch)
     (oio:hasBroadSynonym skos:broadMatch)
     (oio:hasNarrowSynonym skos:narrowMatch)
     (oio:hasRelatedSynonym skos:relatedMatch)
     
     (skos:exactMatch skos:exactMatch)
     (skos:broadMatch skos:broadMatch)
     (skos:narrowMatch skos:narrowMatch)
     (skos:relatedMatch skos:relatedMatch)
     
     (oio:hasDbXref oio:hasDbXref)

     (iao_definition: skos:definition)
     (skos:definition skos:definition)

  }

  ?this a owl:Ontology .
  BIND(
     uri( concat("md5:",
                 "Activity",
                 md5(str(?this))))
     AS ?activity)
  BIND(
     uri( concat("md5:",
                 "Agent",
                 md5(str(?this))))
     AS ?agent)
  BIND( now() as ?now )
}
