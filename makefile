cminus: parser.y Cminus.l funcs.h funcs.c
	bison -d -o parser.c parser.y
	flex  -o cminus.lex.c Cminus.l
	gcc -o $@ parser.c cminus.lex.c funcs.c  -lfl -lm
