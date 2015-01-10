ICARUS_DIR=/home/pawel/Programming/icarus/bin
IVERILOG=$(ICARUS_DIR)/iverilog
VVP=$(ICARUS_DIR)/vvp

XST=/home/pawel/xilinx/14.7/ISE_DS/ISE/bin/lin64/xst
NGDBUILD=/home/pawel/xilinx/14.7/ISE_DS/ISE/bin/lin64/ngdbuild
MAP=/home/pawel/xilinx/14.7/ISE_DS/ISE/bin/lin64/map
PAR=/home/pawel/xilinx/14.7/ISE_DS/ISE/bin/lin64/par
TRCE=/home/pawel/xilinx/14.7/ISE_DS/ISE/bin/lin64/trce
BITGEN=/home/pawel/xilinx/14.7/ISE_DS/ISE/bin/lin64/bitgen

DEVICE=xc6slx16
PARTNAME=$(DEVICE)-csg324-3
DESIGN=ksenios
SRC=ksenios.v \
	psram/ram_controller.v \
    ethernet/ethernet.v ethernet/ethernet_init.v ethernet/ethernet_nibble_aggregator.v ethernet/ethernet_smi.v ethernet/ethernet_rx.v \
    ethernet/ethernet_preamble_detector.v \
    uart/baud_rate_generator.v uart/uart.v uart/uart_tx.v uart/uart_rx.v \
    utils/display.v utils/debounce.v utils/fifo_16x8.v utils/xilinx_dist_ram_16x8.v utils/fifo_16x4.v utils/xilinx_dist_ram_16x4.v utils/bin2ascii.v
UCF=Nexys3_Master.ucf
TESTBENCH=testbench_ethernet_rx.v

TMP=tmp
PROJECT=$(TMP)/$(DESIGN).prj
SCRIPT=$(TMP)/$(DESIGN).xst
SYR=$(TMP)/$(DESIGN).syr
NGC=$(TMP)/$(DESIGN).ngc
NGD=$(TMP)/$(DESIGN).ngd
MAP_NCD=$(TMP)/map_$(DESIGN).ncd
NCD=$(TMP)/$(DESIGN).ncd
TWR=$(TMP)/$(DESIGN).twx
TWR=$(TMP)/$(DESIGN).twr
PCF=$(TMP)/$(DESIGN).pcf
BIT=$(TMP)/$(DESIGN).bit
DST=$(TMP)/$(DESIGN)

STYLE=ise

.PHONY: all clean synthesis translate map place timing bitgen testbench

all: bitgen

synthesis: $(NGC)

translate: $(NGD)

map: $(MAP_NCD)

place: $(NCD)

timing: $(TWR)

bitgen: $(BIT)

$(BIT): $(TWR)
	$(BITGEN) -intstyle $(STYLE) -w -g DebugBitstream:No -g Binary:No -g CRC:Enable -g Reset_on_err:No -g ConfigRate:2 -g ProgPin:PullUp -g TckPin:PullUp -g TdiPin:PullUp -g TdoPin:PullUp -g TmsPin:PullUp -g UnusedPin:PullDown -g UserID:0xFFFFFFFF -g ExtMasterCclk_en:No -g SPI_buswidth:1 -g TIMER_CFG:0xFFFF -g multipin_wakeup:No -g StartUpClk:CClk -g DONE_cycle:4 -g GTS_cycle:5 -g GWE_cycle:6 -g LCK_cycle:NoWait -g Security:None -g DonePipe:Yes -g DriveDone:No -g en_sw_gsr:No -g drive_awake:No -g sw_clk:Startupclk -g sw_gwe_cycle:5 -g sw_gts_cycle:4 $(NCD)

$(TWR): $(NCD)
	$(TRCE) -intstyle $(STYLE) -v 3 -s 3 -n 3 -fastpaths $(XML) $(NCD) -o $(TWR) $(PCF)

$(NCD): $(MAP_NCD)
	$(PAR) -intstyle $(STYLE) -w -ol high -mt off $(MAP_NCD) $(NCD) $(PCF)

$(MAP_NCD): $(NGD)
	$(MAP) -intstyle $(STYLE) -p $(PARTNAME) -w -logic_opt off -ol high -t 1 -xt 0 -register_duplication off -r 4 -global_opt off -mt off -ir off -pr off -lc off -o $(MAP_NCD) $(NGD) $(PCF) 

$(NGD): $(NGC) $(UCF)
	$(NGDBUILD) -intstyle $(STYLE) -dd $(TMP)/_ngo -nt timestamp -uc $(UCF) -p $(PARTNAME) $(NGC) $(NGD)

$(NGC): $(SCRIPT)
	$(XST) -ifn $(SCRIPT) -ofn $(SYR) -intstyle $(STYLE)

testbench: $(DST)
	$(VVP) $(DST)

$(DST): $(SRC) $(TESTBENCH) |$(TMP)
	$(IVERILOG) -Dtestbench -Wall $^ -o $@

$(PROJECT): $(SRC) |$(TMP)
	@rm -f $(PROJECT)
	@for i in $(SRC) ; do \
    	echo "verilog work ../$$i" >> $(PROJECT); \
	done
	@echo "Created $(PROJECT)"

$(SCRIPT): $(PROJECT)
	@echo "run -ifn $(PROJECT) -ifmt mixed -ofn $(NGC) -ofmt NGC -p $(DEVICE) -opt_mode Speed -opt_level 1 -top ksenios" > $(SCRIPT)
	@echo "Created $(SCRIPT)"

$(TMP):
	mkdir $(TMP)

clean:
	rm -rf $(TMP) xst xlnx_auto_0_xdb _xmsgs iseconfig *lso _impact.* *xrpt *html *xml
