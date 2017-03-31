cc= gcc
cflags = -Wall -std=gnu99
SRCS= lexC.l parserY.y tab_symb.c tab_branche.c tab_fun.c
OBJS= y.tab.o lex.yy.o tab_symb.o tab_branche.o tab_fun.o
TARGET = compilator y.dot y.pdf y.tab.c y.tab.h lex.yy.c *.o y.output y.vcg test_symb test_branche test_fun


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

test_symb : test_tab_symb.c tab_symb.o
		gcc $^ -o $@

test_branche : test_tab_branche.c tab_branche.o
		gcc $^ -o $@

test_fun : test_tab_fun.c tab_fun.o
		gcc $^ -o $@
