.PHONY: all test clean

all:
	jbuilder build

test:
	jbuilder runtest

clean:
	find -L . -name "*~" -delete
	jbuilder clean


