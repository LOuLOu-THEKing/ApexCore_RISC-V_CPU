/**
 * @file csr.v
 *
 * This module implements the Control and Status Register (CSR) logic for a RISC-V processor.
 * It handles the reading, writing, and management of CSRs, including trap handling and status registers.
 * 
 * @input clk             Clock signal.
 * @input rst             Reset signal.
 * @input csr_wr_en       CSR write enable signal.
 * @input csr_ren         CSR read enable signal.
 * @input addr            Address of the CSR to be accessed.
 * @input wr_data         Data to be written to the CSR.
 * @input i_is_ebreak     Indicates if the current instruction is an ebreak.
 * @input i_is_ecall      Indicates if the current instruction is an ecall.
 *
 * @output rdata          Data read from the CSR.
 * @output trap_detected  Indicates if a trap has been detected.
 * 
 * @internal csr_data          4 KB CSR space indexed by a 12-bit address.
 * @internal go_to_trap        Signal to indicate the processor should go to trap mode.
 * @internal return_from_trap  Signal to indicate the processor is returning from trap mode.
 * @internal mstatus_mie       Machine Interrupt Enable bit in MSTATUS register.
 * @internal mstatus_mpie      Machine Previous Interrupt Enable bit in MSTATUS register.
 * @internal mstatus_mpp       Machine Previous Privilege mode bits in MSTATUS register.
 * @internal mie_meie          Machine External Interrupt Enable bit in MIE register.
 * @internal mie_mtie          Machine Timer Interrupt Enable bit in MIE register.
 * @internal mie_msie          Machine Software Interrupt Enable bit in MIE register.
 * @internal mcause_bit        Interrupt (1) or Exception (0) indicator in MCAUSE register.
 * @internal mcause_event      Indicates the event that caused the trap in MCAUSE register.
 * @internal MVENDORID         CSR address for Vendor ID.
 * @internal MARCHID           CSR address for Architecture ID.
 * @internal MIMPID            CSR address for Implementation ID.
 * @internal MHARTID           CSR address for Hardware Thread ID.
 * @internal MSTATUS           CSR address for Machine Status.
 * @internal MISA              CSR address for ISA and Extensions.
 * @internal MIE               CSR address for Machine Interrupt Enable.
 * @internal MTVEC             CSR address for Trap Vector Base Address.
 * @internal MSCRATCH          CSR address for Scratch register.
 * @internal MEPC              CSR address for Exception Program Counter.
 * @internal MCAUSE            CSR address for Cause of Trap.
 * @internal MTVAL             CSR address for Trap Value.
 * @internal MIP               CSR address for Machine Interrupt Pending.
 * @internal ECALL             Local parameter indicating ecall event in MCAUSE.
 * @internal EBREAK            Local parameter indicating ebreak event in MCAUSE.
 */

module csr (
    input wire          clk,                    
    input wire          rst,                     
    input wire          csr_wr_en,               
    input wire          csr_ren,                
    input wire  [11:0]  addr,                   
    input wire  [31:0]  wr_data,                
    output wire [31:0]  rdata,                  
    input wire          i_is_ebreak,             
    input wire          i_is_ecall,             
    output reg          trap_detected           
);

reg [31:0] csr_data [0:4095];                  
reg        go_to_trap;                         
reg        return_from_trap;                   
reg        mstatus_mie;                      
reg        mstatus_mpie;                       
reg [1:0]  mstatus_mpp;                         
reg        mie_meie;                         
reg        mie_mtie;                         
reg        mie_msie;                          
reg        mcause_bit;                       
reg [3:0]  mcause_event;                      

/* Local parameter definitions for CSR addresses and trap events */
localparam    MVENDORID = 12'hF11,  
               MARCHID = 12'hF12,
               MIMPID = 12'hF13,
               MHARTID = 12'hF14,
               
               MSTATUS = 12'h300, 
               MISA = 12'h301,
               MIE = 12'h304,
               MTVEC = 12'h305,
               
               MSCRATCH = 12'h340, 
               MEPC = 12'h341,
               MCAUSE = 12'h342,
               MTVAL = 12'h343,
               MIP = 12'h344;

localparam     ECALL = 11,                    
               EBREAK = 3;                    

/* Initialization of registers used in the always block */
initial begin 
    trap_detected   <= 0;       
    mstatus_mie     <= 0;
    mstatus_mpie    <= 0;
    mstatus_mpp     <= 2'b11;
    mie_meie        <= 0;
    mie_mtie        <= 0;
    mie_msie        <= 0;
    mcause_bit      <= 0;
    mcause_event    <= 0;
end 

assign rdata    =   csr_ren ? csr_data[addr] : 0;
    
always @ (posedge clk) begin

   if (csr_wr_en == 1) csr_data[addr]  <=  wr_data;
 /*   case(addr)

        MVENDORID   :   csr_data[3856] = 32'h0;  
        MARCHID     :   csr_data[3857] = 32'h0; 
        MIMPID      :   csr_data[3858] = 32'h0; 
        MHARTID     :   csr_data[3859] = 32'h0;              
                 
        MSTATUS : begin                             
            csr_data[03] = mstatus_mie;
            csr_data[07] = mstatus_mpie;
            csr_data[12] = mstatus_mpp[1];
            csr_data[11] = mstatus_mpp[0]; 
        end
                        
        MISA    : begin                                
            csr_data[08] = 1'b1;
            csr_data[31] = 1'b0; 
            csr_data[30] = 1'b1;
        end 
                        
        MIE     : begin                                 
            csr_data[03] = mie_msie;
            csr_data[07] = mie_mtie;
            csr_data[11] = mie_meie;
        end

        MCAUSE  : begin                              
            csr_data[31] = mcause_bit; 
            csr_data[03] = mcause_event[3];
            csr_data[02] = mcause_event[2];
            csr_data[01] = mcause_event[1];
            csr_data[00] = mcause_event[0];
        end
    endcase 

*/
    if(addr == MSTATUS) begin                                          
        mstatus_mie     <= rdata[3];
        mstatus_mpie    <= rdata[7];
        mstatus_mpp     <= rdata[12:11];
    end 
    else begin
        if(go_to_trap && !trap_detected) begin
            mstatus_mie     <= 0; 
            mstatus_mpie    <= mstatus_mie; 
            mstatus_mpp     <= 2'b11;
        end
        else if(return_from_trap) begin
            mstatus_mie     <= mstatus_mpie; 
            mstatus_mpie    <= 1;
            mstatus_mpp     <= 2'b11;
        end
    end

  
    if(addr == MIE) begin   
        mie_msie    <= rdata[3]; 
        mie_mtie    <= rdata[7]; 
        mie_meie    <= rdata[11]; 
    end  

    
    if(addr == MCAUSE) begin
        mcause_bit      <= rdata[31];
        mcause_event    <= rdata[3:0];         
    end

    if(go_to_trap && !trap_detected) begin
        if(i_is_ecall) begin
            mcause_event    <= ECALL;
            mcause_bit      <= 0;
        end
        if(i_is_ebreak) begin
            mcause_event    <= EBREAK;
            mcause_bit      <= 0;
        end
    end
end
endmodule
