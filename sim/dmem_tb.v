`timescale 1ns / 1ps

module data_mem_tb;

    // Parameters
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 32;
    parameter MEM_SIZE   = 64;
    parameter GPIO       = 100;

    // Inputs
    reg clk;
    reg wr_en;
    reg [ADDR_WIDTH-1:0] wr_addr;
    reg [DATA_WIDTH-1:0] wr_data;

    // Outputs
    wire [DATA_WIDTH-1:0] rd_data_mem;
    
    // Inouts
    wire [GPIO-1:0] gpio_pins;

    // Instantiate the data_mem module
    data_mem #(DATA_WIDTH, ADDR_WIDTH, MEM_SIZE, GPIO) uut (
        .clk(clk),
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .rd_data_mem(rd_data_mem),
        .gpio_pins(gpio_pins)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    initial begin
        // Initialize inputs
        wr_en   = 0;
        wr_addr = 0;
        wr_data = 0;

        // Wait for global reset
        #100;

        // Test 1: Read from instruction memory
        wr_addr = 32'h02000000; // Address within instruction memory range
        #10;
        $display("Instruction Memory Read: Addr=0x%h, Data=0x%h", wr_addr, rd_data_mem);

        // Test 2: Write to data memory and read back
        wr_en   = 1;
        wr_addr = 32'h02000000; // Address within data memory range
        wr_data = 32'hDEADBEEF;
        #10;
        wr_en   = 0; // Disable write enable
        #10;
        $display("Data Memory Write/Read: Addr=0x%h, Data=0x%h", wr_addr, rd_data_mem);

        // Test 3: Write to GPIO and read back
        wr_en   = 1;
        wr_addr = 32'h020000F0; // Address within GPIO range
        wr_data = 32'hA5A5A5A5;
        #10;
        wr_en   = 0; // Disable write enable
        #10;
        $display("GPIO Write/Read: Addr=0x%h, Data=0x%h", wr_addr, rd_data_mem);

        // Test 4: Read from data memory with no write enable
        wr_addr = 32'h02000000; // Address within data memory range
        #10;
        $display("Data Memory Read: Addr=0x%h, Data=0x%h", wr_addr, rd_data_mem);

        // Test 5: Read from GPIO with no write enable
        wr_addr = 32'h020000F0; // Address within GPIO range
        #10;
        $display("GPIO Read: Addr=0x%h, Data=0x%h", wr_addr, rd_data_mem);

        // End simulation
        #100;
        $finish;
    end

endmodule
