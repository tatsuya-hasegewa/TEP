################################################################################
# Makefile : sof file generation using Quartus II
# Usage:
#		make compile for synthesis all files
#       make download for download .sof file to FPGA board
################################################################################
# 2011-09-12,13 Initial version by Y.Okuyama (based on PICO's makefile)
# 2012-10-08    CABLE is modified for linux environment
# 2013-07-09    Modified for DE0/windows environment
################################################################################

ifndef SRCDIR
SRCDIR	= .
endif

VPATH		= $(SRCDIR)
WORKDIR		= synth
DESIGN		= TEP
BOARD		= DE0_CV
NSL2VL    	= nsl2vl
NSLFLAGS  	= -O2 -neg_res -I$(SRCDIR)
MKPROJ		= $(SRCDIR)/mkproj-$(BOARD).tcl
Q2SH		= quartus_sh
Q2PGM		= quartus_pgm
CABLE		= "USB-Blaster [USB-0]"
PMODE		= JTAG
MIFS		:= $(wildcard $(SRCDIR)/*.mif)
VFILES 		= $(notdir $(wildcard $(SRCDIR)/*.v))
LIBS		= 
CLEANVFILES = $(filter-out %altBram4k.v, $(VFILES))

########

all:
	@if [ ! -d $(WORKDIR) ]; then \
		echo mkdir $(WORKDIR); \
		mkdir $(WORKDIR); \
	fi
	cp $(MIFS) $(VFILES) $(WORKDIR)
	( cd $(WORKDIR); make -f ../Makefile SRCDIR=.. compile )

########

.SUFFIXES: .v .nsl
.PHONY: test

$(DESIGN).qsf: $(VFILES) $(LIBS)
	$(Q2SH) -t $(MKPROJ) -project $(DESIGN) $^

$(DESIGN).sof: $(DESIGN).qsf
	$(Q2SH) --flow compile $(DESIGN)

########

compile: $(DESIGN).qsf
#	@echo "**** $(DESIGN).fit.summary" | tee -a $(RESULT)
#	@cat $(DESIGN).fit.summary | tee -a $(RESULT)
#	@echo "**** $(DESIGN).tan.rpt" | tee -a $(RESULT)
#	@grep "Info: Fmax" $(DESIGN).tan.rpt | tee -a $(RESULT)

download: config-n

config: all
	$(Q2PGM) -c $(CABLE) -m $(PMODE) -o "p;$(WORKDIR)/$(DESIGN).sof"
config-n: # without re-compile
	$(Q2PGM) -c $(CABLE) -m $(PMODE) -o "p;$(WORKDIR)/$(DESIGN).sof"

clean:
	rm -rf - $(WORKDIR)
	rm $(CLEANVFILES) mainmem.mif

########

#$(DESIGN).v	: $(DESIGN).nsl
