SRC= main.o
OBJ=$(SRC:c=.o)
all: compilator y.pdf
y.pdf: y.dot
        dot -Tpdf y.dot > y.pdf
y.tab.c y.tab.h y.dot y.output: yacc.y
        yacc -dvg yacc.y
lex.yy.c: lex.l y.tab.h
        flex lex.l
compilator: t.tab.o lex.yy.o $(OBJ)
        gcc y.tab.o lex.yy.o $(OBJ) -|| -o compilator
test: compilator
        ./compilator < test.c 


