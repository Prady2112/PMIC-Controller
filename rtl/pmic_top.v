//==============================================================================
// Module: pmic_top
// Description: Simplified Top-Level PMIC Controller for learning.
//
// This module ties together the Power FSM and three PWM generators.
// It takes basic inputs (clock, reset, enable, fault) and coordinates
// the submodules to produce the PWM outputs.
//==============================================================================

module pmic_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        enable,
    input  wire        fault,
    
    // External PWM duty cycle controls for the 3 rails
    input  wire [7:0]  duty_rail1,
    input  wire [7:0]  duty_rail2,
    input  wire [7:0]  duty_rail3,
    
    // Outputs
    output wire [2:0]  rail_en,
    output wire [2:0]  pwm_out
);

    //==========================================================================
    // Instantiate the Power Sequencing FSM
    //==========================================================================
    power_fsm #(
        .TIMER_MAX(50) // Wait 50 clock cycles between turning on rails
    ) u_power_fsm (
        .clk     (clk),
        .rst_n   (rst_n),
        .enable  (enable),
        .fault   (fault),
        .rail_en (rail_en)
    );

    //==========================================================================
    // Instantiate PWM Generators for each rail
    // A rail's PWM is only enabled if the FSM has enabled that rail AND 
    // there is no fault in the system.
    //==========================================================================
    
    wire pwm_en_rail1 = rail_en[0] && !fault;
    wire pwm_en_rail2 = rail_en[1] && !fault;
    wire pwm_en_rail3 = rail_en[2] && !fault;
    
    pwm_gen #(
        .PWM_PERIOD(100),
        .DUTY_WIDTH(8)
    ) u_pwm_rail1 (
        .clk     (clk),
        .rst_n   (rst_n),
        .enable  (pwm_en_rail1),
        .duty    (duty_rail1),
        .pwm_out (pwm_out[0])
    );
    
    pwm_gen #(
        .PWM_PERIOD(100),
        .DUTY_WIDTH(8)
    ) u_pwm_rail2 (
        .clk     (clk),
        .rst_n   (rst_n),
        .enable  (pwm_en_rail2),
        .duty    (duty_rail2),
        .pwm_out (pwm_out[1])
    );
    
    pwm_gen #(
        .PWM_PERIOD(100),
        .DUTY_WIDTH(8)
    ) u_pwm_rail3 (
        .clk     (clk),
        .rst_n   (rst_n),
        .enable  (pwm_en_rail3),
        .duty    (duty_rail3),
        .pwm_out (pwm_out[2])
    );

endmodule
