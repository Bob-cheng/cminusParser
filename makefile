cminus: parser.y Cminus.l node.h
	bison -d parser.y
	flex Cminus.l
	gcc -o $@ parser.tab.c lex.yy.c  -lfl
