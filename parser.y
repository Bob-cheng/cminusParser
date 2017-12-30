/* simplest version of calculator */
%{
# include "funcs.h"
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
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
                                ($2->children[0])->subType = $1->type;
                                    if(addFuncRec($2->children[0]) == 0){
                                    myerror(4, "函数出现重复定义");
                                    }
                                /*检查函数的返回类型*/
                                FUNCRt* p =  FUNCRtType;
                                while(p){
                                    if(p->type != $1->type){
                                        printf("Error type 8 at Line %d: return语句的返回类型与函数定义的返回类型不匹配。\n",p->line);
                                    }
                                    p = p->next;
                                }
                                FUNCRtType=NULL;
                                }
                                
| error SEMI                {$$ = own0Child("ExtDef");}
;



ExtDecList:  VarDec       {$$ = own1Child("ExtDecList", $1);}
|  VarDec COMMA  ExtDecList   {$$ = own3Child("ExtDecList", $1, $2, $3);}
;

Specifier: TYPE             {$$ = own1Child("Specifier", $1);  IDType = $1->type; $$->type = IDType;} //在词法分析文件中给出了
| StructSpecifier           {$$ = own1Child("Specifier", $1); 
                            IDType = 3;
                            $$->type = IDType; 
                            }
;
StructSpecifier: STRUCT OptTag LC DefList RC  {//这个是结构体在定义
                                                $$ = own5Child("StructSpecifier", $1, $2, $3, $4, $5);
                                               STDclList = STDefList;//给出当前的声明结构体参数表
                                                if($2->chCount!=0){
                                                    ($2->children[0])->stdefList=STDefList;//设置结构体定义
                                                    //outPutLinks(STDefList);
                                                    if(addVarRec($2->children[0]) == 0){
                                                        myerror(16, "结构体的名字与前面定义过的结构体或变量的名字重复。");
                                                    } else{
                                                        addStRec($2->children[0]);//增加结构体记录
                                                    }
                                                }
                                                ISDefSt=0;
                                                STDefList=NULL;}
| STRUCT Tag                { //这个是结构体在使用
                                $$ = own2Child("StructSpecifier", $1, $2);

                            }
;
OptTag:                     {//这个是结构体在定义
                            $$ = own0Child("OptTag");
                            ISDefSt=1;
                            }
|  ID                        {$$ = own1Child("OptTag", $1);  $1->type = 3;
                            ISDefSt=1;
                            }
;
Tag: ID                     {//这个是结构体在使用
                                $$ = own1Child("Tag", $1);
                                VarRec* rcd = checkVarRec($1);
                                    if(rcd == NULL || rcd->type != 3){
                                        myerror(17, "直接使用未定义过的结构体来定义变量。");
                                    }else{
                                        StRec* strec = checkStRec($1);
                                        //outPutLinks(strec->def_list);
                                        STDclList = strec->def_list;//给出当前的声明结构体参数表
                                        //outPutLinks(STDclList);
                                    }
                            }
;

FunDec: ID LP VarList RP       {$$ = own4Child("FunDec", $1, $2, $3, $4); 
                            $1->type = 4;
                            $1->parmCnt = $3->parmCnt;
                            $1->parmList = PARMList;
                            PARMList = NULL;
                            //添加到函数表在上层进行操作，为了拥有返回值
                            }
|   ID LP RP                  {$$ = own3Child("FunDec", $1, $2, $3);
                                $1->type = 4;  
                                $1->subType = IDType;
                                $1->parmCnt = 0;
                                $1->parmList = NULL;
                                PARMList = NULL;
                                //添加到函数表在上层进行操作，为了拥有返回值
                            }
;
VarList: ParamDec COMMA VarList  {$$ = own3Child("VarList", $1, $2, $3);
                                    VarRec* newNode = (VarRec*)malloc(sizeof(VarRec));
                                    newNode->name = $1->sval;
                                    newNode->type = $1->type;
                                    addToParmList(newNode);
                                    $$->parmCnt = $3->parmCnt + 1;}
| ParamDec                  {$$ = own1Child("VarList", $1);
                            VarRec* newNode = (VarRec*)malloc(sizeof(VarRec));
                            newNode->name = $1->sval;
                            newNode->type = $1->type;
                            addToParmList(newNode);
                            $$->parmCnt=1;}
;
ParamDec: Specifier   VarDec  {$$ = own2Child("ParamDec", $1, $2);
                                $$->type = $2->type;
                                $$->sval = $2->sval;//这两个属性已经在下方定义过了

                                }
;

CompSt: LC DefList StmtList RC  {$$ = own4Child("CompSt", $1, $2, $3, $4); STDefList=NULL;}
| error RC              {$$ = own0Child("CompSt");}
;
StmtList:               {$$ = own0Child("StmtList");}
| Stmt StmtList         {$$ = own2Child("StmtList", $1, $2);}
;
Stmt: Exp SEMI          {$$ = own2Child("Stmt", $1, $2);}
| CompSt                {$$ = own1Child("Stmt", $1);}
| RETURN Exp SEMI       {$$ = own3Child("Stmt", $1, $2, $3);
                            //添加返回链表
                            FUNCRt* newNode = (FUNCRt*)malloc(sizeof(FUNCRt));
                            newNode->line = $1->lineNo;
                            newNode->type = $2->type;
                            newNode->next = FUNCRtType;
                            FUNCRtType = newNode;
                         }
| IF LP Exp RP Stmt    %prec AFTER_ELSE {$$ = own5Child("Stmt", $1, $2, $3, $4, $5);}    
| IF LP Exp RP Stmt ELSE Stmt {$$ = own7Child("Stmt", $1, $2, $3, $4, $5, $6, $7);}
| WHILE LP Exp RP Stmt  {$$ = own5Child("Stmt", $1, $2, $3, $4, $5);}
| error SEMI            {$$ = own0Child("Stmt"); }
;

DefList:                {$$ = own0Child("DefList");}
| Def DefList           {$$ = own2Child("DefList", $1, $2);}
;
Def: Specifier  DecList SEMI {$$ = own3Child("Def", $1, $2, $3);}
| Specifier error SEMI  {$$ = own0Child("Def"); }
;
DecList: Dec            {$$ = own1Child("DecList", $1);}
|  Dec COMMA  DecList     {$$ = own3Child("DecList", $1, $2, $3);}
;
Dec:  VarDec             {$$ =  own1Child("Dec", $1);
                        if(ISDefSt){
                          VarRec* newNode = (VarRec*)malloc(sizeof(newNode));
                          newNode->name=$1->sval;
                          newNode->type=$1->type;
                          addToSTDefList(newNode);
                        }
                          
                          }
|  VarDec ASSIGNOP Exp   {$$ =  own3Child("Dec", $1, $2, $3);
                            if(ISDefSt == 1){
                                myerror(15, "在定义时对域进行初始化");
                            }
                            if($1->type != $3->type){
                                myerror(5, "赋值号两边的表达式类型不匹配。");
                            }
                          }
;

// VarDec:  ID                  {$$ = own1Child("VarDec", $1);}
// |  VarDec LB INT RB          {$$ = own4Child("VarDec", $1, $2, $3, $4);}
// ;
//消除左递归

VarDec:  ID VarDec_x  {$$ = own2Child("VarDec", $1, $2); 
                    $1->type = IDType;
                    //如果ID是结构体而不是结构体数组的时候，为ID添加结构体内容链。
                    if($1->type == 3 && $2->type != 5){
                        $1->stdefList = STDclList;
                        addStRec($1);
                    }
                    //如果是数组的话则改变ID的类型，否则不变。
                    if($2->type == 5){
                        $1->subType = $1->type;
                        $1->type = 5;
                        $1->arrDim = $2->arrDim;
                        addArrRec($1);
                    }
                    //让VarDec包含ID的类型和值
                    $$->type = $1->type;
                    $$->sval = $1->sval;
                    if(addVarRec($1) == 0){
                        if(ISDefSt){
                            myerror(5, "结构体中域名重复定义");
                        }else{
                            myerror(3, "变量出现重复定义，或变量与前面定义过的结构体名字重复。");
                        }
                        
                    }}
;
VarDec_x:              {$$ = own0Child("VarDec_x"); $$->type = 0; $$->arrDim=0; }
| LB INT RB VarDec_x  {$$ = own4Child("VarDec_x", $1, $2, $3, $4); $$->type = 5; $$->arrDim = $4->arrDim+1;}
;

Exp: Exp ASSIGNOP Exp    {$$ = own3Child("Exp", $1, $2, $3);
                        if($1->type != $3->type){
                            myerror(5, "赋值号两边的表达式类型不匹配。");
                            
                        }else if($1->subType == -1){
                            myerror(6, "赋值号左边出现一个只有右值的表达式。");
                        }else if($1->type == 5 && ($1->subType != $3->subType || $1->arrDim != $3->arrDim)){
                            myerror(6, "赋值号两边的表达式类型不匹配。数组需要类型和维度都相同");
                        }else if($1->type == 3 && !checkListTypeEqual($1->stdefList, $3->stdefList)){
                            myerror(6, "赋值号两边的表达式类型不匹配。结构体类型不等价 ");
                        }else{
                            $$->type = $1->type;
                        }}
| Exp AND Exp    {$$ = own3Child("Exp", $1, $2, $3);
                    if($1->type != $3->type || $1->type != 1){
                        myerror(-2, "仅有int型变量才能进行逻辑运算");
                    }else{
                        $$->type = $1->type;
                    }}
| Exp OR Exp     {$$ = own3Child("Exp", $1, $2, $3);
                    if($1->type != $3->type || $1->type != 1){
                        myerror(-2, "仅有int型变量才能进行逻辑运算");
                    }else{
                        $$->type = $1->type;
                    }}
| Exp RELOP Exp  {$$ = own3Child("Exp", $1, $2, $3);
                    if($1->type != $3->type || $1->type == 3 || $1->type == 4 || $1->type == 5){
                        myerror(7, "操作数类型不匹配或操作数类型与操作符不匹配");
                    }else{
                        $$->type = $1->type;
                    }}
| Exp PLUS Exp   {$$ = own3Child("Exp", $1, $2, $3);
                    if($1->type != $3->type || $1->type == 3 || $1->type == 4 || $1->type == 5){
                        myerror(7, "操作数类型不匹配或操作数类型与操作符不匹配");
                    }else{
                        $$->type = $1->type;
                    }}
| Exp MINUS Exp  {$$ = own3Child("Exp", $1, $2, $3);
                    if($1->type != $3->type || $1->type == 3 || $1->type == 4 || $1->type == 5){
                        myerror(7, "操作数类型不匹配或操作数类型与操作符不匹配");
                    }else{
                        $$->type = $1->type;
                    }}
| Exp STAR Exp   {$$ = own3Child("Exp", $1, $2, $3);
                    if($1->type != $3->type || $1->type == 3 || $1->type == 4 || $1->type == 5){
                        myerror(7, "操作数类型不匹配或操作数类型与操作符不匹配");
                    }else{
                        $$->type = $1->type;
                    }}
| Exp DIV Exp    {$$ = own3Child("Exp", $1, $2, $3);
                    if($1->type != $3->type || $1->type == 3 || $1->type == 4 || $1->type == 5){
                        myerror(7, "操作数类型不匹配或操作数类型与操作符不匹配");
                    }else{
                        $$->type = $1->type;
                    }}
| LP Exp RP      {$$ = own3Child("Exp", $1, $2, $3);
                    $$->type = $2->type;}
| MINUS Exp    %prec RMINUS  {$$ = own2Child("Exp", $1, $2);
                                if($2->type != 1 && $2->type != 2){
                                    myerror(-2, "仅有int型和float型变量才能参与算术运算。");
                                }else{
                                    $$->type = $2->type;
                                }
                            }
| NOT Exp        {$$ = own2Child("Exp", $1, $2);
                    if($2->type != 1){
                        myerror(-2, "仅有int型变量才能进行逻辑运算");
                    }else{
                        $$->type = 1;
                    }}
| ID LP Args RP  {$$ = own4Child("Exp", $1, $2, $3, $4);
                    VarRec* rcd = checkVarRec($1);
                    if(rcd != NULL){
                        myerror(11, "对普通变量使用“(…)”或“()”（函数调用）操作符。");
                    }else{
                        FuncRec* funrcd = checkFuncRec($1);
                        if(funrcd == NULL){
                            myerror(2, "函数在调用时未经定义。");
                        }else if(funrcd->para_count != $3->parmCnt){
                            myerror(9, "函数调用时实参与形参的数目不匹配。");
                        }else{
                            VarRec* p = funrcd->def_list;
                            VarRec* q = $3->parmList;
                            int flag = 1;
                            if(!p || !q){
                                myerror(0, "代码逻辑错误");
                            }
                            while(p && q){
                                if(p->type != q->type){
                                    flag = 0;
                                }
                                p = p->next;
                                q = q->next;
                            }
                            if(flag == 0){
                                myerror(9, "函数调用时实参与形参类型不匹配。");
                            }
                        }
                        $$->type = funrcd->rtype;
                        
                    }
                }
| ID LP RP       {$$ = own3Child("Exp", $1, $2, $3);
                    VarRec* rcd = checkVarRec($1);
                    if(rcd != NULL){
                        myerror(11, "对普通变量使用“(…)”或“()”（函数调用）操作符。");
                    }else{
                        FuncRec* funrcd = checkFuncRec($1);
                        if(funrcd == NULL){
                            myerror(2, "函数在调用时未经定义。");
                        }else if(funrcd->para_count != 0){
                            myerror(9, "函数调用时实参与形参的数目不匹配。");
                        }
                        $$->type = funrcd->rtype;
                        
                    }}
| Exp LB Exp RB  {$$ = own4Child("Exp", $1, $2, $3, $4);
                    if($1->type != 5){
                        myerror(10, "对非数组型变量使用“[…]”（数组访问）操作符。");
                    }else if($3->type != 1){
                        myerror(12, "数组访问操作符“[…]”中出现非整数");
                    }else if($1->arrDim == 1){
                        $$->type = $1->subType;
                    }else{
                        $$->type = 5;
                        $$->arrDim = ($1->arrDim)-1;
                        $$->subType = $1->subType;
                    }
                    }
| Exp DOT ID   {$$ = own3Child("Exp", $1, $2, $3);
                if($1->type != 3){
                    myerror(13, "对非结构体型变量使用“.”操作符。");
                }else{
                    
                    VarRec* p = $1->stdefList;
                    int flag = 0;
                    while(p){
                        if(!strcmp(p->name, $3->sval)){
                            $$->type = p->type;
                            flag = 1;
                            break;
                        }
                        p = p->next;
                    }
                    if(!flag){
                        myerror(14, "访问结构体中未定义过的域");
                    }
                }
                }
| ID    {$$ = own1Child("Exp", $1); 
        VarRec* rcd = checkVarRec($1);
            if(rcd == NULL){
                myerror(1, "变量在使用时未经定义");
            }else{
                
                $$->type = rcd->type;
                if($$->type == 3){
                    StRec* strcd = checkStRec($1);
                    $$->stdefList = strcd->def_list;
                }else if($$->type == 5){
                    ArrRec* arrrcd = checkArrRec($1);
                    $$-> subType= arrrcd->type;
                    $$-> arrDim= arrrcd->dim;
                }
            }
        
        }
| INT   {$$ = own1Child("Exp", $1); $$->type = 1; $$->subType = -1;}
| FLOAT {$$ = own1Child("Exp", $1); $$->type = 2; $$->subType = -1;}
;
Args: Exp COMMA Args  {$$ = own3Child("Args", $1, $2, $3);
                    $$->parmCnt = ($3->parmCnt)+1;
                    VarRec* arg = (VarRec*)malloc(sizeof(VarRec));
                    arg->name=NULL;
                    arg->type=$1->type;
                    arg->next = $3->parmList;
                    $$->parmList = arg;}
| Exp   {$$ = own1Child("Args", $1);
        $$->parmCnt = 1;
        VarRec* arg = (VarRec*)malloc(sizeof(VarRec));
        arg->name=NULL;
        arg->type=$1->type;
        $$->parmList = arg;}
;
%%

