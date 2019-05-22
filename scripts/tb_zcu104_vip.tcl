
set ProjectName tb_zcu104_vip
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

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_vip:1.1 axi_vip_0
set_property -dict [list CONFIG.INTERFACE_MODE {SLAVE}] [get_bd_cells axi_vip_0]
#set_property -dict [list CONFIG.SUPPORTS_NARROW.VALUE_SRC USER] [get_bd_cells axi_vip_0]
#set_property -dict [list CONFIG.SUPPORTS_NARROW {0}] [get_bd_cells axi_vip_0]
#set_property -dict [list CONFIG.ID_WIDTH.VALUE_SRC USER] [get_bd_cells axi_vip_0]
#set_property -dict [list CONFIG.ID_WIDTH {4}] [get_bd_cells axi_vip_0]
#set_property -dict [list CONFIG.HAS_REGION.VALUE_SRC USER] [get_bd_cells axi_vip_0]
#set_property -dict [list CONFIG.HAS_REGION {0}] [get_bd_cells axi_vip_0]

make_bd_intf_pins_external  [get_bd_intf_pins axi_vip_0/S_AXI]
set_property name S_AXI [get_bd_intf_ports S_AXI_0]
set_property -dict [list CONFIG.HAS_REGION {0}] [get_bd_intf_ports S_AXI]
set_property -dict [list CONFIG.MAX_BURST_LENGTH {16}] [get_bd_intf_ports S_AXI]
set_property -dict [list CONFIG.ID_WIDTH {1}] [get_bd_intf_ports S_AXI]
set_property -dict [list CONFIG.SUPPORTS_NARROW_BURST {0}] [get_bd_intf_ports S_AXI]

make_bd_pins_external  [get_bd_pins axi_vip_0/aclk]
set_property name CLOCK [get_bd_ports aclk_0]

make_bd_pins_external  [get_bd_pins axi_vip_0/aresetn]
set_property name RESET [get_bd_ports aresetn_0]
endgroup


startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_protocol_checker:2.0 axi_protocol_checker_0
set_property location {2 355 -175} [get_bd_cells axi_protocol_checker_0]
connect_bd_intf_net [get_bd_intf_pins axi_protocol_checker_0/PC_AXI] [get_bd_intf_pins axi_vip_0/S_AXI]
connect_bd_net [get_bd_ports CLOCK] [get_bd_pins axi_protocol_checker_0/aclk]
connect_bd_net [get_bd_ports RESET] [get_bd_pins axi_protocol_checker_0/aresetn]

make_bd_pins_external  [get_bd_pins axi_protocol_checker_0/pc_status]
set_property name PC_STATUS [get_bd_ports pc_status_0]

make_bd_pins_external  [get_bd_pins axi_protocol_checker_0/pc_asserted]
set_property name PC_ASSERTED [get_bd_ports pc_asserted_0]
endgroup

assign_bd_address [get_bd_addr_segs {axi_vip_0/S_AXI/Reg }]
set_property offset 0x00000000 [get_bd_addr_segs {S_AXI/SEG_axi_vip_0_Reg}]
set_property range 4G [get_bd_addr_segs {S_AXI/SEG_axi_vip_0_Reg}]

regenerate_bd_layout
save_bd_design

make_wrapper -files [get_files ./$ProjectName/$ProjectName.srcs/sources_1/bd/bd/bd.bd] -top
add_files -norecurse ./$ProjectName/$ProjectName.srcs/sources_1/bd/bd/hdl/bd_wrapper.v

add_files -norecurse -scan_for_includes ./hdl/axi4_master_orig.v
add_files -fileset sim_1 -norecurse -scan_for_includes ./hdl/tb_axi4_master.sv
update_compile_order -fileset sources_1
