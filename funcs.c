#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdarg.h>
#include "funcs.h"

int getVarRecSize(VarRec * p){
    int lastLength = 0;
    Node* tempN = (Node*)malloc(sizeof(Node));
    switch (p->type){
        case 0:
            printf("声明类型为0,错误\n");
            break;
        case 1:
            lastLength = 4;
            break;
        case 2:
            lastLength = 4;
            break;
        case 3:
            tempN->sval = p->name;
            StRec* st_rec = checkStRec(tempN); 
            if(st_rec == NULL){
                printf("找不到结构体\n");
            }else{
                lastLength = st_rec->size;
            }
            break;
        case 5:
            tempN->sval = p->name;
            ArrRec* arr_rec = checkArrRec(tempN);
            if(arr_rec ==NULL){
                printf("找不到数组\n");
            }else{
                lastLength = arr_rec->size;
            }
            break;
        default:
            break;
    }
    return lastLength;
}

//注意这里不支持结构体的自嵌套, 返回的是结构体的总长度。
int  setRelAddress(VarRec* stdefList){
    VarRec* p = stdefList;
    int lastLength = 0;
    int lastAddr = 0;
    int size = 0;
    //Node* tempN = (Node*)malloc(sizeof(Node));
    while (p){
        p->address = lastAddr + lastLength;
        lastAddr = p->address;
        lastLength = getVarRecSize(p);
        p = p->next;
    }
    size = lastAddr + lastLength;
    return size;
}

int checkStLength(VarRec* stdDclList){
    int length = 0;
    int lastaddr = 0;
    if(stdDclList != NULL){
        VarRec* p = stdDclList;
        while (p->next){
            p = p->next;
        }
        lastaddr = p->address;
        length = lastaddr +  getVarRecSize(p);
    }
    return length;
}

//将lbaddr添加到tgt的type标签的引用表里边
void addToCiteTable(Node* tgt, char** lbaddr, int type){
    if(type > 2 || type < 0){
        printf("\n类型错误\n");
        return;
    }
    int top = tgt->citeTableTop[type];
    tgt->citeTable[type][top] = lbaddr;
    tgt->citeTableTop[type] = top + 1;
}

void labelAssign(Node*  tgt, Node* src, int tgtType, int srcType){
    if(tgtType > 2 || tgtType < 0|| srcType > 2 || srcType < 0){
        printf("\n类型错误\n");
        return;
    }
    //添加tgt到src的引用。
    addToCiteTable(src, tgt->labelsAddr[tgtType], srcType);
    //将src的值付给tgt。
    *(tgt->labelsAddr[tgtType]) = *(src->labelsAddr[srcType]);
    //将src的值付给tgt的引用列表中的所有值，并且将那些引用添加到src的引用列表中
    int citeCount = tgt->citeTableTop[tgtType];
    for( int i = 0; i < citeCount; i++){
        *(tgt->citeTable[tgtType][i]) = *(src->labelsAddr[srcType]);
        addToCiteTable(src, tgt->citeTable[tgtType][i], srcType);
    }
}




void addToDECCodeList(Node* node){
    if(node->codeHead != NULL && node->codeTail != NULL){
        node->next = DECCodeList;
        DECCodeList = node;
    }
}

void addToDEFCodeList(Node* node){
    if(node->codeHead != NULL && node->codeTail != NULL){
        node->next = DEFCodeList;
        DEFCodeList = node;
    }
}

void addToPStmtCodeList(Node* node){
    if(node->codeHead != NULL && node->codeTail != NULL){
        node->next = PStmtCodeList;
        PStmtCodeList = node;
    }
}

//level表示创建的类型，1->一级指针， 2->二级指针
CodeBlock* getCodeblock(int level, ...){
    CodeBlock* newBlock = (CodeBlock*)malloc(sizeof(CodeBlock));
    newBlock->level=level;
    va_list pArgs;
    va_start(pArgs, level);
    if(level == 1){
        char* str = va_arg(pArgs, char*);
        newBlock->pCode = str;
    }else if (level == 2){
        char** pstr = va_arg(pArgs, char**);
        newBlock->ppCode = pstr;
    }else{
        printf("build code block error\n");
    }
    va_end(pArgs);
    return newBlock;
}

void combineNodeCode(Node* target, int num, ...){
    va_list pArgs;
    va_start(pArgs, num);
    if(num > 0){
        while (num){
            Node* curNode = va_arg(pArgs, Node*);
            num--;
            copyCode(target, curNode);
        }
    }
    va_end(pArgs);
}

//将num个codeBlock合并起来添加到targetNode对应代码的后面
void combineCode(Node* target, int num, ...){
    va_list pArgs;
    va_start(pArgs, num);
    if(num >= 1){
        CodeBlock* curCode = va_arg(pArgs, CodeBlock*);
        CodeBlock* firstCode = curCode;
        num--;
        while (num){
            CodeBlock* newCode = va_arg(pArgs, CodeBlock*);
            num--;
            curCode->next = newCode;
            curCode = curCode->next;
        }
        if(target->codeHead == NULL && target->codeTail == NULL){
            target->codeHead = firstCode;
            target->codeTail = curCode;
        }else{
            curCode->next = target->codeTail->next;
            target->codeTail->next = firstCode;
            target->codeTail = curCode;
        }
    }
    va_end(pArgs);
}

void addCode(Node* target, CodeBlock* code){
    combineCode(target, 1, code);
}

//将source的代码拷贝到target的后面
void copyCode(Node* target, Node* source){
    if(source->codeHead != NULL && source->codeTail !=NULL){
        CodeBlock* firstCode = source->codeHead;
        CodeBlock* curCode = source->codeTail;
        if(target->codeHead == NULL && target->codeTail == NULL){
            target->codeHead = firstCode;
            target->codeTail = curCode;
        }else{
            curCode->next = target->codeTail->next;
            target->codeTail->next = firstCode;
            target->codeTail = curCode;
        }
    }
}

void printCode(Node* node){
    if(node != NULL){
        CodeBlock* p = node->codeHead;
        while (p){
            char* code = (p->level==1) ? p->pCode : (*(p->ppCode));
            printf("%s", code);
            if(p == node->codeTail){
                break;
            }else{
                p = p->next;
            }
        }
    }
}




// void _AEqualB_(char* a, char* b){
//     printf("%s := %s\n", a, b);
// }

char*  s_AEqualB_(char* a, char* b){
    char* s1 = (char*)malloc(sizeof(char)*100);
    //printf("%s := %s\n", a, b);
    sprintf(s1, "%s := %s\n", a, b);
    return s1;
}

// void _putLabel_(char* l){
//     printf("LABEL %s :\n", l);
// }

// void _putGoto_(char* l){
//     printf("GOTO %s\n", l);
// }

Node* n_putLabel_(char** l){
    //printf("LABEL %s :\n", l);
    Node* outCode = (Node*)malloc(sizeof(Node));
    combineCode(outCode, 3, getCodeblock(1, "LABEL "),
                 getCodeblock(2, l), getCodeblock(1, " :\n"));
    return outCode;
}

Node* n_putGoto_(char** l){
    //printf("GOTO %s\n", l);
    Node* outCode = (Node*)malloc(sizeof(Node));
    combineCode(outCode, 3, getCodeblock(1, "GOTO "),
                 getCodeblock(2, l), getCodeblock(1, "\n"));
    return outCode;
}

// void _pushTfStack(){
//     int top = ++tfStack.top;
//     tfStack.stack[top][0] = EXPTrue;
//     tfStack.stack[top][1] = EXPFalse;
// }

// void _popTfStack(){
//     int top = tfStack.top;
//     EXPTrue = tfStack.stack[top][0];
//     EXPFalse = tfStack.stack[top][1];
//     tfStack.top--;
// }

// void _pushSNextStack(){
//     int top = ++sNextStack.top;
//     sNextStack.stack[top] = STMTNext;
// }

// void _popSNextStack(){
//     int top = sNextStack.top;
//     STMTNext = sNextStack.stack[top];
//     sNextStack.top--;
// }

void pushDefCodeListStk(){
    int top = ++defCodeListStk.top;
    defCodeListStk.stack[top] = DEFCodeList;
}

void popDefCodeListStk(){
    int top = defCodeListStk.top;
    DEFCodeList = defCodeListStk.stack[top];
    defCodeListStk.top--;
}

void pushPStmtCodeListStk(){
    int top = ++pStmtCodeListStk.top;
    pStmtCodeListStk.stack[top] = PStmtCodeList;
}

void popPStmtCodeListStk(){
    int top = pStmtCodeListStk.top;
    PStmtCodeList = pStmtCodeListStk.stack[top];
    pStmtCodeListStk.top--;
}

char* _insNumFmt(char* in){
    char * out;
    out = (char*)malloc(sizeof(char)*20);
    sprintf(out, "#%s", in);
    return out;
}

void _callFunc_(Node* ss, Node* s1, Node* s3){
    if(s3 == NULL){
        s3 = (Node*)malloc(sizeof(Node));
        s3->parmList=NULL;
        s3->parmCnt=0;
    }
    VarRec* rcd = checkVarRec(s1);
    if(rcd != NULL){
        myerror(11, "对普通变量使用“(…)”或“()”（函数调用）操作符。");
    }else{
        FuncRec* funrcd = checkFuncRec(s1);
        if(funrcd == NULL){
            myerror(2, "函数在调用时未经定义。");
        }else if(funrcd->para_count != s3->parmCnt){
            myerror(9, "函数调用时实参与形参的数目不匹配。");
        }else{
            VarRec* p = funrcd->def_list;
            VarRec* q = s3->parmList;
            int flag = 1;
            while(p || q){
                if(p == NULL | q == NULL){
                    flag = 0;
                    break;
                }
                if(p->type != q->type){
                    flag = 0;
                }
                p = p->next;
                q = q->next;
            }
            if(flag == 0){
                myerror(9, "函数调用时实参与形参类型不匹配。");
            }
            ss->type = funrcd->rtype;
            char* t;
            _getNewTemp(&t);
            ss->coreName = t;
            char tt[20];
            sprintf(tt, "CALL %s", s1->sval);
            //_AEqualB_(t, tt);
            if(s3->codeHead == NULL){
                debug();
            }
            copyCode(ss, s3);
            addCode(ss, getCodeblock(1, s_AEqualB_(t, tt)));
        }
        
        
    }
}

void _expOption_(Node* ss, Node* s1, Node* s2, Node* s3){
    if(s1->type != s3->type || s1->type == 3 || s1->type == 4 || s1->type == 5){
        myerror(7, "操作数类型不匹配或操作数类型与操作符不匹配");
    }else{
        ss->type = s1->type;
    }
    combineNodeCode(ss, 2, s1, s3);
    char* t;
    _getNewTemp(&t);
    ss->coreName = t;
    char tt[20];
    sprintf(tt, "%s %s %s", s1->coreName, s2->sval, s3->coreName);
    //_AEqualB_(t, tt);
    addCode(ss, getCodeblock(1, s_AEqualB_(t, tt)));
}

void _decFunc_(Node * ID){
    printf("FUNCTION %s :\n", ID->sval);
    VarRec* p = ID->parmList;
    while (p){
        char * v;
        v = _checkCoreName(p->name);
        printf("PARAM %s\n", v);
        p = p->next;
    }
}

char* _checkCoreName(char* varname){
    char * out = NULL;
    VarRec* p = var_head;
    p = p->next;
    while (p){
        if(!strcmp(p->name, varname)){
            out = p->coreName;
            break;
        }
        p = p->next;
    }
    return out;
} 

void _arrDefOperation_(Node* ss, Node* s1, Node*s2){
    s1->type = IDType;
    //如果ID是结构体而不是结构体数组的时候，为ID添加结构体内容链。
    if(s1->type == 3 && s2->type != 5){
        s1->stdefList = STDclList;
        addStRec(s1);
        //让VarDec包含ID的类型和值
        ss->type = s1->type;
        ss->sval = s1->sval;
        if(addVarRec(s1) == 0){
            if(ISDefSt){
                myerror(5, "结构体中域名重复定义");
            }else{
                myerror(3, "变量出现重复定义，或变量与前面定义过的结构体名字重复。");
            }
        }
        int size = checkStLength(STDclList);
        char* s = (char*)malloc(sizeof(char)*100);
        //printf("DEC %s %d\n", s1->coreName, s2->subType*4);
        sprintf(s, "DEC %s %d\n", s1->coreName, size);
        addCode(ss, getCodeblock(1, s));
    }
    //如果是数组的话则改变ID的类型，否则不变。
    else if(s2->type == 5){
        s1->subType = s1->type;
        s1->type = 5;
        s1->arrDim = s2->arrDim;
        int size = s2->subType*4;
        s1->parmCnt = size;
        //如果是结构体数组的话
        if(s1->subType == 3){
            s1->stdefList = STDclList;
            s1->parmCnt = checkStLength(STDclList);
            addStRec(s1);
            size = s2->subType * checkStLength(STDclList);
            s1->parmCnt = size;
        }
        addArrRec(s1);
        //让VarDec包含ID的类型和值
        ss->type = s1->type;
        ss->sval = s1->sval;
        if(addVarRec(s1) == 0){
            if(ISDefSt){
                myerror(5, "结构体中域名重复定义");
            }else{
                myerror(3, "变量出现重复定义，或变量与前面定义过的结构体名字重复。");
            }
        }
        char* s = (char*)malloc(sizeof(char)*100);
        //printf("DEC %s %d\n", s1->coreName, s2->subType*4);
        sprintf(s, "DEC %s %d\n", s1->coreName, size);
        addCode(ss, getCodeblock(1, s));
        
    }else{
        //让VarDec包含ID的类型和值
        ss->type = s1->type;
        ss->sval = s1->sval;
        if(addVarRec(s1) == 0){
            if(ISDefSt){
                myerror(5, "结构体中域名重复定义");
            }else{
                myerror(3, "变量出现重复定义，或变量与前面定义过的结构体名字重复。");
            }
        }
    }
    ss->coreName = _checkCoreName(s1->sval);
}

void _getNewVar(char** out){
    VARnum++;
    (*out) = (char*)malloc(sizeof(char)*20);
    sprintf((*out), "v_%03d", VARnum);
    return;
}

void _getNewTemp(char** out){
    TEMPnum++;
    (*out) = (char*)malloc(sizeof(char)*20);
    sprintf((*out), "t_%03d", TEMPnum);
    return;
}

void _getNewLabel(char** out){
    LABELnum++;
    (*out) = (char*)malloc(sizeof(char)*20);
    sprintf((*out), "label_%03d", LABELnum);
    return;
}

void addToParmList(VarRec* node){
    node->next = PARMList;
    PARMList = node;
}

void addToSTDefList(VarRec* node){
    //debug();
    //printf("-");
    // node->next = STDefList;
    // STDefList = node;
    node->next = NULL;
    if(STDefList == NULL){
        STDefList = node;
    }else{
        VarRec*p = STDefList;
        while (p->next){
            p = p->next;
        }
        p->next = node;
    }
}

void outPutLinks(VarRec* link){
    printf("\n---link-start\n");
    while (link)
    {
        printf("[%d, %s]", link->type, link->name);
        link = link->next;
    }
    printf("\n---link-end\n");
}

void funcDefOption(Node* ss, Node* s1, Node* s2, Node* s3){
    //设置返回值类型
    (s2->children[0])->subType = s1->type;
        // if(addFuncRec(s2->children[0]) == 0){
        // myerror(4, "函数出现重复定义");
        // }
    // FuncRec* q = func_head;
    // q=q->next;
    // int flag = 0;
    // while(q){
    //     if(!strcmp(q->name, (s2->children[0])->sval)){
    //         q->rtype = s1->type;
    //         flag = 1;
    //         break;
    //     }
    //     q=q->next;
    // }
    // if(flag==0){
    //     debug();
    // }
    /*检查函数的返回类型*/
    FUNCRt* p =  FUNCRtType;
    if(p == NULL){
        myerror(8, "函数缺少返回值");
    }
    while(p){
        if(p->type != s1->type){
            printf("Error type 8 at Line %d: return语句的返回类型与函数定义的返回类型不匹配。\n",p->line);
        }
        p = p->next;
    }
    FUNCRtType=NULL;
}

int checkListTypeEqual(VarRec* link, VarRec* link2){
    VarRec *p=link, *q=link2;
    int flag = 1;
    while(p || q){
        if(p == NULL | q == NULL){
            flag = 0;
            break;
        }else if(p->type != q->type){
                flag = 0;
                break;
        }
        p = p->next; q = q->next;
    }
    return flag;
}

void debug(){
    printf("\n--------debug---------\n");
}

//增加变量记录 0->失败 1->成功
int addVarRec(Node* ID){
    if(ID == NULL){
        printf("error get info from ID");
        return 0;
    }else if(checkVarRec(ID) != NULL){
        //已经存在。
        return 0;
    }else{
        VarRec* newNode = (VarRec*)malloc(sizeof(VarRec));
        char* v;
        _getNewVar(&v);
        newNode->coreName = v; //增加变量在中间代码中的名字。
        ID->coreName = v; //也将这个值返回给ID
        newNode->name = ID->sval;
        newNode->type = ID->type;
        newNode->next = NULL;
        var_tail->next = newNode;
        var_tail = var_tail->next;


        return 1;
    }
}
//查找变量记录 0表示没找到 1表示找到了
VarRec* checkVarRec(Node* ID){
    if(ID == NULL){
        printf("error get info from ID");
        return NULL;
    }else{
        VarRec* p = var_head;
        if(p->next==NULL){
            return NULL;
        }
        p=p->next;
        while (p!=NULL)
        {
            if(!strcmp(p->name, ID->sval)){
                return p;
            }else{
                p=p->next;
            }
        }
        return NULL;
    }
}

//建立函数符号表
int addFuncRec(Node* ID){
    if(ID == NULL){
        printf("error get info from ID");
        return 0;
    }else if(checkFuncRec(ID) != NULL){
        return 0;
    }else{
        FuncRec* newNode = (FuncRec*)malloc(sizeof(FuncRec));
        newNode->name = ID->sval;
        newNode->next = NULL;
        newNode->rtype = ID->subType;
        newNode->def_list = ID->parmList;
        newNode->para_count = ID->parmCnt;
        func_tail->next = newNode;
        func_tail = func_tail->next;
        return 1;
    }
}
//查找函数记录，找不到返回NULL，找到了就返回指针
FuncRec* checkFuncRec(Node* ID){
    if(ID == NULL){
        printf("error get info from ID");
        return NULL;
    }else{
        FuncRec* p = func_head;
        if(p->next==NULL){
            return NULL;
        }
        p=p->next;
        while (p!=NULL)
        {
            if(!strcmp(p->name, ID->sval)){
                return p;
            }else{
                p=p->next;
            }
        }
        return NULL;
    }
}

//增加数组记录
void addArrRec(Node* ID){
    if(ID == NULL){
        printf("error get info from ID");
        return;
    }else{
        ArrRec* newNode = (ArrRec*)malloc(sizeof(ArrRec));
        newNode->name = ID->sval;
        newNode->type = ID->subType;
        newNode->next = NULL;
        newNode->dim = ID->arrDim;
        newNode->size = ID->parmCnt;
        arr_tail->next = newNode;
        arr_tail = arr_tail->next;
        return;
    }
}

//查找数组记录，找不到返回NULL，找到了就返回指针
ArrRec* checkArrRec(Node* ID){
    if(ID == NULL){
        printf("error get info from ID");
        return NULL;
    }else{
        ArrRec* p = arr_head;
        if(p->next==NULL){
            return NULL;
        }
        p=p->next;
        while (p!=NULL)
        {
            if(!strcmp(p->name, ID->sval)){
                return p;
            }else{
                p=p->next;
            }
        }
        return NULL;
    }
}

//增加结构体记录
void addStRec(Node* ID){
    if(ID == NULL){
        printf("error get info from ID");
        return;
    }else{
        StRec* newNode = (StRec*)malloc(sizeof(StRec));
        newNode->name = ID->sval;
        newNode->def_list = ID->stdefList;
        newNode->next = NULL;
        newNode->size = ID->parmCnt;
        st_tail->next = newNode;
        st_tail = st_tail->next;
        return;
    }
}

//查找结构体记录，找不到返回NULL，找到了就返回指针
StRec* checkStRec(Node* ID){
    if(ID == NULL){
        printf("error get info from ID");
        return NULL;
    }else{
        StRec* p = st_head;
        if(p->next==NULL){
            return NULL;
        }
        p=p->next;
        while (p!=NULL)
        {
            if(!strcmp(p->name, ID->sval)){
                return p;
            }else{
                p=p->next;
            }
        }
        return NULL;
    }
}

int power(int a, int b){
    int out = 1;
    for (size_t i = 0; i < b; i++)
    {
        out *= a;
    }
    return out;
}



int HToD(char * str, int leng){
    str += 2;
    leng -= 2;
    int out=0;
    for (int i = 0; i < leng; i++){
        int num;
        if(str[i] >= '0' && str[i] <= '9'){
            num = str[i] - '0';
        }else{
            num = 10 + str[i] - 'A';
        }
        out += power(16, leng-i-1)*num;
    }
    return out;
}

int OToD(char * str, int leng){
    str++;
    leng--;
    int out=0;
    for (int i = 0; i < leng; i++){
        int num = str[i]-'0';
        out += power(8, leng-i-1)*num;
    }
    return out;
}

float strTof(char * str, int leng){
    int indexE = strchr(str, 'e') - str;
    str[indexE] = '\0';
    float after = atof(str+indexE+1);
    float before = atof(str);
    float out = before * powf(10, after);
    return out;
}


Node* getTermNode(int lineno, char* tkName){
    Node* Nptr = (Node*) malloc(sizeof(Node));
    Nptr->nodeType = 0;
    Nptr->tkName = tkName;
    Nptr->lineNo = lineno;
    Nptr->chCount = 0;
    return Nptr;
}

//创建ID TYPE  FLOAT 3个类型的节点
Node* getStrNode(char* yytext, int lineno, char* tkName,int yyleng){
    char* str = (char*) malloc((yyleng+10) * sizeof(char));
    strncpy(str, yytext, (size_t)yyleng);
    //sval[yyleng] = '\0';
    Node* Nptr = (Node*) malloc(sizeof(Node));
    Nptr->nodeType = 0;
    Nptr->tkName = tkName;
    Nptr->lineNo = lineno;
    Nptr->chCount = 0;
    Nptr->sval = str;
    Nptr->trueL = (char*)malloc(sizeof(char)*100);
    Nptr->falseL = (char*)malloc(sizeof(char)*100);
    Nptr->sNextL = (char*)malloc(sizeof(char)*100);
    Nptr->labelsAddr[0] = &(Nptr->trueL);
    Nptr->labelsAddr[1] = &(Nptr->falseL);
    Nptr->labelsAddr[2] = &(Nptr->sNextL);
    if(!strcmp(tkName, "FLOAT")){
        //Nptr->type = "float";
        if(strchr(str, 'e') != NULL){
            Nptr->fval=strTof(str, yyleng);
        }else{
            Nptr->fval = atof(str);
        }
    }else if (!strcmp(tkName, "INT")){
        //Nptr->type = "float";
        if(str[0] == '0' && str[1] == 'x'){
            Nptr-> ival = HToD(str, yyleng);
        }else if(str[0] == '0'){
            Nptr->ival = OToD(str, yyleng);
        }else{
            Nptr -> ival = atoi(str);
        }
    }
    return Nptr;
}
// //INT
// Node* getIntNode(int yyint, int lineno){
//     Node* Nptr = (Node*) malloc(sizeof(Node));
//     Nptr->nodeType = 0;
//     Nptr->tkName = "INT";
//     Nptr->lineNo = lineno;
//     Nptr->chCount = 0;
//     Nptr->ival = yyint;
//     return Nptr;
// }

Node* ownManyChild(char* tkName, int count, Node* ch0, Node* ch1, 
                    Node* ch2,Node* ch3, Node* ch4, Node* ch5, Node* ch6){
    Node* Nptr = (Node*) malloc(sizeof(Node));
    Nptr->nodeType = 1;
    Nptr->tkName = tkName;
    Nptr->lineNo = count==0?-1:ch0->lineNo;
    Nptr->chCount = count;
    Nptr->trueL = (char*)malloc(sizeof(char)*100);
    Nptr->falseL = (char*)malloc(sizeof(char)*100);
    Nptr->sNextL = (char*)malloc(sizeof(char)*100);
    Nptr->labelsAddr[0] = &(Nptr->trueL);
    Nptr->labelsAddr[1] = &(Nptr->falseL);
    Nptr->labelsAddr[2] = &(Nptr->sNextL);
    Nptr->children[0] = ch0;
    Nptr->children[1] = ch1;
    Nptr->children[2] = ch2;
    Nptr->children[3] = ch3;
    Nptr->children[4] = ch4;
    Nptr->children[5] = ch5;
    Nptr->children[6] = ch6;
    return Nptr;
}

Node* own0Child(char* tkName){
    Node* Nptr = ownManyChild(tkName, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
                    
    return Nptr;
}

Node* own1Child(char* tkName, Node* ch0){
    
    Node* Nptr = ownManyChild(tkName, 1, ch0, NULL, NULL, NULL, NULL, NULL, NULL);
                    
    return Nptr;
}

Node* own2Child(char* tkName, Node* ch0, Node* ch1){
    
    Node* Nptr = ownManyChild(tkName, 2, ch0, ch1, NULL, NULL, NULL, NULL, NULL);
                    
    return Nptr;
}

Node* own3Child(char* tkName, Node* ch0, Node* ch1, Node* ch2){
    
    Node* Nptr = ownManyChild(tkName, 3, ch0, ch1, ch2, NULL, NULL, NULL, NULL);
                    
    return Nptr;
}

Node* own4Child(char* tkName, Node* ch0, Node* ch1, Node* ch2,Node* ch3){
    
    Node* Nptr = ownManyChild(tkName, 4, ch0, ch1, ch2,ch3, NULL, NULL, NULL);
                    
    return Nptr;
}

Node* own5Child(char* tkName, Node* ch0, Node* ch1, Node* ch2,Node* ch3, Node* ch4){
    
    Node* Nptr = ownManyChild(tkName, 5, ch0, ch1, ch2,ch3, ch4, NULL, NULL);
                    
    return Nptr;
}

Node* own7Child(char* tkName, Node* ch0, Node* ch1, 
                    Node* ch2,Node* ch3, Node* ch4, Node* ch5, Node* ch6){
    Node* Nptr = ownManyChild(tkName, 7, ch0, ch1, ch2,ch3, ch4, ch5, ch6);
                    
    return Nptr;
}

void initiate(){
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
    FUNCRtType=NULL;
    LABELnum = 0;
    VARnum = 0;
    TEMPnum = 0;
    SPECIALFUNC=0;
    TESTFunStage=0;
    FUNCRtTypeINT=0;
    

    Node* funcRead = (Node*)malloc(sizeof(Node));
    funcRead->sval = "read";
    funcRead->subType = 1; //返回的是从控制台读入的数据
    funcRead->parmList = NULL;
    funcRead->parmCnt = 0;
    addFuncRec(funcRead);

    Node* funcWrite = (Node*)malloc(sizeof(Node));
    funcWrite->sval = "write";
    funcWrite->subType = 1; // 返回值固定为0;
    VarRec* intParm = (VarRec*)malloc(sizeof(VarRec));
    intParm->type = 1;
    intParm->name = "undefined";
    intParm->next = NULL;
    funcWrite->parmList = intParm;
    funcWrite->parmCnt = 1;
    addFuncRec(funcWrite);

    // tfStack.top=-1;
    // EXPTrue =NULL;
    // EXPFalse =NULL;
    // sNextStack.top=-1;
    // STMTNext =NULL;
    defCodeListStk.top = -1;
    pStmtCodeListStk.top = -1;
    DEFCodeList = NULL; 
    DECCodeList = NULL;
    PStmtCodeList = NULL; 
    // char* a = "123\n", *b = "666\n";
    // Node* testNode = (Node*)malloc(sizeof(Node));
    // Node* testNode2 = (Node*)malloc(sizeof(Node));
    // Node* testNode3 = (Node*)malloc(sizeof(Node));
    // combineCode(testNode, 3, getCodeblock(1, "555\n"), getCodeblock(1, "777\n"), getCodeblock(2, &b));
    // addCode(testNode2, getCodeblock(1, "123123123\n"));
    // addCode(testNode2, getCodeblock(2, &a));
    // addCode(testNode3, getCodeblock(1, "123123123\n"));
    // combineNodeCode(testNode, 2, testNode2, testNode3);
    // a = "456\n";
    // printCode(testNode);
    

}

void showTree(Node* root, int level){
    if(root->nodeType == 1 && root->chCount != 0){
        for(int i = 0; i < level; i++){
            printf(" ");
        }
        printf("%s(%d)\n", root->tkName, root->lineNo);
        for(int j = 0; j < root->chCount; j++){
            showTree(root->children[j], level + 2);
        }
    }else if (root -> nodeType == 0){
        for(int i = 0; i < level; i++){
            printf(" ");
        }
        if(! strcmp(root->tkName, "TYPE")){
            printf("TYPE:%s\n", root->sval);
        }else if (! strcmp(root->tkName, "ID")){
            if(root->type==4){
                printf("ID:%s(%d)rt(%d)pmcnt(%d)", root->sval, root->type, root->subType, root->parmCnt);
                VarRec* p = root->parmList;
                while (p)
                {
                    printf("[%s:%d]", p->name, p->type);
                    p=p->next;
                }
                printf("\n");
            }else if(root->type==5){
                printf("ID:%s(%d)artp(%d)ardm(%d)\n", root->sval, root->type, root->subType, root->arrDim);
            }else if(root->type==3){
                printf("ID:%s(%d)st", root->sval, root->type);
                VarRec* p = root->stdefList;
                while (p)
                {
                    printf("[%s:%d]", p->name, p->type);
                    p=p->next;
                }
                printf("\n");
            }else{
                printf("ID:%s(%d)\n", root->sval, root->type);
            }
        }else if (! strcmp(root->tkName, "INT")){
            printf("INT:%d\n", root->ival);
        }else if (! strcmp(root->tkName, "FLOAT")){
            printf("FLOAT:%f\n", root->fval);
        }else{
            printf("%s\n", root->tkName);
        }
    }
}
