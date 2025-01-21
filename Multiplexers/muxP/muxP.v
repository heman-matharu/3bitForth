module muxP(Select, I, A, P);
    input Select;
    input [3:0] [0:2] I;
    input [3:0] [0:2] A;

    output reg [3:0] [0:2] P;

    always @(*) begin
        case (Select)
            0: P = A;
            1: P = I;
            default: P = I;
        endcase
    end


endmodule