`timescale 1ns/1ns

module clk_div_preset(
    en,
    divisor_ld,
    divisor_sel, 
    clk_in,
    clk_out
);

parameter WIDTH = 4;

input en;
input divisor_ld;
input [1:0] divisor_sel;
input clk_in;
output reg clk_out;

reg [WIDTH-1:0] CNT;
parameter DIV_2 = 4'h1;
parameter DIV_4 = 4'h3;
parameter DIV_8 = 4'h7;
parameter DIV_16 = 4'hF;
reg [3:0] DIVISOR;

initial begin
    clk_out = 1'b1;
    DIVISOR = DIV_2;
    CNT = DIVISOR;
end

always @(divisor_ld) begin
    DIVISOR = divisor_sel[1] ? (divisor_sel[0] ? DIV_16 : DIV_8) : (divisor_sel[0] ? DIV_4 : DIV_2);
    CNT <= {WIDTH{1'b0}};
end

always @(posedge clk_in) begin
    if(en) begin
        CNT <= CNT + {{WIDTH-1{1'b0}},1'b1};
            
        if(CNT>DIVISOR-1) begin
            CNT <= {WIDTH{1'b0}};
            clk_out <= 1'b1;
        end
        else begin
            clk_out <= (CNT<DIVISOR/2) ? 1'b1 : 1'b0;
        end
    end
    else begin
        CNT <= {WIDTH{1'b0}};
        clk_out <= 1'b1;
    end
end


endmodule