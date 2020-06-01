RUN = ./scripts/sparql-match.sh

TESTDATA = tests/data
TARGET = target

all: test-basic

clean:
	rm target/*

$(TARGET):
	mkdir $@

test-%: $(TARGET)/test-matches-%.tsv
	echo success
.PHONEY: test-%

$(TARGET)/test-matches-%.tsv: $(TESTDATA)/%.ttl $(TARGET)
	$(RUN) -b $(TARGET)/intermediate-$*- -i $< -o $@
.PRECIOUS: $(TARGET)/test-matches-%.tsv

# test an intermediate target
$(TARGET)/lexical-%.ttl: $(TESTDATA)/%.ttl $(TARGET) sparql/insert-lexical-nodes.ru
	robot query -i $< -u sparql/insert-lexical-nodes.ru -o $@

# --------------------
# Run SPARQL service inside Docker
# --------------------
BGVERSION = 2.1.5
URLBASE = http://localhost:8889/bigdata

bg: bg-run pause bg-load
bg-run:
	docker run --name blazegraph -d -p 8889:8080 -v $(PWD)/conf/RWStore.properties:/RWStore.properties -v $(PWD)/stage:/data lyrasis/blazegraph:$(BGVERSION)

bg-load:
	curl -X POST --data-binary @conf/dataloader.txt   --header 'Content-Type:text/plain' $(URLBASE)/dataloader


bg-update:
	curl -X POST -d "@sparql/insert-sources.ru"  -H 'Content-Type: application/sparql-update' $(URLBASE)/namespace/kb/sparql

bg-query:
	curl -H "Accept: text/csv" -X POST --data-urlencode "query@sparql/all.rq" $(URLBASE)/sparql

bg-stop:
	docker kill blazegraph; docker rm blazegraph
