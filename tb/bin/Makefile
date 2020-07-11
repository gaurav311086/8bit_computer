PHONY: clean



TEST := "cpu_rom_update"
LIB_CREATE:="vlib.exe"
LIB_MAP:="vmap.exe"
SIM_TOOL :="vsim.exe"
VERILOG_COMPILE:="vlog.exe"
RTL_DIR := "../../dig/rtl"
RTL_F := rtl.f
TB_DIR := "../"
TEST_DIR := "../tests/${TEST}/"
LIB_WORK := ${TEST_DIR}/work
GUI := -gui

TB_TOP := work.tb_top

lib_create:
	${LIB_CREATE} ${LIB_WORK}; \

lib_map:
	${LIB_MAP} work ${LIB_WORK}; \

all: clean lib_create lib_map
	${VERILOG_COMPILE} -work ${LIB_WORK} -incr ${RTL_DIR}/*.v; \
	${VERILOG_COMPILE} -work ${LIB_WORK} -incr ${TB_DIR}/*.v; \
	${SIM_TOOL} -voptargs=+acc ${TB_TOP} ${GUI} -wlf ${TEST_DIR}/run.wlf -msgfile ${TEST_DIR}/run.log  -do "add log -r tb_top/*;run 200 us;"

clean:
	rm -fR ${TEST_DIR}/work; \
	rm -fR wlf* \
	


