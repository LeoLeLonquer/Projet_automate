SRC= main.o 
OBJ=$(SRC:c=.o)
all: TP 
y.tab.c y.tab.h y.dot y.output: parserY 
	yacc -dvg parserY 
lex.yy.c: lexY y.tab.h
	lex lexY

