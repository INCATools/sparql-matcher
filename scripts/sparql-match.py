#!/usr/bin/env python3

import click
import requests
import logging
import subprocess
from SPARQLWrapper import SPARQLWrapper, JSON

logging.basicConfig(level=logging.INFO)

url = 'http://localhost:8889/bigdata'
qurl = 'http://localhost:8889/bigdata/sparql'

sparql_prefixes = """
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
"""

@click.group()
#@click.option('-u', '--url', default=url)
def cli():
    pass

@cli.command()
@click.argument('inputs', nargs=-1)
def insert(inputs):
    """
    sparql insert
    """
    for f in inputs:
        sparql_insert_from_file(f)

@cli.command()
@click.argument('inputs', nargs=-1)
def load(inputs):
    """
    sparql insert
    """
    for f in inputs:
        fmt = 'turtle'
        if f.endswith('.owl'):
            fmt = 'rdfxml'
        sparql_load(f, format=fmt)

@cli.command()
def list_sources():
    """
    summarize
    """
    run_sparql("SELECT * WHERE {?x dcterms:source ?y}")
        
@cli.command()
def prefixes():
    """
    prefixes
    """
    run_sparql("SELECT * WHERE { [ sh:prefix ?p ; sh:namespace ?ns ] }")
        
@cli.command()
def summarize():
    """
    summarize
    """
    print("SOURCES")
    run_sparql("""
    SELECT ?src (count(distinct ?x) as ?num_entities)
    WHERE {?x dcterms:source ?src}
    GROUP BY ?src
    """)
    print("SIZE")
    run_sparql("""
    SELECT (count(distinct ?x) as ?num_entities)
    WHERE {?x a ?xt}
    """)

@cli.command()
def matches():
    """
    summarize
    """
    print("MATCHES")
    run_sparql("""
    SELECT ?src count(distinct ?m) as ?num_matches)
    WHERE {?x dcterms:source ?src . ?m sm:subject_id ?x}
    GROUP BY ?src
    """)
        

def sparql_insert_from_file(f):
    cmd = f'curl -X POST -d "@{f}"  -H "Content-Type: application/sparql-update" {qurl}'
    runcmd(cmd)

def sparql_load(f, format='turtle'):
    h = 'Content-Type: text/turtle'
    if format == 'rdfxml':
        h = 'Content-Type: application/rdf+xml'
    cmd = f'curl -X POST --upload-file {f}  -H "{h}" {qurl}'
    runcmd(cmd)

def run_sparql(q):
    # TODO: select endpoint based on ontology
    #sparql = SPARQLWrapper("http://rdf.geneontology.org/sparql")
    logging.info("Connecting to sparql endpoint...")
    sparql = SPARQLWrapper(qurl)
    logging.debug("Made wrapper: {}".format(sparql))
    # TODO: iterate over large sets?
    qstr = f'{sparql_prefixes} {q}'
    logging.debug(f'Q={qstr}')
    sparql.setQuery(qstr)
    sparql.setReturnFormat(JSON)
    logging.info("Query: {}".format(q))
    results = sparql.query().convert()
    bindings = results['results']['bindings']
    logging.info("Rows: {}".format(len(bindings)))
    for r in bindings:
        vals = [v['value'] for k,v in r.items()]
        print(f'ROW: {vals}')
        #print(f'ROW: {r}')
    
def runcmd(cmd):
    logging.info("RUNNING: {}".format(cmd))
    p = subprocess.Popen([cmd], stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    (out, err) = p.communicate()
    logging.info('OUT: {}'.format(out))
    if err:
        logging.info(f'STDERR: {err}')
    if p.returncode != 0:
        raise Exception('Failed: {}'.format(cmd))
    
                
if __name__ == "__main__":
    cli()
    
