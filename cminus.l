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

integer         -?([1-9][0-9]*)|-?(0[0-7]*)|(0x[0-9A-F]*)
float           -?([0-9]+\.[0-9]*)|-?([0-9]+\.[0-9]*e-?[1-9][0-9]*)
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
    Node* np = getTermNode(yylineno, "SEMI");
    yylval.node = np;
    return SEMI;}
","             {
    Node* np = getTermNode(yylineno, "COMMA");
    yylval.node = np;
    return COMMA;}
"="             {
    Node* np = getTermNode(yylineno, "ASSIGNOP");
    yylval.node = np;
    return ASSIGNOP;}
">"|"<"|">="|"<="|"=="|"!="     {
    Node* np = getStrNode(yytext, yylineno, "RELOP", yyleng);
    yylval.node = np;
    return RELOP;}
"+"             {
    Node* np = getTermNode(yylineno, "PLUS");
    yylval.node = np;
    return PLUS;}
"-"             {
    Node* np = getTermNode(yylineno, "MINUS");
    yylval.node = np;
    return MINUS;}
"*"             {
    Node* np = getTermNode(yylineno, "STAR");
    yylval.node = np;
    return STAR;}
"/"             {
    Node* np = getTermNode(yylineno, "DIV");
    yylval.node = np;
    return DIV;}
"||"            {
    Node* np = getTermNode(yylineno, "OR");
    yylval.node = np;
    return OR;}
"&&"            {
    Node* np = getTermNode(yylineno, "AND");
    yylval.node = np;
    return AND;}
"."             {
    Node* np = getTermNode(yylineno, "DOT");
    yylval.node = np;
    return DOT;}
"!"             {
    Node* np = getTermNode(yylineno, "NOT");
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
    Node* np = getTermNode(yylineno, "LP");
    yylval.node = np;
    return LP;}
")"             {
    Node* np = getTermNode(yylineno, "RP");
    yylval.node = np;
    return RP;}
"["             {
    Node* np = getTermNode(yylineno, "LB");
    yylval.node = np;
    return LB;}
"]"             {
    Node* np = getTermNode(yylineno, "RB");
    yylval.node = np;
    return RB;}
"{"             {
    Node* np = getTermNode(yylineno, "LC");
    yylval.node = np;
    return LC;}
"}"             {
    Node* np = getTermNode(yylineno, "RC");
    yylval.node = np;
    return RC;}
"struct"      {
    Node* np = getTermNode(yylineno, "STRUCT");
    yylval.node = np;
    return STRUCT;}
"return"        {
    Node* np = getTermNode(yylineno, "RETURN");
    yylval.node = np;
    return RETURN;}
"if"            {
    Node* np = getTermNode(yylineno, "IF");
    yylval.node = np;
    return IF;}
"else"          {
    Node* np = getTermNode(yylineno, "ELSE");
    yylval.node = np;
    return ELSE;}
"while"         {
    Node* np = getTermNode(yylineno, "WHILE");
    yylval.node = np;
    return WHILE;}
{id}            {
    Node* np = getStrNode(yytext, yylineno, "ID", yyleng);
    yylval.node = np;
    return ID;}
.   {yyerrorA();}

%%

int main(int argc, char **argv)
{
    var_head = (VarRec*)malloc(sizeof(VarRec));
    var_tail = var_head;
    var_head->next=NULL;

    func_head = (FuncRec*)malloc(sizeof(FuncRec));
    func_tail = func_head;
    func_head->next=NULL;

    arr_head = (ArrRec*)malloc(sizeof(ArrRec));
    arr_tail = arr_head;
    arr_head->next=NULL;

    st_head = (StRec*)malloc(sizeof(StRec));
    st_tail = st_head;
    st_head->next=NULL;

    PARMList=NULL;
    STDefList=NULL;
    STDclList=NULL;
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
    fprintf(stderr, "Error type %d at Line %d:%d %s \n",type, yylineno,yylloc.first_column, s);
}
