/* simplest version of calculator */
%{
# include "funcs.h"
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
%type<node> StructSpecifier OptTag Tag VarDec VarDec_x FunDec VarList ParamDec
%type<node> CompSt StmtList Stmt DefList Dec Exp Args Def DecList 

%nonassoc	AFTER_ELSE
%nonassoc	ELSE
%right ASSIGNOP
%left OR 
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV 
%right NOT RMINUS
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
ExtDef: Specifier           { IDType = $1->type;} 
        ExtDecList SEMI   {$$ = own3Child("ExtDef", $1, $2, $3);}
| Specifier SEMI            {$$ = own2Child("ExtDef", $1, $2);}
| Specifier                  { FUNCRtType = $1->type; }
        FunDec CompSt   {$$ = own3Child("ExtDef", $1, $2, $3);}
| error SEMI                {$$ = own0Child("ExtDef");}
;


ExtDecList:                 {$1 = setType($1, $$->type);} 
    VarDec                  {$$ = combineType($$, own1Child("ExtDecList", $1));}
|                           {$1 = setType($1, $$->type);}
    VarDec COMMA            {$3 = setType($3, $$->type);}
    ExtDecList              {$$ = combineType($$, own3Child("ExtDecList", $1, $2, $3));}
;

Specifier: TYPE             {$$ = own1Child("Specifier", $1); $$->type = $1->type;} //在词法分析文件中给出了
| StructSpecifier           {$$ = own1Child("Specifier", $1); $$->type = $1->type; }
;
StructSpecifier: STRUCT OptTag LC DefList RC  {$$ = own5Child("StructSpecifier", $1, $2, $3, $4, $5); $$->type=3;}
| STRUCT Tag                {
                                $$ = own2Child("StructSpecifier", $1, $2);
                                $$->type=3;//表示结构体类型
                            }
;
OptTag:                     {$$ = own0Child("OptTag");}
|                           {$1 = setType($1, 3);}
    ID                        {$$ = own1Child("OptTag", $1);}
;
Tag:                        {$1 = setType($1, 3);}
     ID                     {$$ = own1Child("Tag", $1);}
;

FunDec:                     {$1 = setType($1, 4); $1 = setRtType($1, $$->funcRtType);} 
     ID LP VarList RP    {$$ = own4Child("FunDec", $1, $2, $3, $4);}
|                           {$1 = setType($1, 4);  $1 = setRtType($1, $$->funcRtType);} 
     ID LP RP                  {$$ = own3Child("FunDec", $1, $2, $3);}
;
VarList: ParamDec COMMA VarList  {$$ = own3Child("VarList", $1, $2, $3);}
| ParamDec                  {$$ = own1Child("VarList", $1);}
;
ParamDec: Specifier { $2 = setType($2, $1->type); } 
            VarDec  {$$ = own2Child("ParamDec", $1, $2);}
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
| IF LP Exp RP Stmt    %prec AFTER_ELSE {$$ = own5Child("Stmt", $1, $2, $3, $4, $5);}    
| IF LP Exp RP Stmt ELSE Stmt {$$ = own7Child("Stmt", $1, $2, $3, $4, $5, $6, $7);}
| WHILE LP Exp RP Stmt  {$$ = own5Child("Stmt", $1, $2, $3, $4, $5);}
| error SEMI            {$$ = own0Child("Stmt"); yyerrorB("Missing2 \";\"");}
;

DefList:                {$$ = own0Child("DefList");}
| Def DefList           {$$ = own2Child("DefList", $1, $2);}
;
Def: Specifier {$2 = setType($2, $1->type);} 
     DecList SEMI {$$ = own3Child("Def", $1, $2, $3);}
| Specifier error SEMI  {$$ = own0Child("Def"); yyerrorB("Missing \";\"");}
;
DecList:                {$1 = setType($1, $$->type);} 
        Dec            {$$ = combineType($$, own1Child("DecList", $1));}
|                         {$1 = setType($1, $$->type);} 
        Dec COMMA {$3 = setType($3, $$->type);} 
        DecList     {$$ =combineType($$, own3Child("DecList", $1, $2, $3));}
;
Dec:                    {$1 = setType($1, $$->type);} 
    VarDec             {$$ = combineType($$, own1Child("Dec", $1));}
|                       {$1 = setType($1, $$->type);} 
    VarDec ASSIGNOP Exp   {$$ = combineType($$, own3Child("Dec", $1, $2, $3));}
;

// VarDec:  ID                  {$$ = own1Child("VarDec", $1);}
// |  VarDec LB INT RB          {$$ = own4Child("VarDec", $1, $2, $3, $4);}
// ;
//消除左递归

VarDec:                 {$1 = setType($1, $$->type);} 
    ID VarDec_x  {$$ = combineType($$, own2Child("VarDec", $1, $2)); 
                    //如果是数组的话则改变ID的类型，否则不变。
                    if($2->type == 5){
                        $1->arrType = $1->type;
                        $1 = setType($1, $2->type);
                    }}
;
VarDec_x:              {$$ = own0Child("VarDec_x"); $$ = setType($$, 0);}
| LB INT RB VarDec_x  {$$ = own4Child("VarDec_x", $1, $2, $3, $4); $$ = setType($$, 5);}
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
| MINUS Exp    %prec RMINUS  {$$ = own2Child("Exp", $1, $2);}
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

