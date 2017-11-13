#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "funcs.h"



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
        if(strchr(str, 'e') != NULL){
            Nptr->fval=strTof(str, yyleng);
        }else{
            Nptr->fval = atof(str);
        }
    }else if (!strcmp(tkName, "INT")){
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
//INT
Node* getIntNode(int yyint, int lineno){
    Node* Nptr = (Node*) malloc(sizeof(Node));
    Nptr->nodeType = 0;
    Nptr->tkName = "INT";
    Nptr->lineNo = lineno;
    Nptr->chCount = 0;
    Nptr->ival = yyint;
    return Nptr;
}


Node* own0Child(char* tkName){
    Node* Nptr = (Node*) malloc(sizeof(Node));
    Nptr->nodeType = 1;
    Nptr->tkName = tkName;
    Nptr->lineNo = -1;
    Nptr->chCount = 0;
    return Nptr;
}

Node* own1Child(char* tkName, Node* ch0){
    Node* Nptr = (Node*) malloc(sizeof(Node));
    Nptr->nodeType = 1;
    Nptr->tkName = tkName;
    Nptr->lineNo = ch0->lineNo;
    Nptr->chCount = 1;
    Nptr->children[0] = ch0;
    return Nptr;
}

Node* own2Child(char* tkName, Node* ch0, Node* ch1){
    Node* Nptr = (Node*) malloc(sizeof(Node));
    Nptr->nodeType = 1;
    Nptr->tkName = tkName;
    Nptr->lineNo = ch0->lineNo;
    Nptr->chCount = 2;
    Nptr->children[0] = ch0;
    Nptr->children[1] = ch1;
    return Nptr;
}

Node* own3Child(char* tkName, Node* ch0, Node* ch1, Node* ch2){
    Node* Nptr = (Node*) malloc(sizeof(Node));
    Nptr->nodeType = 1;
    Nptr->tkName = tkName;
    Nptr->lineNo = ch0->lineNo;
    Nptr->chCount = 3;
    Nptr->children[0] = ch0;
    Nptr->children[1] = ch1;
    Nptr->children[2] = ch2;
    return Nptr;
}

Node* own4Child(char* tkName, Node* ch0, Node* ch1, Node* ch2,Node* ch3){
    Node* Nptr = (Node*) malloc(sizeof(Node));
    Nptr->nodeType = 1;
    Nptr->tkName = tkName;
    Nptr->lineNo = ch0->lineNo;
    Nptr->chCount = 4;
    Nptr->children[0] = ch0;
    Nptr->children[1] = ch1;
    Nptr->children[2] = ch2;
    Nptr->children[3] = ch3;
    return Nptr;
}

Node* own5Child(char* tkName, Node* ch0, Node* ch1, Node* ch2,Node* ch3, Node* ch4){
    Node* Nptr = (Node*) malloc(sizeof(Node));
    Nptr->nodeType = 1;
    Nptr->tkName = tkName;
    Nptr->lineNo = ch0->lineNo;
    Nptr->chCount = 5;
    Nptr->children[0] = ch0;
    Nptr->children[1] = ch1;
    Nptr->children[2] = ch2;
    Nptr->children[3] = ch3;
    Nptr->children[4] = ch4;
    return Nptr;
}

Node* own7Child(char* tkName, Node* ch0, Node* ch1, 
                    Node* ch2,Node* ch3, Node* ch4, Node* ch5, Node* ch6){
    Node* Nptr = (Node*) malloc(sizeof(Node));
    Nptr->nodeType = 1;
    Nptr->tkName = tkName;
    Nptr->lineNo = ch0->lineNo;
    Nptr->chCount = 7;
    Nptr->children[0] = ch0;
    Nptr->children[1] = ch1;
    Nptr->children[2] = ch2;
    Nptr->children[3] = ch3;
    Nptr->children[4] = ch4;
    Nptr->children[5] = ch5;
    Nptr->children[6] = ch6;
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
            printf("ID:%s\n", root->sval);
        }else if (! strcmp(root->tkName, "INT")){
            printf("INT:%d\n", root->ival);
        }else if (! strcmp(root->tkName, "FLOAT")){
            printf("FLOAT:%f\n", root->fval);
        }else{
            printf("%s\n", root->tkName);
        }
    }
}
