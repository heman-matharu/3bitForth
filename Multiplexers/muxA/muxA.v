module muxA(Select, I, J, S, H, A);
    input [1:0] Select;
    input [3:0] [0:2] I;
    input [3:0] [0:2] J;
    input [3:0] [0:2] S;
    input [3:0] [0:2] H;

    output reg [3:0] [0:2] A;

    always @(*) begin
        case (Select)
            2'b00: A = I;
            2'b01: A = J;
            2'b10: A = S;
            2'b11: A = H;
            default: A = I;
        endcase
    end


endmodule