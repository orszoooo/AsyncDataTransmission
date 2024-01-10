//Data Transmission Unit
`timescale 1ns/100ps

module dtu(
    input clk,
    input tx_start, 
    input [9:0] tx_pi,
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
    .clk(clk),
    .presCLK(clk_100Hz)
);

clkdiv #(
    .Width(26),
    .Divider(5000000)
) clkdiv10Hz(
    .Enable(1'b0),
    .clk(clk),
    .presCLK(clk_10Hz)
);

tx Tx1(
    .clk(clk),
    .tx_start(tx_start),
    .tx_pi(tx_pi),
    .Tx(serial_connection)
);

rx Rx1(
    .clk(clk),
    .Rx(serial_connection),
    .Ready(ready),
    .Frame(Frame), 
    .Valid(valid)
);

dispDriver d1(
    .clk(clk),
    .Frame(Frame),
    .Valid(valid),
    .Ready(ready),
    .Hex1(Hex1),
    .Hex2(Hex2),
    .Hex3(Hex3),
    .Hex4(Hex4)
);

endmodule