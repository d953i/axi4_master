`timescale 1ns / 1ps

//`include "axi4_master_v1_0_tb_include.svh"

//import axi_vip_pkg::*;
//import bd_axi_vip_0_0_pkg::*;

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
bit                      tb_asserted;
bit [159:0]              tb_status;

reg  tb_begin_test = 0;

bd_wrapper BD_WRAPPER
(
    .CLOCK(tb_clock),
    .RESET(tb_reset),
    .PC_ASSERTED(tb_asserted),
    .PC_STATUS(tb_status),
    .BEGIN_TEST(tb_begin_test)
);

always begin
    #CLK_HALF_PERIOD tb_clock = !tb_clock;
end

initial begin
    tb_reset = 0;
    tb_clock = 1;

    #(32 * CLK_PERIOD);
    tb_reset = 1;
    tb_begin_test = 0; 
    
    #(10 * CLK_PERIOD);
    tb_begin_test = 1; 
    
    #(1 * CLK_PERIOD);
    tb_begin_test = 0;
    
    $display("AXI4_MASTER: FINISHED!");
    
    #(5 * CLK_PERIOD);
    $finish;
end

//initial begin
//    #1;
//    forever begin
//        slv_agent_0.monitor.item_collected_port.get(slv_monitor_transaction);
//        slave_moniter_transaction_queue.push_back(slv_monitor_transaction);
//        slave_moniter_transaction_queue_size++;
//    end
//end

endmodule
