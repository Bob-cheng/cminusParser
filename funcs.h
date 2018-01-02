#ifndef HEAD
#define  HEAD

int IDType; //记录当前的ID类型的全局变量
int ISDefSt; // 表示是否是在定义结构体
int VARnum; //中间代码生成的变量标识
int TEMPnum;//中间代码生成的临时变量标识
int LABELnum;//中间代码生成的标签标识
int SPECIALFUNC;//判断是否是特殊函数的标签
int TESTFunStage;
int FUNCRtTypeINT;

typedef struct CodeBlock{
    int level; //表示指针的级数，1表示一级指针，2表示二级指针
    char* pCode;
    char** ppCode;
    struct CodeBlock *next;
}CodeBlock;




typedef struct TFStack{
    int top;
    char* stack[100][2];
} TFStack;
TFStack tfStack;
char* EXPTrue;
char* EXPFalse;

typedef struct SNEXTStack{
    int top;
    char* stack[100];
} SNEXTStack;
SNEXTStack sNextStack;
char* STMTNext;


typedef struct VarRec
{
    int type; //变量的类型 0->not know 1->int 2->float 3->struct 4->func 5->array 
    char* name;//变量的名字 实际上就是 sval
    char* coreName;//变量在中间代码中的名字
    struct VarRec* next;
} VarRec;
VarRec* var_head, *var_tail; //注意这个是包含头节点的
VarRec* PARMList;//记录函数参数类型和名字的链表
VarRec* STDefList;//结构体定义的时候的参数列表
VarRec* STDclList;//结构体声明的时候的参数列表

typedef struct FUNCRt
{
    int type; //返回的类型 0->not know 1->int 2->float 3->struct 4->func 5->array 
    int line; //返回的时候的行号
    struct FUNCRt* next;
} FUNCRt;
FUNCRt* FUNCRtType;//记录函数中的各返回语句返回的类型，type字段用来记录行号。

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
    int subType; //如果是[数组或函数]的ID，记录数组类型或函数返回类型 1->int 2->float 3->struct, [-1]表示是一个右值
    int parmCnt;//如果是[函数]，记录函数的参数个数
    int arrDim;//如果是[数组]，记录数组的维度
    VarRec* parmList;//如果是[函数]，记录函数的参数列表
    VarRec* stdefList;//如果是[结构体]，记录结构体的参数列表
    char* coreName;//中间代码生成的名字
    char* subCoreName;//对于数组来说需要储存两个名字,这个表示的是地址
    //char* type;// 常数的类型 tkName=='FLOAT'或'INT'有效，例如 1->int  1.0->float 
    char* trueL;  //用于表达式的真出口标签
    char* falseL; //用于表达式的假出口标签
    char* sNextL;  //用于stmt的结束出口标签
    CodeBlock* codeHead; //用于指向代码链的头部
    CodeBlock* codeTail; //用于指向代码链的尾部
} Node;

typedef struct FuncRec
{
    char* name;
    int rtype;//返回值类型 0->not know 1->int 2->float 3->struct
    int para_count;//形参个数,这里暂且限制为10个及以下
    VarRec* def_list; //形参列表
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
int addVarRec(Node* ID);
VarRec* checkVarRec(Node* ID);
int addFuncRec(Node* ID);
FuncRec* checkFuncRec(Node* ID);
void addArrRec(Node* ID);
ArrRec* checkArrRec(Node* ID);
void addStRec(Node* ID);
StRec* checkStRec(Node* ID);
void debug();
int checkListTypeEqual(VarRec* link, VarRec* link2);
void addToParmList(VarRec* node);
void addToSTDefList(VarRec* node);
void outPutLinks(VarRec* link);
void initiate();
void funcDefOption(Node* ss, Node* s1, Node* s2, Node* s3);

CodeBlock* getCodeblock(int level, ...);
void combineCode(Node* target, int num, ...);
void combineNodeCode(Node* target, int num, ...);
void addCode(Node* target, CodeBlock* code);
void copyCode(Node* target, Node* source);
char*  s_AEqualB_(char* a, char* b);
void printCode(Node* node);

void _getNewVar(char** out);
void _getNewTemp(char** out);
char* _checkCoreName(char* varname);
void _decFunc_(Node * ID);
void _getNewLabel(char** out);
void _AEqualB_(char* a, char* b);
char* _insNumFmt(char* in);
     void _expOption_(Node* ss, Node* s1, Node* s2, Node* s3);
     void _callFunc_(Node* ss, Node* s1, Node* s3);
     void _arrDefOperation_(Node* ss, Node* s1, Node*s2);
void _pushTfStack();
void _popTfStack();
void _pushSNextStack();
void _popSNextStack();
void _putLabel_(char* l);
void _putGoto_(char* l);

void yyerror(char * s);
void yyerrorA();
void myerror(int type, char * s);
int yylex ();

//用于创建{}（）+—等符号对应的节
#endif // !HEAD
