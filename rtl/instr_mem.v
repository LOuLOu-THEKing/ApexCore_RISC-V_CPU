/**
 * @file instr_mem.v
 * This module works as a memory module for instructions to get stored.
 *
 * @param DATA_WIDTH Width of the data in bits (default: 32)
 * @param ADDR_WIDTH Width of the address in bits (default : 32)
 * @param MEM-SIZE   Number of words in memory (default : 512)
 *
 * @input instr_addr Address input for fetching an instruction.
 * 
 * @output instr     Output instruction corresponding to the address.
 */


module instr_mem #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 32, MEM_SIZE = 512) (
    input       [ADDR_WIDTH-1:0] instr_addr,
    output      [DATA_WIDTH-1:0] instr
);

reg [DATA_WIDTH-1:0]    instr_ram [0:MEM_SIZE-1];
initial                 $readmemh({"/home/shrivishakh/project_1/project_1.sim/sim_1/behav/xsim/program_dump.hex"}, instr_ram);
assign instr    =       instr_ram[instr_addr[31:2]];

endmodule
