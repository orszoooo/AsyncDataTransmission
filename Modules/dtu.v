`timescale 1ns / 1ps

module Data_Transmission_Unit(
    input CLK,
    input Start, //Start transmisji
    input [9:0] SWIn,
    output [6:0] Hex1,
    output [6:0] Hex2,
    output [6:0] Hex3,
    output [6:0] Hex4
);

wire ready;
wire serial_connection;
wire clk_100Hz, clk_10Hz;
wire valid;
wire [9:0] Frame;

clkdiv #(
    .Width(20),
    .Divider(500000)
) clkdiv100Hz(
    .Enable(1'b0),
    .CLK(CLK),
    .presCLK(clk_100Hz)
);

clkdiv #(
    .Width(26),
    .Divider(5000000)
) clkdiv10Hz(
    .Enable(1'b0),
    .CLK(CLK),
    .presCLK(clk_10Hz)
);

Transmiter Tx1(
    .CLK(CLK),
    .Start(Start),
    .SWIn(SWIn),
    .Tx(serial_connection)
);

Receiver Rx1(
    .CLK(CLK),
    .Rx(serial_connection),
    .Ready(ready),
    .Frame(Frame), 
    .Valid(valid)
);

dispDriver d1(
    .CLK(CLK),
    .Frame(Frame),
    .Valid(valid),
    .Ready(ready),
    .Hex1(Hex1),
    .Hex2(Hex2),
    .Hex3(Hex3),
    .Hex4(Hex4)
);

endmodule