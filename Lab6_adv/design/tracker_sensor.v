module tracker_sensor(clk, reset, left_track, right_track, mid_track, state, prev_state);
    input clk;
    input reset;
    input left_track, right_track, mid_track;
    output reg [1:0] state;
    output reg [1:0] prev_state;

    // TODO: Receive three tracks and make your own policy.
    // Hint: You can use output state to change your action.
    parameter LEFT = 2'b00;
    parameter RIGHT = 2'b01;
    parameter STRAIGHT = 2'b10;
    parameter BACK = 2'b11;

    reg [1:0] next_state;
    always @(posedge clk) begin
        if(reset) begin
            state <= STRAIGHT;
        end
        else begin
            state <= next_state;
        end
    end

    wire [2:0] LMR;
    assign LMR = {left_track, mid_track, right_track};
    reg loss_track;
    reg need_recover;
    reg [25:0] cnt;

    always @(posedge clk) begin
        if(LMR == 3'b111 && loss_track == 0) cnt <= cnt + 1;
        else cnt <= 0;
    end

    always @(posedge clk) begin
        if(cnt == 26'b11_1111_1111_1111_1111_1111_1111 && loss_track == 0) need_recover <= 1;
        else if(loss_track == 1) need_recover <= 0;
    end

    always @(posedge clk) begin
        if(reset) begin
            prev_state <= STRAIGHT;
            loss_track <= 0;
        end
        else if(LMR == 3'b111 && loss_track == 0 && need_recover) begin
            prev_state <= state;
            loss_track <= 1;
        end
        else if(LMR != 3'b111 && loss_track == 1) begin
            loss_track <= 0;
            prev_state <= prev_state;
        end
    end

    always @(*) begin
        case(LMR)
            3'b001: next_state = LEFT;
            3'b011: next_state = LEFT;
            3'b100: next_state = RIGHT;
            3'b101: next_state = STRAIGHT;
            3'b110: next_state = RIGHT;
            3'b111: begin
                if(prev_state == RIGHT && loss_track) next_state = LEFT;
                else if(prev_state == LEFT && loss_track) next_state = RIGHT;
                else if(prev_state == STRAIGHT && loss_track) next_state = BACK;
                else if(prev_state == BACK && loss_track) next_state = STRAIGHT;
                else next_state = state;
            end
            default: next_state = state;
        endcase
    end

endmodule
