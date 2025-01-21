module muxB(Select, address, regD_out, B);
    input Select;
    input [3:0] [0:2] address;
    input [3:0] [0:2] regD_out;

    output reg [3:0] [0:2] B;


    always @(*) begin
        case (Select)
            0: B = address;
            1: B = regD_out;
            default: B = address;
        endcase
    end


endmodule