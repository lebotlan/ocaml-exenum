.PHONY: all test clean

all:
	jbuilder build

test:
	jbuilder runtest

doc:
	jbuilder build @doc
	cp _build/default/_doc/exenum/Exenum/index.html docs/
	cp style/style.css docs/

clean:
	find -L . -name "*~" -delete
	jbuilder clean


