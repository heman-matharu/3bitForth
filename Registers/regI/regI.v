module regI(clk, rst_n, regP, I_F, I_In, I);

    input clk;
    input rst_n;
    input regP;
    input [1:0] I_F;
    input [11:0] I_In;
    

    output reg [11:0] I;
    reg [11:0] I_Next;
    
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            I <= 12'o100; 
        end
        else
        begin
            I <= I_Next;
        end
    end

    always @(*)
    begin
        if (regP == 0)
            begin
                case (I_F)
                    2'b00: I_Next = I;
                    2'b01: I_Next = I + 1;
                    2'b10: I_Next = I_In;
                    default: I_Next = I;
                endcase
            end
        else
            begin
              I_Next = I;
            end
    end
endmodule

