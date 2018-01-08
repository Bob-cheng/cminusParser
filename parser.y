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
%type<node> CompSt StmtList Stmt DefList Dec Exp Args Def DecList  PStmt

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
                                funcDefOption($$, $1, $2, $3);
                                //这里还没写完，暂时不用输出
                                printCode($3);
                                printf("\n");
                                }
                                
| error SEMI                {$$ = own0Child("ExtDef");}
;



ExtDecList:  VarDec       {$$ = own1Child("ExtDecList", $1);}
|  VarDec COMMA  ExtDecList   {$$ = own3Child("ExtDecList", $1, $2, $3);}
;

Specifier: TYPE             {$$ = own1Child("Specifier", $1);
                            IDType = $1->type; 
                            $$->type = IDType; 
                            TESTFunStage=1;} //在词法分析文件中给出了
| StructSpecifier           {$$ = own1Child("Specifier", $1); 
                            IDType = 3;
                            $$->type = IDType; 
                            TESTFunStage=1;
                            }
;
StructSpecifier: STRUCT OptTag LC DefList RC  {//这个是结构体在定义
                                                $$ = own5Child("StructSpecifier", $1, $2, $3, $4, $5);
                                                int size = setRelAddress(STDefList);
                                               STDclList = STDefList;//给出当前的声明结构体参数表
                                                if($2->chCount!=0){
                                                    ($2->children[0])->stdefList=STDefList;//设置结构体定义
                                                    ($2->children[0])->parmCnt = size;
                                                    //outPutLinks(STDefList);
                                                    if(addVarRec($2->children[0]) == 0){
                                                        myerror(16, "结构体的名字与前面定义过的结构体或变量的名字重复。");
                                                    } else{
                                                        addStRec($2->children[0]);//增加结构体记录
                                                    }
                                                }
                                                ISDefSt=0;
                                                STDefList=NULL;
                                                
                                                //作为debug用，其实不用输出。
                                                //printCode(DEFCodeList);
                                                DEFCodeList = NULL;
                                                }
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
                            $1->subType = FUNCRtTypeINT;
                            PARMList = NULL;
                            if(addFuncRec($1) == 0){
                                    myerror(4, "函数出现重复定义");
                            }
                            _decFunc_($1);
                            }
|   ID LP RP                  {$$ = own3Child("FunDec", $1, $2, $3);
                                $1->type = 4;  
                                $1->subType = IDType;
                                $1->parmCnt = 0;
                                $1->parmList = NULL;
                                PARMList = NULL;
                                if(addFuncRec($1) == 0){
                                    myerror(4, "函数出现重复定义");
                                }
                                _decFunc_($1);
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

CompSt: LC DefList StmtList RC  {$$ = own4Child("CompSt", $1, $2, $3, $4); 
                                STDefList=NULL;
                                //将递归起来的DefList代码传递给Compst
                                Node* p = DEFCodeList;
                                while(p){
                                    copyCode($$, p);
                                    p = p->next;
                                }
                                DEFCodeList = NULL;
                                popDefCodeListStk();
                                //将递归起来的StmtList代码传递给Compst
                                Node* q = PStmtCodeList;
                                while(q){
                                    copyCode($$, q);
                                    q = q->next;
                                }
                                PStmtCodeList = NULL;
                                popPStmtCodeListStk();
                                }
| error RC              {$$ = own0Child("CompSt");}
;
StmtList:               {$$ = own0Child("StmtList");
                        pushPStmtCodeListStk();
                        PStmtCodeList = NULL;
                        }
| PStmt StmtList         {$$ = own2Child("StmtList", $1, $2);
                        addToPStmtCodeList($1);
                        }
;

// PRES:                   {   _pushSNextStack();                    
//                             char* l;
//                             _getNewLabel(&l); 
//                             STMTNext = l;
                            
//                         }
// ;

// NEWStmt: PRES Stmt      {
//                             $$ = own1Child("NEWStmt", $2);
//                             //_putLabel_(STMTNext);
//                             _popSNextStack();
//                         }
// ; 

PStmt: Stmt                {  
                              $$ = own1Child("PStmt", $1);
                              char* l;
                              _getNewLabel(&l);
                              if($1->sNextL == NULL){
                                  debug();
                              }
                              strcpy($1->sNextL, l);
                              //$1->sNextL = l;
                              copyCode($$, $1);
                              copyCode($$, n_putLabel_(&($1->sNextL)));
                          }
| Exp SEMI          {$$ = own2Child("PStmt", $1, $2); 
                        //不应该在这里输出，只是测试用
                        //printCode($1);
                        copyCode($$, $1);
                        }
| CompSt                {$$ = own1Child("PStmt", $1);
                            copyCode($$, $1);
                        }
| RETURN Exp SEMI       {$$ = own3Child("PStmt", $1, $2, $3);
                            //添加返回链表
                            FUNCRt* newNode = (FUNCRt*)malloc(sizeof(FUNCRt));
                            newNode->line = $1->lineNo;
                            newNode->type = $2->type;
                            newNode->next = FUNCRtType;
                            FUNCRtType = newNode;

                            copyCode($$, $2);
                            char* s1 = (char*)malloc(sizeof(char)*100);
                            //printf("RETURN %s\n", $2->coreName);
                            sprintf(s1, "RETURN %s\n", $2->coreName);
                            addCode($$, getCodeblock(1, s1));
                        }
;

// AFTIF:                  {
//                             _putLabel_(EXPTrue);
                            
//                         }
// ;
// PREWS:                  {
//                             _putLabel_(EXPTrue);
//                         }
// ;


Stmt:   IF LP Exp RP  PStmt    %prec AFTER_ELSE {
                                    $$ = own5Child("Stmt", $1, $2, $3, $4, $5);
                                    char* l1;
                                    _getNewLabel(&l1);
                                    strcpy($3->trueL, l1);
                                    //$3->falseL = $$->sNextL;
                                    labelAssign($3, $$, 1, 2);
                                    combineNodeCode($$, 3, $3, n_putLabel_(&($3->trueL)), $5);
                                        }    
| IF LP Exp RP  PStmt ELSE PStmt  {$$ = own7Child("Stmt", $1, $2, $3, $4, $5, $6, $7);
                                char* l1, *l2;
                                _getNewLabel(&l1);
                                _getNewLabel(&l2);
                                //$3->trueL = l1;
                                strcpy($3->trueL, l1);
                                //$3->falseL = l2;
                                strcpy($3->falseL, l2);
                                //$5->sNextL = $$->sNextL;
                                //$7->sNextL = $$->sNextL;
                                copyCode($$, $3); //B.code
                                copyCode($$, n_putLabel_(&($3->trueL)));
                                //addCode($$, getCodeblock(2,&($3->trueL)));
                                copyCode($$, $5);//S1.code
                                copyCode($$, n_putGoto_(&($$->sNextL)));
                                copyCode($$, n_putLabel_(&($3->falseL)));
                                copyCode($$, $7);//S2.code
                            //_popTfStack();
                            }
| WHILE LP Exp RP  PStmt {
                                $$ = own5Child("Stmt", $1, $2, $3, $4, $5);
                                // _putGoto_(STMTNext);
                                // _popSNextStack();
                                // _popTfStack();
                                char* begin, *l1;
                                _getNewLabel(&begin);
                                _getNewLabel(&l1);
                                strcpy($3->trueL,  l1);
                                //$3->falseL = $$->sNextL;
                                labelAssign($3, $$, 1, 2);
                                combineNodeCode($$, 5, n_putLabel_(&begin), $3, n_putLabel_(&($3->trueL)),
                                                $5, n_putGoto_(&begin));
                                }
| error SEMI            {$$ = own0Child("Stmt"); }
;

DefList:                {$$ = own0Child("DefList");
                            pushDefCodeListStk();
                            DEFCodeList = NULL;
                        }
| Def DefList           {$$ = own2Child("DefList", $1, $2);
                            addToDEFCodeList($1);
                        }
;
Def: Specifier  DecList SEMI {
                            $$ = own3Child("Def", $1, $2, $3);
                            Node* p = DECCodeList;
                            while(p){
                                copyCode($$, p);
                                p = p->next;
                            }
                            DECCodeList = NULL;
                            }
| Specifier error SEMI  {$$ = own0Child("Def"); }
;
DecList: Dec            {
                            $$ = own1Child("DecList", $1);
                            DECCodeList = NULL;
                            addToDECCodeList($1);
                        }
|  Dec COMMA  DecList     {$$ = own3Child("DecList", $1, $2, $3);
                            addToDECCodeList($1);
                        }
;
Dec:  VarDec             {$$ =  own1Child("Dec", $1);
                        copyCode($$, $1);
                        if(ISDefSt){
                          VarRec* newNode = (VarRec*)malloc(sizeof(VarRec));
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
                            combineNodeCode($$, 2, $1, $3);
                            addCode($$, getCodeblock(1, s_AEqualB_($1->coreName, $3->coreName)));
                          }
;

// VarDec:  ID                  {$$ = own1Child("VarDec", $1);}
// |  VarDec LB INT RB          {$$ = own4Child("VarDec", $1, $2, $3, $4);}
// ;
//消除左递归

VarDec:  ID VarDec_x  {$$ = own2Child("VarDec", $1, $2); 
                    _arrDefOperation_($$, $1, $2);
                    }
;
VarDec_x:              {$$ = own0Child("VarDec_x"); 
                        $$->type = 0; $$->arrDim=0; 
                        $$->subType=1; //用subtype来表示分配空间的大小
                        }
| LB INT RB VarDec_x  {$$ = own4Child("VarDec_x", $1, $2, $3, $4); 
                        $$->type = 5; 
                        $$->arrDim = $4->arrDim+1;
                        $$->subType= $4->subType * $2->ival;
                        }
;


//codeOK
Exp: Exp ASSIGNOP Exp    {$$ = own3Child("Exp", $1, $2, $3);
                        if($1->type != $3->type){
                            myerror(5, "赋值号两边的表达式类型不匹配。");
                        }else if($1->subType != -1){
                            myerror(6, "赋值号左边出现一个只有右值的表达式。");
                        }else if($1->type == 5 && ($1->subType != $3->subType || $1->arrDim != $3->arrDim)){
                            myerror(6, "赋值号两边的表达式类型不匹配。数组需要类型和维度都相同");
                        }else if($1->type == 3 && !checkListTypeEqual($1->stdefList, $3->stdefList)){
                            myerror(6, "赋值号两边的表达式类型不匹配。结构体类型不等价 ");
                        }else{
                            combineNodeCode($$, 2, $1, $3);
                            $$->type = $1->type;
                            if($1->subCoreName){
                                //printf("*%s := %s\n", $1->subCoreName, $3->coreName);
                                //printf("%s := *%s\n", $1->coreName, $1->subCoreName);
                                char* s1 = (char*)malloc(sizeof(char)*100);
                                char* s2 = (char*)malloc(sizeof(char)*100);
                                sprintf(s1, "*%s := %s\n", $1->subCoreName, $3->coreName);
                                sprintf(s2, "%s := *%s\n", $1->coreName, $1->subCoreName);
                                combineCode($$, 2, getCodeblock(1, s1), getCodeblock(1, s2));
                            }else{
                                //_AEqualB_($1->coreName, $3->coreName);
                                addCode($$, getCodeblock(1, s_AEqualB_($1->coreName, $3->coreName)));
                            }
                            $$->coreName = $1->coreName;
                        }
                        }
| Exp AND Exp  {    
                    $$ = own3Child("Exp", $1, $2, $3);
                    if($1->type != $3->type || $1->type != 1){
                        myerror(-2, "仅有int型变量才能进行逻辑运算");
                    }else{
                        $$->type = 1;
                        char* l;
                        _getNewLabel(&l);
                        strcpy($1->trueL, l);
                        // $1->falseL = $$->falseL;
                        // $3->trueL = $$->trueL;
                        // $3->falseL = $$->falseL;
                        labelAssign($1, $$, 1, 1);
                        labelAssign($3, $$, 0, 0);
                        labelAssign($3, $$, 1, 1);
                        combineNodeCode($$, 3, $1, n_putLabel_(&($1->trueL)), $3);
                    }}
| Exp OR Exp     {$$ = own3Child("Exp", $1, $2, $3);
                    if($1->type != $3->type || $1->type != 1){
                        myerror(-2, "仅有int型变量才能进行逻辑运算");
                    }else{
                        $$->type = 1;
                        $1->trueL = $$->trueL;
                        char* l;
                        _getNewLabel(&l);
                        strcpy($1->falseL, l);
                        // $3->trueL = $$->trueL;
                        // $3->falseL = $$->falseL;
                        labelAssign($3, $$, 0, 0);
                        labelAssign($3, $$, 1, 1);
                        combineNodeCode($$, 3, $1,n_putLabel_(&($1->falseL)), $3);
                    }}
| Exp RELOP Exp  {$$ = own3Child("Exp", $1, $2, $3);
                    if($1->type != $3->type || $1->type == 3 || $1->type == 4 || $1->type == 5){
                        myerror(7, "操作数类型不匹配或操作数类型与操作符不匹配");
                    }else{
                        //$$->type = $1->type;
                        //printf("IF %s %s %s GOTO %s\n", $1->coreName, $2->sval, $3->coreName, EXPTrue);
                        //_putGoto_(EXPFalse);
                        $$->type = 1;
                        combineNodeCode($$, 2, $1, $3);
                        char* s1 = (char*)malloc(sizeof(char)*100);
                        sprintf(s1, "IF %s %s %s GOTO ", $1->coreName, $2->sval, $3->coreName);
                        combineCode($$,3 , getCodeblock(1, s1), getCodeblock(2, &($$->trueL)), getCodeblock(1, "\n"));
                        copyCode($$, n_putGoto_(&($$->falseL)));

                    }}
| Exp PLUS Exp   {  //codeOK
                    $$ = own3Child("Exp", $1, $2, $3);
                    _expOption_($$, $1, $2, $3);
                    }
| Exp MINUS Exp  {  //codeOK
                    $$ = own3Child("Exp", $1, $2, $3);
                    _expOption_($$, $1, $2, $3);
                    }
| Exp STAR Exp   {  //codeOK
                    $$ = own3Child("Exp", $1, $2, $3);
                    _expOption_($$, $1, $2, $3);
                    }
| Exp DIV Exp    {  //codeOK
                    $$ = own3Child("Exp", $1, $2, $3);
                    _expOption_($$, $1, $2, $3);
                    }
| LP Exp RP      {  //codeOK
                    //$$ = own3Child("Exp", $1, $2, $3);
                    //copyCode($$, $2);
                    //$$->type = $2->type;
                    //$$->coreName = $2->coreName;
                    $$ = $2; 
                    // 这里处理的很巧妙，因为括号只是起到辅助归约的作用实际上节点没有任何的区别。
                }
| MINUS Exp    %prec RMINUS  {  //codeOK
                                $$ = own2Child("Exp", $1, $2);
                                if($2->type != 1 && $2->type != 2){
                                    myerror(-2, "仅有int型和float型变量才能参与算术运算。");
                                }else{
                                    $$->type = $2->type;
                                }
                                copyCode($$, $2);
                                char* t;
                                _getNewTemp(&t);
                                $$->coreName = t;
                                char tt[20];
                                sprintf(tt, "- %s", $2->coreName);
                                //_AEqualB_(t, tt);
                                addCode($$, getCodeblock(1, s_AEqualB_(t, tt)));
                            }
| NOT Exp     {$$ = own2Child("Exp", $1, $2);
                    if($2->type != 1){
                        myerror(-2, "仅有int型变量才能进行逻辑运算");
                    }else{
                        $$->type = 1;
                        // $2->trueL = $$->falseL;
                        //$2->falseL = $$->trueL;
                        labelAssign($2, $$, 0, 1);
                        labelAssign($2, $$, 1, 0);
                        copyCode($$, $2);
                    }}
| ID LP Args RP  {  //codeOK
                    $$ = own4Child("Exp", $1, $2, $3, $4);
                    if(!strcmp($1->sval, "write")){
                        //printf("WRITE %s\n", $3->coreName);
                        char* s1 = (char*)malloc(sizeof(char)*100);
                        sprintf(s1, "WRITE %s\n", $3->coreName);
                        addCode($$, getCodeblock(1, s1));
                        $$->coreName = "#0";
                        $$->type = 1;
                    }else{
                        
                        _callFunc_($$, $1, $3); 
                    }
                }
| ID LP RP       {  //codeOK
                    $$ = own3Child("Exp", $1, $2, $3);
                    
                    if(!strcmp("read", $1->sval)){
                        char* t;
                        _getNewTemp(&t);
                        char* s1 = (char*)malloc(sizeof(char)*100);
                        //printf("READ %s\n", t);
                        sprintf(s1, "READ %s\n", t);
                        addCode($$, getCodeblock(1, s1));
                        $$->coreName = t;
                        $$->type = 1;
                    }else{
                        _callFunc_($$, $1, NULL);
                    }
                }
| Exp LB Exp RB  {  //codeOK
                    $$ = own4Child("Exp", $1, $2, $3, $4);
                    $$->subType = -1; //表示这是一个左值
                    if($1->type != 5){
                        myerror(10, "对非数组型变量使用“[…]”（数组访问）操作符。");
                    }else if($3->type != 1){
                        myerror(12, "数组访问操作符“[…]”中出现非整数");
                    }else if($1->arrDim == 1){
                        $$->type = $1->subType;
                        int size = 4;
                        if($$->type == 3){
                            StRec * rec = checkStRec($1);
                            $$->stdefList = rec->def_list;
                            size = rec->size;
                        }
                        //因为要求中说只考虑一维数组，所以这里不考虑高维数组的情况
                        char* t1, *t2, *t3;
                        _getNewTemp(&t1);
                        _getNewTemp(&t2);                        
                        _getNewTemp(&t3);
                        char* s1 = (char*)malloc(sizeof(char)*100);     
                        char* s2 = (char*)malloc(sizeof(char)*100);     
                        char* s3 = (char*)malloc(sizeof(char)*100);     
                        sprintf(s1, "%s := %s * #%d\n", t1, $3->coreName, size);
                        sprintf(s2, "%s := %s + %s\n", t2, $1->coreName, t1);
                        sprintf(s3, "%s := *%s\n", t3, t2);
                        // printf("%s := %s * 4\n", t1, $3->coreName);
                        // printf("%s := %s + %s\n", t2, $1->coreName, t1);
                        // printf("%s := *%s\n", t3, t2);
                        combineNodeCode($$, 2, $1, $3);
                        combineCode($$, 3, getCodeblock(1, s1), getCodeblock(1, s2), getCodeblock(1, s3));
                        $$->coreName = t3;
                        $$->subCoreName = t2;
                    }else{
                        $$->type = 5;
                        $$->arrDim = ($1->arrDim)-1;
                        $$->subType = $1->subType;
                    }
                    }
| Exp DOT ID   {
                $$ = own3Child("Exp", $1, $2, $3);
                $$->subType = -1; //表示这是一个左值
                if($1->type != 3){
                    myerror(13, "对非结构体型变量使用“.”操作符。");
                }else{
                    
                    VarRec* p = $1->stdefList;
                    int flag = 0;
                    while(p){
                        if(!strcmp(p->name, $3->sval)){
                            $$->type = p->type;
                            if(p->type == 5){
                                Node* tempN = (Node*)malloc(sizeof(Node));
                                tempN->sval = p->name;
                                ArrRec* rec = checkArrRec(tempN);
                                $$->subType = rec->type;
                                $$->arrDim = rec->dim;
                            }
                            int addr = p->address;
                            char* t1, *t2;
                            _getNewTemp(&t1);
                            _getNewTemp(&t2);
                            char* s1 = (char*)malloc(sizeof(char)*100);     
                            char* s2 = (char*)malloc(sizeof(char)*100);
                            sprintf(s1, "%s := %s + #%d\n", t2, $1->coreName, addr);
                            sprintf(s2, "%s := *%s\n", t1, t2);
                            $$->coreName = t1;
                            $$->subCoreName = t2;
                            copyCode($$, $1);
                            combineCode($$, 2, getCodeblock(1, s1), getCodeblock(1, s2));
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
| ID    {
        $$ = own1Child("Exp", $1); 
        $$->subType = -1; //表示这是一个左值
        VarRec* rcd = checkVarRec($1);
        if(rcd == NULL){
            myerror(1, "变量在使用时未经定义");
        }else{
            $$->type = rcd->type;
            $$->coreName = rcd->coreName;
            if($$->type == 3){
                StRec* strcd = checkStRec($1);
                $$->stdefList = strcd->def_list;
            }else if($$->type == 5){
                ArrRec* arrrcd = checkArrRec($1);
                $$-> subType= arrrcd->type;
                $$-> arrDim= arrrcd->dim;
                $$->sval = $1->sval;
            }
        }
        
        }
| INT   {$$ = own1Child("Exp", $1); $$->type = 1;
        $$->coreName = _insNumFmt($1->sval);
        // char* t;
        // _getNewTemp(&t);
        // _AEqualB_(t, _insNumFmt($1->sval));
        // $$->coreName = t;
}
| FLOAT {$$ = own1Child("Exp", $1); $$->type = 2;
        $$->coreName = _insNumFmt($1->sval);
        // char* t;
        // _getNewTemp(&t);
        // _AEqualB_(t, _insNumFmt($1->sval));
        // $$->coreName = t;
        }
;
Args: Exp COMMA Args  {  //codeOK
                    $$ = own3Child("Args", $1, $2, $3);
                    $$->parmCnt = ($3->parmCnt)+1;
                    VarRec* arg = (VarRec*)malloc(sizeof(VarRec));
                    arg->name=NULL;
                    arg->type=$1->type;
                    arg->next = $3->parmList;
                    $$->parmList = arg;
                    $$->coreName = $1->coreName;
                    if(!SPECIALFUNC){
                       //printf("ARG %s\n", $1->coreName); 
                       combineNodeCode($$, 2, $1, $3);
                       char* s = (char*)malloc(sizeof(char)*100);
                       sprintf(s, "ARG %s\n", $1->coreName); 
                       addCode($$, getCodeblock(1, s));
                    }
                    }
| Exp   {  //codeOK
        $$ = own1Child("Args", $1);
        $$->parmCnt = 1;
        VarRec* arg = (VarRec*)malloc(sizeof(VarRec));
        arg->name=NULL;
        arg->type=$1->type;
        $$->parmList = arg;
        $$->coreName = $1->coreName;
        if(!SPECIALFUNC){
            //printf("ARG %s\n", $1->coreName);
            copyCode($$, $1);
            char* s = (char*)malloc(sizeof(char)*100);
            sprintf(s, "ARG %s\n", $1->coreName);
            addCode($$, getCodeblock(1, s));
        }
        }
;
%%

