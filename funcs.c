#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
# include<stdarg.h>
#include "funcs.h"

void addToParmList(VarRec* node){
    node->next = PARMList;
    PARMList = node;
}

void addToSTDefList(VarRec* node){
    node->next = STDefList;
    STDefList = node;
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
    }else{
        Nptr->sval = str;
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
