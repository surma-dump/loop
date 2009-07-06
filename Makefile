all:
	bison -d loop.y
	flex loop.l
	gcc *.c -lfl -o loop
clean:
	-@rm *~ *.tab.* lex.yy.c loop
