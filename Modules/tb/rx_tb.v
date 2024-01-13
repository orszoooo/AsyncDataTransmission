`timescale 1ns/1ns

module rx_tb;

reg clk;
reg rx;
reg ack;
wire [7:0] frame;
wire rx_busy;
wire rx_ready;
wire rx_error;

rx Rx1(
    .clk(clk),
    .rx_si(rx),
    .rx_data_ack(ack),
    .rx_po(frame),
    .rx_busy(rx_busy),
    .rx_ready(rx_ready),
    .rx_error(rx_error)
);

//-------------
initial clk = 1'b1;
always #5 clk = ~clk; 
//-------------

initial
begin 
    ack = 1'b0;
    rx = 1'b1;
    #50

    rx = 1'b0;
    #80 rx = 1'b1;
    #80 rx = 1'b0;
    #80 rx = 1'b1;
    #80 rx = 1'b0;
    #80 rx = 1'b1;
    #80 rx = 1'b0;
    #80 rx = 1'b1;
    #80 rx = 1'b0;
    #80 rx = 1'b1;

    #80 rx = 1'b1;  
    #50 ack = 1'b1;
    #20 ack = 1'b0;
    
    #50
    rx = 1'b0;
    #80 rx = 1'b1;
    #80 rx = 1'b0;
    #80 rx = 1'b1;
    #80 rx = 1'b0;
    #80 rx = 1'b1;
    #80 rx = 1'b0;
    #80 rx = 1'b1;
    #80 rx = 1'b1;
    #80 rx = 1'b0;
    #80 rx = 1'b0; 
	#100 $finish;
end

// Writing VCD waveform
initial begin
	$dumpfile("./Output/rx_sim.vcd");
	$dumpvars(0, Rx1);
	$dumpon;
end

endmodule