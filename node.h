#ifndef HEAD
#define  HEAD

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
    struct Node* children[10]; //指向孩子的指针

} Node;

//用于创建{}（）+—等符号对应的节点
Node* getTermNode(int lineno, char* tkName){
    Node* Nptr = (Node*) malloc(sizeof(Node));
    Nptr->nodeType = 0;
    Nptr->tkName = tkName;
    Nptr->lineNo = lineno;
    Nptr->chCount = 0;
    return Nptr;
}


//创建ID TYPE 2个类型的节点
Node* getStrNode(char* yytext, int lineno, char* tkName){
    Node* Nptr = (Node*) malloc(sizeof(Node));
    Nptr->nodeType = 0;
    Nptr->tkName = tkName;
    Nptr->lineNo = lineno;
    Nptr->chCount = 0;
    Nptr->sval = yytext;
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
//FLOAT
Node* getFloatNode(int yyfloat, int lineno){
    Node* Nptr = (Node*) malloc(sizeof(Node));
    Nptr->nodeType = 0;
    Nptr->tkName = "FLOAT";
    Nptr->lineNo = lineno;
    Nptr->chCount = 0;
    Nptr->fval = yyfloat;
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

#endif // !HEAD
