SHELL=bash
FPGABOARD=top
FPGADIR=Altera
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
SIMTOP=main
TESTBENCH=testBench

all:  $(SYSEXE)

sim: tep.v sys.v sysmain.v $(TARGET).mem
	cp $(TARGET).mem $(SYSMEM)
	./8to16.py $(SYSMEM)
	sed -i -E -e "s/#include \"V.*___024root\.h\"$$/#include \"V$(SIMTOP)___024root\.h\"/g" $(TESTBENCH).cpp
	sed -i -E -e "s/#include \"V.*[^024root]\.h\"$$/#include \"V$(SIMTOP)\.h\"/g" $(TESTBENCH).cpp
	sed -i -e"s/V.*\\\*top;/V$(SIMTOP) *top;/g" $(TESTBENCH).cpp
	sed -i -e"s/top = new V.*;/top = new V$(SIMTOP);/g" $(TESTBENCH).cpp
	verilator -Wno-STMTDLY -Wno-TIMESCALEMOD -Wno-REALCVT -Wno-INFINITELOOP -Wno-IMPLICIT -Wno-WIDTH -Wno-BLKANDNBLK --default-language 1364-2005 -cc --trace --trace-underscore sysmain.v tep.v sys.v --top-module $(SIMTOP) -exe $(TESTBENCH).cpp -O3
	make -C ./obj_dir/ -f V$(SIMTOP).mk
	./obj_dir/V$(SIMTOP)

$(TARGET).s:	$(TARGET).c
	lcc -S $(TARGET).c

$(TARGET).mem:	tepasm/tepasm $(TARGET).s
	sh asm.sh  $(TARGET).s | tee $(TARGET).mem

tepasm/tepasm:
	( cd tepasm; make all )

$(SYSEXE): tep.v sys.v sysmain.v
	$(VERILOG) -o $(SYSEXE) sys.v tep.v sysmain.v

sys.v: $(SRC) sys.nsl
	$(NSL2VLEXE) sys.nsl -O2

tep.v:	tep.nsl
	$(NSL2VLEXE) tep.nsl -O2

synthe:	$(SRC) $(FPGABOARD).nsl $(TARGET).mem tep.v
	$(NSL2VLEXE) $(FPGABOARD).nsl $(SYNTHEOPT)
	mv $(FPGABOARD).v tep.v $(FPGADIR)
	./memtomif.py $(TARGET).mem
	mv $(TARGET).mif $(FPGADIR)/mainmem.mif
	make -C $(FPGADIR)

distclean:
	make clean
	-rm tepasm/tepasm.exe

clean:
	-rm $(CLEAN) 2> /dev/null
	-rm -rf obj_dir
	-(cd tepasm; rm $(ASMCLEANS))
