# MIPS_32bit_CPU (Verilog 32-bit CPU Design)



## Introduction



This project is designed by Anubhav Singh Pawar as a self-project. The main objective of this project is to develop a 32-bit CPU using Verilog, incorporating various instructions and functionality, including arithmetic operations, logical operations, jumps, and memory access operations.



## Project Structure



The project contains the following files:



1. **cpu_32bit.v**: This file contains the Verilog code for the 32-bit CPU module.

2. **cpu_32_tb.v**: This file contains the test bench for the 32-bit CPU module to verify its functionality.

3. **README.md**: This file contains the project overview and instructions.



## Verilog CPU Design



### CPU Module (cpu_32bit.v)



The CPU module includes the following components:



- **Registers**:

  - **PC**: Program Counter

  - **SP**: Stack Pointer

  - **Regs**: General Purpose Registers

  - **Mem**: Memory



- **Pipeline Registers**:

  - **IF_ID_IR**, **IF_ID_PC**

  - **ID_EX_A**, **ID_EX_B**, **ID_EX_IMM**, **ID_EX_IR**, **ID_EX_PC**

  - **EX_MEM_ALUOut**, **EX_MEM_B**, **EX_MEM_IR**, **EX_MEM_cond**

  - **MEM_WB_ALUOut**, **MEM_WB_LMD**, **MEM_WB_IR**



- **Opcodes**:

  - **Arithmetic**: `ADD`, `SUB`, `MUL`, `DIV`, `INC`, `DEC`

  - **Logical**: `AND`, `OR`, `XOR`, `NOT`

  - **Control**: `JMP`, `BEQ`, `BNE`, `CALL`, `RET`

  - **Memory**: `LD`, `ST`

  - **Halt**: `HLT`



### Instruction Set



#### Arithmetic Instructions

1. **ADD r1, r2, r3**

   - **Description**: Add the values in registers `r2` and `r3`, and store the result in `r1`.

   - **Operation**: `r1 = r2 + r3`



2. **SUB r1, r2, r3**

   - **Description**: Subtract the value in register `r3` from the value in register `r2`, and store the result in `r1`.

   - **Operation**: `r1 = r2 - r3`



3. **MUL r1, r2, r3**

   - **Description**: Multiply the values in registers `r2` and `r3`, and store the result in `r1`.

   - **Operation**: `r1 = r2 * r3`



4. **DIV r1, r2, r3**

   - **Description**: Divide the value in register `r2` by the value in register `r3`, and store the result in `r1`.

   - **Operation**: `r1 = r2 / r3`



5. **INC r1**

   - **Description**: Increment the value in register `r1` by 1.

   - **Operation**: `r1 = r1 + 1`



6. **DEC r1**

   - **Description**: Decrement the value in register `r1` by 1.

   - **Operation**: `r1 = r1 - 1`



#### Logical Instructions

1. **AND r1, r2, r3**

   - **Description**: Perform a bitwise AND on the values in registers `r2` and `r3`, and store the result in `r1`.

   - **Operation**: `r1 = r2 & r3`



2. **OR r1, r2, r3**

   - **Description**: Perform a bitwise OR on the values in registers `r2` and `r3`, and store the result in `r1`.

   - **Operation**: `r1 = r2 | r3`



3. **XOR r1, r2, r3**

   - **Description**: Perform a bitwise XOR on the values in registers `r2` and `r3`, and store the result in `r1`.

   - **Operation**: `r1 = r2 ^ r3`



4. **NOT r1, r2**

   - **Description**: Perform a bitwise NOT on the value in register `r2`, and store the result in `r1`.

   - **Operation**: `r1 = ~r2`



#### Control Flow Instructions

1. **JMP addr**

   - **Description**: Jump to the specified address.

   - **Operation**: `PC = addr`



2. **BEQ r1, r2, addr**

   - **Description**: Branch to the specified address if the values in registers `r1` and `r2` are equal.

   - **Operation**: `if (r1 == r2) PC = addr`



3. **BNE r1, r2, addr**

   - **Description**: Branch to the specified address if the values in registers `r1` and `r2` are not equal.

   - **Operation**: `if (r1 != r2) PC = addr`



4. **CALL addr**

   - **Description**: Call a subroutine at the specified address.

   - **Operation**: `stack[SP] = PC + 1; SP = SP - 1; PC = addr`



5. **RET**

   - **Description**: Return from a subroutine.

   - **Operation**: `SP = SP + 1; PC = stack[SP]`



#### Memory Access Instructions

1. **LD r1, addr**

   - **Description**: Load the value from the specified memory address into register `r1`.

   - **Operation**: `r1 = memory[addr]`



2. **ST addr, r1**

   - **Description**: Store the value in register `r1` to the specified memory address.

   - **Operation**: `memory[addr] = r1`



### Test Bench (cpu_32_tb.v)



The test bench is designed to validate the functionality of the CPU module. It includes:



- Clock and reset signal generation.

- Initialization of memory and registers with test instructions and values.

- Monitoring key signals and generating a waveform file for analysis.

