
`timescale 1 ns / 1 ps

module axi4_tester #
(
    parameter P_TARGET_SLAVE_BASE_ADDR     = 32'h0,                             //Base address of targeted slave
    
    parameter integer P_WRITE_BURSTS = 1,                                       //Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
    parameter integer P_READ_BURSTS  = 16,                                      //Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
    parameter integer P_ID_WIDTH     = 6,                                       //Thread ID Width
    parameter integer P_ADDR_WIDTH   = 32,                                      //Width of Address Bus
    parameter integer P_DATA_WIDTH   = 256                                      //Width of Data Bus
)
(
    input  wire CLOCK,                                                          //Global Clock Signal.
    input  wire RESET,                                                          //Global Reset Signal. This Signal is Active Low

    input  wire BEGIN_TEST,

    output wire [P_ADDR_WIDTH - 1:0] WRITE_ADDR,
    output wire [P_DATA_WIDTH - 1:0] WRITE_DATA,
    output wire WRITE_START,
    input  wire WRITE_READY,
    input  wire WRITE_DONE,                                                     //Asserts when transaction is complete
    input  wire WRITE_ERROR                                                    //Asserts when ERROR is detected
);

//State machine parameters.
reg [3:0] current_state;
localparam [3:0] STATE_IDLE  = 0;
localparam [3:0] STATE_WAIT1 = 1;
localparam [3:0] STATE_WAIT2 = 2;
localparam [3:0] STATE_WAIT3 = 3;
localparam [3:0] STATE_DONE  = 4;

reg  [P_ADDR_WIDTH - 1:0] m_waddr;
reg  [P_DATA_WIDTH - 1:0] m_wdata;
reg  m_wstart;

assign WRITE_START = m_wstart;
assign WRITE_ADDR = m_waddr;
assign WRITE_DATA = m_wdata;

always @(posedge CLOCK) begin
    if (!RESET) begin
        current_state <= STATE_IDLE;
        m_wstart <= 0;
        m_waddr <= 0;
        m_wdata <= 0;
    end else begin
        case (current_state)
            STATE_IDLE: begin
                if (BEGIN_TEST) begin
                    current_state <= STATE_WAIT1;
                    m_wstart <= 1;
                    m_waddr <= 'h20;
                    m_wdata <= 'h1111_2222_3333_4444_5555_6666_7777_8888_1111_2222_3333_4444_5555_6666_7777_8888;
                end
            end
            STATE_WAIT1: begin
                if (WRITE_READY) begin
                    current_state <= STATE_WAIT2;
                    m_wstart <= 1;
                    m_waddr <= 'h40;
                    m_wdata <= 'h2222_3333_4444_5555_6666_7777_8888_1111_2222_3333_4444_5555_6666_7777_8888_1111;
                end
            end            
            STATE_WAIT2: begin
                if (WRITE_READY) begin
                    current_state <= STATE_WAIT3;
                    m_wstart <= 1;
                    m_waddr <= 'h40;
                    m_wdata <= 'h2222_3333_4444_5555_6666_7777_8888_1111_2222_3333_4444_5555_6666_7777_8888_1111;
                end
            end            
            STATE_WAIT3: begin
                if (WRITE_READY) begin
                    current_state <= STATE_DONE;
                    m_wstart <= 0;
                    m_waddr <= 'h0;
                    m_wdata <= 'h0;
                end
            end
            STATE_DONE: begin
                if (!BEGIN_TEST) begin
                    current_state <= STATE_IDLE;
                    m_wstart <= 0;
                    m_waddr <= 'h0;
                    m_wdata <= 'h0;
                end            
            end            
            default: begin
                current_state <= STATE_IDLE;
            end
        endcase
    end
end


endmodule
