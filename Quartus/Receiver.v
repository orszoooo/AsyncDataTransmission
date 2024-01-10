module Receiver(
    input CLK,
    input RXD,
    input DATA_ACK,
    output reg [9:0] Frame,
    output reg RX_BUSY,
    output reg RX_READY,
    output reg RX_ERROR
);

reg [2:0] current_state, next_state;
reg [3:0] count; //Licznik położenia w ramce
reg [2:0] baud_sync; 

parameter IDLE = 3'h0;
parameter SYNC = 3'h1;
parameter RECV = 3'h2;
parameter VALID_TEST = 3'h3;

//Przetwarzanie wejścia i ustawienie stanu
always@(*) begin
    case(current_state)
        IDLE: begin
            if(Frame[1] == 1'b1 & Frame[0] == 1'b0) begin
                next_state = SYNC;
            end
            else begin
                next_state = IDLE;
            end
        end

        SYNC: begin
            if(baud_sync > 3'h0)
                next_state = SYNC;
            else if(baud_sync == 3'h0)
                next_state = RECV;
        end

        RECV: begin
            if(count > 4'h0)
                next_state = RECV;
            else if(count == 4'h0)
                next_state = VALID_TEST;
        end

        VALID_TEST: begin
            if(DATA_ACK) 
                next_state = IDLE;
            else 
                next_state = VALID_TEST;
        end

        default: next_state = IDLE; //samokorekcja
    endcase

end

//Aktualizacja stanu
always@(posedge CLK) begin 
    current_state <= next_state;
    
    //Ustawienie wyjść i zmiennych wewnętrznych
    case(current_state)
        IDLE: begin
            Frame <= {Frame[8:0], RXD};
            count <= 4'd9;
            baud_sync <= 3'h2;
            RX_READY <= 1'b0;
            RX_ERROR <= 1'b0;
            RX_BUSY <= 1'b0;
        end

        SYNC: begin
            if(baud_sync > 3'h0) 
                baud_sync <= baud_sync - 1'b1;
            else
                baud_sync <= 3'h7;

            RX_BUSY <= 1'b1;
        end

        RECV: begin
            if(baud_sync > 3'h0) 
                baud_sync <= baud_sync - 1'b1;
            else begin
                baud_sync <= 3'h7;
                Frame <= {Frame[8:0], RXD};
                if(count > 4'd0) 
                    count <= count - 1'b1;
            end
        end

        VALID_TEST: begin
            if(Frame[0] == 1'b0)                  
                RX_ERROR <= 1'b1;

            RX_READY <= 1'b1;
        end

        default: begin
            count <= 4'd9;
            baud_sync <= 3'h0;
        end

    endcase
end

endmodule