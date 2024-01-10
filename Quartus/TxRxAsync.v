module TxRxAsync(
    input CLK,
    input Start, //Start transmisji
    input [9:0] SWIn
);

wire ready;
wire clk, clk_div8;
wire valid;
wire [9:0] Frame;

/*
clkdiv #(
    .Width(26),
    .Divider(5000000)
) clkdiv10Hz(
    .Enable(1'b0),
    .CLK(CLK),
    .presCLK(clk_div8)
);

clkdiv #(
    .Width(26),
    .Divider(5000000)
) clkdiv10Hz(
    .Enable(1'b0),
    .CLK(CLK),
    .presCLK(clk)
);

Transmiter Tx1(
    .CLK(clk_div8),
    .Start(Start),
    .SWIn(SWIn),
	 .TXD(),
    .TX_BUSY()
);

Receiver Rx1(
    .CLK(clk),
    .RXD(),
    .DATA_ACK(),
    .Frame(),
    .RX_BUSY(),
    .RX_READY(),
    .RX_ERROR()
);

*/
endmodule