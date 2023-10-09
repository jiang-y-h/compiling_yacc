%{
/*********************************************
将所有的词法分析功能均放在 yylex 函数内实现，为 +、-、*、\、(、 ) 每个运算符及整数分别定义一个单词类别，在 yylex 内实现代码，能
识别这些单词，并将单词类别返回给词法分析程序。
实现功能更强的词法分析程序，可识别并忽略空格、制表符、回车等
空白符，能识别多位十进制整数。
YACC file
**********************************************/
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include <string.h>
int yylex();

int search(char *);
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);

//符号数据结构
struct symbol{
        char id[50];
        double value;
}; 
struct symbol symtab[10];

int count=0;
%}
//属性值具有的类型
%union{
    double  num;
    struct symbol *symbolp;
}



//TODO:给每个符号定义一个单词类别
%token <num>NUMBER
%token ADD MINUS 
%token MULT DIV 
%token LEFTPAR RIGHTPAR
%token EQUAL
%token <symbolp> ID

%right EQUAL
%left ADD MINUS
%left MULT DIV
%right UMINUS         

%type <num> expr

%%


lines   :       lines expr ';' { printf("%f\n", $2); }
        |       lines ';'
        |
        ;
//TODO:完善表达式的规则
expr    :       expr ADD expr   { $$=$1+$3; }
        |       expr MINUS expr   { $$=$1-$3; }
        |       expr MULT expr   { $$=$1*$3; }
        |       expr DIV expr   { $$=$1/$3; }
        |       LEFTPAR expr RIGHTPAR   { $$=$2; }
        |       MINUS expr %prec UMINUS   {$$=-$2;}
        |       NUMBER  {$$=$1;}
        |       ID EQUAL expr  {$1->value=$3;$$=$3;}
        |       ID {$$=$1->value;}
        ;


%%

// programs section

int yylex()
{

    int t;
    while(1){
        t=getchar();
        if(t==' '||t=='\t'||t=='\n'){
            //do noting
        }else if(isdigit(t)){
            //TODO:解析多位数字返回数字类型
            yylval.num = 0;
            while (isdigit(t)) {
                yylval.num = yylval.num * 10 + t - '0';
                t = getchar();
            }
            // ungetc函数将多读的字符放回缓冲区
            ungetc(t, stdin);
            return NUMBER;
        }else if(t=='_'||(t>='a'&&t<='z')||(t>='A'&&t<='Z')){
            char * id=(char*)malloc(50);
            int i=0;
            id[i++]=t;
            t = getchar();
            while (t=='_'||(t>='a'&&t<='z')||(t>='A'&&t<='Z')||isdigit(t)) {
                id[i++]=t;
                t = getchar();
            }
            id[i]='\0';
            ungetc(t, stdin);
            int index=search(id);
            if(index==count){
                strcpy(symtab[count].id,id);
                symtab[count].value=0;
                count++;
            };
            
            yylval.symbolp=&symtab[index];
            return ID;

        }else if(t=='+'){
            return ADD;
        }else if(t=='-'){
            return MINUS;
        }//TODO:识别其他符号
        else if(t=='*'){
            return MULT;
        }else if(t=='/'){
            return DIV;
        }else if(t=='('){
            return LEFTPAR;
        }else if(t==')'){
            return RIGHTPAR;
        }else if(t=='='){
            return EQUAL;
        }
        else{
            return t;
        }
    }
}

int main(void)
{
    yyin=stdin;
    do{
        yyparse();
    }while(!feof(yyin));
    return 0;
}


void yyerror(const char* s){
    fprintf(stderr,"Parse error: %s\n",s);
    exit(1);
}

int search(char * id){
    for(int i=0;i<count;i++){
        if(strcmp(id,symtab[i].id)==0){
        return i; 
        }
    }
    return count;
}
