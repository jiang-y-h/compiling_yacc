.PHONY:expr1 expr2 expr3 expr_ad assembly 
expr1:
	yacc expr1.y
	gcc y.tab.c -o expr1

expr2:
	yacc expr2.y
	gcc y.tab.c -o expr2

expr3:
	yacc expr3.y
	gcc y.tab.c -o expr2

expr_ad:
	yacc expr_ad.y
	gcc y.tab.c -o expr_ad

assembly:
	yacc assembly.y
	gcc y.tab.c -o assembly
