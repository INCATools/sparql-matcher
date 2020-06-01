# sparql-matcher

Performs entity matching / ontology alignment using SPARQL queries.

## Methods

We first pre-index the ontology by creating skos Concepts for
normalized lexical entities. Thus "foo-1", "foo 1" and "FOO 1" would
all be the same skos Concept.

We then query for all pairs of classes that share the same skos Concept

This can then be queried to generate a SSSOM file

## Updates and Queries

See the [sparql/](sparql/) directory

## Execution

 * [local-sparql-match.sh](scripts/local-sparql-match.sh)
    * runs on local files
    * uses chained ROBOT update queries
 * [sparql-match.py](scripts/sparql-match.py)
    * runs against a (writeable) SPARQL endpoint
    * currently blazegraph assumed


