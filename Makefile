# Project setup
PROJ      = uart
BUILD     = ./build
#DEVICE    = 1k
DEVICE    = 8k
ifeq (8k,$(DEVICE))
FOOTPRINT = ct256
else
FOOTPRINT = tq144
endif

export test=1

# Files
FILES = top.sv
# FILES += globals.vh
FILES += audioEngine.sv
FILES += uart_trx.sv
FILES += sketch.sv
FILES += clock_divider.sv
FILES += osc_square.sv
FILES += osc_saw.sv
FILES += LFSR.v
# FILES += dsp_invert.v
FILES += dsp_addcl.sv
FILES += dsp_mult.sv
FILES += dsp_mix2.sv
FILES += dsp_lowp.sv
FILES += dsp_highp.sv
FILES += seq3.sv
FILES += bitseq.sv
FILES += bitrotate.sv
FILES += envseq.sv


.PHONY: all clean burn

all:$(BUILD)/$(PROJ).bin

$(BUILD)/$(PROJ).bin: $(FILES) Makefile
	# if build folder doesn't exist, create it
	mkdir -p $(BUILD)
	# synthesize using Yosys
	yosys -p "synth_ice40 -top top -blif $(BUILD)/$(PROJ).blif" $(FILES)
	# Place and route using arachne
	arachne-pnr -d $(DEVICE) -P $(FOOTPRINT) -o $(BUILD)/$(PROJ).asc -p pinmap_$(FOOTPRINT).pcf $(BUILD)/$(PROJ).blif
	# Convert to bitstream using IcePack
	icepack $(BUILD)/$(PROJ).asc $(BUILD)/$(PROJ).bin

burn:   $(BUILD)/$(PROJ).bin
	# iceprog -d i:0x0403:0x6010:1 $(BUILD)/$(PROJ).bin
	source ./liveburn.sh
clean:
	rm -f build/*
