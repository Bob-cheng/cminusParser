%{
# include "funcs.h"
# include "parser.h"
int yycolumn = 1;
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno; \
yylloc.first_column = yycolumn; yylloc.last_column = yycolumn+yyleng-1; \
yycolumn += yyleng;
int iserror = 1;
%}
%option yylineno

integer         ([1-9][0-9]*)|-?(0[0-7]*)|(0x[0-9A-F]*)
float           ([0-9]+\.[0-9]*)|-?([0-9]+\.[0-9]*e-?[1-9][0-9]*)
id              [a-zA-Z_][a-zA-Z0-9_]*
ws              [ \t]+

%%

{ws}
"/*"[^*]*\*+([^/*][^*]*\*+)*"/"     
"//".*\n        {yycolumn = 1;}  
\n              {yycolumn = 1;}
{integer}       {
    Node* np = getStrNode(yytext, yylineno, "INT", yyleng);
    yylval.node = np; 
    return INT;
    }
{float}         {
    Node* np = getStrNode(yytext, yylineno, "FLOAT", yyleng);
    yylval.node = np;
    return FLOAT;}
";"             {
    Node* np = getStrNode(yytext,yylineno, "SEMI", yyleng);
    yylval.node = np;
    SPECIALFUNC=0;
    return SEMI;
    TESTFunStage = 0;
    }
","             {
    Node* np = getStrNode(yytext,yylineno, "COMMA", yyleng);
    yylval.node = np;
    return COMMA;}
"="             {
    Node* np = getStrNode(yytext,yylineno, "ASSIGNOP", yyleng);
    yylval.node = np;
    return ASSIGNOP;}
">"|"<"|">="|"<="|"=="|"!="     {
    Node* np = getStrNode(yytext, yylineno, "RELOP", yyleng);
    yylval.node = np;
    return RELOP;}
"+"             {
    Node* np = getStrNode(yytext,yylineno, "PLUS", yyleng);
    yylval.node = np;
    return PLUS;}
"-"             {
    Node* np = getStrNode(yytext,yylineno, "MINUS", yyleng);
    yylval.node = np;
    return MINUS;}
"*"             {
    Node* np = getStrNode(yytext,yylineno, "STAR", yyleng);
    yylval.node = np;
    return STAR;}
"/"             {
    Node* np = getStrNode(yytext,yylineno, "DIV", yyleng);
    yylval.node = np;
    return DIV;}
"||"            {
    Node* np = getStrNode(yytext,yylineno, "OR", yyleng);
    yylval.node = np;
    return OR;}
"&&"            {
    Node* np = getStrNode(yytext,yylineno, "AND", yyleng);
    yylval.node = np;
    return AND;}
"."             {
    Node* np = getStrNode(yytext,yylineno, "DOT", yyleng);
    yylval.node = np;
    return DOT;}
"!"             {
    Node* np = getStrNode(yytext,yylineno, "NOT", yyleng);
    yylval.node = np;
    return NOT;}
"int"           {
    Node* np = getStrNode(yytext, yylineno, "TYPE", yyleng);
    np->type = 1; //提前确定类型，int
    yylval.node = np;
    return TYPE;}
"float"         {
    Node* np = getStrNode(yytext, yylineno, "TYPE", yyleng);
    np->type = 2; //提前确定类型，float
    yylval.node = np;
    return TYPE;}

"("             {
    Node* np = getStrNode(yytext,yylineno, "LP", yyleng);
    yylval.node = np;
    if(TESTFunStage==2){
        FUNCRtTypeINT=IDType;
    }else{
        TESTFunStage=0;
    }
    return LP;
    }
")"             {

    Node* np = getStrNode(yytext,yylineno, "RP",  yyleng);
    yylval.node = np;
    return RP;}
"["             {
    Node* np = getStrNode(yytext,yylineno, "LB", yyleng);
    yylval.node = np;
    return LB;}
"]"             {
    Node* np = getStrNode(yytext,yylineno, "RB", yyleng);
    yylval.node = np;
    return RB;}
"{"             {
    Node* np = getStrNode(yytext,yylineno, "LC", yyleng);
    yylval.node = np;
    return LC;}
"}"             {
    Node* np = getStrNode(yytext,yylineno, "RC", yyleng);
    yylval.node = np;
    return RC;}
"struct"      {
    Node* np = getStrNode(yytext,yylineno, "STRUCT", yyleng);
    yylval.node = np;
    return STRUCT;}
"return"        {
    Node* np = getStrNode(yytext,yylineno, "RETURN", yyleng);
    yylval.node = np;
    return RETURN;}
"if"            {
    
    Node* np = getStrNode(yytext,yylineno, "IF", yyleng);
    yylval.node = np;
    // _pushTfStack();
    // char* l1, *l2;
    // _getNewLabel(&l1);
    // _getNewLabel(&l2);
    // EXPTrue = l1;
    // EXPFalse = l2;
    return IF;}
"else"          {
    Node* np = getStrNode(yytext,yylineno, "ELSE", yyleng);
    yylval.node = np;
    // _putGoto_(STMTNext);
    // _putLabel_(EXPFalse);
    return ELSE;}
"while"         {
    Node* np = getStrNode(yytext,yylineno, "WHILE", yyleng);
    yylval.node = np;
    // _pushTfStack();
    // char* l, *l1;
    // _getNewLabel(&l);
    // _getNewLabel(&l1);
    // EXPTrue = l1;
    // EXPFalse = STMTNext;
    // _pushSNextStack();
    // STMTNext=l;
    // _putLabel_(l);
    return WHILE;}
{id}            {
    Node* np = getStrNode(yytext, yylineno, "ID", yyleng);
    if(!strcmp(np->sval, "write")){
        SPECIALFUNC=1;
    }
    if(TESTFunStage == 1){
        TESTFunStage = 2;
    }else{
        TESTFunStage=0;
    }
    yylval.node = np;
    return ID;}
.   {yyerrorA();}

%%

int main(int argc, char **argv)
{
    initiate();

    if(argc > 1) {
        if(!(yyin = fopen(argv[1], "r"))) {
            perror(argv[1]);
            return (1);
        }
    }
    yyparse();
}

void yyerror(char * s){
    iserror = 1;
    fprintf(stderr, "Error type B at Line %d:%d %s \n", yylineno,yylloc.first_column, s);
}

void yyerrorA()
{
    iserror = 1;
    fprintf(stderr, "Error type A at Line %d:%d Mysterious character '%s'\n", yylineno, yylloc.first_column, yytext);
}

void myerror(int type, char * s){
    //iserror = 1;
    fprintf(stderr, "Error type %d at Line %d %s \n",type, yylineno, s);
    exit(1);
}
