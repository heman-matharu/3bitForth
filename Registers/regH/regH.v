module regH(clk, H_F, rst_n, H);

    input clk;
    input H_F;
    input rst_n;

    reg [11:0] H_Next;
    output reg [11:0] H;

    always @(posedge clk or rst_n)
    begin
        if !rst_n
        begin
            H <= 12'o7000;
        end
        else
        begin
            H <= H_Next;
        end
    end
    
    always @(*)
    begin
        case (H_F)
            1'b0: H_Next = H;
            1'b1: H_Next = H + 1;
            default: H_Next = H;
        endcase
    
    end


endmodule