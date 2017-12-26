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
ExtDef: Specifier ExtDecList SEMI   {$$ = own3Child("ExtDef", $1, $2, $3);}
| Specifier SEMI            {$$ = own2Child("ExtDef", $1, $2);}
| Specifier  FunDec CompSt   {$$ = own3Child("ExtDef", $1, $2, $3);
                                //设置函数ID的返回类型
                                ($2->children[0])->subType = $1->type;}
| error SEMI                {$$ = own0Child("ExtDef");}
;



ExtDecList:  VarDec       {$$ = own1Child("ExtDecList", $1);}
|  VarDec COMMA  ExtDecList   {$$ = own3Child("ExtDecList", $1, $2, $3);}
;

Specifier: TYPE             {$$ = own1Child("Specifier", $1);  IDType = $1->type; $$->type = IDType;} //在词法分析文件中给出了
| StructSpecifier           {$$ = own1Child("Specifier", $1); IDType = 3;$$->type = IDType;}
;
StructSpecifier: STRUCT OptTag LC DefList RC  {$$ = own5Child("StructSpecifier", $1, $2, $3, $4, $5);}
| STRUCT Tag                {
                                $$ = own2Child("StructSpecifier", $1, $2);
                            }
;
OptTag:                     {$$ = own0Child("OptTag");}
|  ID                        {$$ = own1Child("OptTag", $1);  $1->type = 3;}
;
Tag: ID                     {$$ = own1Child("Tag", $1); $1->type = 3;}
;

FunDec: ID LP VarList RP       {$$ = own4Child("FunDec", $1, $2, $3, $4); 
                           $1->type = 4;
                            $1->parmCnt = PARMCnt;
                            $1->parmList = PARMList;
                            PARMList = 0;
                            PARMCnt = 0;}
|   ID LP RP                  {$$ = own3Child("FunDec", $1, $2, $3);
                                $1->type = 4;  
                                $1->subType = IDType;
                                $1->parmCnt = 0;
                                $1->parmList = 0;
                                PARMList = 0;
                                PARMCnt = 0;}
;
VarList: ParamDec COMMA VarList  {$$ = own3Child("VarList", $1, $2, $3);
                                    PARMCnt++;}
| ParamDec                  {$$ = own1Child("VarList", $1);
                            PARMCnt = 1;}
;
ParamDec: Specifier   VarDec  {$$ = own2Child("ParamDec", $1, $2);
                                VarRec* newNode = (VarRec*)malloc(sizeof(VarRec));
                                newNode->name = $2->sval; //在下方定义
                                newNode->type = $2->type;
                                addToParmList(newNode);
                                }
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
Def: Specifier  DecList SEMI {$$ = own3Child("Def", $1, $2, $3);}
| Specifier error SEMI  {$$ = own0Child("Def"); yyerrorB("Missing \";\"");}
;
DecList: Dec            {$$ = own1Child("DecList", $1);}
|  Dec COMMA  DecList     {$$ = own3Child("DecList", $1, $2, $3);}
;
Dec:  VarDec             {$$ =  own1Child("Dec", $1);}
|  VarDec ASSIGNOP Exp   {$$ =  own3Child("Dec", $1, $2, $3);}
;

// VarDec:  ID                  {$$ = own1Child("VarDec", $1);}
// |  VarDec LB INT RB          {$$ = own4Child("VarDec", $1, $2, $3, $4);}
// ;
//消除左递归

VarDec:  ID VarDec_x  {$$ = own2Child("VarDec", $1, $2); 
                    $1->type = IDType;
                    //如果是数组的话则改变ID的类型，否则不变。
                    if($2->type == 5){
                        $1->subType = $1->type;
                        $1->type = 5;
                    }
                    $$->type = $1->type;
                    $$->sval = $1->sval;
                    }
;
VarDec_x:              {$$ = own0Child("VarDec_x"); $$->type = 0;}
| LB INT RB VarDec_x  {$$ = own4Child("VarDec_x", $1, $2, $3, $4); $$->type = 5;}
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

