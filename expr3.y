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
#ifndef YYSTYPE
#define YYSTYPE char*
#endif
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}


//TODO:给每个符号定义一个单词类别
%token NUMBER
%token ADD MINUS 
%token MULT DIV 
%token LEFTPAR RIGHTPAR


%left ADD MINUS
%left MULT DIV
%right UMINUS         

%%


lines   :       lines expr ';' { printf("%s\n", $2); }
        |       lines ';'
        |
        ;
//TODO:完善表达式的规则
expr    :       expr ADD expr   { $$= (char*)malloc(100);char add[3]="+";strcpy($$, $1);strncat($$, $3,strlen($3));strncat($$, add,strlen(add));}
        |       expr MINUS expr   {$$= (char*)malloc(100);char minus[3]="-";strcpy($$, $1);strncat($$, $3,strlen($3));strncat($$, minus,strlen(minus));}
        |       expr MULT expr   { $$= (char*)malloc(100);char mult[3]="*";strcpy($$, $1);strncat($$, $3,strlen($3));strncat($$, mult,strlen(mult));}
        |       expr DIV expr   { $$= (char*)malloc(100);char div[3]="/";strcpy($$, $1);strncat($$, $3,strlen($3));strncat($$, div,strlen(div));}
        |       LEFTPAR expr RIGHTPAR   {$$= (char*)malloc(100);strcpy($$, $2);}
        |       MINUS expr %prec UMINUS   {$$= (char*)malloc(100);char minus[3]="-";strcpy($$, $2);strncat($$, minus,strlen(minus));}
        |       NUMBER  {$$= (char*)malloc(100);strcpy($$, $1);}
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
            yylval = (char*)malloc(50);
            int num=0;
            while (isdigit(t)) {
                num = num * 10 + t - '0';
                t = getchar();
            }
            //ungetc函数将多读的字符放回缓冲区
            snprintf(yylval, sizeof(yylval), "%d", num);
            ungetc(t, stdin);
            return NUMBER;
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