.globl startup
.text
.align 2
startup:
CNST $15,$0,4096
CALL $2,$0,main
HLT $0,$0,0
.size startup,.Lf2-startup
.ident "LCC: 4.1"
