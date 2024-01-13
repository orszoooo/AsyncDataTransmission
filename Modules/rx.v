`timescale 1ns/1ns

module rx(
    clk,
    rx_si, //serial input
    rx_data_ack,
    rx_po, //parallel output
    rx_busy,
    rx_ready,
    rx_error
);

input clk;
input rx_si; //serial input
input rx_data_ack;
output reg [7:0] rx_po; //parallel output
output reg rx_busy;
output reg rx_ready;
output reg rx_error;

reg [3:0] current_state, next_state;
reg [3:0] bit_received_count; //counts from 7 to 0, every sent received results in decrementation
reg [2:0] baud_sync; 

parameter IDLE = 4'h0;
parameter SYNC = 4'h1;
parameter RECV = 4'h2;
parameter VALID_TEST = 4'h3;
parameter RESULT = 4'h4;

reg [1:0] lastRXD;
reg rx_finished;

initial begin 
    lastRXD = 2'h0;
    rx_po = {8{1'b0}};
    rx_busy = 1'b0;
    rx_ready = 1'b0;
    rx_error = 1'b0;
    rx_finished = 1'b0;
end

always@(*) begin
    case(current_state)
        IDLE: begin
            if(lastRXD[1] & !lastRXD[0]) begin
                next_state = SYNC;
            end
            else begin
                next_state = IDLE;
            end

            rx_ready = 1'b0;
            rx_error = 1'b0;
            rx_busy = 1'b0;
            rx_finished = 1'b0;
        end

        SYNC: begin
            if(baud_sync > 3'h0)
                next_state = SYNC;
            else if(baud_sync == 3'h0)
                next_state = RECV;

            rx_busy = 1'b1;
        end

        RECV: begin
            if(bit_received_count > 4'h0)
                next_state = RECV;
            else if(bit_received_count == 4'h0)
                next_state = VALID_TEST;
        end

        VALID_TEST: begin
            if(rx_finished) 
                next_state = RESULT;
            else 
                next_state = VALID_TEST;
        end

        RESULT: begin
            if(rx_data_ack) 
                next_state = IDLE;
            else 
                next_state = RESULT;
        end

        default: next_state = IDLE; 
    endcase

end

always@(posedge clk) begin 
    current_state <= next_state;
    lastRXD <= {lastRXD[0],rx_si};

    case(current_state)
        IDLE: begin
            bit_received_count <= 4'd8;
            baud_sync <= 3'h2;
        end

        SYNC: begin
            if(baud_sync > 3'h0) 
                baud_sync <= baud_sync - 1'b1;
            else
                baud_sync <= 3'h7;
        end

        RECV: begin
            if(baud_sync > 3'h0) 
                baud_sync <= baud_sync - 1'b1;
            else begin
                baud_sync <= 3'h7;
                rx_po <= {rx_po[6:0], rx_si};
                if(bit_received_count > 4'd0) 
                    bit_received_count <= bit_received_count - 1'b1;
            end
        end

        VALID_TEST: begin
            if(baud_sync > 3'h0) 
                baud_sync <= baud_sync - 1'b1;
            else begin
                if(lastRXD == 2'h0) begin
                    rx_finished <= 1'b1;
                    rx_busy <= 1'b0;
                    rx_error <= 1'b1;
                    rx_ready <= 1'b1;
                end
                else begin
                    rx_finished <= 1'b1;
                    rx_busy <= 1'b0;
                    rx_error <= 1'b0;
                    rx_ready <= 1'b1;
                end
            end
        end 

        RESULT:begin

        end

        default: begin
            bit_received_count <= 4'd8;
            baud_sync <= 3'h0;
        end
    endcase
end

endmodule