.PHONY: all test clean doc build examples

all:	build

build:
	jbuilder build

examples:
	jbuilder build @examples/examples

clean:
	find -L . -name "*~" -delete
	jbuilder clean


doc:	build
	ocamldoc -html -d docs _build/default/src/exenum.mli -I _build/default/src/internals/
	cp style/style.css docs/

# I do not use odoc yet, because it is undocumented, and the generated files use the css file in ../../odoc.css
# which is not correct when deploying the pages. I will not /sed/ the output files to fix this.
#
#	jbuilder build @doc
#	cp _build/default/_doc/exenum/Exenum/index.html docs/
#	cp style/style.css docs/
