`timescale 1ns/100ps

module tx #(
    parameter WIDTH = 8 // 1 bit Start, 8 bit Data, 1 Stop bit
)(
    clk,
    tx_start,
    tx_pi, //parallel input
    tx_so, //serial output
    tx_busy
);

input clk;
input tx_start; 
input [WIDTH-1:0] tx_pi;
output reg tx_so;
output reg tx_busy;

reg [WIDTH-1:0] data;
reg current_state, next_state;
reg [3:0] count; 

parameter IDLE = 1'b0;
parameter SEND = 1'b1;

//State machine
always @(*) begin
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
            if(count > 4'd0) begin
                next_state = SEND;
            end
            else
                next_state = IDLE;
        end
        default: next_state = IDLE; 
    endcase

end

always @(posedge clk) begin 
    current_state <= next_state;

    case(current_state)
        IDLE: begin
            data <= tx_pi;
            count <= 4'd10;
            tx_so <= 1'b1;
        end

        SEND: begin
            //Sending data 
            if(count == 4'd10) begin
                tx_so <= 1'b0; //Start bit
                count <= count - 1'b1; 
            end
            else if(count > 4'd0) begin
                count <= count - 1'b1;

				data <= {data[WIDTH-1:0], 1'b1};
				tx_so <= data[WIDTH-1];
            end
        end

        default: tx_so <= 1'b1;
    endcase
end

endmodule