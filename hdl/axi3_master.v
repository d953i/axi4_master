
`timescale 1 ns / 1 ps

module axi3_master #
(
    parameter P_TARGET_SLAVE_BASE_ADDR     = 64'h0,                             //Base address of targeted slave
    
    parameter integer P_WRITE_BURSTS = 1,                                       //Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
    parameter integer P_READ_BURSTS  = 16,                                      //Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
    parameter integer P_ID_WIDTH     = 4,                                       //Thread ID Width
    parameter integer P_ADDR_WIDTH   = 64,                                      //Width of Address Bus
    parameter integer P_DATA_WIDTH   = 256                                      //Width of Data Bus
)
(
    input  wire [P_ADDR_WIDTH - 1:0] WRITE_ADDR,
    input  wire [P_DATA_WIDTH - 1:0] WRITE_DATA,
    input  wire WRITE_START,
    output wire WRITE_READY,
    output wire WRITE_DONE,                                                     //Asserts when transaction is complete
    output wire WRITE_ERROR,                                                    //Asserts when ERROR is detected

    input  wire CLOCK,                                                          //Global Clock Signal.
    input  wire RESET,                                                          //Global Reset Signal. This Signal is Active Low

    output wire [P_ID_WIDTH - 1:0] AWID,                                        //Master Interface Write Address ID
    output wire [P_ADDR_WIDTH - 1:0] AWADDR,                                    //Master Interface Write Address
    output wire [3:0] AWLEN,                                                    //Burst length. The burst length gives the exact number of transfers in a burst
    output wire [2:0] AWSIZE,                                                   //Burst size. This signal indicates the size of each transfer in the burst
    output wire [1:0] AWBURST,                                                  //Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
    output wire AWVALID,                                                        //Write address valid. This signal indicates that the channel is signaling valid write address and control information.
    input  wire AWREADY,                                                        //Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals
    output wire [P_DATA_WIDTH-1 : 0] WDATA,                                     //Master Interface Write Data.
    output wire [P_DATA_WIDTH/8-1 : 0] WSTRB,                                   //Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
    output wire WLAST,                                                          //Write last. This signal indicates the last transfer in a write burst.
    output wire WVALID,                                                         //Write valid. This signal indicates that valid write data and strobes are available
    input  wire WREADY,                                                         //Write ready. This signal indicates that the slave can accept the write data.

    output wire [P_ID_WIDTH-1 : 0] ARID,                                        //Master Interface Read Address.
    output wire [P_ADDR_WIDTH-1 : 0] ARADDR,                                    //Read address. This signal indicates the initial address of a read burst transaction.
    output wire [5:0] ARLEN,                                                    //Burst length. The burst length gives the exact number of transfers in a burst
    output wire [2:0] ARSIZE,                                                   //Burst size. This signal indicates the size of each transfer in the burst
    output wire [1:0] ARBURST,                                                  //Burst type. The burst type and the size information, determine how the address for each transfer within the burst is calculated.
    output wire ARVALID,                                                        //Write address valid. This signal indicates that the channel is signaling valid read address and control information
    input  wire ARREADY,                                                        //Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals
    input  wire [P_ID_WIDTH-1 : 0] RID,                                         //Read ID tag. This signal is the identification tag for the read data group of signals generated by the slave.
    input  wire [P_DATA_WIDTH-1 : 0] RDATA,                                     //Master Read Data
    input  wire [1 : 0] RRESP,                                                  //Read response. This signal indicates the status of the read transfer
    input  wire RLAST,                                                          //Read last. This signal indicates the last transfer in a read burst
    input  wire RVALID,                                                         //Read valid. This signal indicates that the channel is signaling the required read data.
    output wire RREADY,                                                         //Read ready. This signal indicates that the master can accept the read data and response information.

    output wire BREADY,                                                         //Response ready. This signal indicates that the master can accept a write response.
    input  wire BVALID,                                                         //Write response valid. This signal indicates that the channel is signaling a valid write response.
    input  wire [1 : 0] BRESP,                                                  //Write response. This signal indicates the status of the write transaction.
    input  wire [P_ID_WIDTH-1 : 0] BID                                          //Master Interface Write Response.
);

//Function called clogb2 that returns an integer which has the value of the ceiling of the log base 2
function integer clogb2 (input integer bit_depth);
begin
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
        bit_depth = bit_depth >> 1;
    end
endfunction

//P_WRITE_TRANSACTIONS_NUM is the width of the index counter for number of write or read transaction.
localparam integer P_WRITE_TRANSACTIONS_NUM = clogb2(P_WRITE_BURSTS - 1);

//Burst length for transactions, in P_DATA_WIDTHs. Non-2^n lengths will eventually cause bursts across 4K address boundaries.
localparam integer C_MASTER_LENGTH = 12;

//Total number of burst transfers is master length divided by burst length and burst size
localparam integer C_NO_BURSTS_REQ = C_MASTER_LENGTH-clogb2((P_WRITE_BURSTS*P_DATA_WIDTH/8)-1);

// Example State machine to initialize counter, initialize write transactions, initialize read transactions and comparison of read data with the written data words.
reg [1:0] writer_state;
localparam [1:0] WRITE_IDLE = 0;
localparam [1:0] INIT_WRITE  = 1;
localparam [1:0] INIT_WBURST = 2;

//reg [P_ADDR_WIDTH - 1:0] m_write_addr = 0;
//reg [P_DATA_WIDTH - 1:0] m_write_data = 0;
//reg [P_ID_WIDTH - 1:0]   m_write_awid = 0;

//AXI4 internal tmp signals
reg [P_ID_WIDTH - 1:0]   m_awid = 0;
reg [P_ADDR_WIDTH - 1:0] m_awaddr;
reg m_awvalid;
reg [P_DATA_WIDTH - 1:0] m_wdata;
reg m_wlast;
reg m_wvalid;
reg m_bready;
reg [P_ADDR_WIDTH - 1:0] m_araddr;
reg m_arvalid;
reg m_rready;
reg [P_WRITE_TRANSACTIONS_NUM:0] write_index;                                   //write beat count in a burst
reg [P_WRITE_TRANSACTIONS_NUM:0] read_index;                                    //read beat count in a burst
wire [P_WRITE_TRANSACTIONS_NUM + 2: 0] burst_size_bytes;                        //size of P_WRITE_BURSTS length burst in bytes

//The burst counters are used to track the number of burst transfers of 
//P_WRITE_BURSTS burst length needed to transfer 2^C_MASTER_LENGTH bytes of data.
reg [C_NO_BURSTS_REQ : 0] write_burst_counter;
reg [C_NO_BURSTS_REQ : 0] read_burst_counter;
reg start_single_burst_write;
reg start_single_burst_read;
reg writes_done;
reg reads_done;
reg error_reg;
reg compare_done;
reg read_mismatch;
reg burst_write_active;
reg burst_read_active;
reg [P_DATA_WIDTH - 1: 0] expected_rdata;

//Interface response error flags
wire write_resp_error;
wire read_resp_error;
wire wnext;
wire rnext;
reg  init_txn_ff;
reg  init_txn_ff2;
reg  init_txn_edge;
wire init_txn_pulse;

reg [31:0] m_writer_counter = 0;

// I/O Connections assignments
//assign WRITE_READY = ((AWREADY && WREADY) || current_state == IDLE) ? 1 : 0;

//Write Address (AW)
assign AWID = m_awid + m_writer_counter;
assign AWADDR = P_TARGET_SLAVE_BASE_ADDR + m_awaddr;                            //The AXI address is a concatenation of the target base address + active offset range
assign AWLEN= P_WRITE_BURSTS - 1;                                               //Burst LENgth is number of transaction beats, minus 1
assign AWSIZE = clogb2((P_DATA_WIDTH / 8) - 1);                                 //Size should be P_DATA_WIDTH, in 2^SIZE bytes, otherwise narrow bursts are used
assign AWBURST = 2'b01;                                                         //INCR burst type is usually used, except for keyhole bursts
assign AWVALID = m_awvalid;
                                                                                //Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.
//Write Data(W)
assign WDATA = m_wdata;                                                         //All bursts are complete and aligned in this example
assign WSTRB = {(P_DATA_WIDTH / 8){1'b1}};
assign WLAST = m_wlast;
assign WVALID = m_wvalid;

//Write Response (B)
assign BREADY = m_bready;

//Read Address (AR)
assign ARID = 'b0;
assign ARADDR = P_TARGET_SLAVE_BASE_ADDR + m_araddr;                            //Burst Length is number of transaction beats, minus 1
assign ARLEN = P_READ_BURSTS - 1;                                               //Size should be P_DATA_WIDTH, in 2^n bytes, otherwise narrow bursts are used
assign ARSIZE = clogb2((P_DATA_WIDTH / 8) - 1);                                 //INCR burst type is usually used, except for keyhole bursts
assign ARBURST = 2'b01;
assign ARVALID = m_arvalid;
                                                                                //Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache.

//Read and Read Response (R)
assign RREADY = m_rready;

//Example design I/O
//assign TXN_DONE = compare_done;
assign burst_size_bytes = P_WRITE_BURSTS * P_DATA_WIDTH / 8;                    //Burst size in bytes
//assign init_txn_pulse = (!init_txn_ff2) && init_txn_ff;

//Write Address Channel
always @(posedge CLOCK) begin
    if (RESET == 0) begin
        m_awvalid <= 0;
    end else if (WRITE_START) begin
        m_awvalid <= 1;
        m_writer_counter <= m_writer_counter + 1;
    end else if (AWREADY && m_awvalid) begin                                    //Once asserted, VALIDs cannot be de-asserted, so m_awvalid must wait until transaction is accepted
        m_awvalid <= 0;
        m_writer_counter <= m_writer_counter - 1;
    end else begin
        m_awvalid <= m_awvalid;
    end
end

always @(posedge CLOCK) begin
    if (RESET == 0) begin
        m_awaddr <= 0;
    end else if (WRITE_START) begin
        m_awaddr <= WRITE_ADDR;
    end else if (AWREADY && m_awvalid) begin
        m_awaddr <= 0;
    end else begin
        m_awaddr <= m_awaddr;
    end
end

always @(posedge CLOCK) begin
    if (RESET == 0) begin
        m_wvalid <= 0;
    end else if (WRITE_START) begin
        m_wvalid <= 1;
    end else if (WREADY && m_wvalid) begin
        m_wvalid <= 0;
    end else begin
        m_wvalid <= m_wvalid;
    end
end

always @(posedge CLOCK) begin
    if (RESET == 0) begin
        m_wlast <= 0;
    end else if (WRITE_START) begin
        m_wlast <= 1;
    end else if (WREADY && m_wvalid) begin
        m_wlast <= 0;
    end else begin
        m_wlast <= m_wlast;
    end
end

//Write Data Generator.Data pattern is only a simple incrementing count from 0 for each burst.
always @(posedge CLOCK) begin
    if (RESET == 0) begin
        m_wdata <= 0;
    end else if (WRITE_START) begin
        m_wdata <= WRITE_DATA;
    end else if (WREADY && m_wvalid) begin
        m_wdata <= 0;
    end else begin 
        m_wdata <= m_wdata;
    end
end

//Write Response (B) Channel
 always @(posedge CLOCK) begin
    if (RESET == 0) begin
        m_bready <= 0;
    end else begin
        m_bready <= 1;
        //m_bready <= m_bready;
    end
end

//Need this to silent VIP warning
always @(posedge CLOCK) begin
    if (RESET == 0) begin
        m_arvalid <= 0;
    end else begin
        m_arvalid <= m_arvalid;
    end
end

//Need this to silent VIP warning
always @(posedge CLOCK) begin
    if (RESET == 0) begin
        m_rready <= 0;
    end else begin
        m_rready <= m_rready;
    end
end

////implement master command interface state machine
//always @ (posedge CLOCK) begin
//    if (RESET == 0) begin
//        writer_state <= WRITE_IDLE;
//    end else begin
//        case (writer_state)
//            WRITE_IDLE: begin
//                if (WRITE_START == 1) begin
//                    writer_state <= INIT_WRITE;
//                end else begin
//                    writer_state <= WRITE_IDLE;
//                end
//            end
//            INIT_WRITE: begin
//                if (WRITE_START == 0) begin
//                    writer_state <= WRITE_IDLE;
//                end
//            end
//            default: begin
//                writer_state <= WRITE_IDLE;
//            end
//        endcase
//    end
//end


endmodule