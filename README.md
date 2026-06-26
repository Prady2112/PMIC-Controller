# Basic Digital PMIC Controller

![Verilog](https://img.shields.io/badge/Language-Verilog-blue.svg)
![Simulation](https://img.shields.io/badge/Simulation-Icarus_Verilog-green.svg)
![Level](https://img.shields.io/badge/Level-Undergraduate_Educational-orange.svg)

This is an educational hardware design project that demonstrates how to build a **Digital Power Management IC (PMIC) Controller** using Verilog. It serves as an excellent introduction to Finite State Machines (FSM) and hardware counters.

In real-world electronics, complex chips (like CPUs and GPUs) require multiple voltage rails that must be turned on in a specific order to prevent damage. This project acts as a digital "traffic cop," sequencing the power rails and generating the signals that control analog voltage converters.

## 🌟 Features
*   **Power Sequencing**: A Moore FSM that safely sequences three power rails (Core, Memory, I/O) one after the other with built-in timing delays.
*   **PWM Generation**: Parameterized, counter-based Pulse Width Modulation (PWM) generators for each rail to control the duty cycle of connected DC-DC converters.
*   **Fault Protection**: Instantaneous hardware shut-off triggered by an asynchronous fault signal, simulating Over-Current or Over-Temperature protection.
*   **Educational Codebase**: Stripped of complex industry-specific bloat, heavily commented, and designed specifically for students learning digital logic.

## 🏗️ Architecture
The project consists of three main modules interacting as shown below:

```mermaid
graph TD
    clk((clk)) --> pmic_top
    rst_n((rst_n)) --> pmic_top
    enable((enable)) --> FSM
    fault((fault)) --> FSM
    
    subgraph pmic_top [Top Level Module]
        FSM[power_fsm]
        PWM1[pwm_gen Rail 1]
        PWM2[pwm_gen Rail 2]
        PWM3[pwm_gen Rail 3]
        
        FSM -- rail_en[0] --> PWM1
        FSM -- rail_en[1] --> PWM2
        FSM -- rail_en[2] --> PWM3
    end
    
    duty1((duty_rail1)) --> PWM1
    duty2((duty_rail2)) --> PWM2
    duty3((duty_rail3)) --> PWM3
    
    PWM1 --> out1("pwm_out[0]")
    PWM2 --> out2("pwm_out[1]")
    PWM3 --> out3("pwm_out[2]")
```

### Finite State Machine (Power Sequencer)
The `power_fsm.v` acts as the master controller. It uses a built-in timer to ensure each rail has 50 clock cycles to stabilize before powering the next one. A critical safety feature is that an incoming `fault` signal will instantly override any state and return the system to `IDLE`.

```mermaid
stateDiagram-v2
    [*] --> IDLE : System Reset
    IDLE --> TURN_ON_RAIL1 : enable = 1
    TURN_ON_RAIL1 --> TURN_ON_RAIL2 : timer >= 50
    TURN_ON_RAIL2 --> TURN_ON_RAIL3 : timer >= 50
    TURN_ON_RAIL3 --> RUN : timer >= 50
    RUN --> IDLE : enable = 0
    
    note right of TURN_ON_RAIL2
        If (fault == 1) at ANY point,
        the system immediately jumps
        back to IDLE.
    end note
```

## 🚀 Quick Start (Simulation)
This project is designed to be easily simulated using open-source tools.

### Prerequisites
*   [Icarus Verilog](http://iverilog.icarus.com/) (for compiling and simulation)
*   [GTKWave](https://gtkwave.sourceforge.net/) (for viewing the waveform results)

### Running the Testbench
1. Clone the repository and navigate to the root directory.
2. Compile the Verilog files:
   ```bash
   iverilog -o pmic_sim.vvp rtl/pwm_gen.v rtl/power_fsm.v rtl/pmic_top.v tb/tb_pmic_top.v
   ```
3. Run the simulation:
   ```bash
   vvp pmic_sim.vvp
   ```
4. A waveform file named `pmic_simple.vcd` will be generated in your directory.

### Viewing the Waveforms
Open GTKWave and load the generated `.vcd` file:
```bash
gtkwave pmic_simple.vcd
```
*Tip: Expand the `tb_pmic_top` -> `uut` hierarchy to view the internal FSM states, PWM outputs, and fault triggers.*

## 📈 Simulation & Hardware Results

### Waveform Analysis
This waveform demonstrates the FSM successfully sequencing the three rails, outputting the variable-duty PWM signals, and reacting instantly to a fault trigger.
![Simulation Waveform](assets/waveform.png)

### Vivado Implementation
The project can also be synthesized and implemented in Xilinx Vivado to map the logic to a physical FPGA.
![Vivado Device View](assets/device.png)

*Vivado Utilization & Power Reports:*
![Utilization Report](assets/Utilization.png)
![Power Report](assets/power.png)
