module regF(clk, F_In, F_F, rst_n, F);
    input clk;
    input F_In;
    input F_F;
    input rst_n;

    reg  F_Next;
    output reg  F;

    always @(negedge clk or rst_n)
    begin
        if (!rst_n)
        begin
            F <= 0;
        end
        else begin
            F <= F_Next;
        end
    end

    always @(*)
    begin
        case (F_F)
            1'b0: F_Next = F;
            1'b1: F_Next = F_In;
            default: F_Next = F;
        endcase
    end

endmodule