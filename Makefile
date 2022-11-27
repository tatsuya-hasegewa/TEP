SHELL=bash
FPGABOARD=top
FPGADIR=Xilinx
SYNTHEOPT=-O2 -DSYNTHE
VCD=+vcd=1
P=
TARGET=mon
SRC=sys.nsl tep.nsl serial_clkfix.nsl serial_in.nsl serial_out.nsl serial.h clkdep.h 
CLEANS=tep.v sys.v tep.mem sim.log tepasm/tepasm.exe tep.vcd
ASMCLEANS = tepasm.tab.o lex.yy.o tepasm.tab.c lex.yy.c tepasm.tab.h tepasm.y~ tepasm.l~ tepasm.h~ Makefile~
CLEANX=$(FPGADIR)/$(TARGET).mem $(FPGADIR)/$(FPGABOARD).v
CLEANT=$(TARGET).mem $(TARGET).dat $(TARGET).s
CLEAN=$(CLEANS) $(CLEANT) $(CLEANX)
SYSEXE=./sys
SYSMEM=tep.mem
NSL2VLEXE=nsl2vl
VERILOG=iverilog
VVP=vvp

all:  $(SYSEXE)


sim:	$(TARGET).mem $(SYSEXE)
	cp $(TARGET).mem $(SYSMEM)
	$(VVP) $(SYSEXE) $(VCD)| tee sim.log

$(TARGET).s:	$(TARGET).c
	lcc -S $(TARGET).c

$(TARGET).mem:	tepasm/tepasm.exe $(TARGET).s
	sh asm.sh  $(TARGET).s | tee $(TARGET).mem


tepasm/tepasm.exe:
	( cd tepasm; make all )

$(SYSEXE): tep.v sys.v sysmain.v
	$(VERILOG) -o $(SYSEXE) sys.v tep.v sysmain.v

sys.v:	sys.nsl
	$(NSL2VLEXE) sys.nsl -O

tep.v:	tep.nsl
	$(NSL2VLEXE) tep.nsl -O

synthe:	$(SRC) $(FPGABOARD).nsl $(TARGET).mem
	$(NSL2VLEXE) $(FPGABOARD).nsl $(SYNTHEOPT)
	mv $(FPGABOARD).v $(FPGADIR)
	cp $(TARGET).mem $(FPGADIR)
	

distclean:
	make clean
	-rm tepasm/tepasm.exe

clean:
	-rm $(CLEAN) 2> /dev/null
	-(cd tepasm; rm $(ASMCLEANS))
