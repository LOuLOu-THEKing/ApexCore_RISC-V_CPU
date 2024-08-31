## INTRODUCTION : 

 - This project is a part of the Eklavya Mentorship Programme organized by the Society of Robotics and Automation (SRA) at VJTI, Mumbai. The project is based on improving the functionality of a CPU core. This project covers domains of computer architecture, FPGA, and digital design.
 - This project has been done to understand the Field Programmable Logic Arrays (FPGAs) and how the functionality of CPU cores can be improved using them. Additionally, the architecture that we have used is projected to become important and in-demand in the coming years. 


## Project Overview: 

 - This project is about improving the capabilities of the CPU core by adding extensions. Extensions consist of the instructions that are needed for doing a specific computation task. Each core is based on an architecture that defines these extensions and instructions. We used Reduced Instruction Set Architecture (RISC-V) as it is free and open source, unlike x86 and ARM, which require a licensing fee. 



## General details: 

This project has been done under the Eklavya Mentorship Programme by: 


 - Aditya Sundar Mahajan    (Second Year: Electronics Engineering)     |     [Github](https://github.com/aditya200523)



 - Shri Vishakh Devanand     (Second Year: Electrical Engineering)     |     [Github](https://github.com/LOuLOu-THEKing)


## Project Repository: [APEXCORE](https://github.com/LOuLOu-THEKing/ApexCore_RISC-V_CPU)

### TECHNOLOGY STACK 

 - This project is essentially based on two main things: Field Programmable Logic Arrays (FPGAs) and Computer Architecture. 
Computer architecture refers to the design and organization of a computer's components and systems, defining how hardware and software interact to achieve processing tasks. It encompasses the structure of the CPU, memory hierarchy, data paths, and input/output systems.

 - A FPGA is a hardware device that consists of an array of logic blocks that can be programmed to implement custom circuits and systems. They can be reprogrammed anytime to meet necessary requirements. The FPGA architecture typically includes logic cells, multiplexers, and I/O blocks, enabling complex computations and parallel processing.
We used an Arty A7 35T FPGA from Xilinx.

 - Xilinx Vivado Ecosystem: We used the Vivado software by Xilinx to program the extensions and necessary modules. This was used to simulate the codes and finally for bitstream generation to be flashed onto the FPGA. 

 - EDA Playground and makerchip.io: We used makerchip.io to program a RISC-V core in TL-Verilog as part of Steeven Hoover’s EdX course. Additionally, we used an EDA-playground simulator to understand the language. 

 - RISC-V stands for Reduced Instruction Set Architecture, which is the most important part of the project. This was developed at the University of Berkeley. The core is based on this architecture, and the primary reason is that it is free and open-source. This consists of a set of instructions and extensions defining all the operations and computations. 


---



### EXTENSIONS AND INSTRUCTIONS

- We implemented multiplication (M) extension and atomic (A) extension as defined by the RISC-V architecture. The M extension is for integer multiplication and division. Atomic Extension is used to change values at a memory location. It ensures that a task completes in a single, uninterrupted step for avoiding race conditions and ensuring data consistency.
 
#### Instructions in M extension:

      
| INSTRUCTION |               DESCRIPTION                                 |
| ----------- | --------------------------------------------------------- |
|     MUL     |Multiply 2 integers and store the lower portion.           |
|     MULH    |Multiply 2 integers and store the upper portion.           | 
|     MULHSU  |Multiply signed and unsigned and store the upper portion.  |
|     MULHU   |Multiply two unsigned and store the upper portion.         |
|     DIV     |Divide 2 integers and store the quotient.                  |
|     DIVU    |Divide 2 unsigned and store the quotient.                  |
|     REM     |Store the remainder.                                       |
|     REMU    |Store the remainder of two unsigned integers.              |

 


#### Instructions in Atomic Extension: 
 
| INSTRUCTION               |                          DESCRIPTION                                                            |
| ------------------------- | ----------------------------------------------------------------------------------------------- |
| AMOSWAP.W                 |This instruction swaps a value in the memory with a new value and returns the original value.    |
| AMOADD.W                  |This instruction adds a value to memory and returns the original value.                          |
| AMOAND.W AMOOR.W AMOXOR.W |These are used to perform bitwise operations on memory locations.                                |

---
---

### CONTROL AND STATUS REGISTERS

In the RISC-V computer architecture, Control and Status Registers (CSRs) are special registers used to manage and monitor the computer's operations, ensuring that the operations run efficiently. These are the tools that help the computer control its various functions and keep track of its status.
Control registers are used to enable and disable signals that tell the computer about an event that is interrupting its processes. It handles the interrupts. 
Status registers are used to provide information about the CPU's current state.



#### CSRs that have been implemented:
| INSTRUCTION                       |                   DESCRIPTION                                                         |
| --------------------------------- | ------------------------------------------------------------------------------------- |
| mstatus (Machine Status Register) |This CSR controls the core’s operating mode.                                           |
| mcause (Machine Cause Register)   |This CSR provides a reason for exceptions and interrupts.                              |
| mie (machine interrupt enabled)   |This CSR controls which interrupt is allowed to interrupt the core at machine level.   |
| misa (Machine ISA Register)       |Gives information about current extensions and instructions executing in the core.     |
 
---
### INPUT AND OUTPUT CAPABILITY: 

 - Implemented memory segmentation in the data memory module to allocate a separate memory space for general purpose input-output (GPIO) and program instructions.
 - Created a GPIO_controller module to handle input and output data from core to pins. 
 - By doing so, we created a single memory unit with two more extra buses for memory instead of two modules.


---
### CONTRIBUTION :

 - This project was completed in a fixed timeframe of 2 months as a part of the Eklavya Programme. Below are detailed points that explain the entire journey of the project:

---
#### Week 1 and 2 (Learning Phase) 
 
 - The Ekalavya program started with Steeve Hoover’s RISC-V Core using the TL-Verilog course on the EdX platform. This course helped us to understand the basics of computer architecture and RISC-V instructions. 
 - The next target was to start coding small circuits like Half-Adder, Counter in TL-Verilog, and finally the RISC-V core. All these things were done on the makerchip.io website. 
 - After completing the EdX course, we decided to start learning the Verilog language. To accomplish this, we referred to two resources. ChipVerify for theory and HDLbits for questions
We covered wires and regs, combinational circuits, sequential circuits, and finite state machines (FSM). 

---
#### WEEK 3 (Frequency Task and Understanding RTL) 

 - This week was entirely focused on working on a frequency divider code. The task was about converting a higher frequency to a lower frequency. Through this code, we revised the verilog syntax.
 - After completing the task, we began learning the actual things from the existing RISC-V repository. This was the most crucial phase, as we were understanding how the core is working and the exact purpose of each module.

---
#### WEEK 4 (Repository RTL and RISC-V ISA resource) 
 
 - After understanding the existing RTL, we were given a task to think about how it can be optimized. Initially, we could not figure out exactly how to optimize, but then realized about certain points: 
 - Avoiding the signal of immediate value to be given to ALU. The purpose of ALU is to only do arithmetic operations, and it has nothing to do with the type of the inputs. So, we decided to give only RS1 and RS2 inputs rather than making ALU differentiate normal values from immediate ones. Reduced the bus between ALU and control unit to 16 bits. 
 - The correct use of assign statements and if-else statements as they lead to the use of multiplexers that increase the overall cost of core.
 
 - We then started referring to the RISC-V Instruction brochure and other resources from RISC-V to understand the RISC instructions and types and how the extensions are to be implemented in the core.
 
#### WEEK 5 (Multiplication (M) Extension) COMMIT (After hardware testing M extension)
 
 - This week was dedicated to understanding the M-extension and implementing the same in the core. After understanding the instructions, we added the necessary operations in ALU. We then expanded the decoder to include those instructions and then changed the control unit to support the changes. 
 
#### WEEK 6 (Atomic Extension)  COMMIT
 - This week was entirely focused on implementing the Atomic Extension instructions. We accomplished changing the RTL in a short span of time, as we had received a great deal of experience from the past week. 
 - But we faced multiple problems while testing the extension. The main reason was the fetch instruction in assembly, which was not allowing the actual execution of the instruction. After researching the problem and meeting with mentors, we realized the importance of control and status registers that were scheduled for the next week.
 
#### WEEK 7 (Control and Status Registers) COMMIT
 - We began with a number of Youtube videos that were all about the CSRs. This includes topics related to interrupts and traps. John’s Basement Channel helped us a lot. We then created a CSR module and did the corresponding changes in other modules. 


#### WEEK 8 (Input-Output)  COMMIT
 - This week was focused on working on memory partitioning of data memory to create a separate memory location for input and output streams and for program instruction. We then created the GPIO controller module and started working on how to test it. By doing so, we created a single memory module with two extra buses instead of two different modules. 


---
### CONCLUSION :

 - Through this project, we implemented the multiplication and atomic extensions. We also implemented control and status registers (CSRs) and worked on memory segmentation for input-output functionality. 
 - We tested the Multiplication Extension on the FPGA by using factorial series, which requires the use of basic multiplication operations. 
We performed the simulations for atomic extension, CSRs, and IO in Vivado. 
 
---

### PENDING TASKS 

 - Working more on atomic extensions and CSRs and finally testing them directly on the FPGA. 
 - Completing the input-output functionality to support a wide range of hardware devices. 


---

### Future Goals:
- [ ] Interrupt handling.
- [ ] UART implmentation.
- [ ] Implementation of remaining extensions.

---

### ACKNOWLEDGEMENT :
 - This project saw the daylight due to the mentorship program of Eklavya by SRA-VJTI, whose members helped me on every obstacle that ultimately shaped this project.
 - Our entire project went under the guidance of our mentors, Atharva Kashalkar and Saish Karole. They are the reason why this project was developed on such a scale in such a short amount of time.


 - The Society of Robotics and Automation (SRA) community of VJTI has created a nice ecosystem to grow and learn something new and to explore various domains. 
 - From having weekly update meetings and doubt sessions, our mentors took efforts to see if we didn't go off track during this entire program. The edX course and various resources across the internet helped us to clear our doubts.

