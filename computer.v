`include "Registers/regI/regI.v"
`include "Registers/regR/regR.v"
`include "Registers/regS/regS.v"
`include "Registers/regJ/regJ.v"
`include "Registers/regT/regT.v"
`include "Registers/regF/regF.v"
`include "Registers/regP/regP.v"
`include "Multiplexers/muxA/muxA.v"
`include "Multiplexers/muxB/muxB.v"
`include "Multiplexers/muxC/muxC.v"
`include "Multiplexers/muxD/muxD.v"
`include "Multiplexers/muxP/muxP.v"
`include "ALU/alu.v"
`include "Decoder/decoder.v"

// always on
// clock oscillator
// counter 3bit -> 12bit
// memory
// first is 1 phase, then is 2 phase.
// add an alu that does a subtract


module computer (
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
    R_F,
    J_F,
    S_F,
    ALU_F,
    A_Sel,
    B_Sel,
    C_Sel,
    D_Sel
    );
    
    input clk;

    input rst_n;

    output [11:0] I;
    output [11:0] J;
    output [11:0] S;
    output [2:0] T;
    output [2:0] R;

    output [11:0] A;
    output [11:0] B;
    output [11:0] X;
    output [2:0] C;
    output [2:0] D;
    
    output F;
    output P;

    wire F_In;

    output [1:0] A_Sel;
    output B_Sel;
    output C_Sel;
    output D_Sel;

    output H_F;
    output F_F;
    output T_F;
    output [1:0] I_F;
    output R_F;
    output [2:0] J_F;
    output [1:0] S_F;
    output [1:0] ALU_F;

    output [2:0] ALU_Out;
 
    regI regI (clk, rst_n, P, I_F, J, I);

    regJ regJ (clk, J_F, B, rst_n, J);

    regS regS (clk, S_F, A, rst_n, S);

    regT regT (clk, C, T_F, rst_n, T);

    regF regF (clk, F_In, F_F, rst_n, F);
    
    regP regP (clk, rst_n, P);

    regR ram (clk, R_F, A, T, R);

    muxA muxA (A_Sel, I, J, S, 12'd0, X);

    muxB muxB (B_Sel, A, (R + 12'd0), B);

    muxC muxC (C_Sel, D, J[2:0], C);

    muxD muxD (D_Sel, ALU_Out, 3'b0, D);
    
    muxP muxP (P, I, X, A);

    alu alu (ALU_F, R, T, F_In, ALU_Out );

    decoder decoder(clk, R, T, P, F,
                    A_Sel, B_Sel, C_Sel, D_Sel,
                    ALU_F, I_F, S_F, R_F, J_F,
                    H_F, F_F, T_F, rst_n);





endmodule       
