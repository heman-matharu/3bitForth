module regJ(clk, J_F, J_In, rst_n, J);

    input clk;
    input [2:0] J_F;
    input [11:0] J_In;
    input rst_n;

    reg [11:0] J_Next;
    output reg [11:0] J;

    always @(posedge clk or rst_n)
    begin
        if (!rst_n)
        begin
            J <= 12'd85;
        end
        else
        begin
            J <= J_Next;
        end
    end

    always @(*)
    begin
        case (J_F)
            3'b000: J_Next = J;
            3'b001: J_Next = J + 1;
            3'b010: J_Next = J_In;
            3'b100: J_Next = (J & 12'o7770) | (J_In & 12'o0007);
            3'b101: J_Next = (J & 12'o7707) | ((J_In >> 8) & 12'o0070);
            3'b110: J_Next = (J & 12'o7077) | ((J_In >> 16) & 12'o0700);
            3'b111: J_Next = (J & 12'o0777) | ((J_In >> 24) & 12'o7000);
            default: J_Next = J;
        endcase
    end

endmodule