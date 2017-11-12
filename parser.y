/* simplest version of calculator */
%{
# include "node.h"
# include "funcs.c"
extern int yylineno;
extern int iserror;

%}
%locations
%union {
    Node * node;
}
/* declare tokens */
%token<node> INT FLOAT ID LCOM RCOM COMMENT  //6
%token<node> SEMI COMMA ASSIGNOP RELOP  //4
%token<node> PLUS MINUS STAR DIV OR AND DOT NOT TYPE // 9
%token<node> LP RP LB RB LC RC   // 6
%token<node> STRUCT RETURN IF ELSE WHILE //5

%type<node> Program ExtDefList ExtDef ExtDecList Specifier
%type<node> StructSpecifier OptTag Tag VarDec FunDec VarList ParamDec
%type<node> CompSt StmtList Stmt DefList Dec Exp Args Def DecList

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
Program: ExtDefList        {$$ = own1Child("Program", $1);
                            if(!iserror){
                                showTree($$, 0);
                            }
                            }
;
ExtDefList:                 {$$ = own0Child("ExtDefList");}
| ExtDef ExtDefList         {$$ = own2Child("ExtDefList", $1, $2);}
;
ExtDef: Specifier ExtDecList SEMI   {$$ = own3Child("ExtDef", $1, $2, $3);}
| Specifier SEMI            {$$ = own2Child("ExtDef", $1, $2);}
| Specifier FunDec CompSt   {$$ = own3Child("ExtDef", $1, $2, $3);}
| error SEMI                {$$ = own0Child("ExtDef");}
;
ExtDecList: VarDec          {$$ = own1Child("ExtDecList", $1);}
| VarDec COMMA ExtDecList   {$$ = own3Child("ExtDecList", $1, $2, $3);}
;

Specifier: TYPE             {$$ = own1Child("Specifier", $1);}
| StructSpecifier           {$$ = own1Child("Specifier", $1);}
;
StructSpecifier: STRUCT OptTag LC DefList RC  {$$ = own5Child("StructSpecifier", $1, $2, $3, $4, $5);}
| STRUCT Tag                {$$ = own2Child("StructSpecifier", $1, $2);}
;
OptTag:                     {$$ = own0Child("OptTag");}
| ID                        {$$ = own1Child("OptTag", $1);}
;
Tag: ID                     {$$ = own1Child("Tag", $1);}
;

VarDec: ID                  {$$ = own1Child("VarDec", $1);}
| VarDec LB INT RB          {$$ = own4Child("VarDec", $1, $2, $3, $4);}
;
FunDec: ID LP VarList RP    {$$ = own4Child("FunDec", $1, $2, $3, $4);}
| ID LP RP                  {$$ = own3Child("FunDec", $1, $2, $3);}
;
VarList: ParamDec COMMA VarList  {$$ = own3Child("VarList", $1, $2, $3);}
| ParamDec                  {$$ = own1Child("VarList", $1);}
;
ParamDec: Specifier VarDec  {$$ = own2Child("ParamDec", $1, $2);}
;

CompSt: LC DefList StmtList RC  {$$ = own4Child("CompSt", $1, $2, $3, $4);}
| error RC              {$$ = own0Child("CompSt");}
;
StmtList:               {$$ = own0Child("StmtList");}
| Stmt StmtList         {$$ = own2Child("StmtList", $1, $2);}
;
Stmt: Exp SEMI          {$$ = own2Child("Stmt", $1, $2);}
| CompSt                {$$ = own1Child("Stmt", $1);}
| RETURN Exp SEMI       {$$ = own3Child("Stmt", $1, $2, $3);}
| IF LP Exp RP Stmt     {$$ = own5Child("Stmt", $1, $2, $3, $4, $5);}
| IF LP Exp RP Stmt ELSE Stmt {$$ = own7Child("Stmt", $1, $2, $3, $4, $5, $6, $7);}
| WHILE LP Exp RP Stmt  {$$ = own5Child("Stmt", $1, $2, $3, $4, $5);}
| error SEMI            {$$ = own0Child("Stmt"); yyerrorB("Missing2 \";\"");}
;

DefList:                {$$ = own0Child("DefList");}
| Def DefList           {$$ = own2Child("DefList", $1, $2);}
;
Def: Specifier DecList SEMI {$$ = own3Child("Def", $1, $2, $3);}
| Specifier error SEMI  {$$ = own0Child("Def"); yyerrorB("Missing \";\"");}
;
DecList: Dec            {$$ = own1Child("DecList", $1);}
| Dec COMMA DecList     {$$ = own3Child("DecList", $1, $2, $3);}
;
Dec: VarDec             {$$ = own1Child("Dec", $1);}
| VarDec ASSIGNOP Exp   {$$ = own3Child("Dec", $1, $2, $3);}
;

Exp: Exp ASSIGNOP Exp    {$$ = own3Child("Exp", $1, $2, $3);}
| Exp AND Exp    {$$ = own3Child("Exp", $1, $2, $3);}
| Exp OR Exp     {$$ = own3Child("Exp", $1, $2, $3);}
| Exp RELOP Exp  {$$ = own3Child("Exp", $1, $2, $3);}
| Exp PLUS Exp   {$$ = own3Child("Exp", $1, $2, $3);}
| Exp MINUS Exp  {$$ = own3Child("Exp", $1, $2, $3);}
| Exp STAR Exp   {$$ = own3Child("Exp", $1, $2, $3);}
| Exp DIV Exp    {$$ = own3Child("Exp", $1, $2, $3);}
| LP Exp RP      {$$ = own3Child("Exp", $1, $2, $3);}
| MINUS Exp      {$$ = own2Child("Exp", $1, $2);}
| NOT Exp        {$$ = own2Child("Exp", $1, $2);}
| ID LP Args RP  {$$ = own4Child("Exp", $1, $2, $3, $4);}
| ID LP RP       {$$ = own3Child("Exp", $1, $2, $3);}
| Exp LB Exp RB  {$$ = own4Child("Exp", $1, $2, $3, $4);}
| Exp DOT ID   {$$ = own3Child("Exp", $1, $2, $3);}
| ID    {$$ = own1Child("Exp", $1);}
| INT   {$$ = own1Child("Exp", $1);}
| FLOAT {$$ = own1Child("Exp", $1);}
;
Args: Exp COMMA Args  {$$ = own3Child("Args", $1, $2, $3);}
| Exp   {$$ = own1Child("Args", $1);}
;
%%

