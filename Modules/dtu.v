//Data Transmission Unit
`timescale 1ns/1ns
module dtu(
    en, 
    clk_tx,
    clk_rx,
    tx_start,
    tx_character_sel,
    rx_ack,
    rx_character1,
    rx_character2,
    tx_busy,
    rx_busy,
    rx_ready,
    rx_error
);
localparam CLK_DIVISOR = 17'd100000;
localparam CLK_DIVISOR_WIDTH = 17;
localparam CLK_TX_DIVISOR = 4'h8;
localparam CLK_TX_DIVISOR_WIDTH = 4;

input en; 
input clk_tx;
input clk_rx;
input tx_start;
input [1:0] tx_character_sel; //Select preprogrammed character to send
input rx_ack;
output [6:0] rx_character1;
output [6:0] rx_character2;
output tx_busy;
output rx_busy;
output rx_ready;
output rx_error;

//Preprogrammed characters select
reg [7:0] TX_CHARACTERS [3:0]; //4 hex numbers

initial begin
    TX_CHARACTERS[0] = 8'h77;
    //TX_CHARACTERS[1] = 8'hEF;
    TX_CHARACTERS[1] = 8'hAA;
    TX_CHARACTERS[2] = 8'hA9;
    TX_CHARACTERS[3] = 8'h10;
end

//Clock dividers
wire clk_tx_div1, clk_tx_div2, clk_rx_div;

clk_div  #(
    .DIVIDE_BY(CLK_DIVISOR),
    .WIDTH(CLK_DIVISOR_WIDTH))
clk_div_tx1 (
    .en(en),
    .clk_in(clk_tx),
    .clk_out(clk_tx_div1)
);

clk_div  #(
    .DIVIDE_BY(CLK_TX_DIVISOR),
    .WIDTH(CLK_TX_DIVISOR_WIDTH))
clk_div_tx2 (
    .en(en),
    .clk_in(clk_tx),
    .clk_out(clk_tx_div2)
);

clk_div #(
    .DIVIDE_BY(CLK_DIVISOR),
    .WIDTH(CLK_DIVISOR_WIDTH))
clk_div_rx (
    .en(en),
    .clk_in(clk_rx), 
    .clk_out(clk_rx_div)
);

//Transmitter
wire tx_to_rx;

tx tx1(
    .clk(clk_tx_div2),
    .en(en),
    .tx_start(tx_start),
    .tx_pi(TX_CHARACTERS[tx_character_sel]), 
    .tx_so(tx_to_rx), 
    .tx_busy(tx_busy)
);

wire [7:0] rx_output;

rx rx1(
    .clk(clk_rx), //clk_rx_div for FPGA
    .en(en),
    .rx_si(tx_to_rx), //serial input
    .rx_data_ack(rx_ack),
    .rx_po(rx_output), //parallel output
    .rx_busy(rx_busy),
    .rx_ready(rx_ready),
    .rx_error(rx_error)
);

led_disp char_disp1(
    .in(rx_output[7:4]),
    .out(rx_character1)
);

led_disp char_disp2(
    .in(rx_output[3:0]),
    .out(rx_character2)
);

endmodule