cc= gcc
cflags = -Wall -std=gnu99
SRCS= lexC.l parserY.y tab_symb.c
OBJS= y.tab.o lex.yy.o tab_symb.o
TARGET = compilator y.dot y.pdf y.tab.c y.tab.h lex.yy.c *.o y.output


default : compilator

all: compilator

clean :
	rm -f $(TARGET)

compilator : $(OBJS)
		gcc $^ -o $@ -ll -lm

%.o: %.c
	gcc -c $^

y.pdf : y.dot
	dot -Tpdf $^ -o $@

y.tab.c y.tab.h y.dot : parserY.y
		yacc -dvg parserY.y

lex.yy.c : lexY.l
		lex lexY.l
