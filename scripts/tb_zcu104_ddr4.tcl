
set ProjectName tb_zcu104_ddr4
set ProjectFolder ./$ProjectName

#Remove unnecessary files.
set file_list [glob -nocomplain webtalk*.*]
foreach name $file_list {
    file delete $name
}

#Delete old project if folder already exists.
if {[file exists .Xil]} { 
    file delete -force .Xil
}

#Delete old project if folder already exists.
if {[file exists "$ProjectFolder"]} { 
    file delete -force $ProjectFolder
}


create_project $ProjectName ./$ProjectName -part xczu7ev-ffvc1156-2-e
set_property board_part xilinx.com:zcu104:part0:1.1 [current_project]

create_bd_design "bd"

import_files -norecurse ./memory/BLS4G4S26BFSD.csv

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 ddr4_0
#apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {clk_300mhz ( Programmable Differential Clock (300MHz) ) } Manual_Source {Auto}}  [get_bd_intf_pins ddr4_0/C0_SYS_CLK]
make_bd_intf_pins_external  [get_bd_intf_pins ddr4_0/C0_DDR4]
make_bd_intf_pins_external  [get_bd_intf_pins ddr4_0/C0_SYS_CLK]
set_property name clock [get_bd_intf_ports C0_SYS_CLK_0]
set_property CONFIG.FREQ_HZ 300000000 [get_bd_intf_ports /clock]
endgroup
        
startgroup
set_property -dict [list CONFIG.C0.DDR4_TimePeriod {833}] [get_bd_cells ddr4_0]
set_property -dict [list CONFIG.C0.DDR4_CustomParts [lindex [get_files */BLS4G4S26BFSD.csv] 0] CONFIG.C0.DDR4_isCustom {true}] [get_bd_cells ddr4_0]
set_property -dict [list CONFIG.C0.DDR4_MemoryType {SODIMMs} CONFIG.C0.DDR4_MemoryPart {BLS4G4S26BFSD-2400} CONFIG.C0.DDR4_DataWidth {64} CONFIG.C0.DDR4_AxiDataWidth {256} CONFIG.C0.DDR4_AxiAddressWidth {32}] [get_bd_cells ddr4_0]
set_property -dict [list CONFIG.C0.DDR4_InputClockPeriod {9996}] [get_bd_cells ddr4_0]
set_property -dict [list CONFIG.C0.DDR4_AxiNarrowBurst.VALUE_SRC USER] [get_bd_cells ddr4_0]
set_property -dict [list CONFIG.C0.DDR4_AxiNarrowBurst {false}] [get_bd_cells ddr4_0]
set_property -dict [list CONFIG.C0.DDR4_AxiIDWidth.VALUE_SRC USER] [get_bd_cells ddr4_0]
set_property -dict [list CONFIG.C0.DDR4_AxiIDWidth {6}] [get_bd_cells ddr4_0]
set_property -dict [list CONFIG.C0.DDR4_AxiArbitrationScheme {WRITE_PRIORITY}] [get_bd_cells ddr4_0]
endgroup

#startgroup
#create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.2 zynq_ultra_ps_e_0
#apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1" }  [get_bd_cells zynq_ultra_ps_e_0]
#set_property -dict [list CONFIG.PSU__USE__M_AXI_GP0 {1} CONFIG.PSU__USE__M_AXI_GP1 {0} CONFIG.PSU__USE__M_AXI_GP2 {0}] [get_bd_cells zynq_ultra_ps_e_0]
#apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( FPGA Reset ) } Manual_Source {New External Port (ACTIVE_HIGH)}}  [get_bd_pins ddr4_0/sys_rst]
#apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {/ddr4_0/c0_ddr4_ui_clk (333 MHz)} Clk_xbar {Auto} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/ddr4_0/C0_DDR4_S_AXI} intc_ip {Auto} master_apm {0}}  [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI]
#set_property -dict [list CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {100}] [get_bd_cells ddr4_0]
#endgroup

startgroup
make_bd_intf_pins_external  [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI]
set_property name axi4 [get_bd_intf_ports C0_DDR4_S_AXI_0]
set_property -dict [list CONFIG.NUM_WRITE_OUTSTANDING {64} CONFIG.NUM_READ_OUTSTANDING {64} CONFIG.SUPPORTS_NARROW_BURST {0}] [get_bd_intf_ports axi4]

make_bd_pins_external  [get_bd_pins ddr4_0/c0_ddr4_aresetn]
set_property name reset [get_bd_ports c0_ddr4_aresetn_0]

set_property -dict [list CONFIG.FREQ_HZ {100000000}] [get_bd_intf_ports clock]
set_property -dict [list CONFIG.FREQ_HZ {100000000}] [get_bd_intf_ports axi4]

endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_checker:2.0 axi_protocol_checker_0
connect_bd_intf_net [get_bd_intf_pins axi_protocol_checker_0/PC_AXI] [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI]

make_bd_pins_external  [get_bd_pins axi_protocol_checker_0/pc_status]
set_property name pc_status [get_bd_ports pc_status_0]

make_bd_pins_external  [get_bd_pins axi_protocol_checker_0/pc_asserted]
set_property name pc_asserted [get_bd_ports pc_asserted_0]
endgroup

#assign_bd_address
#set_property range 4G [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_ddr4_0_C0_DDR4_ADDRESS_BLOCK}]
assign_bd_address [get_bd_addr_segs {ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK }]

add_files -fileset constrs_1 -norecurse ./xdc/ZCU104_SODIMM.xdc
import_files -fileset constrs_1 ./xdc/ZCU104_SODIMM.xdc

make_wrapper -files [get_files ./$ProjectName/$ProjectName.srcs/sources_1/bd/bd/bd.bd] -top
add_files -norecurse ./$ProjectName/$ProjectName.srcs/sources_1/bd/bd/hdl/bd_wrapper.v
add_files -norecurse -scan_for_includes ./hdl/axi4_master.v
add_files -fileset sim_1 -norecurse -scan_for_includes ./hdl/tb_axi4_master.v
update_compile_order -fileset sources_1
