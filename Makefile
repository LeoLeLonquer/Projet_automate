cc= gcc
cflags = -Wall -std=gnu99
SRCS= lexC.l parserY.y
OBJS= y.tab.o lex.yy.o
TARGET = compilator y.dot y.pdf y.tab.c y.tab.h lex.yy.c *.o

default : compilator

all: compilator y.pdf

clean :
	rm -f $(TARGET)

compilator : y.tab.o lex.yy.o
		gcc $^ -o $@ -ll -lm

%.o: %.c
	gcc -c $^

y.pdf : y.dot
	dot -Tpdf $^ -o $@

y.tab.c y.tab.h y.dot : parserY.y
		yacc -dvg parserY.y

lex.yy.c : lexY.l
		lex lexY.l
