module regP(clk, rst_n, P);
    input clk;
    input rst_n;

    reg P_Next;
    output reg P;

    always @(posedge clk or rst_n)
    begin
        if (!rst_n)
        begin
            P <= 0;
        end
        else
        begin
            P <= P_Next;
        end
    end

    always @(*)
    begin
        P_Next = !P;
    end



endmodule