#!/bin/sh

set -x # echo on

extra_inputs=
tmpdir=$(mktemp -d)
tmpbase="${tmpdir}/out"
touch $tmpdir/touch

while getopts ":hi:o:m:b:" opt; do
    case ${opt} in
        h ) # process option h
            echo "Usage:"
            echo "    $0 -h                      Display this help message."
            exit 0
            ;;
        i ) # ttl/owl to be processed
            input=$OPTARG
            ;;
        o ) # tsv output in sssom format
            output=$OPTARG        
            ;;
        m ) # merge in additional files such as prefixes
            extra_inputs="${extra_inputs} -i $OPTARG"
            ;;
        b ) # base
            tmpbase=$OPTARG        
            ;;
        \? ) 
             echo "Invalid Option: -$OPTARG" 1>&2
             exit 1
             ;;
        : )
            echo "Invalid Option: -$OPTARG requires an argument" 1>&2
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

if [ "x$input" == "x" ]
then
    echo "must specify input with -i"
    exit 1
fi
if [ "x$output" == "x" ]
then
    echo "must specify output with -o"
    exit 1
fi

PATH_TO_ME=`dirname $0`;
SPARQLDIR=$PATH_TO_ME/../sparql
robot -v \
      annotate -i $input -l rdfs:comment "post-processed with sparqlmatch" en \
      merge $extra_inputs -o $tmpbase-merged.ttl \
      query -u $SPARQLDIR/insert-sources.ru -o $tmpbase-with-sources.ttl \
      query -u $SPARQLDIR/insert-lexical-nodes.ru -o $tmpbase-with-lexical-nodes.ttl \
      query -u $SPARQLDIR/insert-matches.ru -o $tmpbase-with-matches.ttl\
      query -q $SPARQLDIR/select-matches.rq $output
rm $tmpdir/*
