%{
# include "parser.tab.h"
int yycolumn = 1;
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno; \
yylloc.first_column = yycolumn; yylloc.last_column = yycolumn+yyleng-1; \
yycolumn += yyleng;
%}
%option yylineno
%%
\n { yycolumn = 1;}
"+" { return ADD; }
"-" { return SUB; }
"*" { return MUL; }
"/" { return DIV; }
"|" { return ABS; }
[0-9]+ { yylval.val = atoi(yytext); return NUMBER; }
"\\" {return EOL;}
[ \t] { /* ignore whitespace */ }
. {yyerrorA();}

%%

int main(int argc, char **argv)
{
    if(argc > 1) {
        if(!(yyin = fopen(argv[1], "r"))) {
            perror(argv[1]);
            return (1);
        }
    }
    yyparse();
}

void yyerror(char * s){
    fprintf(stderr, "Error type B at Line %d:%d %s \n", yylineno,yylloc.first_column, s);
}

void yyerrorA()
{
 fprintf(stderr, "Error type A at Line %d:%d Mysterious character '%s'\n", yylineno, yylloc.first_column, yytext);
}