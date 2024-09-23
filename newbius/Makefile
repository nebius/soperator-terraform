SHELL = /bin/bash

ifeq ($(shell uname), Darwin)
    SED_COMMAND = sed -i ''
else
    SED_COMMAND = sed -i
endif

all: graph

.PHONY: graph
graph: graph.svg graph-beautified.svg

.PHONY: graph.svg
graph.svg: graph.viz
	cat imgs/graph.viz | dot -T svg > imgs/$@

.PHONY: graph.viz
graph.viz:
	cd installations/example && \
	terraform graph -type plan > $@
	mv installations/example/$@ imgs/$@

.PHONY: graph-beautified.svg
graph-beautified.svg: imgs/tgbeauty graph-beautified.viz
	cat imgs/graph-beautified.viz \
	| dot -T svg > imgs/$@

.PHONY: graph-beautified.viz
graph-beautified.viz: imgs/tgbeauty graph.viz
	cat imgs/graph.viz \
	| ./imgs/tgbeauty \
	  --output-type graphviz > imgs/$@
	$(SED_COMMAND) -E 's/rankdir=TB/rankdir=RL/' imgs/$@

.PHONY: tooling
tooling: imgs/tgbeauty

imgs/tgbeauty:
	git clone --depth 1 https://github.com/pcasteran/terraform-graph-beautifier.git $@.d
	cd $@.d && go build && mv terraform-graph-beautifier ../../$@
	rm -rf $@.d
