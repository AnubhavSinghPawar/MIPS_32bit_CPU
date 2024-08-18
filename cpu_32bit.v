module cpu_32bit (
    input clk,
    input reset
);
    // Opcode Parameters
    parameter ADD   = 6'b000001;
    parameter SUB   = 6'b000010;
    parameter MUL   = 6'b000011;
    parameter DIV   = 6'b000100;
    parameter INC   = 6'b000101;
    parameter DEC   = 6'b000110;
    parameter AND   = 6'b000111;
    parameter OR    = 6'b001000;
    parameter XOR   = 6'b001001;
    parameter NOT   = 6'b001010;
    parameter JMP   = 6'b001011;
    parameter BEQ   = 6'b001100;
    parameter BNE   = 6'b001101;
    parameter CALL  = 6'b001110;
    parameter RET   = 6'b001111;
    parameter LD    = 6'b010000;
    parameter ST    = 6'b010001;
    parameter HLT   = 6'b111111;

    // Program Counter and Stack Pointer
    reg [31:0] PC;
    reg [31:0] SP;
    
    // Register File
    reg [31:0] Regs [0:31];
    
    // Memory (Instructions and Data combined for simplicity)
    reg [31:0] Mem [0:1023];
    
    // Pipeline Registers
    reg [31:0] IF_ID_IR, IF_ID_PC;
    reg [31:0] ID_EX_A, ID_EX_B, ID_EX_IMM, ID_EX_IR, ID_EX_PC;  // Added ID_EX_PC
    reg [31:0] EX_MEM_ALUOut, EX_MEM_B, EX_MEM_IR;
    reg EX_MEM_cond; 
    reg [31:0] MEM_WB_ALUOut, MEM_WB_LMD, MEM_WB_IR;
    
    // Control Signals
    reg ID_EX_MemRead, ID_EX_MemWrite, ID_EX_RegWrite, ID_EX_Branch;
    reg EX_MEM_MemRead, EX_MEM_MemWrite, EX_MEM_RegWrite, EX_MEM_Branch;
    reg MEM_WB_RegWrite;

    // Hazard Control
    reg stall;  // Stall signal for data hazards

    // Instruction fields
    wire [5:0] opcode = IF_ID_IR[31:26];
    wire [4:0] rs = IF_ID_IR[25:21];
    wire [4:0] rt = IF_ID_IR[20:16];
    wire [4:0] rd = IF_ID_IR[15:11];
    wire [15:0] immediate = IF_ID_IR[15:0];
    
    // IF: Instruction Fetch
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC <= 32'b0;
        end else if (!stall) begin
            IF_ID_IR <= Mem[PC];  // Fetch instruction
            IF_ID_PC <= PC;
            PC <= PC + 1;
        end
    end
    
    // ID: Instruction Decode
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ID_EX_A <= 32'b0;
            ID_EX_B <= 32'b0;
            ID_EX_IMM <= 32'b0;
            ID_EX_IR <= 32'b0;
            ID_EX_PC <= 32'b0;  // Resetting ID_EX_PC
        end else if (!stall) begin
            ID_EX_A <= Regs[rs];  // Read register rs
            ID_EX_B <= Regs[rt];  // Read register rt
            ID_EX_IMM <= {{16{immediate[15]}}, immediate};  // Sign-extend immediate
            ID_EX_IR <= IF_ID_IR;  // Pass the instruction
            ID_EX_PC <= IF_ID_PC;  // Pass the PC value

            // Control logic
            case(opcode)
                ADD: begin  // ADD
                    ID_EX_RegWrite <= 1'b1;
                end
                SUB: begin  // SUB
                    ID_EX_RegWrite <= 1'b1;
                end
                MUL: begin  // MUL
                    ID_EX_RegWrite <= 1'b1;
                end
                DIV: begin  // DIV
                    ID_EX_RegWrite <= 1'b1;
                end
                INC: begin  // INC
                    ID_EX_RegWrite <= 1'b1;
                end
                DEC: begin  // DEC
                    ID_EX_RegWrite <= 1'b1;
                end
                AND: begin  // AND
                    ID_EX_RegWrite <= 1'b1;
                end
                OR: begin  // OR
                    ID_EX_RegWrite <= 1'b1;
                end
                XOR: begin  // XOR
                    ID_EX_RegWrite <= 1'b1;
                end
                NOT: begin  // NOT
                    ID_EX_RegWrite <= 1'b1;
                end
                LD: begin  // Load Word
                    ID_EX_MemRead <= 1'b1;
                    ID_EX_RegWrite <= 1'b1;
                end
                ST: begin  // Store Word
                    ID_EX_MemWrite <= 1'b1;
                end
                JMP: begin  // Jump
                    PC <= ID_EX_IMM;
                end
                BEQ: begin  // BEQ
                    ID_EX_Branch <= 1'b1;
                end
                BNE: begin  // BNE
                    ID_EX_Branch <= 1'b1;
                end
                CALL: begin  // CALL
                    SP <= SP - 1;
                    Mem[SP] <= PC;
                    PC <= ID_EX_IMM;
                end
                RET: begin  // RET
                    PC <= Mem[SP];
                    SP <= SP + 1;
                end
                HLT: begin  // HALT
                    ID_EX_RegWrite <= 1'b0;
                    $finish;  // Halt the simulation
                end
                default: begin
                    ID_EX_RegWrite <= 1'b0;
                    ID_EX_MemRead <= 1'b0;
                    ID_EX_MemWrite <= 1'b0;
                end
            endcase
        end
    end
    
    // EX: Execution
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            EX_MEM_ALUOut <= 32'b0;
            EX_MEM_B <= 32'b0;
            EX_MEM_IR <= 32'b0;
            stall <= 1'b0;  // Reset stall signal
        end else begin
            // Forwarding and Hazard detection
            if ((ID_EX_RegWrite && (rs == rd || rt == rd)) || ID_EX_Branch) begin
                stall <= 1'b1;  // Stall the pipeline
            end else begin
                stall <= 1'b0;
                case(ID_EX_IR[31:26])
                    ADD: EX_MEM_ALUOut <= ID_EX_A + ID_EX_B;  // ADD
                    SUB: EX_MEM_ALUOut <= ID_EX_A - ID_EX_B;  // SUB
                    MUL: EX_MEM_ALUOut <= ID_EX_A * ID_EX_B;  // MUL
                    DIV: EX_MEM_ALUOut <= ID_EX_A / ID_EX_B;  // DIV
                    INC: EX_MEM_ALUOut <= ID_EX_A + 1;        // INC
                    DEC: EX_MEM_ALUOut <= ID_EX_A - 1;        // DEC
                    AND: EX_MEM_ALUOut <= ID_EX_A & ID_EX_B;  // AND
                    OR: EX_MEM_ALUOut <= ID_EX_A | ID_EX_B;   // OR
                    XOR: EX_MEM_ALUOut <= ID_EX_A ^ ID_EX_B;  // XOR
                    NOT: EX_MEM_ALUOut <= ~ID_EX_A;           // NOT
                    LD: EX_MEM_ALUOut <= ID_EX_A + ID_EX_IMM;  // Calculate address for LD
                    ST: EX_MEM_ALUOut <= ID_EX_A + ID_EX_IMM;  // Calculate address for ST
                    BEQ: begin  // BEQ
                        if (ID_EX_A == ID_EX_B) begin
                            EX_MEM_cond <= 1'b1;
                            PC <= ID_EX_PC + 1 + ID_EX_IMM;  // Updated to use ID_EX_PC
                        end else begin
                            EX_MEM_cond <= 1'b0;
                        end
                    end
                    BNE: begin  // BNE
                        if (ID_EX_A != ID_EX_B) begin
                            EX_MEM_cond <= 1'b1;
                            PC <= ID_EX_PC + 1 + ID_EX_IMM;  // Updated to use ID_EX_PC
                        end else begin
                            EX_MEM_cond <= 1'b0;
                        end
                    end
                    JMP: begin  // JMP
                        PC <= ID_EX_IMM;
                    end
                    CALL: begin  // CALL
                        SP <= SP - 1;
                        Mem[SP] <= ID_EX_PC;  // Store the return address
                        PC <= ID_EX_IMM;
                    end
                    RET: begin  // RET
                        PC <= Mem[SP];
                        SP <= SP + 1;
                    end
                    default: EX_MEM_ALUOut <= 32'b0;
                endcase
            end
            EX_MEM_B <= ID_EX_B;
            EX_MEM_IR <= ID_EX_IR;
            EX_MEM_RegWrite <= ID_EX_RegWrite;
            EX_MEM_MemRead <= ID_EX_MemRead;
            EX_MEM_MemWrite <= ID_EX_MemWrite;
            EX_MEM_Branch <= ID_EX_Branch;
        end
    end
    
    // MEM: Memory Access
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            MEM_WB_ALUOut <= 32'b0;
            MEM_WB_LMD <= 32'b0;
            MEM_WB_IR <= 32'b0;
        end else begin
            if (EX_MEM_MemRead) begin
                MEM_WB_LMD <= Mem[EX_MEM_ALUOut];  // Load memory data
            end else if (EX_MEM_MemWrite) begin
                Mem[EX_MEM_ALUOut] <= EX_MEM_B;  // Store data
            end
            MEM_WB_ALUOut <= EX_MEM_ALUOut;
            MEM_WB_IR <= EX_MEM_IR;
            MEM_WB_RegWrite <= EX_MEM_RegWrite;
        end
    end
    
    // WB: Write Back
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Do nothing on reset
        end else begin
            if (MEM_WB_RegWrite) begin
                Regs[MEM_WB_IR[15:11]] <= MEM_WB_ALUOut;  // Write back to register
            end
        end
    end

endmodule