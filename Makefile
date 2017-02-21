SRC= main.o
OBJ=$(SRC:.c=.o)
all: compilator
#y.pdf: y.dot
	#	dot -Tpdf y.dot > y.pdf
y.tab.c y.tab.h y.dot y.output: parserY.y
	yacc -dvg parserY.y
lex.yy.c: lexY.l y.tab.h
	lex  lexY.l
compilator: y.tab.o lex.yy.o $(OBJ)
	 gcc y.tab.o lex.yy.o $(OBJ) -std=c99 -pedantic -|| -o compilator
test: compilator
	 ./compilator < test.c
