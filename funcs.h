#ifndef HEAD
#define  HEAD
int IDType;
int FUNCRtType;

typedef struct VarRec
{
    int type; //变量的类型 0->not know 1->int 2->float 3->struct 4->func 5->array 
    char* name;//变量的名字 实际上就是 sval
    struct VarRec* next;
} VarRec;
VarRec* var_head, *var_tail;

typedef struct Node
{
    int nodeType; //表示节点的类型 0：终结符 1：非终结符
    int type;//节点的类型 0->not know 1->int 2->float 3->struct 4->func 5->array
    char* tkName; //节点的名字 Exp、INT、LR、LP等等
    int lineNo; //所在的行号;
    char* sval; //字符串属性的值，如ID的值, 字面值（TYPE，float）中的第二个
    int ival; //整数属性的值
    float fval; //浮点数属性的值
    int chCount; //孩子节点的个数
    struct Node* children[10]; //指向孩子的指针
    int arrType; //如果是数组的ID，记录数组类型 1->int 2->float 3->struct
    int funcParmCnt;//如果是函数，记录函数的参数个数
    int funcRtType;//如果是函数，记录函数的返回值类型 0->not know 1->int 2->float 3->struct
    VarRec* funcParmList;//如果是函数，记录函数的参数列表
    //char* type;// 常数的类型 tkName=='FLOAT'或'INT'有效，例如 1->int  1.0->float 

} Node;





typedef struct FuncRec
{
    char* name;
    int rtype;//返回值类型 0->not know 1->int 2->float 3->struct
    int para_count;//形参个数,这里暂且限制为10个及以下
    int para_types[10];//按顺序储存形参的类型
    struct FuncRec* next;
} FuncRec;
FuncRec* func_head, *func_tail;

typedef struct ArrRec
{
    char* name;
    int dim; //数组的维度
    int type;//数组的类型
    struct ArrRec* next;
} ArrRec;
ArrRec* arr_head, *arr_tail;

typedef struct StRec
{
    char* name;
    VarRec* def_list; //结构体定义列表
    struct StRec* next;
} StRec;
StRec* st_head, *st_tail;



Node* getTermNode(int lineno, char* tkName);
Node* getStrNode(char* yytext, int lineno, char* tkName,int yyleng);
Node* ownManyChild(char* tkName, int count, Node* ch0, Node* ch1, 
                    Node* ch2,Node* ch3, Node* ch4, Node* ch5, Node* ch6);
Node* own0Child(char* tkName);
Node* own1Child(char* tkName, Node* ch0);
Node* own2Child(char* tkName, Node* ch0, Node* ch1);
Node* own3Child(char* tkName, Node* ch0, Node* ch1, Node* ch2);
Node* own4Child(char* tkName, Node* ch0, Node* ch1, Node* ch2,Node* ch3);
Node* own5Child(char* tkName, Node* ch0, Node* ch1, Node* ch2,Node* ch3, Node* ch4);
Node* own7Child(char* tkName, Node* ch0, Node* ch1, 
                    Node* ch2,Node* ch3, Node* ch4, Node* ch5, Node* ch6);
void showTree(Node* root, int level);
Node* setType(Node* in, int type);
Node* combineType(Node* carryType, Node* src);
void addVarRec(Node* ID);
VarRec* checkVarRec(Node* ID);
void addFuncRec(Node* ID);
Node* setRtType(Node* in, int type);

void yyerror(char * s);
void yyerrorA();
void yyerrorB(char* info);
int yylex ();
//用于创建{}（）+—等符号对应的节
#endif // !HEAD
