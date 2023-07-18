.globl main

.text

.align 2

main:

CNST $7,$0,-1

CNST $8,$0,2

LSHL_R $8,$7

HLT $0,$0,0

.size startup,.Lf2-startup

.ident "LCC: 4.1"
