`timescale 1ns/1ns

module rx(
    clk,
    en,
    rx_si, //serial input
    rx_data_ack,
    rx_po, //parallel output
    rx_busy,
    rx_ready,
    rx_error
);

input clk, en;
input rx_si; //serial input
input rx_data_ack;
output reg [7:0] rx_po; //parallel output
output reg rx_busy;
output reg rx_ready;
output reg rx_error;
reg [3:0] current_state, next_state;
reg [3:0] bit_received_count; //counts from 7 to 0, every sent received results in decrementation
reg [3:0] baud_sync; 

reg [3:0] BITS_TO_RECEIVE = 4'd8;
reg [3:0] SYNC_START_VAL = 4'h2;
reg [3:0] SYNC_SAMPLING_VAL = 4'h7;

localparam IDLE = 4'h0;
localparam SYNC = 4'h1;
localparam RECV = 4'h2;
localparam VALID_TEST = 4'h3;
localparam RESULT = 4'h4;

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
    if(en) begin
        case(current_state)
            IDLE: begin
                if(lastRXD[1] & !lastRXD[0]) begin
                    next_state = SYNC;
                end
                else begin
                    next_state = IDLE;
                end
            end

            SYNC: begin
                if(baud_sync > 4'h0)
                    next_state = SYNC;
                else if(baud_sync == 4'h0)
                    next_state = RECV;
                else
                    next_state = IDLE; 
            end

            RECV: begin
                if(bit_received_count > 4'h0)
                    next_state = RECV;
                else if(bit_received_count == 4'h0)
                    next_state = VALID_TEST;
                else
                    next_state = IDLE;
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
	else
		next_state = IDLE; 
end

always@(posedge clk) begin 
    if(en) begin
        current_state <= next_state;
        lastRXD <= {lastRXD[0],rx_si};

        case(current_state)
            IDLE: begin
                bit_received_count <= BITS_TO_RECEIVE; 
                baud_sync <= SYNC_START_VAL; 
				rx_ready <= 1'b0;
                rx_error <= 1'b0;
                rx_busy <= 1'b0;
                rx_finished <= 1'b0;
            end

            SYNC: begin
                if(baud_sync > 4'h0) 
                    baud_sync <= baud_sync - 1'b1;
                else
                    baud_sync <= SYNC_SAMPLING_VAL;
						  
					rx_busy = 1'b1;
            end

            RECV: begin
                if(baud_sync > 4'h0) 
                    baud_sync <= baud_sync - 1'b1;
                else begin
                    baud_sync <= SYNC_SAMPLING_VAL; 
                    rx_po <= {rx_po[6:0], rx_si};
                    if(bit_received_count > 4'd0) 
                        bit_received_count <= bit_received_count - 1'b1;
                end
            end

            VALID_TEST: begin
                if(baud_sync > 4'h0) 
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
                rx_finished <= 1'b0;
                rx_busy <= 1'b0;
                rx_error <= rx_error;
                rx_ready <= 1'b1;
            end

            default: begin
                bit_received_count <= BITS_TO_RECEIVE;
                baud_sync <= SYNC_START_VAL;
            end
        endcase
    end
end

endmodule