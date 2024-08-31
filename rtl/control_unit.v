/**
 * @file control_unit.v
 * 
 * @brief
 * This module implements the control unit of a RISC-V processor. It handles the generation of control signals and controls the data path based on the current instruction. The control unit takes several inputs like the opcode, immediate values, register data, and outputs control signals to various components such as the ALU, memory, and the register file.
 * 
 * @details
 * The control unit is responsible for coordinating the execution of instructions by controlling the flow of data and signals within the processor. It manages the execution of ALU operations, memory reads/writes, register writes, and control flow instructions like jumps and branches. The module also includes logic for handling special cases like CSR operations, ecall, and ebreak.
 * 
 * @param clk          Inputs clock signal, which drives the control unit.
 * @param rst          Inputs reset signal, which initializes or resets the control unit.
 * @param rs1_input    Inputs value from the first source register (rs1).
 * @param rs2_input    Inputs value from the second source register (rs2).
 * @param imm          Immediate value associated with certain instructions.
 * @param mem_read     Data read from memory, used in load instructions.
 * @param out_signal   Decoded instruction signals that dictate the operation.
 * @param opcode       Opcode of the current instruction, used to determine the instruction type.
 * @param pc_input     Current program counter (PC) value.
 * @param ALUoutput    Result from the ALU operation.
 * @param csr_rdata    Data read from a Control and Status Register (CSR).
 * @param csr_addr     Address of the CSR to be accessed.
 * @param i_is_ebreak  Signal indicating whether the current instruction is an ebreak.
 * @param i_is_ecall   Signal indicating whether the current instruction is an ecall.
 * 
 * @return instructions Bus containing the instruction data for the ALU.
 * @return unsigned_rs1 The value of the first source register (rs1) sent to the ALU, potentially unsigned.
 * @return unsigned_rs2 The value of the second source register (rs2) sent to the ALU, potentially unsigned.
 * @return mem_write    Data to be written to memory during store operations.
 * @return wr_en        Write enable signal for memory operations.
 * @return addr         Address used in memory operations (load/store).
 * @return j_signal     Signal indicating a jump instruction is being executed.
 * @return jump         Target address for jump instructions.
 * @return final_output Data to be written back to the destination register.
 * @return wr_en_rf     Write enable signal for the register file.
 * @return csr_wr_data  Data to be written to a CSR.
 * @return csr_wr_en    Write enable signal for CSR operations.
 * @return csr_ren      Read enable signal for CSR operations.
 * 
 * @description
 * The `control_unit` module operates in several stages:
 * - **Initialization**: Sets default values for control signals.
 * - **ALU Operations**: Depending on the opcode and decoded instruction, it generates control signals for the ALU, selects the appropriate operands, and determines the final output.
 * - **Memory Operations**: Handles load and store instructions by controlling memory read/write operations, aligning data as needed based on the address offset.
 * - **Control Flow**: Manages jumps and branches by calculating target addresses and setting jump signals.
 * - **CSR Operations**: Controls access to CSRs, handling read and write operations.
 * - **Special Instructions**: Handles instructions like `ebreak` and `ecall` which require special processing.
 * 
 * @note 
 * The module assumes that all inputs are valid for the given clock cycle and that the ALU operations are performed synchronously with the clock. The control unit does not include pipeline logic, as it is designed for single-cycle operation.
 */

module control_unit (
    input               clk,
    input               rst,
    input               i_is_ebreak,
    input               i_is_ecall,
    input       [31:0]  rs1_input,
    input       [31:0]  rs2_input,
    input       [31:0]  imm,
    input       [31:0]  mem_read,
    input       [60:0]  out_signal,
    input       [06:0]  opcode,
    input       [31:0]  pc_input,
    input       [63:0]  ALUoutput,
    input       [31:0]  csr_rdata,
    input       [11:0]  csr_addr,

    output reg          j_signal,
    output reg          wr_en,
    output reg          csr_wr_en,
    output reg          csr_ren,
    output reg          wr_en_rf,
    output reg  [15:0]  instructions,
    output reg  [31:0]  unsigned_rs1,
    output reg  [31:0]  unsigned_rs2,
    output reg  [31:0]  mem_write,
    output reg  [31:0]  addr,
    output reg  [31:0]  jump,
    output reg  [31:0]  final_output,
    output reg  [31:0]  csr_wr_data

);




reg         memory_busy         = 0;
reg         fence_active        = 0;
reg         execute_instruction = 0;
reg [1:0]   mem_count           = 0;



initial begin 
	csr_wr_en       <= 0;
	csr_ren         <= 0;
	csr_wr_data     <= 0;
	memory_busy     <= 0;
	wr_en_rf        <= 0;
	wr_en           <= 0;
	j_signal        <= 0;
	instructions    <= 0;
	mem_write       <= 0;
	addr            <= 0;
	jump            <= 0;
	final_output    <= 0;
	unsigned_rs1    <= 0;
	unsigned_rs2    <= 0;
end




always@(*) begin
	if (wr_en == 0) mem_write <= 0;
	case(opcode)
		7'b0110011, 7'b0010011 : begin
			memory_busy     <= 0;
			csr_wr_en       <= 0;
			csr_ren         <= 0;
			j_signal <= 0;
			if (wr_en_rf == 0) wr_en_rf <= 1;

			case (out_signal)
				61'h1: begin
					instructions    <= 16'd1;
					unsigned_rs1    <= rs1_input;
					unsigned_rs2    <= rs2_input;
					final_output    <= ALUoutput;
				end


				61'h2: begin
					instructions    <= 16'd2;
					unsigned_rs1    <= rs1_input;
					unsigned_rs2    <= rs2_input;
					final_output    <= ALUoutput;
				end


				61'h4: begin
					instructions    <= 16'd4;
					unsigned_rs1    <= rs1_input;
					unsigned_rs2    <= rs2_input;
					final_output    <= ALUoutput;
				end


				61'h8: begin
					instructions    <= 16'd8;
					unsigned_rs1    <= rs1_input;
					unsigned_rs2    <= rs2_input;
					final_output    <= ALUoutput;
				end


				61'h10: begin
					instructions    <= 16'd16;
					unsigned_rs1    <= rs1_input;
					unsigned_rs2    <= rs2_input;
					final_output    <= ALUoutput;
				end


				61'h20: begin
					instructions    <= 16'd32;
					unsigned_rs1    <= rs1_input;
					unsigned_rs2    <= rs2_input;
					final_output    <= ALUoutput;
				end


				61'h40: begin
					instructions    <= 16'd64;
					unsigned_rs1    <= rs1_input;
					unsigned_rs2    <= rs2_input;
					final_output    <= ALUoutput;
				end


				61'h80: begin
					instructions    <= 16'd128;
					unsigned_rs1    <= rs1_input;
					unsigned_rs2    <= rs2_input;
					final_output    <= ALUoutput;
				end


				61'h100: begin
					instructions    <= 16'd256;
					unsigned_rs1    <= rs1_input;
					unsigned_rs2    <= rs2_input;
					final_output    <= ALUoutput;
				end


				61'h200: begin
					instructions    <= 16'd512;
					unsigned_rs1    <= rs1_input;
					unsigned_rs2    <= rs2_input;
					final_output    <= ALUoutput;
				end


				61'h400: begin
					instructions    <= 16'd1;
					unsigned_rs1    <= rs1_input;
					unsigned_rs2    <= imm;
					final_output    <= ALUoutput;
				end


				61'h800: begin
					instructions    <= 16'd4;
					unsigned_rs1    <= rs1_input;
					unsigned_rs2    <= imm;
					final_output    <= ALUoutput;
				end


				61'h1000: begin
					instructions    <= 16'd8;
					unsigned_rs1    <= rs1_input;
					unsigned_rs2    <= imm;
					final_output    <= ALUoutput;
				end


				61'h2000: begin
					instructions    <= 16'd16;
					unsigned_rs1    <= rs1_input;
					unsigned_rs2    <= imm;
					final_output    <= ALUoutput;
				end


				61'h4000: begin
					instructions    <= 16'd32;
					unsigned_rs1    <= rs1_input;
					unsigned_rs2    <= imm;
					final_output    <= ALUoutput;
				end


				61'h8000: begin
					instructions    <= 16'd64;
					unsigned_rs1    <= rs1_input;
					unsigned_rs2    <= imm;
					final_output    <= ALUoutput;
				end


				61'h10000: begin
					instructions    <= 16'd128;
					unsigned_rs1    <= rs1_input;
					unsigned_rs2    <= imm;
					final_output    <= ALUoutput;
				end


				61'h20000: begin
					instructions    <= 16'd256;
					unsigned_rs1    <= rs1_input;
					unsigned_rs2    <= imm;
					final_output    <= ALUoutput;
				end


				61'h40000: begin
					instructions    <= 16'd512;
					unsigned_rs1    <= rs1_input;
					unsigned_rs2    <= imm;
					final_output    <= ALUoutput;
				end


				61'h2000000000 : begin
					instructions    <= 16'd1024; 
					unsigned_rs1    <= rs1_input;
					unsigned_rs2    <= rs2_input;
					final_output    <= ALUoutput[31:0];
				end


				61'h4000000000 : begin
					if (rs1_input[31]   == 1 && rs2_input[31] == 1)     final_output[31] <= 1'b0;

					if (rs1_input[31]   == 1 || rs2_input[31] == 1)     final_output[31] <= 1'b1;

					if              (rs1_input[31]   == 1)              unsigned_rs1 <= ~rs1_input + 1;
					else                                                unsigned_rs1 <= rs1_input;

					if              (rs2_input[31]   == 1) 		    	unsigned_rs2 <= ~rs2_input + 1;
					else                       						    unsigned_rs2 <= rs2_input;

                    instructions        <= 16'd1024;
					final_output[30:0]  <= ALUoutput[62:32];
				end


				61'h8000000000 : begin
					instructions        <= 16'd1024; 
					final_output[31]    <= rs1_input[31];
					unsigned_rs1                  <= ~rs1_input + 1;
					unsigned_rs2                  <= rs2_input;
					final_output[30:0]  <= ALUoutput[62:32];
				end


				61'h10000000000 : begin
					instructions        <= 16'd1024; //!mulhu
					unsigned_rs1                  <= rs1_input;
					unsigned_rs2                  <= rs2_input;
                    final_output        <= ALUoutput[63:32];
				end


				
				61'h20000000000 : begin
					instructions <= 16'd2048; //!div
					if (rs1_input[31] == 1 && rs2_input[31] == 1)   final_output[31] <= 1'b0;

					if (rs1_input[31] == 1 || rs2_input[31] == 1)   final_output[31] <= 1'b1;		

					if          (rs1_input[31] == 1)                unsigned_rs1 <= ~rs1_input + 1;
					else                    						unsigned_rs1 <= rs1_input;

					if          (rs2_input[31] == 1)               	unsigned_rs2 <= ~rs2_input + 1;
					else begin
                                                                    unsigned_rs2 <= rs2_input;
                                                                    final_output[30:0] <= ALUoutput[30:0];
                    end
				end


				61'h40000000000 : begin

					instructions        <= 16'd2048; 
					unsigned_rs1                  <= rs1_input;
					unsigned_rs2                  <= rs2_input;
					final_output        <= ALUoutput[31:0];
				end


				
				61'h80000000000 : begin
					instructions        <= 16'd4096; 
					if (rs1_input[31] == 1 && rs2_input[31] == 1) final_output[31] <= 1'b0;
					if (rs1_input[31] == 1 || rs2_input[31] == 1) final_output[31] <= 1'b1;
					if (rs1_input[31] == 1) begin
						unsigned_rs1              <= ~rs1_input + 1;
					end else begin
						unsigned_rs1              <= rs1_input;
					end
					if (rs2_input[31] == 1) begin
						unsigned_rs2              <= ~rs2_input + 1;
					end else begin
						unsigned_rs2              <= rs2_input;
					end
					final_output[30:0]  <= ALUoutput[30:0];
				end


				61'h100000000000 : begin
					instructions        <= 16'd4096; 
					unsigned_rs1                  <= rs1_input;
					unsigned_rs2                  <= rs2_input;
					final_output        <= ALUoutput[31:0];
				end


			endcase
		end 


        7'b0000011 : begin                                                                       
            addr        <= rs1_input[imm[11:0] +: 32];																						
            mem_count   <= addr % 4;
            wr_en_rf    <= 0;
            wr_en       <= 0;
            csr_wr_en   <= 0;
            csr_ren     <= 0;
            if(j_signal==1) j_signal<=0;			                                         
			if(wr_en==1)    wr_en<=0;


            case(out_signal) 
                61'h80000 : begin
                    case (mem_count)
                        2'b00:begin
                            final_output    <= { {24{mem_read[7]}}, mem_read[7:0]}; 
                            memory_busy     <= 1;
                        end                       			
                        2'b01: begin
                            final_output    <= { {24{mem_read[15]}}, mem_read[15:8]};
                            memory_busy     <= 1;
                        end
                        2'b10: begin
                            final_output    <= { {24{mem_read[23]}}, mem_read[23:16]};
                            memory_busy     <= 1;
                        end
                        2'b11: begin
                            final_output    <= { {24{mem_read[31]}},  mem_read[31:24]};
                            memory_busy     <= 1;
                        end
                    endcase
                end        


				61'h100000 :begin
                    case (mem_count)
                        2'b00: begin
                            final_output    <= { {16{mem_read[15]}}, mem_read[15:0]};   
                            memory_busy     <= 1;
                        end              										
                        2'b10: begin
                            final_output    <= { {16{mem_read[31]}}, mem_read[31:16]};
                            memory_busy     <= 1;
                        end
                    endcase
                    end
                

                61'h200000 : begin
                    final_output    <= mem_read[31:0];                                      
                    memory_busy     <= 1;
                end


				61'h400000 :begin
                    case (mem_count)
                        2'b00: begin 
                            final_output  <= mem_read[7:0];                                        
                            memory_busy   <= 1;
                        end
                        2'b01: begin 
                            final_output  <= mem_read[15:8];
                            memory_busy   <= 1;
                        end
                        2'b10: begin
                            final_output  <= mem_read[23:16];
                            memory_busy   <= 1;
                        end
                        2'b11: begin 
                            final_output  <= mem_read[31:24];
                            memory_busy   <= 1;
                        end
                    endcase
				end


				61'h800000 :begin
					case(mem_count)
						2'b00: begin
							final_output  <= mem_read[15:0]; 
							memory_busy   <= 1;
						end                                      
						2'b10: begin 
							final_output  <= mem_read[31:16];
							memory_busy   <= 1;
						end
					endcase
				end

			endcase        
        end

        7'b0100011 : begin
			addr            <= rs1_input + imm;                                                               
            wr_en           <= 2'b1;                                                                         
            mem_count       <= addr % 4;
			wr_en_rf        <= 0;
			csr_wr_en       <= 0;
			csr_ren         <= 0;
			if(j_signal==1) j_signal<=0;

            case(out_signal)

                61'h1000000 :begin
                    case(mem_count)
                        2'b00: begin 
                            mem_write   <= {mem_read[31:8], rs2_input[7:0]};                                      
                            memory_busy <= 1;
                        end
                        2'b01: begin 
                            mem_write   <= { mem_read[31:16],  rs2_input[7:0], mem_read[7:0]};
                            memory_busy <= 1;
                        end
                        2'b10: begin
                                mem_write   <= { mem_read[31:24], rs2_input[7:0], mem_read[15:0]};
                                memory_busy <= 1;
                        end
                        2'b11: begin 
                            mem_write   <= { rs2_input[7:0], mem_read[23:0]};
                            memory_busy <= 1;
                        end
                    endcase
                end

                61'h2000000 :begin
                    case(mem_count)
                        2'b00: begin
                            mem_write   <= {mem_read[31:16], rs2_input[15:0]};                                     
                            memory_busy <= 1;
                        end
                        2'b10: begin
                            mem_write   <= { rs2_input[15:0], mem_read[15:0]};
                            memory_busy <= 1;
                        end
                    endcase
                end      

                61'h4000000 : begin 
                    mem_write   <= rs2_input[31:0];													
                    memory_busy <= 1;
                end

            endcase

        end

        7'b1100011 :begin    																								
			memory_busy <= 0;  
			wr_en_rf    <= 1;
			csr_wr_en   <= 0;
			csr_ren     <= 0;


			case(out_signal)
				61'h8000000 :begin
					if  (rs1_input == rs2_input) begin 
						jump        <= pc_input + 	{{20{imm[12]}},imm[12:1],1'b0};                                                    
                    	j_signal    <= 2'b1;   
            		end else begin
						j_signal    <= 2'b0;
					end
                end		
                																		   
				61'h10000000 :begin
					if  (rs1_input != rs2_input) begin 
						jump        <= pc_input +	{{20{imm[12]}},imm[12:1],1'b0};                                                    
						j_signal    <= 2'b1;
					end	else begin
						j_signal    <= 2'b0;
					end
				end			
                															          			 
                61'h20000000 :begin
                    if  (rs1_input < rs2_input) begin 
						jump        <= pc_input +	{{20{imm[12]}},imm[12:1],1'b0};                                                  
						j_signal    <= 2'b1;   
					end else begin
						j_signal    <= 2'b0;
					end
					if(wr_en==1)    wr_en<=0;
				end					
                													         
				61'h40000000 :begin
					if  (rs1_input >= rs2_input) begin 
						jump        <= pc_input +	{{20{imm[12]}},imm[12:1],1'b0};                                                    
						j_signal    <= 2'b1;   
                    end else begin
						j_signal    <= 2'b0;
					end
					if(wr_en==1)    wr_en<=0;
				end				
                														           
                61'h80000000 :begin
					if(rs1_input < rs2_input) begin 
						jump        <= pc_input +	{{20{imm[12]}},imm[12:1],1'b0};                                                   
						j_signal    <= 2'b1;   
					end
					else begin
						j_signal    <= 2'b0;
					end
					if(wr_en==1)    wr_en<=0;
				end			

                61'h100000000 :begin
					if(rs1_input >= rs2_input) begin 
						jump        <= pc_input +	{{20{imm[12]}},imm[12:1],1'b0};                                                  
                        j_signal    <= 2'b1;   
                    end else begin
						j_signal    <= 2'b0;
					end
					if(wr_en==1)    wr_en<=0;
                  end																		     
			endcase
        end


        7'b1101111 : begin
			memory_busy <= 0;
			wr_en_rf    <= 1;
			csr_wr_en   <= 0;
			csr_ren     <= 0;
		if(out_signal == 61'h200000000) begin   						
            jump            <= pc_input + imm;
            j_signal        <= 1;  
            final_output    <= pc_input + 4;
            end 
			if  (wr_en==1)  wr_en<=0;
        end

        7'b1100111 : begin                                                                         
		memory_busy <= 0;
		wr_en_rf    <= 1;
		csr_wr_en   <= 0;
		csr_ren     <= 0;
		if(out_signal == 61'h400000000) begin			
				jump        <= rs1_input + imm;
				j_signal    <= 1;  
            final_output    <= pc_input + 4; 
            end
			if  (wr_en==1)  wr_en<=0;
        end

		7'b0110111 : begin
			memory_busy <= 0;
			csr_wr_en   <= 0;
			csr_ren     <= 0;
			wr_en_rf    <= 1;
			if  (j_signal==1)                 j_signal        <=  0;
			if  (out_signal == 61'h800000000) final_output    <=  {imm[31:12],12'b0};                                                          
			if  (wr_en==1)                    wr_en           <=  0;
        end

        7'b0010111 : begin
			memory_busy <= 0;
			wr_en_rf    <= 1;
			csr_wr_en   <= 0;
			csr_ren     <= 0;
			if  (j_signal==1)     j_signal<=0;
		    if  (out_signal == 61'h200000000000) final_output    <=   pc_input + {imm[31:12],12'b0};                          
			if  (wr_en==1)    wr_en<=0;				
	  	end      


	7'b0101111 : begin
		wr_en_rf    <= 0;
		csr_wr_en   <= 0;
		csr_ren     <= 0;
		case(out_signal)
			61'h800000000000 : begin      //AMOSWAP
				instructions    <= 16'd8192;
			        unsigned_rs1          <= mem_read;
			        unsigned_rs2          <= rs2_input;
			    final_output    <= mem_read;
			    mem_write       <= ALUoutput;
			    addr            <= rs1_input;
			    wr_en           <= 1;
			    wr_en_rf        <= 1;
				memory_busy     <= 1'b1;
			end 
			61'h1000000000000 : begin   //AMOADD.W
				instructions    <= 16'd1;
				unsigned_rs1              <= mem_read;
				unsigned_rs2              <= rs2_input;
				final_output    <= mem_read;
				mem_write       <= ALUoutput;
				addr            <= rs1_input;
				wr_en           <= 1;
				wr_en_rf        <= 1;
				memory_busy     <= 1;
			end 
			61'h2000000000000: begin     //AMOAND.W
				instructions    <= 16'd16;
				unsigned_rs1              <= mem_read;
				unsigned_rs2              <= rs2_input;
				final_output    <= mem_read;
				mem_write       <= ALUoutput;
				addr            <= rs1_input;
				wr_en           <= 1;
				wr_en_rf        <= 1;
				memory_busy     <= 1;
			end 
			61'h4000000000000 : begin     //AMOOR.W
				instructions    <= 16'd8;
				unsigned_rs1              <= mem_read;
				unsigned_rs2              <= rs2_input;
				final_output    <= mem_read;
				mem_write       <= ALUoutput;
				addr            <= rs1_input;
				wr_en           <= 1;
				wr_en_rf        <= 1;
				memory_busy     <= 1;
			end 
		    61'h8000000000000 : begin     //AMOXOR.W
				instructions    <= 16'd4;
				unsigned_rs1              <= mem_read;
				unsigned_rs2              <= rs2_input;
				final_output    <= mem_read;
				mem_write       <= ALUoutput;
				addr            <= rs1_input;
				wr_en           <= 1;
				wr_en_rf        <= 1;
				memory_busy     <= 1;
			end 
			61'h10000000000000  : begin     //AMOMAX.W
				instructions    <= 16'd16384;
				unsigned_rs1              <= mem_read;
				unsigned_rs2              <= rs2_input;
				final_output    <= mem_read;
				mem_write       <= ALUoutput;
				addr            <= rs1_input;
				wr_en           <= 1;
				wr_en_rf        <= 1;
				memory_busy     <= 1;
			end 
			61'h20000000000000 : begin     //AMOMIN.W
				instructions    <= 16'd32768;
				unsigned_rs1              <= mem_read;
				unsigned_rs2              <= rs2_input;
				final_output    <= mem_read;
				mem_write       <= ALUoutput;
				addr            <= rs1_input;
				wr_en           <= 1;
				wr_en_rf        <= 1;
				memory_busy     <= 1;
			end 
		endcase
	end

	7'b1110011 : begin
		csr_wr_en <= 1;
		csr_ren <= 1;
		wr_en_rf <= 1;
		case(out_signal)

			61'h40000000000000  :   begin        //csrrw
                if (csr_addr != 12'h0) begin
                    final_output    <= csr_rdata;
                    csr_wr_data     <= rs1_input;
                end
			end
			61'h80000000000000  :   begin	    //csrrs
                if (csr_addr != 12'h0) begin
                    final_output    <= csr_rdata;
                    csr_wr_data     <= csr_rdata | rs1_input;
                end
			end
			61'h100000000000000 :   begin	    //csrrc
                if (csr_addr != 12'h0) begin							
                    final_output    <= csr_rdata;
                    csr_wr_data     <= csr_rdata & ~rs1_input;
                end
			end
			61'h200000000000000 :   begin		//csrrwi
                if (csr_addr != 12'h0) begin
                    final_output    <= csr_rdata;
                    csr_wr_data     <= imm;
                end
			end
			61'h400000000000000 :   begin		//csrrsi
                if (csr_addr != 12'h0) begin
                    final_output    <= csr_rdata;
                    csr_wr_data     <= csr_rdata | imm;
                end
			end
			61'h800000000000000 :   begin		//csrrci
                if (csr_addr != 12'h0) begin
                    final_output    <= csr_rdata;
                    csr_wr_data     <= csr_rdata & ~imm;
                end
			end
		endcase
	end


    7'b0001111 : begin
		if (out_signal == 61'h1000000000000000) begin     
			fence_active    <= 1'b1;
		end
	end
    endcase
end


endmodule
