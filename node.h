#ifndef HEAD
#define HEAD

#include <stdlib.h>

typedef struct Node
{
    int nodeType; //表示节点的类型 0：终结符 1：非终结符
    char* tkName; //节点的名字 Exp、INT、LR、LP等等
    int lineNo; //所在的行号;
    char* sval; //字符串属性的值，如ID的值
    int ival; //整数属性的值
    float fval; //浮点数属性的值
    int chCount; //孩子节点的个数
    Node* children[10]; //指向孩子的指针

} Node;

//用于创建{}（）+—等符号对应的节点
Node* getTermNode(int lineno, char* tkName){
    Node* Nptr = (Node*) malloc(sizeof(Node));
    Nptr->nodeType = 0;
    Nptr->tkName = tkName;
    Nptr->lineNo = lineno;
    Nptr->chCount = 0;
}


//创建ID TYPE 2个类型的节点
Node* getStrNode(char* yytext, int lineno, char* tkName){
    Node* Nptr = (Node*) malloc(sizeof(Node));
    Nptr->nodeType = 0;
    Nptr->tkName = tkName;
    Nptr->lineNo = lineno;
    Nptr->chCount = 0;
    Nptr->sval = yytext;
}
//INT
Node* getIntNode(int yyint, int lineno){
    Node* Nptr = (Node*) malloc(sizeof(Node));
    Nptr->nodeType = 0;
    Nptr->tkName = "INT";
    Nptr->lineNo = lineno;
    Nptr->chCount = 0;
    Nptr->ival = yyint;
}
//FLOAT
Node* getFloatNode(int yyfloat, int lineno){
    Node* Nptr = (Node*) malloc(sizeof(Node));
    Nptr->nodeType = 0;
    Nptr->tkName = "FLOAT";
    Nptr->lineNo = lineno;
    Nptr->chCount = 0;
    Nptr->fval = yyfloat;
}

#endif // !HEAD