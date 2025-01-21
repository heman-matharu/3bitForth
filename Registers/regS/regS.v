module regS(clk, S_F, S_In, rst_n, S_Out);

    input clk;
    input [1:0] S_F;
    input [11:0] S_In;
    input rst_n;


    reg [11:0] S_Next;
    output reg [11:0] S;

    output reg [11:0] S_Out;

    always @(negedge clk or rst_n)
    begin
        if (!rst_n)
        begin
            S <= 12'd75;
        end
        else
        begin
            S <= S_Next;
        end
    end

    always @(*)
    begin
        case (S_F)
            2'b00: begin
            S_Next = S;
            S_Out = S;
            end
            2'b01: begin
            S_Next = S + 1;
            S_Out = S;
            end
            2'b10: begin
            S_Next = S - 1;
            S_Out = S;
            end
            2'b11: begin
            S_Next = S_In;
            S_Out = S;
            end
            default: begin
            S_Next = S;
            S_Out = S;
            end
        endcase
    end




endmodule