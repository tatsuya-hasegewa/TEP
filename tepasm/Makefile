# Makefile for TEP Assembler
# Gnu C Version
# N. Shimizu 12 Aug 2001
#

CC = gcc
YACC = bison -y
LEX = flex
INSTALLDIR = /usr/local/bin
TEPASM=tepasm

CFLAGS =  -g

CLEANS = $(TEPASM).tab.o lex.yy.o $(TEPASM).tab.c lex.yy.c $(TEPASM).tab.h $(TEPASM).y~ $(TEPASM).l~ $(TEPASM).h~ Makefile~
OBJS = $(TEPASM).tab.o lex.yy.o
SRCS = $(TEPASM).y $(TEPASM).l $(TEPASM).h

all: $(TEPASM)
install:	$(TEPASM)
	cp $(TEPASM)$E $(INSTALLDIR)

$(TEPASM): $(OBJS)
	 $(CC) $(CFLAGS) $(OBJS) -o $(TEPASM)

$(TEPASM).tab.o: $(TEPASM).tab.c $(TEPASM).y
	$(CC) $(CFLAGS) -c $(TEPASM).tab.c

lex.yy.o: lex.yy.c $(TEPASM).tab.h
	$(CC) $(CFLAGS) -c lex.yy.c

$(TEPASM).tab.c: $(TEPASM).y $(TEPASM).h
	$(YACC) -b $(TEPASM) -d $(TEPASM).y

lex.yy.c: $(TEPASM).l $(TEPASM).h
	$(LEX) $(TEPASM).l

clean:
	-rm $(CLEANS)

tar:
	tar cvf $(TEPASM).tar Makefile $(SRCS)
