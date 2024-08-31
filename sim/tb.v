`timescale 1 ns/1 ns

module tb;

reg clk, reset;
wire [7:0] led;

top uut (clk, reset//, //led[0], led[1], led[2], led[3], led[4], led[5], led[6], led[7] 
);
localparam counter = 0;
initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    clk <= 0;
    reset <= 0;
end

always begin
    #10 clk = ~clk;
    if (counter == 100000000) begin
        $finish;
    end
end

endmodule