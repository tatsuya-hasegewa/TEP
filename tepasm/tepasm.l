/******************************************
 Tokai Embedded Processor 16  (TEP16)
 Assembler source code.
  (C)Copyright by Naohiko Shimizu, 2008.
  All rights are reserved.

  Contact information:

  Naohiko Shimizu, Ph.D.
  IP ARCH, Inc.
  Email: naohiko.shimizu@gmail.com
  URL: http://www.ip-arch.jp/


  Update informations:

    20-Jan-2009: change operations
    21-Nov-2008: Initial vesion from snxasm.
******************************************/

%{
#include <stdlib.h>
#include "tepasm.h"
#include "tepasm.tab.h"

struct node {
	char *sym;
	int  id;
	struct node *node;
};

void yyerror(char *s);
int slookup(char *s);
int hextoi(char *s);
int bintoi(char *s);

extern int Line;
int labelindex=0;
char *optable[256];
%}

%%

"0"[xX][0-9a-fA-F]+	{
                yylval.iValue = hextoi(&yytext[2]);
                return INTEGER;
		}
"0"[bB][0-1]+	{
                yylval.iValue = bintoi(&yytext[2]);
                return INTEGER;
		}
[0-9]+      {
                yylval.iValue = atoi(yytext);
                return INTEGER;
            }
"$"[0-9]    {
                yylval.iValue = yytext[1] - '0';
                return REG;
            }
"$1"[0-5]    {
                yylval.iValue = yytext[2] - '0' + 10;
                return REG;
            }



[,():<+-] {
                return *yytext;
             }
"*" {
                return *yytext;
             }

[\n] {
                Line++; return *yytext;
             }

";".*$      ;       /* ignore comments */
"\.globl".*$      ;       /* ignore comments */
"\.text".*$      ;       /* ignore comments */
"\.type".*$      ;       /* ignore comments */
"\.size".*$      ;       /* ignore comments */
"\.ident".*$      ;       /* ignore comments */
"\.data".*$      ;       /* ignore comments */
"\.bss".*$      ;       /* ignore comments */

"\.align"	{
		return ALIGN;
		}
"\.byte"	{
		return BYTE;
		}
"\.word"	{
		return WORD;
		}
"\.long"	{
		return LONG;
		}
"\.comm"	{
		return COMM;
		}
"\.lcomm"	{
		return LCOMM;
		}
"\.org"	        {
		return ORIGIN;
		}

"db"	{
		return BYTE;
		}
"dw"	{
		return WORD;
		}
"dd"	{
		return LONG;
		}

"equ"|"EQU"		{
		return EQU;
		}
"cnst"|"CNST"            {
                yylval.iValue = 0x00;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return ITYPE;
             }
"ld1"|"LD1"            {
                yylval.iValue = 0x01;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return ITYPE;
             }
"ld2"|"LD2"           {
                yylval.iValue = 0x02;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return ITYPE;
             }
"st1"|"ST1"            {
                yylval.iValue = 0x03;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return ITYPE;
             }
"st2"|"ST2"           {
                yylval.iValue = 0x04;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return ITYPE;
             }
"jump"|"JUMP"           {
                yylval.iValue = 0x05;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return I1TYPE;
             }
"call"|"CALL"           {
                yylval.iValue = 0x06;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return ITYPE;
             }
"jeq"|"JEQ"           {
                yylval.iValue = 0x07;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return ITYPE;
             }
"jgei"|"JGEI"           {
                yylval.iValue = 0x08;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return ITYPE;
             }
"jgeu"|"JGEU"           {
                yylval.iValue = 0x09;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return ITYPE;
             }
"jgti"|"JGTI"           {
                yylval.iValue = 0x0a;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return ITYPE;
             }
"jgtu"|"JGTU"           {
                yylval.iValue = 0x0b;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return ITYPE;
             }
"jlei"|"JLEI"           {
                yylval.iValue = 0x0c;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return ITYPE;
             }
"jleu"|"JLEU"           {
                yylval.iValue = 0x0d;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return ITYPE;
             }
"jlti"|"JLTI"           {
                yylval.iValue = 0x0e;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return ITYPE;
             }
"jltu"|"JLTU"           {
                yylval.iValue = 0x0f;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return ITYPE;
             }
"jne"|"JNE"           {
                yylval.iValue = 0x10;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return ITYPE;
             }
"mul"|"MUL"           {
                yylval.iValue = 0x80;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return RTYPE;
             }
"cvi2"|"CVI2"           {
                yylval.iValue = 0x81;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return RTYPE;
             }
"add"|"ADD"           {
                yylval.iValue = 0x82;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return RTYPE;
             }
"sub"|"SUB"           {
                yylval.iValue = 0x83;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return RTYPE;
             }
"neg"|"NEG"           {
                yylval.iValue = 0x84;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return RTYPE;
             }
"band"|"BAND"           {
                yylval.iValue = 0x85;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return RTYPE;
             }
"bor"|"BOR"           {
                yylval.iValue = 0x86;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return RTYPE;
             }
"bxor"|"BXOR"           {
                yylval.iValue = 0x87;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return RTYPE;
             }
"bcom"|"BCOM"           {
                yylval.iValue = 0x88;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return RTYPE;
             }
"dint"|"DINT"           {
                yylval.iValue = 0xa9;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return RTYPE;
             }
"eint"|"EINT"           {
                yylval.iValue = 0xaa;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return RTYPE;
             }
"rint"|"RINT"           {
                yylval.iValue = 0xab;
		if(!optable[yylval.iValue])
		optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return RTYPE;
             }
"lshl_r"|"LSHL_R"           {
                yylval.iValue = 0x8c;
        if(!optable[yylval.iValue])
        optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return RTYPE;
             }
"rshl_r"|"RSHL_R"           {
                yylval.iValue = 0x8d;
        if(!optable[yylval.iValue])
        optable[yylval.iValue] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return RTYPE;
             }
"lshl"|"LSHL"           {
                yylval.iValue = 0xc;
		if(!optable[yylval.iValue])
		optable[yylval.iValue<<4] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return RITYPE;
             }
"rsha"|"RSHA"           {
                yylval.iValue = 0xd;
		if(!optable[yylval.iValue])
		optable[yylval.iValue<<4] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return RITYPE;
             }
"rshl"|"RSHL"           {
                yylval.iValue = 0xe;
		if(!optable[yylval.iValue])
		optable[yylval.iValue<<4] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return RITYPE;
             }
"hlt"|"HLT"           {
                yylval.iValue = 0xf;
		if(!optable[yylval.iValue])
		optable[yylval.iValue<<4] = strcpy((char *)malloc(sizeof(yytext)+1),yytext);
                return RITYPE;
             }

[\._a-zA-Z][\._a-zA-Z0-9]*  {
		yylval.iValue = slookup(yytext);
                return LABEL;
            }

[ \t\r]+        ;       /* ignore whitespace */

.               yyerror("Unknown character");

%%
static struct node *stable = NULL;

int slookup(char *s) {
  struct node *p;
  for(p=stable;p;p=p->node) {
    if(!strcmp(s,p->sym)) return p->id;
    }
  p=(struct node *)malloc(sizeof(struct node));
  p->id = labelindex++;
  if(labelindex>=LABELMAX) {fprintf(stderr,"label too much\n");exit(1);}
  p->sym = (char *)malloc(strlen(s) + 1);
  strcpy(p->sym,s);
  p->node = stable;
  stable = p;
  return p->id;
}

char * op2nm(int op) {
  return optable[op];
}
char * id2sym(int id) {
 struct node *p;
 for(p=stable;p;p=p->node) {
   if(p->id == id) return p->sym;
 }
 fprintf(stderr,"id2sym does not find ID(%d)\n", id);
 return NULL;
}

int hextoi(char *s) {
  int val=0;
  while(s[0]) {
    val *= 16;
    if(s[0]>='0' && s[0]<='9') val += s[0] - '0';
    else
    if(s[0]>='a' && s[0]<='f') val += s[0] - 'a' + 10;
    else
    if(s[0]>='A' && s[0]<='F') val += s[0] - 'a' + 10;
    s++;
    }
  return val;
}

int bintoi(char *s) {
  int val=0;
  while(s[0]) {
    val *= 2;
    if(s[0]>='0' && s[0]<='1') val += s[0] - '0';
    s++;
    }
  return val;
}

int yywrap(void) {
    return 1;
}
