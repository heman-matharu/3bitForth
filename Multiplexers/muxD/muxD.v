module muxD(Select, ALU_In, D0, D);
    input Select;
    input [2:0] ALU_In;
    input [2:0] D0;

    output reg [2:0] D;


    always @(*) begin
        case (Select)
            0: D = ALU_In;
            1: D = D0;
            default: D = ALU_In;
        endcase
    end


endmodule