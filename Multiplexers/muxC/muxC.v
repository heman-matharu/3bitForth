module muxC(Select, MuxD, J, C);
    input Select;
    input [2:0] MuxD;
    input [2:0]  J;

    output reg [2:0] C;


    always @(*) begin
        case (Select)
            0: C = MuxD;
            1: C = J;
            default: C = MuxD;
        endcase
    end


endmodule