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

//增加变量记录
void addVarRec(Node* ID){
    if(ID == NULL){
        printf("error get info from ID");
        return;
    }else{
        VarRec* newNode = (VarRec*)malloc(sizeof(VarRec));
        newNode->name = ID->sval;
        newNode->type = ID->type;
        newNode->next = NULL;
        var_tail->next = newNode;
        var_tail = var_tail->next;
        return;
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
        while (p->next!=NULL)
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
void addFuncRec(Node* ID){
    if(ID == NULL){
        printf("error get info from ID");
        return;
    }else{
        FuncRec* newNode = (FuncRec*)malloc(sizeof(FuncRec));
        
        return;
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
                printf("ID:%s(%d)artp(%d)\n", root->sval, root->type, root->subType);
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
