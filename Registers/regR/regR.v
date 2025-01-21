module regR(clk, R_F, Address, Data_In, Data_Out);
    input clk;
    input R_F;
    input [11:0] Address;
    input [2:0] Data_In;

    output [2:0] Data_Out;

    reg [2:0] Ram_Next;

    reg [4096:0] [0:2] Ram;

    integer i;

    initial begin 
        for (i = 0; i < 4096; i = i + 1) begin
            Ram[i] = 3'b000;
        end
        Ram[64] = 3'b000;
        Ram[65] = 3'b111;
        Ram[66] = 3'b111;
        Ram[67] = 3'b100;
        Ram[68] = 3'b111;
        Ram[69] = 3'b000;
        Ram[70] = 3'b000;
        Ram[71] = 3'b011;



    end

    assign Data_Out = Ram[Address];

    always @(negedge clk);



    // We are implementing an asynchronous memory with a clocked write
    // When synthesizing to actual silicon, we need to reconsider this design
    // For example, if synthesizing to a xilinx BRAM, how will this map?
    always @(*)
    begin
        if (R_F == 1)
        begin
            Ram_Next = Data_In;
        end
        else
        begin
            Ram_Next = Data_Out;
        end
    end

    always @(posedge clk)
    begin
        Ram[Address] <= Ram_Next;
    end

endmodule
