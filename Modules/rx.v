`timescale 1ns/100ps

module rx(
    input CLK,
    input RXD,
    input DATA_ACK,
    output reg [7:0] Data,
    output reg RX_BUSY,
    output reg RX_READY,
    output reg RX_ERROR
);

reg [3:0] current_state, next_state;
reg [3:0] count; //Licznik położenia w ramce
reg [2:0] baud_sync; 

parameter IDLE = 4'h0;
parameter SYNC = 4'h1;
parameter RECV = 4'h2;
parameter VALID_TEST = 4'h3;
parameter RESULT = 4'h4;

reg [1:0] lastRXD;
reg RX_FINISHED;

initial begin 
    lastRXD = 2'h0;
    Data = {8{1'b0}};
    RX_BUSY = 1'b0;
    RX_READY = 1'b0;
    RX_ERROR = 1'b0;
    RX_FINISHED = 1'b0;
end

//Przetwarzanie wejścia i ustawienie stanu
always@(*) begin
    case(current_state)
        IDLE: begin
            if(lastRXD[1] & !lastRXD[0]) begin
                next_state = SYNC;
            end
            else begin
                next_state = IDLE;
            end

            RX_READY = 1'b0;
            RX_ERROR = 1'b0;
            RX_BUSY = 1'b0;
            RX_FINISHED = 1'b0;
        end

        SYNC: begin
            if(baud_sync > 3'h0)
                next_state = SYNC;
            else if(baud_sync == 3'h0)
                next_state = RECV;

            RX_BUSY = 1'b1;
        end

        RECV: begin
            if(count > 4'h0)
                next_state = RECV;
            else if(count == 4'h0)
                next_state = VALID_TEST;
        end

        VALID_TEST: begin
            if(RX_FINISHED) 
                next_state = RESULT;
            else 
                next_state = VALID_TEST;
        end

        RESULT: begin
            if(DATA_ACK) 
                next_state = IDLE;
            else 
                next_state = RESULT;
        end

        default: next_state = IDLE; //samokorekcja
    endcase

end

//Aktualizacja stanu
always@(posedge CLK) begin 
    current_state <= next_state;
    lastRXD <= {lastRXD[0],RXD};

    //Ustawienie wyjść i zmiennych wewnętrznych
    case(current_state)
        IDLE: begin
            count <= 4'd8;
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
                Data <= {Data[6:0], RXD};
                if(count > 4'd0) 
                    count <= count - 1'b1;
            end
        end

        VALID_TEST: begin
            if(baud_sync > 3'h0) 
                baud_sync <= baud_sync - 1'b1;
            else begin
                if(lastRXD == 2'h0) begin
                    RX_FINISHED <= 1'b1;
                    RX_BUSY <= 1'b0;
                    RX_ERROR <= 1'b1;
                    RX_READY <= 1'b1;
                end
                else begin
                    RX_FINISHED <= 1'b1;
                    RX_BUSY <= 1'b0;
                    RX_ERROR <= 1'b0;
                    RX_READY <= 1'b1;
                end
            end
        end 

        RESULT:begin

        end

        default: begin
            count <= 4'd8;
            baud_sync <= 3'h0;
        end
    endcase
end

endmodule