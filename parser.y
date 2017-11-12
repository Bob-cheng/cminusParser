/* simplest version of calculator */
%{
#include <stdio.h>
#include "node.h"
extern int yylineno;
%}
%locations
%union {
    Node* node;
}
/* declare tokens */
%token<node> INT FLOAT ID LCOM RCOM COMMENT 
%token<node> SEMI COMMA ASSIGNOP RELOP
%token<node> PLUS MINUS STAR DIV OR AND DOT NOT TYPE
%token<node> LP RP LB RB LC RC 
%token<node> STRUCT RETURN IF ELSE WHILE

%right ASSIGNOP
%left OR 
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV 
%right NOT
%left LP RP LB RB DOT 

%start Program
%%
Program: ExtDefList {}
;
ExtDefList: 
| ExtDef ExtDefList {}
;
ExtDef: Specifier ExtDecList SEMI
| Specifier SEMI
| Specifier FunDec CompSt
;
ExtDecList: VarDec
| VarDec COMMA ExtDecList
;

Specifier: TYPE
| StructSpecifier
;
StructSpecifier: STRUCT OptTag LC DefList RC
| STRUCT Tag
;
OptTag: 
| ID
;
Tag: ID
;

VarDec: ID
| VarDec LB INT RB
;
FunDec: ID LP VarList RP
| ID LP RP
;
VarList: ParamDec COMMA VarList
| ParamDec
;
ParamDec: Specifier VarDec
;

CompSt: LC DefList StmtList RC
| error RC
;
StmtList: 
| Stmt StmtList
;
Stmt: Exp SEMI
| CompSt
| RETURN Exp SEMI
| IF LP Exp RP Stmt
| IF LP Exp RP Stmt ELSE Stmt
| WHILE LP Exp RP Stmt
| error SEMI
;

DefList: 
| Def DefList
;
Def: Specifier DecList SEMI
;
DecList: Dec
| Dec COMMA DecList
;
Dec: VarDec
| VarDec ASSIGNOP Exp
;

Exp: Exp ASSIGNOP Exp
| Exp AND Exp
| Exp OR Exp
| Exp RELOP Exp
| Exp PLUS Exp
| Exp MINUS Exp
| Exp STAR Exp
| Exp DIV Exp
| LP Exp RP
| MINUS Exp
| NOT Exp
| ID LP Args RP
| ID LP RP
| Exp LB Exp RB
| Exp DOT ID
| ID
| INT
| FLOAT
| error RP
;
Args: Exp COMMA Args
| Exp
;
%%

int main(int argc, char **argv)
{
    if(argc > 1) {
        FILE * yyin;
        if(!(yyin = fopen(argv[1], "r"))) {
            perror(argv[1]);
            return (1);
        }
        yyrestrat(yyin);
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