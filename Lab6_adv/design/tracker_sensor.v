module tracker_sensor(clk, reset, left_track, right_track, mid_track, move, recovery);
    input clk;
    input reset;
    input left_track, right_track, mid_track;
    output reg [1:0] move;
    output wire recovery;

    // TODO: Receive three tracks and make your own policy.
    // Hint: You can use output move to change your action.
    parameter LEFT = 2'b00;
    parameter RIGHT = 2'b01;
    parameter STRAIGHT = 2'b10;
    parameter BACK = 2'b11;
    parameter NORMAL = 0;
    parameter RECOVERY = 1;

    reg [1:0] next_move, recover_move;
    reg state, next_state;
    reg need_recovery;
    assign recovery = state;

    always @(posedge clk) begin
        if(reset) state <= NORMAL;
        else state <= next_state;
    end

    always @(posedge clk) begin
        if(reset) move <= STRAIGHT;
        else if(state == NORMAL) move <= next_move;
        else if(state == RECOVERY) move <= recover_move;
    end

    wire [2:0] LMR;
    assign LMR = {left_track, mid_track, right_track};

    // need_recovery will be 1 when LMR is 3'b111 for 1 second
    reg [27:0] cnt;
    always @(posedge clk) begin
        if(LMR == 3'b111 && cnt != 27'b111_1111_1111_1111_1111_1111_1111 && need_recovery == 0) cnt = cnt + 1;
        else if(LMR == 3'b111 && cnt == 27'b111_1111_1111_1111_1111_1111_1111) begin
            need_recovery = 1;
            cnt = cnt;
        end
        else if(LMR != 3'b111) begin
            need_recovery = 0;
            cnt <= 29'd0;
        end
    end

    reg do_recovery;
    always @(posedge clk) begin
        if(need_recovery && LMR == 3'b111) do_recovery <= 1;
        else do_recovery <= 0;
    end

    always @(*) begin
        case (state)
            NORMAL: begin
                if(do_recovery) next_state = RECOVERY;
                else next_state = NORMAL;
            end 
            RECOVERY: begin
                if(!do_recovery) next_state = NORMAL;
                else next_state = RECOVERY;
            end
            default: next_state = state;
        endcase
    end


    always @(*) begin
        next_move = next_move;
        recover_move = recover_move;
        if(state == NORMAL) begin
            case(LMR)
                3'b001: next_move = LEFT;
                3'b011: next_move = LEFT;
                3'b100: next_move = RIGHT;
                3'b101: next_move = STRAIGHT;
                3'b110: next_move = RIGHT;
                default: next_move = move;
            endcase
        end
        else begin
            case (next_move)
                LEFT: recover_move = RIGHT;
                RIGHT: recover_move = LEFT;
                STRAIGHT: recover_move = BACK;
                default: recover_move = BACK;
            endcase
        end
    end

endmodule
