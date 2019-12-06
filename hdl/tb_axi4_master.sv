`timescale 1ns / 1ps

//`include "axi4_master_v1_0_tb_include.svh"

import axi_vip_pkg::*;
import bd_axi_vip_0_0_pkg::*;

module tb_axi4_master();

parameter CLK_HALF_PERIOD = 5;
parameter CLK_PERIOD = 2 * CLK_HALF_PERIOD;

parameter P_TARGET_SLAVE_BASE_ADDR = 32'h10000000;
parameter integer P_WRITE_BURSTS   = 1;
parameter integer P_READ_BURSTS    = 16;
parameter integer P_ID_WIDTH       = 6;
parameter integer P_ADDR_WIDTH     = 32;
parameter integer P_DATA_WIDTH     = 256;

bit                      tb_clock;
bit                      tb_reset;
xil_axi_uint             error_cnt = 0;
xil_axi_uint             comparison_cnt = 0;
axi_transaction          wr_transaction;   
axi_transaction          rd_transaction;   
axi_monitor_transaction  mst_monitor_transaction;  
axi_monitor_transaction  master_moniter_transaction_queue[$];  
xil_axi_uint             master_moniter_transaction_queue_size =0;  
axi_monitor_transaction  mst_scb_transaction;  
axi_monitor_transaction  passthrough_monitor_transaction;  
axi_monitor_transaction  passthrough_master_moniter_transaction_queue[$];  
xil_axi_uint             passthrough_master_moniter_transaction_queue_size =0;  
axi_monitor_transaction  passthrough_mst_scb_transaction;  
axi_monitor_transaction  passthrough_slave_moniter_transaction_queue[$];  
xil_axi_uint             passthrough_slave_moniter_transaction_queue_size =0;  
axi_monitor_transaction  passthrough_slv_scb_transaction;  
axi_monitor_transaction  slv_monitor_transaction;  
axi_monitor_transaction  slave_moniter_transaction_queue[$];  
xil_axi_uint             slave_moniter_transaction_queue_size =0;  
axi_monitor_transaction  slv_scb_transaction;  
xil_axi_uint             mst_agent_verbosity = 0;  
xil_axi_uint             slv_agent_verbosity = 0;  
xil_axi_uint             passthrough_agent_verbosity = 0;  
xil_axi_ulong            mem_rd_addr;
xil_axi_ulong            mem_wr_addr;
bit [P_DATA_WIDTH-1:0]   write_data;
bit                      write_strb[];
bit [P_DATA_WIDTH-1:0]   read_data;
bit                      tb_init;
bit                      tb_done;
bit                      tb_error;
bit                      tb_asserted;
bit [159:0]              tb_status;

wire [P_ID_WIDTH - 1:0] tb_awid;
wire [P_ADDR_WIDTH - 1:0] tb_awaddr;
wire [P_DATA_WIDTH - 1:0] tb_wdata;
wire [P_DATA_WIDTH/8-1:0] tb_wstrb;
wire [1:0] tb_awburst;
wire [2:0] tb_awsize;
wire [3:0] tb_awcache;
wire [7:0] tb_awlen;
wire [0:0] tb_awlock;
wire [2:0] tb_awprot;
wire [3:0] tb_awqos;
wire tb_awvalid;
wire tb_wvalid;
wire tb_wlast;
wire tb_awready;
wire tb_wready;

wire tb_bready;  
wire [P_ID_WIDTH - 1:0] tb_bid;
wire [1:0] tb_bresp;
wire tb_bvalid;

wire tb_arvalid;
wire [P_ADDR_WIDTH - 1:0] tb_araddr;
wire [1:0] tb_arburst;
wire [2:0] tb_arsize;
wire [3:0] tb_arcache;
wire [0:0] tb_arid;
wire [7:0] tb_arlen;
wire [0:0] tb_arlock;
wire [2:0] tb_arprot;
wire [3:0] tb_arqos;

wire tb_arready;
wire [P_DATA_WIDTH-1:0] tb_rdata;
wire [P_ID_WIDTH - 1:0] tb_rid;
wire tb_rlast;
wire tb_rready;
wire [1:0] tb_rresp;
wire tb_rvalid;

reg  [P_ADDR_WIDTH - 1:0] tb_write_addr = 0;
reg  [P_DATA_WIDTH - 1:0] tb_write_data = 0;
reg  tb_write_start = 0;
wire tb_write_ready;
wire tb_write_done;
wire tb_write_err;

bd_axi_vip_0_0_slv_mem_t slv_agent_0;

bd_wrapper BD_WRAPPER
(
    .CLOCK(tb_clock),
    .RESET(tb_reset),
    .PC_ASSERTED(tb_asserted),
    .PC_STATUS(tb_status),
    .WRITE_START(tb_write_start),
    .WRITE_ADDR(tb_write_addr),
    .WRITE_DATA(tb_write_data),
    .WRITE_DONE(tb_write_done),
    .WRITE_ERROR(tb_write_err),
    .WRITE_READY(tb_write_ready)
);

////axi4_master_v1_0_M00_AXI #
//axi4_master #
//(
//    .P_TARGET_SLAVE_BASE_ADDR(P_TARGET_SLAVE_BASE_ADDR),
//    .P_WRITE_BURSTS(P_WRITE_BURSTS),
//    .P_READ_BURSTS(P_READ_BURSTS),
//    .P_ID_WIDTH(P_ID_WIDTH),
//	  .P_ADDR_WIDTH(P_ADDR_WIDTH),
//    .P_DATA_WIDTH(P_DATA_WIDTH)
//)
//axi4_master_i
//(
//    .WRITE_ADDR(tb_write_addr),
//    .WRITE_DATA(tb_write_data),
//    .WRITE_START(tb_write_start),
//    .WRITE_READY(tb_write_ready),
//    .WRITE_DONE(tb_write_done),
//    .WRITE_ERROR(tb_write_err),    
    
//    .CLOCK(tb_clock),
//    .RESET(tb_reset),
    
//    .AWID(tb_awid),
//    .AWADDR(tb_awaddr),
//    .AWLEN(tb_awlen),
//    .AWSIZE(tb_awsize),
//    .AWBURST(tb_awburst),
//    .AWLOCK(tb_awlock),
//    .AWCACHE(tb_awcache),
//    .AWPROT(tb_awprot),
//    .AWQOS(tb_awqos),
//    .AWVALID(tb_awvalid),
//    .AWREADY(tb_awready),
//    .WDATA(tb_wdata),
//    .WSTRB(tb_wstrb),
//    .WLAST(tb_wlast),
//    .WVALID(tb_wvalid),
//    .WREADY(tb_wready),
//    .BID(tb_bid),
//    .BRESP(tb_bresp),
//    .BVALID(tb_bvalid),
//    .BREADY(tb_bready),
//    .ARID(tb_arid),
//    .ARADDR(tb_araddr),
//    .ARLEN(tb_arlen),
//    .ARSIZE(tb_arsize),
//    .ARBURST(tb_arburst),
//    .ARLOCK(tb_arlock),
//    .ARCACHE(tb_arcache),
//    .ARPROT(tb_arprot),
//    .ARQOS(tb_arqos),
//    .ARVALID(tb_arvalid),
//    .ARREADY(tb_arready),
//    .RID(tb_rid),
//    .RDATA(tb_rdata),
//    .RRESP(tb_rresp),
//    .RLAST(tb_rlast),
//    .RVALID(tb_rvalid),
//    .RREADY(tb_rready)
//);

//bd_wrapper BD_WRAPPER
//(
//    .CLOCK(tb_clock),
//    .RESET(tb_reset),
//    .S_AXI_araddr(tb_araddr),
//    .S_AXI_arburst(tb_arburst),
//    .S_AXI_arcache(tb_arcache),
//    .S_AXI_arid(tb_arid),
//    .S_AXI_arlen(tb_arlen),
//    .S_AXI_arlock(tb_arlock),
//    .S_AXI_arprot(tb_arprot),
//    .S_AXI_arqos(tb_arqos),
//    .S_AXI_arready(tb_arready),
//    .S_AXI_arvalid(tb_arvalid),
//    .S_AXI_awaddr(tb_awaddr),
//    .S_AXI_awburst(tb_awburst),
//    .S_AXI_awcache(tb_awcache),
//    .S_AXI_awid(tb_awid),
//    .S_AXI_awlen(tb_awlen),
//    .S_AXI_awlock(tb_awlock),
//    .S_AXI_awprot(tb_awprot),
//    .S_AXI_awqos(tb_awqos),
//    .S_AXI_awready(tb_awready),
//    .S_AXI_awvalid(tb_awvalid),
//    .S_AXI_bid(tb_bid),
//    .S_AXI_bready(tb_bready),
//    .S_AXI_bresp(tb_bresp),
//    .S_AXI_bvalid(tb_bvalid),
//    .S_AXI_rdata(tb_rdata),
//    .S_AXI_rid(tb_rid),
//    .S_AXI_rlast(tb_rlast),
//    .S_AXI_rready(tb_rready),
//    .S_AXI_rresp(tb_rresp),
//    .S_AXI_rvalid(tb_rvalid),
//    .S_AXI_wdata(tb_wdata),
//    .S_AXI_wlast(tb_wlast),
//    .S_AXI_wready(tb_wready),
//    .S_AXI_wstrb(tb_wstrb),
//    .S_AXI_wvalid(tb_wvalid),    
//    .PC_ASSERTED(tb_asserted),
//    .PC_STATUS(tb_status)
//); 
  
initial begin
    slv_agent_0 = new("slave vip agent",BD_WRAPPER.bd_i.axi_vip_0.inst.IF);
    slv_agent_0.vif_proxy.set_dummy_drive_type(XIL_AXI_VIF_DRIVE_NONE);
    slv_agent_0.set_agent_tag("Slave VIP");
    slv_agent_0.set_verbosity(slv_agent_verbosity);
    slv_agent_0.start_slave();
    $timeformat (-12, 1, " ps", 1);
end

always begin
    #CLK_HALF_PERIOD tb_clock = !tb_clock;
end

initial begin
    tb_reset = 0;
    tb_clock = 1;

    #(32 * CLK_PERIOD);
    tb_reset = 1;
    tb_write_start = 0; 
    tb_write_addr = 0;
    tb_write_data = 0;
    
    #(10 * CLK_PERIOD);
    tb_write_start = 1; 
    tb_write_addr = 'h00;
    tb_write_data = 'hF1;
    
    #(1 * CLK_PERIOD);
    tb_write_start = 1; 
    tb_write_addr = 'h04;
    tb_write_data = 'hF2;
    
    #(1 * CLK_PERIOD);
    tb_write_start = 0; 
    tb_write_addr = 0;
    tb_write_data = 0;
    
    wait (tb_write_done == 1);
    $display("AXI4_MASTER: FINISHED!");
    
    #(10 * CLK_PERIOD);
    $finish;
end

initial begin
    #1;
    forever begin
        slv_agent_0.monitor.item_collected_port.get(slv_monitor_transaction);
        slave_moniter_transaction_queue.push_back(slv_monitor_transaction);
        slave_moniter_transaction_queue_size++;
    end
end

endmodule
