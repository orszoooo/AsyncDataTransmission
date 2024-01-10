`timescale 1ns / 1ps

module tx_tb;

reg clk;
reg start;
reg [7:0] switches;
wire Tx;
wire TX_BUSY;

tx Tx1(
    .CLK(clk),
    .Start(start),
    .SWIn(switches),
    .TXD(Tx),
    .TX_BUSY(TX_BUSY)
);

//-------------
initial clk = 1'b1;
always #5 clk = ~clk; //generator zegara
//-------------

initial
begin 
    start = 1'b0;
    switches = 8'h00;
    #20 
    switches = 8'hAC;
    #20
    start = 1'b1;
    #50
    start = 1'b0;
    switches = 8'h00;
    #200
    switches = 8'hDC;
    #20
    start = 1'b1;
    #20 
    start = 1'b0;
    #200
	#10 $finish;
end

// Writing VCD waveform
initial begin
	$dumpfile("./Output/tx_sim.vcd");
	$dumpvars(0, Tx1);
	$dumpon;
end

endmodule