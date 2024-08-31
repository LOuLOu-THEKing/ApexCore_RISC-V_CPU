`timescale 1ps/1ps
module csr_tb;

// Clock and Reset
reg clk;
reg rst;

// CSR inputs
reg [11:0] addr;
reg [31:0] wr_data;
reg [31:0] rdata;

// Trap Handler output
wire trap_detected;

// Instantiate the CSR module (DUT)
csr dut (
    .clk(clk),
    .rst(rst),
    .csr_wr_en(csr_wr_en),
    .csr_ren(csr_ren),
    .addr(addr),
    .wr_data(wr_data),
    .rdata(rdata),
    .i_is_ebreak(i_is_ebreak),
    .i_is_ecall(i_is_ecall),
    .trap_detected(trap_detected)
);

// Clock generation
always #5 clk = ~clk;  // 10 time unit clock period

// Initial block to initialize and drive stimulus
initial begin
    // Initialize signals
    clk = 0;
    rst = 1;
    addr = 0;
    wr_data = 0;
    rdata = 0;

    // Reset the DUT
    #10 rst = 0; // Deassert reset after 10 time units

    // Test Case 1: Write and read CSR registers
    addr = 12'h300; // Access MSTATUS
    rdata = 32'h00000008; // Set MIE bit in MSTATUS
    #10;

    // Add checks and assertions here
    if (dut.mstatus_mie !== 1'b1) begin
        $display("Test Case 1 Failed: MIE not set correctly in MSTATUS");
    end else begin
        $display("Test Case 1 Passed");
    end

    // Test Case 2: Simulate a trap
    dut.go_to_trap = 1;
    #10;
    if (trap_detected !== 1'b1) begin
        $display("Test Case 2 Failed: Trap not detected");
    end else begin
        $display("Test Case 2 Passed");
    end

    // Add more test cases as needed

    // Finish simulation
    #100;
    $finish;
end

endmodule
