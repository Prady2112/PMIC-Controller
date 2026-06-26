`timescale 1ns/1ps

//==============================================================================
// Module: tb_pmic_top
// Description: Simple testbench to demonstrate the PMIC sequencing and fault.
//==============================================================================

module tb_pmic_top;

    // Inputs
    reg clk;
    reg rst_n;
    reg enable;
    reg fault;
    reg [7:0] duty_rail1;
    reg [7:0] duty_rail2;
    reg [7:0] duty_rail3;

    // Outputs
    wire [2:0] rail_en;
    wire [2:0] pwm_out;

    // Instantiate the Unit Under Test (UUT)
    pmic_top uut (
        .clk(clk), 
        .rst_n(rst_n), 
        .enable(enable), 
        .fault(fault), 
        .duty_rail1(duty_rail1), 
        .duty_rail2(duty_rail2), 
        .duty_rail3(duty_rail3), 
        .rail_en(rail_en), 
        .pwm_out(pwm_out)
    );

    // Clock generation (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize Inputs
        rst_n = 0;
        enable = 0;
        fault = 0;
        duty_rail1 = 8'd25; // 25% duty cycle
        duty_rail2 = 8'd50; // 50% duty cycle
        duty_rail3 = 8'd75; // 75% duty cycle

        $display("Starting Simple PMIC Simulation...");

        // Wait a bit, then release reset
        #20;
        rst_n = 1;
        $display("[%0t] Reset released", $time);

        // Wait a bit, then enable the system
        #20;
        enable = 1;
        $display("[%0t] System Enabled. Waiting for sequencing...", $time);

        // The FSM waits 50 clock cycles (500ns) between each rail.
        // Let's wait long enough for all rails to turn on.
        #2000;
        $display("[%0t] All rails should be ON now. rail_en = %b", $time, rail_en);
        
        // Let it run for a while to see the PWM outputs
        #500;

        // Inject a fault
        $display("[%0t] INJECTING FAULT!", $time);
        fault = 1;
        
        // Wait a little bit to see it shut down
        #100;
        $display("[%0t] Fault active. rail_en = %b", $time, rail_en);
        
        // Clear fault and wait
        fault = 0;
        enable = 0;
        #100;

        $display("Simulation Complete.");
        $finish;
    end
    
    // Dump waveforms so we can view them in a tool like GTKWave or Vivado
    initial begin
        $dumpfile("pmic_simple.vcd");
        $dumpvars(0, tb_pmic_top);
    end

endmodule
