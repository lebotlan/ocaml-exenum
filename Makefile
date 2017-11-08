.PHONY: all tests clean doc build examples

all:	build

build:
	jbuilder build

examples:
	jbuilder build @examples/examples

clean:
	find -L . -name "*~" -delete
	jbuilder clean

tests:
	jbuilder build @test/tests

#doc:	build
#	ocamlfind ocamldoc -package lwt -html -d docs _build/default/src/exenum.mli _build/default/src/lwt/lwt_tester.mli -I _build/default/src/internals/ -I _build/default/src
#	cp style/style.css docs/

# I do not use odoc yet, because it is undocumented, and the generated files use the css file in ../../odoc.css
# which is not correct when deploying the pages. I will not /sed/ the output files to fix this.
#
doc:	build
	jbuilder build @doc
	cp -R _build/default/_doc/* docs/
