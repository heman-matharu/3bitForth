module decoder(clk, Data_Out, RegT, regP, regF, A_Sel, B_Sel, C_Sel, D_Sel, ALU_F, I_F, S_F, R_F, J_F, H_F, F_F, T_F, rst_n);
    input clk;
    input [2:0] Data_Out; // rename to OPCODE
    input [2:0] RegT; // rename XTRA_OPCODE
    input regP;
    input regP0; // delete/move?
    input regQ; // delete/move?
    input regF;

    input rst_n;

    output reg [1:0] A_Sel;
    output reg B_Sel;
    output reg C_Sel;
    output reg D_Sel;
    output reg [1:0] ALU_F;
    output reg [1:0] I_F;
    output reg [1:0] S_F;
    output reg  R_F;
    output reg [2:0] J_F;
    output reg H_F;
    output reg F_F;
    output reg T_F;
    output reg P_F0;
    output reg P_Q;

    reg [1:0] A_Sel_next;
    reg B_Sel_next;
    reg C_Sel_next;
    reg D_Sel_next;
    reg [1:0] ALU_F_next;
    reg [1:0] I_F_next;
    reg [1:0] S_F_next;
    reg  R_F_next;
    reg [2:0] J_F_next;
    reg H_F_next;
    reg F_F_next;
    reg T_F_next;
    reg P_F0_next;
    reg P_Q_next;

    always @(posedge clk)
    begin
        A_Sel <= A_Sel_next;
        B_Sel <= B_Sel_next;
        C_Sel <= C_Sel_next;
        D_Sel <= D_Sel_next;
        R_F <= R_F_next;
        F_F <= F_F_next;
        I_F <= I_F_next;
        J_F <= J_F_next;
        S_F <= S_F_next;
        H_F <= H_F_next;
        T_F <= T_F_next;
        ALU_F <= ALU_F_next;
    end

    always @(*)
    begin
        if (regP == 0) begin
            B_Sel_next = 2'b00;
            A_Sel_next = 2'b00; // muxA = regI
            B_Sel_next = 0;  // muxB = muxA
            C_Sel_next = 0; // muxC = muxD
            D_Sel_next = 0; // muxD = ALU_Out
            R_F_next = 0; // Data_Out = RegD[muxA]
            F_F_next = 0;
            I_F_next = 2'b00; // regI = regI
            J_F_next = 3'b00; // regJ = regJ
            S_F_next = 2'b00; // regS = regS
            H_F_next = 2'b00; // regH = regH
            T_F_next = 0; // regT = regT
            ALU_F_next = 2'b10; // ALU_Out = valD
            
        end else begin
            case (Data_Out)
                3'b000: begin
                    // BLK
                    A_Sel_next = 2'b00; // muxA = regI
                    B_Sel_next = 0; // muxB = muxA
                    C_Sel_next = 0; // muxC = muxD
                    D_Sel_next = 0; // muxD = ALU_Out
                    R_F_next = 0; // Data_Out = Data_Out
                    F_F_next = 0;
                    I_F_next = 2'b01; //* regI = regI + 1
                    J_F_next = 3'b000; // regJ = regJ
                    S_F_next = 2'b00; // regS = regS
                    H_F_next = 2'b00; // regH = regH
                    T_F_next = 1; //* regT = muxC
                    ALU_F_next = 2'b00; //* ALU_Out = regT * 2
                end
                3'b001: begin
                    // RIT
                    A_Sel_next = 2'b01; // muxA = regJ
                    B_Sel_next = 0; 
                    C_Sel_next = 0;
                    D_Sel_next = 0;
                    R_F_next = 1; // Ram[RegJ] = regT
                    F_F_next = 0;
                    I_F_next = 2'b01; // IncI : regI += 1
                    J_F_next = 3'b001; // regJ = regJ + 1
                    S_F_next = 2'b00; // regS = regS
                    H_F_next = 2'b00; // regH = regH
                    T_F_next = 0; // regT = regT
                    ALU_F_next = 2'b10; // ALU_Out = valD
                end
                3'b010: begin
                    // GET
                    A_Sel_next = 2'b01; // muxA = regJ
                    B_Sel_next = 0; 
                    C_Sel_next = 0; // muxC = muxD
                    D_Sel_next = 0; // muxD = ALU_Out
                    R_F_next = 0; // Data_Out = regD[regJ]
                    F_F_next = 0;
                    I_F_next = 2'b01; //! IncI : regI = regI
                    J_F_next = 3'b001; // regJ = regJ + 1
                    S_F_next = 2'b00; // regS = regS
                    H_F_next = 2'b00; // regH = regH
                    T_F_next = 1; // regT = muxC
                    ALU_F_next = 2'b10; // ALU_Out = valD

                end
                3'b011: begin
                    // YNK SECTION
                    case (RegT)
                        3'b000: begin
                            // S -> J 
                            A_Sel_next = 2'b10; // muxA = regS
                            B_Sel_next = 0; // muxB = muxA
                            C_Sel_next = 0; // muxC = muxD
                            D_Sel_next = 0; // muxD = ALU_Out
                            R_F_next = 0; // Data_Out = Data_Out
                            F_F_next = 0;
                            I_F_next = 2'b01; //* regI = regI + 1
                            J_F_next = 3'b010; // regJ = regS
                            S_F_next = 2'b00; // regS = regS
                            H_F_next = 2'b00; // regH = regH
                            T_F_next = 1; //* regT = muxC
                            ALU_F_next = 2'b10; // ALU_Out = valD
                        end
                        3'b001: begin
                            // J -> S
                            A_Sel_next = 2'b01; // muxA = regJ
                            B_Sel_next = 0; // muxB = muxA
                            C_Sel_next = 0; // muxC = muxD
                            D_Sel_next = 0; // muxD = ALU_Out
                            R_F_next = 0; // Data_Out = Data_Out
                            F_F_next = 0;
                            I_F_next = 2'b01; //* regI = regI + 1
                            J_F_next = 3'b000; // regJ = regJ
                            S_F_next = 2'b11; // regS = regJ
                            H_F_next = 2'b00; // regH = regH
                            T_F_next = 1; //* regT = muxC
                            ALU_F_next = 2'b10; // ALU_Out = valD
                        end
                        3'b100: begin
                            // T -> J0 J0 -> T
                            A_Sel_next = 2'b10; // muxA = regS
                            B_Sel_next = 1; // muxB = regD
                            C_Sel_next = 1; // muxC = regJ
                            D_Sel_next = 0; // muxD = ALU_Out
                            R_F_next = 0; // Data_Out = ram[regS]
                            F_F_next = 2'b01; // regF = F_In
                            I_F_next = 2'b01; // IncI : regI += 1
                            J_F_next = 3'b100; // regJ = muxB
                            S_F_next = 2'b01; // regS += 1
                            H_F_next = 2'b00; // regH = regH
                            T_F_next = 1; // regT = muxC
                            ALU_F_next = 2'b10; // ALU_Out = valD
                        end
                        3'b101: begin
                            // T -> J1 J1 -> T
                            A_Sel_next = 2'b10; // muxA = regS
                            B_Sel_next = 1; // muxB = regD
                            C_Sel_next = 1; // muxC = regJ
                            D_Sel_next = 0; // muxD = ALU_Out
                            R_F_next = 0; // Data_Out = ram[regS]
                            F_F_next = 2'b01; // regF = F_In
                            I_F_next = 2'b01; // IncI : regI += 1
                            J_F_next = 3'b101; // regJ = muxB
                            S_F_next = 2'b01; // regS += 1
                            H_F_next = 2'b00; // regH = regH
                            T_F_next = 1; // regT = muxC
                            ALU_F_next = 2'b10; // ALU_Out = valD
                        end
                        3'b110: begin
                            // T -> J2 J2 -> T
                            A_Sel_next = 2'b10; // muxA = regS
                            B_Sel_next = 1; // muxB = regD
                            C_Sel_next = 1; // muxC = regJ
                            D_Sel_next = 0; // muxD = ALU_Out
                            R_F_next = 0; // Data_Out = ram[regS]
                            F_F_next = 2'b01; // regF = F_In
                            I_F_next = 2'b01; // IncI : regI += 1
                            J_F_next = 3'b110; // regJ = muxB
                            S_F_next = 2'b01; // regS += 1
                            H_F_next = 2'b00; // regH = regH
                            T_F_next = 1; // regT = muxC
                            ALU_F_next = 2'b10; // ALU_Out = valD
                        end
                        3'b111: begin
                            // T -> J3 J3 -> T
                            A_Sel_next = 2'b10; // muxA = regS
                            B_Sel_next = 1; // muxB = regD
                            C_Sel_next = 1; // muxC = regJ
                            D_Sel_next = 0; // muxD = ALU_Out
                            R_F_next = 0; // Data_Out = ram[regS]
                            F_F_next = 2'b01; // regF = F_In
                            I_F_next = 2'b01; // IncI : regI += 1
                            J_F_next = 3'b111; // regJ = muxB
                            S_F_next = 2'b01; // regS += 1
                            H_F_next = 2'b00; // regH = regH
                            T_F_next = 1; // regT = muxC
                            ALU_F_next = 2'b10; // ALU_Out = valD
                        end
                        default: begin
                            // J -> S
                            A_Sel_next = 2'b01; // muxA = regJ
                            B_Sel_next = 0; // muxB = muxA
                            C_Sel_next = 0; // muxC = muxD
                            D_Sel_next = 0; // muxD = ALU_Out
                            R_F_next = 0; // Data_Out = Data_Out
                            F_F_next = 0;
                            I_F_next = 2'b01; //* regI = regI + 1
                            J_F_next = 3'b000; // regJ = regJ
                            S_F_next = 2'b11; // regS = regJ
                            H_F_next = 2'b00; // regH = regH
                            T_F_next = 1; //* regT = muxC
                            ALU_F_next = 2'b10; // ALU_Out = valD
                        end
                    endcase
                end
                3'b100: begin
                    // DBL 
                    A_Sel_next = 2'b10; // muxA = RegS
                    B_Sel_next = 0; 
                    C_Sel_next = 0;
                    D_Sel_next = 0;
                    R_F_next = 1; // Ram[RegS] = regT
                    F_F_next = 0;
                    I_F_next = 2'b01; // IncI : regI += 1
                    J_F_next = 3'b000; // regJ = regJ
                    S_F_next = 2'b10; // regS -= 1
                    H_F_next = 2'b00; // regH = regH
                    T_F_next = 0; // regT = regT
                    ALU_F_next = 2'b10; // ALU_Out = valD
                end
                3'b101: begin
                    // MIN
                    A_Sel_next = 2'b10; // muxA = regS
                    B_Sel_next = 0; 
                    C_Sel_next = 0;
                    D_Sel_next = 0;
                    R_F_next = 0; // Data_Out = ram[regS]
                    F_F_next = 2'b01; // regF = F_In
                    I_F_next = 2'b01; // IncI : regI += 1
                    J_F_next = 3'b000; // regJ = regJ
                    S_F_next = 2'b01; // regS += 1
                    H_F_next = 2'b00; // regH = regH
                    T_F_next = 1; // regT = muxC
                    ALU_F_next = 2'b11; // ALU_Out = Data_Out - regT

                end
                3'b110: begin
                    // CAL
                    if (regF == 1) begin 
                        A_Sel_next = 2'b00; // muxA = regI
                        B_Sel_next = 2'b00; // muxB = regI
                        C_Sel_next = 0;
                        D_Sel_next = 0;
                        R_F_next = 0; // Data_Out = RegD[muxA]
                        F_F_next = 2'b11; // reset regF : regF = 0
                        I_F_next = 2'b10; // regI = regJ
                        J_F_next = 3'b010; // regJ = regI
                        S_F_next = 2'b00; // regS = regS
                        H_F_next = 2'b00; // regH = regH
                        T_F_next = 0; // regT = regT
                        ALU_F_next = 2'b10; // ALU_Out = valD
                    end else begin
                        A_Sel_next = 2'b00; // muxA = regI
                        B_Sel_next = 2'b00; // muxB = regI
                        C_Sel_next = 0;
                        D_Sel_next = 0;
                        R_F_next = 0; // Data_Out = RegD[muxA]
                        F_F_next = 2'b11; // reset regF : regF = 0
                        I_F_next = 2'b01; // IncI : regI += 1
                        J_F_next = 3'b010; // regJ = regI
                        S_F_next = 2'b00; // regS = regS
                        H_F_next = 2'b00; // regH = regH
                        T_F_next = 0; // regT = regT
                        ALU_F_next = 2'b10; // ALU_Out = valD
                    end 
                end
                3'b111: begin
                    // WHT
                    A_Sel_next = 2'b00; // muxA = regI
                    B_Sel_next = 0; // muxB = muxA
                    C_Sel_next = 0; // muxC = muxD
                    D_Sel_next = 0; // muxD = ALU_Out
                    R_F_next = 0; // Data_Out = Data_Out
                    F_F_next = 0;
                    I_F_next = 2'b01; //* regI = regI + 1
                    J_F_next = 3'b000; // regJ = regJ
                    S_F_next = 2'b00; // regS = regS
                    H_F_next = 2'b00; // regH = regH
                    T_F_next = 1; //* regT = muxC
                    ALU_F_next = 2'b01; //* ALU_Out = regT * 2 1
                    end
                default: begin
                    A_Sel_next = 2'b00; // muxA = regI
                    B_Sel_next = 0; // muxB = muxA
                    C_Sel_next = 0; // muxC = muxD
                    D_Sel_next = 0; // muxD = ALU_Out
                    R_F_next = 0; // Data_Out = Data_Out
                    F_F_next = 0;
                    I_F_next = 2'b01; //* regI = regI + 1
                    J_F_next = 3'b000; // regJ = regJ
                    S_F_next = 2'b00; // regS = regS
                    H_F_next = 2'b00; // regH = regH
                    T_F_next = 1; //* regT = muxC
                    ALU_F_next = 2'b00; //* ALU_Out = regT * 2
                    end
            endcase
        end
    end

endmodule
