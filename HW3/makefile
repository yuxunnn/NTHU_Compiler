.PHONY: all clean

all: codegen

codegen: lex.yy.c y.tab.c code.c
	gcc -o codegen lex.yy.c y.tab.c code.c -lfl

lex.yy.c: scanner.l
	flex scanner.l

y.tab.c: parser.y
	byacc -d parser.y

clean:
	rm -f codegen lex.yy.c y.tab.c y.tab.h