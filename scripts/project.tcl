
set ProjectName tb_axi4_master
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

create_project $ProjectName $ProjectFolder -part xcvu9p-fsgd2104-2L-e

set_property  ip_repo_paths  ./hdl [current_project]
update_ip_catalog

create_bd_design "bd"


startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0
set_property -dict [list CONFIG.DATA_WIDTH {256} CONFIG.SINGLE_PORT_BRAM {1} CONFIG.ECC_TYPE {0}] [get_bd_cells axi_bram_ctrl_0]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0
set_property -dict [list CONFIG.PRIM_type_to_Implement {URAM} CONFIG.Assume_Synchronous_Clk {true} CONFIG.EN_SAFETY_CKT {false}] [get_bd_cells blk_mem_gen_0]
endgroup

startgroup
connect_bd_intf_net [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA] [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_aclk]
set_property name clock [get_bd_ports s_axi_aclk_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn]
set_property name reset [get_bd_ports s_axi_aresetn_0]
endgroup

startgroup
make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_araddr]
set_property name araddr [get_bd_ports s_axi_araddr_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_arburst]
set_property name arburst [get_bd_ports s_axi_arburst_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_arcache]
set_property name arcache [get_bd_ports s_axi_arcache_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_arlen]
set_property name arlen [get_bd_ports s_axi_arlen_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_arlock]
set_property name arlock [get_bd_ports s_axi_arlock_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_arprot]
set_property name arprot [get_bd_ports s_axi_arprot_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_arready]
set_property name arready [get_bd_ports s_axi_arready_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_arsize]
set_property name arsize [get_bd_ports s_axi_arsize_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_arvalid]
set_property name arvalid [get_bd_ports s_axi_arvalid_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_awaddr]
set_property name awaddr [get_bd_ports s_axi_awaddr_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_awburst]
set_property name awburst [get_bd_ports s_axi_awburst_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_awcache]
set_property name awcache [get_bd_ports s_axi_awcache_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_awlen]
set_property name awlen [get_bd_ports s_axi_awlen_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_awlock]
set_property name awlock [get_bd_ports s_axi_awlock_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_awprot]
set_property name awprot [get_bd_ports s_axi_awprot_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_awready]
set_property name awready [get_bd_ports s_axi_awready_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_awsize]
set_property name awsize [get_bd_ports s_axi_awsize_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_awvalid]
set_property name awvalid [get_bd_ports s_axi_awvalid_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_bready]
set_property name bready [get_bd_ports s_axi_bready_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_bresp]
set_property name bresp [get_bd_ports s_axi_bresp_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_bvalid]
set_property name bvalid [get_bd_ports s_axi_bvalid_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_rdata]
set_property name rdata [get_bd_ports s_axi_rdata_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_rlast]
set_property name rlast [get_bd_ports s_axi_rlast_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_rready]
set_property name rready [get_bd_ports s_axi_rready_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_rresp]
set_property name rresp [get_bd_ports s_axi_rresp_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_rvalid]
set_property name rvalid [get_bd_ports s_axi_rvalid_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_wdata]
set_property name wdata [get_bd_ports s_axi_wdata_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_wlast]
set_property name wlast [get_bd_ports s_axi_wlast_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_wready]
set_property name wready [get_bd_ports s_axi_wready_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_wstrb]
set_property name wstrb [get_bd_ports s_axi_wstrb_0]

make_bd_pins_external  [get_bd_pins axi_bram_ctrl_0/s_axi_wvalid]
set_property name wvalid [get_bd_ports s_axi_wvalid_0]
endgroup

regenerate_bd_layout

make_wrapper -files [get_files ./$ProjectName/$ProjectName.srcs/sources_1/bd/bd/bd.bd] -top
add_files -norecurse ./$ProjectName/$ProjectName.srcs/sources_1/bd/bd/hdl/bd_wrapper.v

add_files -norecurse -scan_for_includes ./hdl/axi4_master.v
add_files -fileset sim_1 -norecurse -scan_for_includes ./hdl/tb_axi4_master.v

