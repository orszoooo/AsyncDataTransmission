`timescale 1ns/1ns

module clk_div #(
    parameter DIVIDE_BY = 28'd50000000, //50Mhz to 1Hz
    parameter WIDTH = 28
) (
    en, 
    clk_in,
    clk_out
);

input en;
input clk_in;
output reg clk_out;

reg [WIDTH-1:0] CNT;

initial begin
    clk_out = 1'b0;
    CNT = DIVIDE_BY;
end

always @(posedge clk_in) begin
    if(en) begin
        CNT <= CNT + {{WIDTH-1{1'b0}},1'b1};
            
        if(CNT>=(DIVIDE_BY-1))
            CNT <= {WIDTH{1'b0}};

        clk_out <= (CNT<DIVIDE_BY/2)?1'b1:1'b0;
    end
    else begin
        CNT <= CNT;
    end
end


endmodule