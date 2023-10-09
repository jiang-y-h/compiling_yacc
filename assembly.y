%{
/*********************************************
生成汇编代码。
YACC file
**********************************************/
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include <string.h>
int yylex();

extern int yyparse();
FILE* yyin;
void yyerror(const char* s);

//符号数据结构
//struct symbol{
//        char id[50];
//        char value[10];
//}; 
//struct symbol symtab[10];

struct code
{
    char code[100];
    char value[100];
    int type;
};


int count=0;
%}
//属性值具有的类型
%union{
    char *  num;
    struct code assembly;
}



//TODO:给每个符号定义一个单词类别
%token <num>NUMBER
%token ADD MINUS 
%token MULT DIV 
%token LEFTPAR RIGHTPAR
%token EQUAL
%token <num> ID

%right EQUAL
%left ADD MINUS
%left MULT DIV
%right UMINUS         

%type <assembly> expr

%%


lines   :       lines expr ';' { printf("%s\n", $2.code); }
        |       lines ';'
        |
        ;
//TODO:完善表达式的规则
expr    :
        expr ADD expr{
            $$.type=2;
        strcpy($$.code," ");
        if($1.type==2){strcat($$.code,$1.code);}
        if($3.type==2){strcat($$.code,$1.code);}
        if($1.type==1){
            strcat($$.code,"\n mov r3 ");strcat($$.code,$1.value);
        }
        else{
            strcat($$.code,"\n ldr r3 ");strcat($$.code,$1.value);
        }
        if($3.type==1){
            strcat($$.code,"\n mov r2 ");strcat($$.code,$3.value);
        }
        else{
            strcat($$.code,"\n ldr r2 ");strcat($$.code,$3.value);
        }
        snprintf($$.value, sizeof($$.value), "result%d", count);count++;
        strcat($$.code,"\n add r3 r2 \n str r3 ");strcat($$.code,$$.value);
        }
        
        |       expr MINUS expr   {            $$.type=2;
        strcpy($$.code," ");
        if($1.type==2){strcat($$.code,$1.code);}
        if($3.type==2){strcat($$.code,$1.code);}
        if($1.type==1){
            strcat($$.code,"\n mov r3 ");strcat($$.code,$1.value);
        }
        else{
            strcat($$.code,"\n ldr r3 ");strcat($$.code,$1.value);
        }
        if($3.type==1){
            strcat($$.code,"\n mov r2 ");strcat($$.code,$3.value);
        }
        else{
            strcat($$.code,"\n ldr r2 ");strcat($$.code,$3.value);
        }
        snprintf($$.value, sizeof($$.value), "result%d", count);count++;
        strcat($$.code,"\n sub r3 r2 \n str r3 ");strcat($$.code,$$.value); 
        }
        |       expr MULT expr   {            $$.type=2;
        strcpy($$.code," ");
        if($1.type==2){strcat($$.code,$1.code);}
        if($3.type==2){strcat($$.code,$1.code);}
        if($1.type==1){
            strcat($$.code,"\n mov r3 ");strcat($$.code,$1.value);
        }
        else{
            strcat($$.code,"\n ldr r3 ");strcat($$.code,$1.value);
        }
        if($3.type==1){
            strcat($$.code,"\n mov r2 ");strcat($$.code,$3.value);
        }
        else{
            strcat($$.code,"\n ldr r2 ");strcat($$.code,$3.value);
        }
        snprintf($$.value, sizeof($$.value), "result%d", count);count++;
        strcat($$.code,"\n mul r4 r3 r2 \n str r4 ");strcat($$.code,$$.value); }
        |       expr DIV expr   {$$.type=0; }
        |       LEFTPAR expr RIGHTPAR   {$$.type=$2.type;strcpy($$.code,$2.code);strcat($$.value,$2.value);}
        |       MINUS expr %prec UMINUS   {$$.type=2;strcpy($$.code,$2.code);strcat($$.value,$2.value);
        if($2.type==1){
            $$.type=1;
            strcpy($$.value,"-");strcat($$.value,$2.value);
        }
        else{
            strcat($$.code,"\n ldr r3 ");strcat($$.code,$2.value);
            strcat($$.code,"\n mov r2 #0 \n sub r2 r3 \n str r2 ");
            strcat($$.code,$$.value);
        }
        
        }
        | NUMBER {$$.type=1;strcpy($$.value,$1);}
        |       ID EQUAL expr {$$.type=2;
        if($3.type==1){strcpy($$.code,"\n mov r3 ");strcat($$.code,$3.value);strcat($$.code,"\n str r3 ");strcat($$.code,$1);}
        else if($3.type==0){strcpy($$.code,"\n ldr r3 ");strcat($$.code,$3.value);strcat($$.code,"\n str r3 ");strcat($$.code,$1);}
        else{
        strcat($$.code,$3.code);strcat($$.code,"\n ldr r3 ");strcat($$.code,$3.value);strcat($$.code,"\n str r3 ");strcat($$.code,$1);    
        }
        }
        |       ID {$$.type=0;strcpy($$.value,$1);}
        ;

%%


int yylex()
{

    int t;
    while(1){
        t=getchar();
        if(t==' '||t=='\t'||t=='\n'){
            //do noting
        }else if(isdigit(t)){
            yylval.num=(char*)malloc(100);
            //TODO:解析多位数字返回数字类型
            int num = 0;
            while (isdigit(t)) {
                num =num * 10 + t - '0';
                t = getchar();
            }
            // ungetc函数将读出的多余字符再次放回到缓冲区去，下一次读数字符进行下一个单词识别时会再次读出来。
            // 此时非数字字符已经读出，因此需要再次放回缓冲区
            ungetc(t, stdin);
            snprintf(yylval.num,sizeof(yylval.num),"%d",num);
            return NUMBER;
            
        }else if(t=='_'||(t>='a'&&t<='z')||(t>='A'&&t<='Z')){
            char * id=(char*)malloc(100);
            yylval.num=(char*)malloc(100);
            int i=0;
            id[i++]=t;
            t = getchar();
            while (t=='_'||(t>='a'&&t<='z')||(t>='A'&&t<='Z')||isdigit(t)) {
                id[i++]=t;
                t = getchar();
            }
            id[i]='\0';
            ungetc(t, stdin);
            strcpy(yylval.num,id);
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

