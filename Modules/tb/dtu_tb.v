`timescale 1ns/1ns

module dtu_tb;

reg CLK_TX, CLK_RX;
reg EN;
reg [1:0] CLK_DIV_SEL;
reg CLK_DIV_LD;
reg TX_START;
reg [1:0] TX_CHARACTER_SEL;
reg RX_ACK;
wire [6:0] RX_CHARACTER1;
wire [6:0] RX_CHARACTER2;
wire TX_BUSY;
wire RX_BUSY;
wire RX_READY;
wire RX_ERROR;

dtu dtu1(
    .en(EN), 
    .clk_tx(CLK_TX),
    .clk_rx(CLK_RX),
    .clk_div_ld(CLK_DIV_LD),
    .clk_div_sel(CLK_DIV_SEL),
    .tx_start(TX_START),
    .tx_character_sel(TX_CHARACTER_SEL),
    .rx_ack(RX_ACK),
    .rx_character1(RX_CHARACTER1),
    .rx_character2(RX_CHARACTER2),
    .tx_busy(TX_BUSY),
    .rx_busy(RX_BUSY),
    .rx_ready(RX_READY),
    .rx_error(RX_ERROR)
);

//Clock generators
initial CLK_TX = 1'b1;
always #1 CLK_TX = ~CLK_TX; 

initial CLK_RX = 1'b1;
always #1 CLK_RX = ~CLK_RX; 

initial
begin 
    EN = 1'b0; 
    CLK_DIV_LD = 1'b0;
    CLK_DIV_SEL = 2'h0;
    TX_START = 1'b0;
    TX_CHARACTER_SEL = 2'h0;
    RX_ACK = 1'b0;
    #8 
    CLK_DIV_SEL = 2'b01; 
    #8
    CLK_DIV_LD = 1'b1;
    #8
    CLK_DIV_LD = 1'b0;
    #8
    EN = 1'b1; 
    #8
    TX_START = 1'b1;
    #64
	#1000 $finish;
end

// Writing VCD waveform
initial begin
	$dumpfile("./Output/dtu_sim.vcd");
	$dumpvars(0, dtu1);
	$dumpon;
end

endmodule