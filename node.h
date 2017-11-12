#ifndef HEAD
#define  HEAD

typedef struct Node
{
    int nodeType; //表示节点的类型 0：终结符 1：非终结符
    char* tkName; //节点的名字 Exp、INT、LR、LP等等
    int lineNo; //所在的行号;
    char* sval; //字符串属性的值，如ID的值
    int ival; //整数属性的值
    float fval; //浮点数属性的值
    int chCount; //孩子节点的个数 0表示终结符  -1表示非终结符无孩子
    struct Node* children[10]; //指向孩子的指针

} Node;

Node* getTermNode(int lineno, char* tkName);
int power(int a, int b);
int HToD(char * str, int leng);
int OToD(char * str, int leng);
Node* getStrNode(char* yytext, int lineno, char* tkName,int yyleng);
Node* getIntNode(int yyint, int lineno);
Node* own0Child(char* tkName);
Node* own1Child(char* tkName, Node* ch0);
Node* own2Child(char* tkName, Node* ch0, Node* ch1);
Node* own3Child(char* tkName, Node* ch0, Node* ch1, Node* ch2);
Node* own4Child(char* tkName, Node* ch0, Node* ch1, Node* ch2,Node* ch3);
Node* own5Child(char* tkName, Node* ch0, Node* ch1, Node* ch2,Node* ch3, Node* ch4);
Node* own7Child(char* tkName, Node* ch0, Node* ch1, 
                    Node* ch2,Node* ch3, Node* ch4, Node* ch5, Node* ch6);
void showTree(Node* root, int level);

void yyerror(char * s);
void yyerrorA();
void yyerrorB(char* info);
int yylex ();
//用于创建{}（）+—等符号对应的节
#endif // !HEAD
