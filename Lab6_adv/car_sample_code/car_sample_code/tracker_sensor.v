`timescale 1ns/1ps
module tracker_sensor(clk, reset, left_signal, right_signal, mid_signal, state);
    input clk;
    input reset;
    input left_signal, right_signal, mid_signal; //return 0 when encounter black
    output reg [1:0] state;

    // [TO-DO] Receive three signals and make your own policy.
    // Hint: You can use output state to change your action.
    parameter turn_left = 2'b00;
    parameter turn_right = 2'b01;
    parameter go_straight = 2'b10;
    
    reg [1:0] next_state;
    wire [2:0] LMR;
    assign LMR = {left_signal, mid_signal, right_signal};
    always@(posedge clk) begin
        if(reset) state <= go_straight;
        else state <= next_state;
    end
    always@(*) begin
        case(LMR)
        3'b001: next_state = turn_right;
        3'b010: next_state = go_straight; //the case when the line is too thin
        3'b011: next_state = turn_right;
        3'b100: next_state = turn_left;
        3'b101: next_state = go_straight; //impossible case
        3'b110: next_state = turn_left;
        3'b111: next_state = go_straight;
        default: next_state = state;
        endcase
    end
endmodule
