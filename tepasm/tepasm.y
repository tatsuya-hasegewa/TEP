/******************************************

  Tokai Embedded Processor 16  (TEP16)
  Assembler source code.
  (C)Copyright by Naohiko Shimizu, 2008.
  All rights are reserved.  

  Contact information:
  Naohiko Shimizu, Ph.D.

  IP Architecture Laboratory
  Email: naohiko.shimizu@gmail.com
  URL: http://www.ip-arch.jp/

  
  Update informations:

    20-Jan-2009: change operations 
    21-Nov-2008: Initial vesion from snxasm.
******************************************/

%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "tepasm.h"

FILE *ofile;
FILE *lfile;

void yyerror(char *s);

typedef   enum {unused, defined} status;
typedef struct {
   status stat;
   int sft;
   unsigned int data;
   unsigned int len;
   unsigned int pc;
   int offset,id;
   void *link;
} labelp;

labelp labeltable[LABELMAX];
static unsigned int pc = 0;
static labelp imem[65536];
static enum {Seconds, Intel, Hex, Binary} fmt;
int Line = 1;
int lst = 0;
%}

%union {
    int iValue;                 /* integer value */
    nodeType *nPtr;             /* node pointer */
};

%token <iValue> INTEGER REG LABEL ITYPE I1TYPE RTYPE RITYPE
%token DEFLBL EQU ALIGN BYTE WORD LONG

%type <nPtr> stmt expr con

%%

program:
        init function                { dump(); exit(0); }
        ;

init:
        /* NULL */  	                { sinit();}
        ;

function:
          function stmt                 { ex($2,1,0); freeNode($2); }
        | /* NULL */
        ;

con:	INTEGER		{ $$ = con($1); }
	| '-' INTEGER 	{ $$ = con(-$2); }
	| '*'		{ $$ = con(pc); }
	| '-' '*'	{ $$ = con(-pc); }
	;

expr:	con		{ $$ = $1; }
	| LABEL		{ if(labeltable[$1].stat == defined) 
				$$ = con(labeltable[$1].data + imem[pc].offset);
			   else $$ = opr(LABEL,1,$1); }
	| expr '+' con 	{ imem[pc].offset += $3->con.value; $$ = $1;}
	| expr '-' con 	{ imem[pc].offset -= $3->con.value; $$ = $1;}
	;

stmt:
          '\n'          { $$ = opr(';', 2, NULL, NULL); }
        | LABEL ':'     { $$ = opr(DEFLBL, 1, con($1)); }
        | LABEL EQU expr { $$ = opr(DEFLBL, 2, con($1), $3); }
        | ALIGN expr     { $$ = opr(ALIGN, 1, $2); }
        | BYTE expr      { $$ = opr(BYTE, 1, $2); }
        | WORD expr      { $$ = opr(WORD, 1, $2); }
        | LONG expr      { $$ = opr(LONG, 1, $2); }
	| I1TYPE REG ','  expr '\n'
			{ $$ = opr(ITYPE,4,con($1), con(0), con($2), $4); }
	| ITYPE REG ','  REG ',' expr '\n'
			{ $$ = opr(ITYPE,4,con($1), con($2), con($4), $6); }
        | RTYPE REG ','  REG '\n'
               { $$ = opr(RTYPE,3, con($1), con($2), con($4)); }
        | RITYPE REG ',' REG ',' expr '\n'
               { $$ = opr(RITYPE,4, con($1), con($2), con($4), $6); }
        ;



%%

nodeType *con(int value) {
    nodeType *p;

    /* allocate node */
    if ((p = malloc(sizeof(conNodeType))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeCon;
    p->con.value = value;

    return p;
}

nodeType *opr(int oper, int nops, ...) {
    va_list ap;
    nodeType *p;
    size_t size;
    int i;

    /* allocate node */
    size = sizeof(oprNodeType) + (nops - 1) * sizeof(nodeType*);
    if ((p = malloc(size)) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeOpr;
    p->opr.oper = oper;
    p->opr.nops = nops;
    va_start(ap, nops);
    for (i = 0; i < nops; i++)
        p->opr.op[i] = va_arg(ap, nodeType*);
    va_end(ap);
    return p;
}

void freeNode(nodeType *p) {
    int i;

    if (!p) return;
    if (p->type == typeOpr && p->opr.oper != LABEL) {
        for (i = 0; i < p->opr.nops; i++)
            freeNode(p->opr.op[i]);
    }
    free (p);
}

void yyerror(char *s) {
    extern char * yytext;
    fprintf(stderr, "%s (%s) at %d\n", s, yytext, Line);
}

int main(int argc, char *argv[]) {
  int i;
  fmt=Hex;
  ofile=stdout;
  if(argc<2) {
	printf("Usage: tepasm -fmt {intel,bin,hex} -f infile -o outfile -l listfile\n");
	exit(0);
  }
  for(i=1; i<argc; i++ ) {
    if(!strcmp(argv[i],"-fmt") && argc>i) {
      switch(argv[i+1][0]) {
      case 's': fmt=Seconds; break;
      case 'i': fmt=Intel; break;
      case 'b': fmt=Binary; break;
      default:  fmt=Hex; break;
      }
      i++;
    }
    else if(!strcmp(argv[i],"-f") && argc>i) {
	    if(argv[i+1][0] == '-') yyin=stdin;
	    else yyin = fopen(argv[i+1],"r");
	    if(!yyin) yyerror("cannot find input file.");
	    i++;
	    }
    else if(!strcmp(argv[i],"-o") && argc>i) {
	    if(argv[i+1][0] == '-') ofile=stdout;
	    else ofile = fopen(argv[i+1],"w");
	    if(!ofile) yyerror("cannot open output file.");
	    i++;
    }
    else if(!strcmp(argv[i],"-l") && argc>i) {
	    lst = 1;
	    if(argv[i+1][0] == '-') lfile=stderr;
	    else lfile = fopen(argv[i+1],"w");
	    if(!lfile)  yyerror("cannot open list file.");
	    i++;
    }
    else  {
	    yyin = fopen(argv[i],"r");
	    if(!yyin) yyerror("cannot find input file.");
    }
  }
  yyparse();
  fprintf(ofile,"\n\n");
  fclose(ofile);
  if(lfile) fclose(lfile);
  fclose(yyin);
  return 0;
}

void sinit() {
int i;
 for(i=0;i<LABELMAX;i++) {
   labeltable[i].stat = unused;
   labeltable[i].id = -1;
   labeltable[i].link = NULL;
   }
 for(i=0;i<65536;i++) {
   		imem[i].offset = 0;
   		imem[i].data = 0;
   		imem[i].link = NULL;
    }

}

int ex(nodeType *p, int reg, int pres) {
 labelp *link;
 int id, data, i;
 if(!p) return 0;
 if(p->type != typeOpr) return 1;
 switch(p->opr.oper) {
  case ALIGN:
  	data = p->opr.op[0]->con.value;
	  imem[pc].len = (data - (pc & (data -1)))&(data -1);
	  imem[pc].data = -1;
	  imem[pc].offset = 0;
	  pc+= (data - (pc & (data -1)))&(data -1);
  	  if(lst) fprintf(lfile,"%04X:\t\t\t.align\t%d\n", pc, data);
	break;
  case BYTE:
	imem[pc].len = 1;
	imem[pc].data = p->opr.op[0]->con.value;
	imem[pc].offset = 0;
  	if(lst) fprintf(lfile,"%04X:\t\t\t.byte\t%d\n", pc, imem[pc].data&255);
	pc +=1;
	break;
  case WORD:
  case LONG:
	imem[pc].len = 2;
	if(p->opr.op[0]->type == typeCon) {
		imem[pc].data = p->opr.op[0]->con.value + imem[pc].offset;
  	if(lst) fprintf(lfile,"%04X:\t\t\t.word\t%d\n", pc, imem[pc].data);
	}
	else {
		id=(int)p->opr.op[0]->opr.op[0];
		if(labeltable[id].stat == defined) {
			imem[pc].data = ((labeltable[id].data + imem[pc].offset) & 0xffff);
			if(lst) fprintf(lfile,"%04X:\t\t\t.word\t%d\n", pc, imem[pc].data);
		  }
		else {
			imem[pc].sft = 0;
			imem[pc].pc = pc;
			if(labeltable[id].link) {
				imem[pc].link = labeltable[id].link;
			}
			labeltable[id].link = &imem[pc]; 
			if(lst) fprintf(lfile,"%04X:\t\t\t.word\t%s\n", pc, id2sym(id));
		}
	}
	pc +=2;
	break;
  case ITYPE:
	imem[pc].len = 4;
	imem[pc].data = 
	      (p->opr.op[0]->con.value <<8) + 
	      (p->opr.op[2]->con.value <<4) +
	      (p->opr.op[1]->con.value <<0) ;
	if(p->opr.op[3]->type == typeCon) {
		imem[pc].data += (((p->opr.op[3]->con.value + imem[pc].offset) & 0xffff)<<16);
		if(lst) fprintf(lfile,"%04X:%04X%04X\t\t%s\t$%02d,\t$%02d,\t%04X\n",
		pc, imem[pc].data&0xffff,(imem[pc].data + imem[pc].offset)>>16, op2nm(p->opr.op[0]->con.value),  p->opr.op[1]->con.value, p->opr.op[2]->con.value, (imem[pc].data>>16)&0xffff);
		}
	else {
		nodeType *t;
		t = p->opr.op[3];
		id = (int) t->opr.op[0];
		if(labeltable[id].stat == defined) {
		imem[pc].data += 
		((labeltable[id].data + imem[pc].offset) & 0xffff) << 16;
		if(lst) fprintf(lfile,"%04X:%04X%04X\t\t%s\t$%02d,\t$%02d,\t%04X\n",
		pc, imem[pc].data&0xffff, imem[pc].data>>16, op2nm(p->opr.op[0]->con.value),  p->opr.op[1]->con.value, p->opr.op[2]->con.value, (labeltable[id].data)&0xffff);
	}
	else {
		if(lst) fprintf(lfile,"%04X:%04X%04X\t\t%s\t$%02d,\t$%02d,\t%s\n",
		pc, imem[pc].data&0xffff,imem[pc].data>>16, op2nm(p->opr.op[0]->con.value),  p->opr.op[1]->con.value, p->opr.op[2]->con.value, id2sym(id));
		imem[pc].sft = 16;
		imem[pc].pc = pc;
		if(labeltable[id].link) {
			imem[pc].link = labeltable[id].link;
		}
		labeltable[id].link = &imem[pc]; 
	 }
	}
	pc += 4; break;
  case RTYPE:
	imem[pc].len = 2;
              imem[pc].data = 
              (p->opr.op[0]->con.value <<8) +
              (p->opr.op[2]->con.value <<4) +
              (p->opr.op[1]->con.value )
	      ;
	if(lst) fprintf(lfile,"%04X:%04X\t\t%s\t$%02d,\t$%02d\n", pc, imem[pc].data, op2nm(p->opr.op[0]->con.value), p->opr.op[1]->con.value, p->opr.op[2]->con.value);
              pc += 2; break;
  case RITYPE:
	imem[pc].len = 2;
              imem[pc].data = 
              ((p->opr.op[0]->con.value&0xf) <<12) + 
              ((p->opr.op[3]->con.value & 0xf) <<8) +
              ((p->opr.op[2]->con.value&0xf) <<4) +
              ((p->opr.op[1]->con.value)&0xf);
		if(lst) fprintf(lfile,"%04X:%04X\t\t%s\t$%02d,\t$%02d,\t%04X\n", pc, imem[pc].data, op2nm(p->opr.op[0]->con.value<<4), p->opr.op[1]->con.value, p->opr.op[2]->con.value, p->opr.op[3]->con.value);
              pc += 2; break;
  case DEFLBL:
              id = p->opr.op[0]->con.value;
              if(labeltable[id].stat == defined) {
				fprintf(stderr,"Double defined label %s\n",	id2sym(id));
				exit(1);
				}
              labeltable[id].stat = defined;
	      labeltable[id].id = id; 
  	      if(p->opr.nops == 1) {
		if(lst) fprintf(lfile,"%04X:\t\t%s:\n", pc, id2sym(id));
                    data = pc;
	      }
	      else if(p->opr.nops == 2) {
					if(p->opr.op[1]->type == typeCon)
	                    data = p->opr.op[1]->con.value;
	                 else {
						fprintf(stderr,"equ does not support forward reference.\n");
						exit(1);
						   }
      	      }
              labeltable[id].data = data;
              link = labeltable[id].link;
              while(link) {
                link->data += ((data + link->offset) & 0xffff) << link->sft;
                link = link->link;
                }
              break;
 }
return 0;
}

void dump() {
int i,j,sum;
for(i=0; i<pc; i+= imem[i].len) {
switch(fmt) {
case Intel:
 fprintf(ofile,":%02X%04X00", imem[i].len, i);
 sum = 0;
 for(j=0; j<imem[i].len; j++) {
   fprintf(ofile,"%02X", (imem[i].data>>((j)*8)) & 0xff);
   sum  = sum + (imem[i].data>>((j)*8)) & 0xff;
   }
   sum = (-( imem[i].len + (i>>8) + (i & 0xff) + sum)) & 0xff;
   fprintf(ofile,"%02X\n", sum);
 break;
case Binary:
 for(j=0; j<imem[i].len; j++)
   fprintf(ofile,"%c", (imem[i].data>>((j)*8)) & 0xff);
 break;
case Hex:
 for(j=0; j<imem[i].len; j++)
   fprintf(ofile,"%02X ", (imem[i].data>>((j)*8)) & 0xff);
 if((i&15)>=7) fprintf(ofile,"\n");
 break;
 }
 }
if(fmt==Intel) fprintf(ofile,":00000001FF\n");
if(fmt==Binary) for(i=i;i<128;i++) fprintf(ofile,"%c%c",'\0','\0');
}
