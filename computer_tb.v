`include "computer.v"


module computer_tb;
  reg clk;
  reg rst_n;

  output H_F;
  output F_F;
  output T_F;
  
  output [1:0] I_F;
  output D_F;
  output [2:0] J_F;
  output [1:0] S_F;
  output [1:0] ALU_F;

  output [1:0] A_Sel;
  output B_Sel;
  output C_Sel;
  output D_Sel;

  wire [2:0] R;
  wire [2:0] ALU_Out;
  wire [11:0] A;
  wire [11:0] B;
  wire [2:0] C;
  wire [2:0] D;
  wire [11:0] I;
  wire [11:0] J;
  wire [2:0] T;
  wire F;

  // Instantiate the multiplexer
  computer comp (
    clk,
    rst_n,
    R,
    ALU_Out,
    A,
    B,
    C,
    D,
    I,
    J,
    T,
    F,
    P,
    H_F,
    F_F,
    T_F,
    I_F,
    D_F,
    J_F,
    S_F,
    ALU_F,
    A_Sel,
    B_Sel,
    C_Sel,
    D_Sel
  );

  initial begin
    $dumpfile("computer.vcd");
    $dumpvars (0, computer_tb);
    rst_n = 0;
    clk = 1; #10;
    rst_n = 1;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;
    clk = 0; #10;
    clk = 1; #10;


    $finish;
  end

endmodule
