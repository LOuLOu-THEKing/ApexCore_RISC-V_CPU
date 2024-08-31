/**
 * @module led
 * 
 * This module maps 8-bit input data to 8 individual LED outputs.
 * 
 * @input clk   Clock input.
 * @input led   8-bit input data to control the LEDs.
 * 
 * @return led1 Control signal for LED1.
 * @return led2 Control signal for LED2.
 * @return led3 Control signal for LED3.
 * @return led4 Control signal for LED4.
 * @return led5 Control signal for LED5.
 * @return led6 Control signal for LED6.
 * @return led7 Control signal for LED7.
 * @return led8 Control signal for LED8.
 */
 
module led (
    input               clk,
    input               reset,
    input       [7:0]   led,
    output reg          led1, led2, led3, led4, led5, led6, led7, led8
);
initial begin
    led1 <= 0;
    led2 <= 0;
    led3 <= 0;
    led4 <= 0;
    led5 <= 0;
    led6 <= 0;
    led7 <= 0;
    led8 <= 0;
end
always @ (posedge clk) begin
    if (reset) begin
        led1 <= 0;
        led2 <= 0;
        led3 <= 0;
        led4 <= 0;
        led5 <= 0;
        led6 <= 0;
        led7 <= 0;
        led8 <= 0;
    end else begin
        led1 <= led[0];
        led2 <= led[1];
        led3 <= led[2];
        led4 <= led[3];
        led5 <= led[4];
        led6 <= led[5];
        led7 <= led[6];
        led8 <= led[7];
    end
end
endmodule