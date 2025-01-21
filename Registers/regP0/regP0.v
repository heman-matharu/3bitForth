module regP0(clk, P0_In, P0_F, rst_n, P0);
    input clk;
    input [2:0] P0_In;
    input P0_F;
    input rst_n;

    reg [2:0] P0_Next;
    output reg [2:0] P0;

    always @(posedge clk or rst_n)
    begin
        if (!rst_n)
        begin
            P0 <= 0;
        end
        else
        begin
            P0 <= P0_Next;
        end
    end

    always @(*)
    begin
        case (P0_F)
            0: P0_Next = P0;
            1: P0_Next = P0_In;
            default: P0_Next = P0;
        endcase
    end

endmodule