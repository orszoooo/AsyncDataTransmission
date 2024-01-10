`timescale 1ns / 1ps

module tx #(
    parameter WIDTH = 8 // 1 bit Start, 8 bit Data, 1 Stop bit
)(
    CLK,
    Start, //Start transmisji
    SWIn,
    TXD,
    TX_BUSY
);

input CLK;
input Start; //Start transmisji
input [WIDTH-1:0] SWIn;
output reg TXD;
output reg TX_BUSY;

reg [WIDTH-1:0] data;
reg current_state, next_state;
reg [3:0] count; //Licznik położenia w ramce

parameter IDLE = 1'b0;
parameter SEND = 1'b1;

//Przetwarzanie wejścia i ustawienie stanu
always@(*) begin
    case(current_state)
        IDLE: begin
            if(Start) begin
                next_state = SEND;
            end
            else
                next_state = IDLE;
        end

        SEND: begin
            if(count > 4'd0) begin
                next_state = SEND;
            end
            else
                next_state = IDLE;
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
            data <= SWIn;
            count <= 4'd10;
            TXD <= 1'b1;
				TX_BUSY <= 1'b0;
        end

        SEND: begin
            if(count == 4'd10) begin
                TXD <= 1'b0; //Start bit
                count <= count - 1'b1; 
                TX_BUSY <= 1'b1;
            end
            else if(count > 4'd0) begin
                count <= count - 1'b1;

				data <= {data[WIDTH-1:0], 1'b1};
				TXD <= data[WIDTH-1];
            end
        end

        default: TXD <= 1'b1;
    endcase
end

endmodule