//==============================================================================
// Module: power_fsm
// Description: A simple Moore FSM (Finite State Machine) for power sequencing.
//
// Sequence:
// 1. IDLE: All rails off. Waits for 'enable'.
// 2. TURN_ON_RAIL1: Enables Rail 1, waits for TIMER_MAX cycles.
// 3. TURN_ON_RAIL2: Enables Rail 2, waits for TIMER_MAX cycles.
// 4. TURN_ON_RAIL3: Enables Rail 3, waits for TIMER_MAX cycles.
// 5. RUN: All rails on. Stays here unless 'enable' goes low or 'fault' goes high.
//
// If 'fault' is high at any time, it immediately jumps to IDLE and turns everything off.
//==============================================================================

module power_fsm #(
    parameter TIMER_MAX = 50 // Delay between turning on each rail
) (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       enable,
    input  wire       fault,
    
    output reg [2:0]  rail_en  // [0] = Rail 1, [1] = Rail 2, [2] = Rail 3
);

    // State definitions
    localparam [2:0] IDLE          = 3'd0,
                     TURN_ON_RAIL1 = 3'd1,
                     TURN_ON_RAIL2 = 3'd2,
                     TURN_ON_RAIL3 = 3'd3,
                     RUN           = 3'd4;

    reg [2:0] state, next_state;
    reg [15:0] timer; // simple internal delay timer

    //--------------------------------------------------------------------------
    // State Memory and Timer (Sequential Logic)
    //--------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            timer <= 0;
        end else begin
            state <= next_state;
            
            // Increment timer if we are in a turning-on state, else reset it
            if (state == TURN_ON_RAIL1 || state == TURN_ON_RAIL2 || state == TURN_ON_RAIL3) begin
                timer <= timer + 1;
            end else begin
                timer <= 0;
            end
        end
    end

    //--------------------------------------------------------------------------
    // Next State Logic (Combinational Logic)
    //--------------------------------------------------------------------------
    always @(*) begin
        // Default: stay in the current state
        next_state = state;
        
        // Fault check has highest priority
        if (fault) begin
            next_state = IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (enable) next_state = TURN_ON_RAIL1;
                end
                
                TURN_ON_RAIL1: begin
                    if (timer >= TIMER_MAX) next_state = TURN_ON_RAIL2;
                end
                
                TURN_ON_RAIL2: begin
                    if (timer >= TIMER_MAX) next_state = TURN_ON_RAIL3;
                end
                
                TURN_ON_RAIL3: begin
                    if (timer >= TIMER_MAX) next_state = RUN;
                end
                
                RUN: begin
                    if (!enable) next_state = IDLE;
                end
                
                default: next_state = IDLE;
            endcase
        end
    end

    //--------------------------------------------------------------------------
    // Output Logic (Combinational Logic - Moore Machine)
    // Outputs only depend on the current state
    //--------------------------------------------------------------------------
    always @(*) begin
        case (state)
            IDLE:          rail_en = 3'b000;
            TURN_ON_RAIL1: rail_en = 3'b001;
            TURN_ON_RAIL2: rail_en = 3'b011;
            TURN_ON_RAIL3: rail_en = 3'b111;
            RUN:           rail_en = 3'b111;
            default:       rail_en = 3'b000;
        endcase
    end

endmodule
