`timescale 1ns / 1ps

module TxRx_tb;

reg clk;
reg start;
reg [9:0] switches;
wire [6:0] Hex1, Hex2, Hex3, Hex4;


TxRx TxRx1(
    .CLK(clk),
    .Start(start), //Start transmisji
    .SWIn(switches),
    .Hex1(Hex1),
    .Hex2(Hex2),
    .Hex3(Hex3),
    .Hex4(Hex4)
);

//-------------
initial clk = 1'b1;
always #5 clk = ~clk; //generator zegara
//-------------

initial
begin 
    start = 1'b0;
    switches = 10'd0;
    #40
    switches = 10'b0010001010;
    #50
    start = 1'b1;
    #40
    start = 1'b0;
    #240;
    //////
    start = 1'b0;
    switches = 10'd0;
    #40
    switches = 10'b0010101010;
    #50
    start = 1'b1;
    #40
    start = 1'b0;
    #240;
    /////
    start = 1'b0;
    switches = 10'd0;
    #40
    switches = 10'b0011001010;
    #50
    start = 1'b1;
    #40
    start = 1'b0;
    #240;
    //////
    start = 1'b0;
    switches = 10'd0;
    #40
    switches = 10'b0011101010;
    #50
    start = 1'b1;
    #40
    start = 1'b0;
    #240;
	#10 $finish;
end

// Writing VCD waveform
initial begin
	$dumpfile("TxRx_sim.vcd");
	$dumpvars(0, TxRx1);
	$dumpon;
end

endmodule