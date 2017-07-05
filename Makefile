all:
	jbuilder build

clean:
	find -L . -name "*~" -delete
	jbuilder clean


