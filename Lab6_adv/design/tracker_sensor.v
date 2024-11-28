module tracker_sensor(clk, reset, left_track, right_track, mid_track, state);
    input clk;
    input reset;
    input left_track, right_track, mid_track;
    output reg [1:0] state;

    // TODO: Receive three tracks and make your own policy.
    // Hint: You can use output state to change your action.
    parameter LEFT = 2'b00;
    parameter RIGHT = 2'b01;
    parameter STRAIGHT = 2'b10;

    reg [1:0] next_state;
    always @(posedge clk) begin
        if(reset) state <= STRAIGHT;
        else state <= next_state;
    end

    wire [2:0] LMR;
    assign LMR = {left_track, mid_track, right_track};
    always @(*) begin
        case(LMR)
            3'b001: next_state = RIGHT;
            3'b010: next_state = STRAIGHT;
            3'b011: next_state = RIGHT;
            3'b100: next_state = LEFT;
            3'b101: next_state = STRAIGHT;
            3'b110: next_state = LEFT;
            3'b111: next_state = STRAIGHT;
            default: next_state = state;
        endcase
    end

endmodule
