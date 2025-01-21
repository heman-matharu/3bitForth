module regT(clk, T_In, T_F, rst_n, T);
    input clk;
    input [2:0] T_In;
    input T_F;
    input rst_n;

    reg [2:0] T_Next;
    output reg [2:0] T;

    always @(negedge clk or rst_n)
    begin
        if (!rst_n)
        begin
            T <= 0;
        end
        else
        begin
            T <= T_Next;
        end
    end

    always @(*)
    begin
        case (T_F)
            0: T_Next = T;
            1: T_Next = T_In;
            default: T_Next = T;
        endcase
    end

endmodule