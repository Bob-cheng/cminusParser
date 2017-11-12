%{
#include <stdio.h>
extern int yylineno;
%}
%locations
%union {
    int val;
}
/* declare tokens */
%token<val> NUMBER
%token<val> ADD SUB MUL DIV ABS
%token EOL
%type <val> exp factor term
 

%%
calclist: /* nothing */ 
| calclist exp EOL { printf("= %d\n", $2); } 
;
exp: factor 
| exp ADD factor { $$ = $1 + $3; printf("%d", @2.first_line);}
| exp SUB factor { $$ = $1 - $3; printf("%d", @2.first_line);}
;
factor: term 
| factor MUL term { $$ = $1 * $3; printf("%s", $2);}
| factor DIV term { $$ = $1 / $3; }
;
term: NUMBER 
| ABS term { $$ = $2 >= 0? $2 : - $2; }
;
%%
