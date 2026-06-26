//==============================================================================
// Module: pwm_gen
// Description: A simple PWM (Pulse Width Modulation) generator.
// 
// How it works:
// 1. A counter counts up from 0 to PWM_PERIOD.
// 2. If the counter value is less than the requested 'duty', the output is HIGH (1).
// 3. Otherwise, the output is LOW (0).
// 4. The 'enable' signal must be HIGH for any output.
//==============================================================================

module pwm_gen #(
    parameter PWM_PERIOD = 100,  // Period of the PWM cycle
    parameter DUTY_WIDTH = 8     // Number of bits needed to store PWM_PERIOD
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     enable,
    input  wire [DUTY_WIDTH-1:0]    duty,
    output reg                      pwm_out
);

    reg [DUTY_WIDTH-1:0] counter;

    // The free-running counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
        end else begin
            if (counter >= PWM_PERIOD - 1) begin
                counter <= 0; // Reset counter at the end of the period
            end else begin
                counter <= counter + 1; // Count up
            end
        end
    end

    // The output comparator
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pwm_out <= 0;
        end else begin
            if (enable && (counter < duty)) begin
                pwm_out <= 1; // Output HIGH when counter is within the duty cycle
            end else begin
                pwm_out <= 0; // Output LOW otherwise
            end
        end
    end

endmodule
