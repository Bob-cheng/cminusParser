cminus: parser.y Cminus.l
	bison -d parser.y
	flex Cminus.l
	gcc -o $@ parser.tab.c lex.yy.c -lfl