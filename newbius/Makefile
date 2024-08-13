SHELL = /bin/bash

all: graph

.PHONY: graph
graph: graph.svg graph-beautified.svg

.PHONY: graph.svg
graph.svg: graph.viz
	cat imgs/graph.viz | dot -T svg > imgs/$@

.PHONY: graph.viz
graph.viz:
	cd slurm_k8s && \
	terraform graph -type plan > $@
	mv slurm_k8s/$@ imgs/$@

.PHONY: graph-beautified.svg
graph-beautified.svg: imgs/tgbeauty graph-beautified.viz
	cat imgs/graph-beautified.viz \
	| dot -T svg > imgs/$@

.PHONY: graph-beautified.viz
graph-beautified.viz: imgs/tgbeauty graph.viz
	cat imgs/graph.viz \
	| ./imgs/tgbeauty \
	  --exclude 'var.' \
	  --exclude 'local.' \
	  --exclude 'module.labels.' \
	  --exclude 'data.units' \
	  --output-type graphviz > imgs/$@

.PHONY: tooling
tooling: imgs/tgbeauty

imgs/tgbeauty:
	git clone --depth 1 https://github.com/pcasteran/terraform-graph-beautifier.git $@.d
	cd $@.d && go build && mv terraform-graph-beautifier ../../$@
	rm -rf $@.d
