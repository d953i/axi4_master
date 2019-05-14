`timescale 1ns / 1ps

module tb_axi256();

parameter CLK_HALF_PERIOD = 1;
parameter CLK_PERIOD = 2 * CLK_HALF_PERIOD;

reg  tb_clock;
reg  tb_reset;

reg          tb_start;
wire         tb_ready;
wire         tb_idle;
wire         tb_done;
reg  [63:0]  tb_waddr;
reg  [255:0] tb_wdata;

initial begin

    tb_clock  = 1;
    tb_reset = 0;

    #(16 * CLK_PERIOD);
    tb_reset = 1; 

	#(CLK_PERIOD);
	tb_start = 1;
	tb_waddr = 'h01;
	tb_wdata = 101;

	#(CLK_PERIOD);
	tb_waddr = 'h02;
	tb_wdata = 102;

	#(CLK_PERIOD);
	tb_waddr = 'h03;
	tb_wdata = 103;

	#(CLK_PERIOD);
	tb_waddr = 'h04;
	tb_wdata = 104;

	#(CLK_PERIOD);
	tb_waddr = 'h05;
	tb_wdata = 105;

	#(CLK_PERIOD);
	tb_waddr = 'h06;
	tb_wdata = 106;

	#(CLK_PERIOD);
	tb_waddr = 'h07;
	tb_wdata = 107;

end

always begin
    #CLK_HALF_PERIOD tb_clock = !tb_clock;
end

bd_wrapper dut
(
    .clock(tb_clock),
    .reset(tb_reset),
    .writer_addr(tb_waddr),
    .writer_data(tb_wdata),
    .writer_done(tb_done),
    .writer_idle(tb_idle),
    .writer_ready(tb_ready),
    .writer_start(tb_start)
);

endmodule

