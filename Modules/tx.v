`timescale 1ns/1ns
module tx #(
    parameter WIDTH = 8 // 1 bit Start, 8 bit Data, 1 Stop bit
)(
    clk,
    en,
    tx_start,
    tx_pi, //parallel input
    tx_so, //serial output
    tx_busy
);

input clk, en;
input tx_start; 
input [WIDTH-1:0] tx_pi;
output reg tx_so;
output reg tx_busy;

reg [WIDTH-1:0] data;
reg current_state, next_state;
reg [3:0] bit_sent_count; //counts from 10 to 0, every sent bit results in decrementation

parameter IDLE = 1'b0;
parameter SEND = 1'b1;

//State machine
always @(*) begin
    if(en) begin
        case(current_state)
            IDLE: begin
                if(tx_start) begin
                    next_state = SEND;
                end
                else
                    next_state = IDLE;

                tx_busy <= 1'b0;
            end

            SEND: begin
                tx_busy <= 1'b1;
                if(bit_sent_count > 4'h0) begin
                    next_state = SEND;
                end
                else
                    next_state = IDLE;
            end
            default: next_state = IDLE; 
        endcase
    end
end

always @(posedge clk) begin 
    if(en) begin
        current_state <= next_state;

        case(current_state)
            IDLE: begin
                data <= tx_pi;
                bit_sent_count <= 4'hA;
                tx_so <= 1'b1;
            end

            SEND: begin
                //Sending data 
                if(bit_sent_count == 4'hA) begin
                    tx_so <= 1'b0; //Start bit
                    bit_sent_count <= bit_sent_count - 1'b1; 
                end
                else if(bit_sent_count > 4'h0) begin
                    bit_sent_count <= bit_sent_count - 1'b1;

                    data <= {data[WIDTH-1:0], 1'b1};
                    tx_so <= data[WIDTH-1];
                end
            end

            default: tx_so <= 1'b1;
        endcase
    end
end

endmodule