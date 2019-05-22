`timescale 1ns / 1ps

module tb_axi4_master();

parameter CLK_HALF_PERIOD = 1.666;
parameter CLK_PERIOD = 2 * CLK_HALF_PERIOD;

reg  tb_clock;
reg  tb_reset;

wire clk_300mhz_clk_n;
wire clk_300mhz_clk_p;
assign clk_300mhz_clk_n = tb_clock; 
assign clk_300mhz_clk_p = !tb_clock;

reg [255:0] axi4_wdata = 0;
reg [31:0] axi4_awaddr = 0;
reg [1:0] axi4_awburst = 0;
reg [3:0] axi4_awcache = 0;
reg [3:0] axi4_awid = 0;
reg [7:0] axi4_awlen = 0;
reg [0:0] axi4_awlock = 0;
reg [2:0] axi4_awprot = 0;
reg [3:0] axi4_awqos = 0;
reg [2:0] axi4_awsize = 0;
reg [31:0] axi4_wstrb = 0;
reg axi4_wvalid = 0;
reg axi4_wlast = 0;
reg axi4_awvalid = 0;
wire axi4_awready;
wire axi4_wready;

reg axi4_bready = 0;
wire [3:0] axi4_bid;
wire [1:0] axi4_bresp;
wire axi4_bvalid;

wire pc_asserted;
wire [159:0]pc_status;

initial begin

    tb_clock  = 1;
    tb_reset = 1;

    #(64 * CLK_PERIOD);
    tb_reset = !tb_reset;
    axi4_bready = 1; 

    wait (pc_asserted == 0);
	#(CLK_PERIOD);
	
	axi4_awaddr = 'hA0001000;
	axi4_wdata = 'hD0000000;
	axi4_awid = 0;
	axi4_awsize = 2;
	axi4_wlast = 1;
	axi4_awvalid = 1;
	axi4_wstrb = 'hF;
	
	wait (axi4_awready == 1);
	axi4_wvalid = 1;

end

always begin
    #CLK_HALF_PERIOD tb_clock = !tb_clock;
end

//axi4_master axi4_dut
//(
//    .WRITE_ENABLED(),
//    .WRITE_ADDR(),
//    .WRITE_DATA(),
//    .WRITE_DONE(),
//    .WRITE_ERROR(),

//    .M_AXI_ACLK(),
//    .M_AXI_ARESETN(),
//    .M_AXI_AWID(),
//    .M_AXI_AWADDR(),
//    .M_AXI_AWLEN(),
//    .M_AXI_AWSIZE(),
//    .M_AXI_AWBURST(),
//    .M_AXI_AWLOCK(),
//    .M_AXI_AWCACHE(),
//    .M_AXI_AWPROT(),
//    .M_AXI_AWQOS(),
//    .M_AXI_AWUSER(),
//    .M_AXI_AWVALID(),
//    .M_AXI_AWREADY(),
//    .M_AXI_WDATA(),
//    .M_AXI_WSTRB(),
//    .M_AXI_WLAST(),
//    .M_AXI_WUSER(),
//    .M_AXI_WVALID(),
//    .M_AXI_WREADY(),
//    .M_AXI_BID(),
//    .M_AXI_BRESP(),
//    .M_AXI_BUSER(),
//    .M_AXI_BVALID(),
//    .M_AXI_BREADY(),
    
//    .M_AXI_ARID(),
//    .M_AXI_ARADDR(),
//    .M_AXI_ARLEN(),
//    .M_AXI_ARSIZE(),
//    .M_AXI_ARBURST(),
//    .M_AXI_ARLOCK(),
//    .M_AXI_ARCACHE(),
//    .M_AXI_ARPROT(),
//    .M_AXI_ARQOS(),
//    .M_AXI_ARUSER(),
//    .M_AXI_ARVALID(),
//    .M_AXI_ARREADY(),
//    .M_AXI_RID(),
//    .M_AXI_RDATA(),
//    .M_AXI_RRESP(),
//    .M_AXI_RLAST(),
//    .M_AXI_RUSER(),
//    .M_AXI_RVALID(),
//    .M_AXI_RREADY()
//);

bd_wrapper bd_dut
(
    .C0_DDR4_0_act_n(),
    .C0_DDR4_0_adr(),
    .C0_DDR4_0_ba(),
    .C0_DDR4_0_bg(),
    .C0_DDR4_0_ck_c(),
    .C0_DDR4_0_ck_t(),
    .C0_DDR4_0_cke(),
    .C0_DDR4_0_cs_n(),
    .C0_DDR4_0_dm_n(),
    .C0_DDR4_0_dq(),
    .C0_DDR4_0_dqs_c(),
    .C0_DDR4_0_dqs_t(),
    .C0_DDR4_0_odt(),
    .C0_DDR4_0_reset_n(),
    .axi4_awaddr(axi4_awaddr),
    .axi4_awburst(axi4_awburst),
    .axi4_awcache(axi4_awcache),
    .axi4_awid(axi4_awid),
    .axi4_awlen(axi4_awlen),
    .axi4_awlock(axi4_awlock),
    .axi4_awprot(axi4_awprot),
    .axi4_awqos(axi4_awqos),
    .axi4_awready(axi4_awready),
    .axi4_awsize(axi4_awsize),
    .axi4_awvalid(axi4_awvalid),
    .axi4_wdata(axi4_wdata),
    .axi4_wlast(axi4_wlast),
    .axi4_wready(axi4_wready),
    .axi4_wstrb(axi4_wstrb),
    .axi4_wvalid(axi4_wvalid),
    .axi4_araddr(),
    .axi4_arburst(),
    .axi4_arcache(),
    .axi4_arid(),
    .axi4_arlen(),
    .axi4_arlock(),
    .axi4_arprot(),
    .axi4_arqos(),
    .axi4_arready(),
    .axi4_arsize(),
    .axi4_arvalid(),
    .axi4_bid(axi4_bid),
    .axi4_bready(axi4_bready),
    .axi4_bresp(axi4_bresp),
    .axi4_bvalid(axi4_bvalid),
    .axi4_rdata(),
    .axi4_rid(),
    .axi4_rlast(),
    .axi4_rready(),
    .axi4_rresp(),
    .axi4_rvalid(),
    .pc_asserted(pc_asserted),
    .pc_status(pc_status),
    .clk_300mhz_clk_n(clk_300mhz_clk_n),
    .clk_300mhz_clk_p(clk_300mhz_clk_p),
    .reset(tb_reset)
);

endmodule

