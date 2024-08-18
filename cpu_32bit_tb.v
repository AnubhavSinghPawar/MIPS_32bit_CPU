`include "cpu_32bit.v"

module cpu_32_tb;
    reg clk;
    reg reset;

    // Instantiate the CPU module
    cpu_32bit uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Clock period = 10 time units
    end

    // Reset sequence
    initial begin
        reset = 1;
        #10 reset = 0;
    end

    // Test sequence with hazard avoidance
    initial begin
        // Initialize memory with instructions using parameters

        // Arithmetic Instructions
        uut.Mem[0] = {uut.ADD, 5'b00010, 5'b00011, 5'b00001, 16'b0};  // r1 = r2 + r3
        uut.Mem[1] = {uut.SUB, 5'b00101, 5'b00110, 5'b00100, 16'b0};  // r4 = r5 - r6
        uut.Mem[2] = {uut.MUL, 5'b01000, 5'b01001, 5'b00111, 16'b0};  // r7 = r8 * r9
        uut.Mem[3] = {uut.DIV, 5'b01011, 5'b01100, 5'b01010, 16'b0};  // r10 = r11 / r12
        
        // ADD NOPs to avoid data hazards
        uut.Mem[4] = {uut.ADD, 5'b00000, 5'b00000, 5'b00000, 16'b0};  // NOP
        uut.Mem[5] = {uut.ADD, 5'b00000, 5'b00000, 5'b00000, 16'b0};  // NOP
        
        uut.Mem[6] = {uut.INC, 5'b00000, 5'b00001, 5'b00001, 16'b0};  // r1 = r1 + 1
        uut.Mem[7] = {uut.DEC, 5'b00000, 5'b00100, 5'b00100, 16'b0};  // r4 = r4 - 1

        // Logical Instructions
        uut.Mem[8] = {uut.AND, 5'b01001, 5'b01000, 5'b00111, 16'b0};  // r7 = r8 & r9
        
        // ADD NOPs to avoid data hazards
        uut.Mem[9] = {uut.ADD, 5'b00000, 5'b00000, 5'b00000, 16'b0};  // NOP
        uut.Mem[10] = {uut.ADD, 5'b00000, 5'b00000, 5'b00000, 16'b0}; // NOP
        
        uut.Mem[11] = {uut.OR,  5'b01100, 5'b01011, 5'b01010, 16'b0};  // r10 = r11 | r12
        uut.Mem[12] = {uut.XOR, 5'b00010, 5'b00011, 5'b00001, 16'b0};  // r1 = r2 ^ r3
        uut.Mem[13] = {uut.NOT, 5'b00000, 5'b00001, 5'b00001, 16'b0};  // r1 = ~r2

        // Memory Instructions
        uut.Mem[14] = {uut.LD, 5'b00001, 5'b00000, 5'b00000, 16'h000A};  // r1 = Mem[10]
        uut.Mem[15] = {uut.ST, 5'b00001, 5'b00000, 5'b00000, 16'h000B};  // Mem[11] = r1

        // ADD NOPs to avoid memory access hazards
        uut.Mem[16] = {uut.ADD, 5'b00000, 5'b00000, 5'b00000, 16'b0};  // NOP
        uut.Mem[17] = {uut.ADD, 5'b00000, 5'b00000, 5'b00000, 16'b0};  // NOP

        // Control Flow Instructions
        uut.Mem[18] = {uut.BEQ, 5'b00001, 5'b00100, 16'd2};  // if (r1 == r4) PC = PC + offset (2)
        uut.Mem[19] = {uut.BNE, 5'b00111, 5'b01010, 16'd2};  // if (r7 != r10) PC = PC + offset (2)
        
        // ADD NOPs to avoid control hazards
        uut.Mem[20] = {uut.ADD, 5'b00000, 5'b00000, 5'b00000, 16'b0};  // NOP
        uut.Mem[21] = {uut.ADD, 5'b00000, 5'b00000, 5'b00000, 16'b0};  // NOP

        uut.Mem[22] = {uut.JMP, 26'h0017};  // Jump to location 0x17
        uut.Mem[23] = {uut.CALL, 26'h0018};  // Call subroutine at location 0x18
        uut.Mem[24] = {uut.RET,  26'b0};  // Return from subroutine

        // Return target and HALT
        uut.Mem[25] = {uut.ADD, 5'b00010, 5'b00011, 5'b00001, 16'b0};  // r1 = r2 + r3 (NOP equivalent)
        uut.Mem[26] = {uut.HLT, 26'b0};  // Halt the CPU
        
        // Dumpfile for waveform analysis
        $dumpfile("cpu_32_tb.vcd");
        $dumpvars(0, cpu_32_tb);
        
        // Dump key internal signals to VCD for GTKWave
        $dumpvars(1, uut.PC);
        $dumpvars(1, uut.IF_ID_IR);
        $dumpvars(1, uut.ID_EX_IR);
        $dumpvars(1, uut.EX_MEM_IR);
        $dumpvars(1, uut.MEM_WB_IR);
        $dumpvars(1, uut.ID_EX_A);
        $dumpvars(1, uut.ID_EX_B);
        $dumpvars(1, uut.EX_MEM_ALUOut);
        $dumpvars(1, uut.MEM_WB_ALUOut);
        $dumpvars(1, uut.MEM_WB_LMD);
        $dumpvars(1, uut.ID_EX_RegWrite);
        $dumpvars(1, uut.EX_MEM_RegWrite);
        $dumpvars(1, uut.MEM_WB_RegWrite);
        $dumpvars(1, uut.EX_MEM_cond);
        $dumpvars(1, uut.stall);
        $dumpvars(1, uut.Regs[1]);
        $dumpvars(1, uut.Regs[2]);
        $dumpvars(1, uut.Regs[3]);
        $dumpvars(1, uut.Regs[4]);
        $dumpvars(1, uut.Regs[7]);
        $dumpvars(1, uut.Regs[10]);

        // Run simulation for some time
        #200 $finish;
    end

    // Monitor signals for debugging
    initial begin
        $monitor("At time %t, PC = %h, Reg[1] = %h, Reg[4] = %h, Reg[7] = %h, Reg[10] = %h", 
                 $time, uut.PC, uut.Regs[1], uut.Regs[4], uut.Regs[7], uut.Regs[10]);
    end

endmodule
