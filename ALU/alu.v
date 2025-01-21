module alu(select, valD, regT, regF, alu_out);
    input [1:0] select;
    input [2:0] valD;
    input [2:0] regT;
    output reg regF = 0;
    output reg [2:0] alu_out;
    always @(*) begin
        case (select)
            2'b00: alu_out = regT * 2;
            2'b01: alu_out = (regT * 2) + 1;
            2'b10: alu_out = valD;
            2'b11: begin
                    alu_out = valD - regT;
                    if (valD < regT) begin
                        regF = 1;
                    end else begin
                        regF = 0;
                    end
                end
            default: alu_out = valD;
        endcase
    end


endmodule