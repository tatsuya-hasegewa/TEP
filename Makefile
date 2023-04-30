SHELL=bash
FPGABOARD=top
FPGADIR=Altera
SYNTHEOPT=-O2 -DSYNTHE -neg_res
VCD=+vcd=1
P=
TARGET=mon
CLEANS=tep.v sys.v tep.mem sim.log tepasm/tepasm.exe tep.vcd
ASMCLEANS = tepasm.tab.o lex.yy.o tepasm.tab.c lex.yy.c tepasm.tab.h tepasm.y~ tepasm.l~ tepasm.h~ Makefile~
CLEANX=$(FPGADIR)/$(TARGET).mem $(FPGADIR)/$(FPGABOARD).v
CLEANT=$(TARGET).mem $(TARGET).dat $(TARGET).s
CLEAN=$(CLEANS) $(CLEANT) $(CLEANX)
SYSEXE=./sys
SYSMEM=tep.mem
NSL2VL=nsl2vl
VERILOG=iverilog
VVP=vvp
SIMTOP=main
TESTBENCH=testBench
NSLFLAGS  	= -O2 -neg_res
SRCS 		= $(wildcard ./*.nsl)
VFILES		= $(addprefix Altera/, $(patsubst %.nsl,%.v,$(notdir $(SRCS))))
SIMSRCS		= $(filter-out %top.nsl, $(SRCS))
SIMVFILES 		= $(addprefix out/, $(patsubst %.nsl,%.v,$(notdir $(SIMSRCS)))) sysmain.v

all:  $(SYSEXE)
.PHONY: test

test:
	echo $(SRCS)
	echo $(SIMSRCS)
	echo $(SIMVFILES)
	echo $(COMPILE.c)
	echo $(OUTPUT_OPTION)

sim: $(SIMVFILES) $(TARGET).mem
	cp $(TARGET).mem $(SYSMEM)
	sed -i -E -e "s/#include \"V.*___024root\.h\"$$/#include \"V$(SIMTOP)___024root\.h\"/g" $(TESTBENCH).cpp
	sed -i -E -e "s/#include \"V.*[^024root]\.h\"$$/#include \"V$(SIMTOP)\.h\"/g" $(TESTBENCH).cpp
	sed -i -e"s/V.*\\\*top;/V$(SIMTOP) *top;/g" $(TESTBENCH).cpp
	sed -i -e"s/top = new V.*;/top = new V$(SIMTOP);/g" $(TESTBENCH).cpp
	verilator -Wno-STMTDLY -Wno-TIMESCALEMOD -Wno-REALCVT -Wno-INFINITELOOP -Wno-IMPLICIT -Wno-WIDTH -Wno-BLKANDNBLK --default-language 1364-2005 -cc --trace --trace-underscore $(SIMVFILES) --top-module $(SIMTOP) -exe $(TESTBENCH).cpp -O3
	make -C ./obj_dir/ -f V$(SIMTOP).mk
	cp ./obj_dir/V$(SIMTOP) simExe

$(TARGET).s:	$(TARGET).c
	lcc -S $(TARGET).c

$(TARGET).mem:	tepasm/tepasm $(TARGET).s
	sh asm.sh  $(TARGET).s > $(TARGET).mem
	./8to16.py $(TARGET).mem

tepasm/tepasm:
	( cd tepasm; make all )

$(SYSEXE): tep.v sys.v sysmain.v
	$(VERILOG) -o $(SYSEXE) sys.v tep.v sysmain.v

out/%.v: $(SIMSRCS)
	if [ ! -d out ]; then \
		mkdir out; \
	fi
	$(NSL2VL) $(NSLFLAGS) $(filter $(shell echo $^ | grep "[^ ]*$*.nsl" -o), $^) -o $@

Altera/%.v: $(SRCS)
	$(NSL2VL) $(SYNTHEOPT) $(filter $(shell echo $^ | grep "[^ ]*$*.nsl" -o), $^) -o $@

synthe:	$(VFILES)
	./memtomif.py $(TARGET).mem
	mv $(TARGET).mif $(FPGADIR)/mainmem.mif
	make -C $(FPGADIR)

distclean:
	make clean
	-rm tepasm/tepasm.exe

clean:
	-rm $(CLEAN) 2> /dev/null
	-rm -rf obj_dir out
	-(cd tepasm; rm $(ASMCLEANS))
