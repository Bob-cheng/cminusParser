cminus: parser.y cminus.l funcs.h funcs.c
	bison -d -o parser.c parser.y
	flex  -o cminus.lex.c cminus.l
	gcc -o $@ parser.c cminus.lex.c funcs.c  -lfl -lm
