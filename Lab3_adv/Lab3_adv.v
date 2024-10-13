module lab3_advanced (
    input wire clk,
    input wire rst,
    input wire right,
    input wire left,
    input wire up,
    input wire down,
    output reg [3:0] DIGIT,
    output wire [6:0] display_Led,
    output reg init,
    output reg move,
    output reg fall,
    output wire [1:0] pos
);

    // Clock Divider
    wire clk_27;
    wire clk_26;
    wire clk_20;
    clock_divider #(.n(27)) clk27(.clk(clk), .clk_div(clk_27));
    clock_divider #(.n(26)) clk26(.clk(clk), .clk_div(clk_26));
    clock_divider #(.n(20)) clk20(.clk(clk), .clk_div(clk_20));

    // debounce
    wire pb_debounced_right;
    wire pb_debounced_left;
    wire pb_debounced_up;
    wire pb_debounced_down;
    debounce debounce_right(.clk(clk), .pb(right), .pb_debounced(pb_debounced_right));
    debounce debounce_left(.clk(clk), .pb(left), .pb_debounced(pb_debounced_left));
    debounce debounce_up(.clk(clk), .pb(up), .pb_debounced(pb_debounced_up));
    debounce debounce_down(.clk(clk), .pb(down), .pb_debounced(pb_debounced_down));

    // one pulse
    wire pb_out_right;
    wire pb_out_left;
    wire pb_out_up;
    wire pb_out_down;
    one_pulse one_pulse_right(.clk(clk_20), .pb_in(pb_debounced_right), .pb_out(pb_out_right));
    one_pulse one_pulse_left(.clk(clk_20), .pb_in(pb_debounced_left), .pb_out(pb_out_left));
    one_pulse one_pulse_up(.clk(clk_20), .pb_in(pb_debounced_up), .pb_out(pb_out_up));
    one_pulse one_pulse_down(.clk(clk_20), .pb_in(pb_debounced_down), .pb_out(pb_out_down));

    // FSM
    reg [1:0] state, next_state;
    parameter INITIAL = 0;
    parameter MOVING = 1;
    parameter FALLING = 2;

    always @(posedge clk_20, posedge rst) begin
        if(rst) begin
            state = INITIAL;
        end
        else begin
            state = next_state;
        end
    end

    // one second counter
    reg [15:0] one_second_counter;
    reg en_one_second_counter;

    always @(posedge clk_27) begin
        if(en_one_second_counter) one_second_counter <= one_second_counter + 16'b1;
        else one_second_counter <= 16'b0;
    end

    // 0.5 second counter
    reg [15:0] half_second_counter;
    reg en_half_second_counter;
    always @(posedge clk_26) begin
        if(en_half_second_counter) half_second_counter <= half_second_counter + 16'b1;
        else half_second_counter <= 16'b0;
    end

    // FSM state transition
    always @(*) begin
        case (state)
            INITIAL: begin
                init = 1;
                move = 0;
                fall = 0;
                if(one_second_counter >= 3) next_state = MOVING;
                else next_state = INITIAL;
            end
            MOVING: begin
                init = 0;
                move = 1;
                fall = 0;
                if(pb_out_down) next_state = FALLING;
                else next_state = MOVING;
            end
            FALLING: begin
                init = 0;
                move = 0;
                fall = 1;
                if(half_second_counter >= 1) next_state = INITIAL;
                else next_state = FALLING;
            end
        endcase
    end

    // FSM behavior
    reg [1:0] head;
    reg [6:0] display;
    assign pos = head;
    assign display_Led = 7'b1111110;
    parameter RIGHT = 0;
    parameter LEFT = 1;
    parameter UP = 2;
    parameter DOWN = 3;

    parameter A = 7'b1111110;
    parameter B = 7'b1111101;
    parameter C = 7'b1111011;
    parameter D = 7'b1110111;
    parameter E = 7'b1101111;
    parameter F = 7'b1011111;
    parameter G = 7'b0111111;

    reg [6:0] record;
    wire [6:0] tmp_display;
    reg [3:0] cor_pos_index;
    parameter cor_A = 0;
    parameter cor_B = 1;
    parameter cor_C = 2;
    parameter cor_D = 3;
    parameter cor_E = 4;
    parameter cor_F = 5;
    parameter cor_G = 6;
    Flashing flash(.idx(cor_pos_index), .clk(clk_26), .record(record), .display(tmp_display));

    always @(*) begin
        DIGIT = 4'b1110;
        case (state)
            INITIAL: begin
                en_half_second_counter = 0;
                en_one_second_counter = 1;
                display = G;
                head = LEFT;
            end
            MOVING: begin
                en_one_second_counter = 0;
                case (display)
                    A: begin
                        if(head == RIGHT) begin
                            if(pb_out_right) begin
                                display = B;
                                head = DOWN;
                                cor_pos_index = cor_B;
                            end
                            else;
                        end
                        else if(head == LEFT) begin
                            if(pb_out_left) begin
                                display = F;
                                head = DOWN;
                                cor_pos_index = cor_F;
                            end
                            else;
                        end
                        else;
                    end 
                    B: begin
                        if(head == UP) begin
                            if(pb_out_left) begin
                                display = A;
                                head = LEFT;
                                cor_pos_index = cor_A;
                            end 
                            else;
                        end
                        else if(head == DOWN) begin
                            if(pb_out_right) begin
                                display = G;
                                head = LEFT;
                                cor_pos_index = cor_G;
                            end
                            else if(pb_out_up) begin
                                display = C;
                                head = DOWN;
                                cor_pos_index = cor_C;
                            end
                            else;
                        end
                        else;
                    end
                    C: begin
                        if(head == UP) begin
                            if(pb_out_left) begin
                                display = G;
                                head = LEFT;
                                cor_pos_index = cor_G;
                            end
                            else if(pb_out_up) begin
                                display = B;
                                head = UP;
                                cor_pos_index = cor_B;
                            end
                            else;
                        end
                        else if(head == DOWN) begin
                            if(pb_out_right) begin
                                display = D;
                                head = DOWN;
                                cor_pos_index = cor_D;
                            end
                            else;
                        end
                        else;
                    end
                    D: begin
                        if(head == RIGHT) begin
                            if(pb_out_left) begin
                                display = C;
                                head = UP;
                                cor_pos_index = cor_C;
                            end
                            else;
                        end
                        else if(head == LEFT) begin
                            if(pb_out_right) begin
                                display = E;
                                head = UP;
                                cor_pos_index = cor_E;
                            end
                            else;
                        end
                        else;
                    end
                    E: begin
                        if(head == UP) begin
                            if(pb_out_right) begin
                                display = G;
                                head = RIGHT;
                                cor_pos_index = cor_G;
                            end
                            else if(pb_out_up) begin
                                display = F;
                                head = UP;
                                cor_pos_index = cor_F;
                            end
                            else;
                        end
                        else if(head == DOWN) begin
                            if(pb_out_left) begin
                                display = D;
                                head = RIGHT;
                                cor_pos_index = cor_D;
                            end
                            else;
                        end
                        else;
                    end
                    F: begin
                        if(head == UP) begin
                            if(pb_out_right) begin
                                display = A;
                                head = RIGHT;
                                cor_pos_index = cor_A;
                            end
                            else;
                        end
                        else if(head == DOWN) begin
                            if(pb_out_left) begin
                                display = G;
                                head = RIGHT;
                                cor_pos_index = cor_G;
                            end
                            else;
                        end
                        else;
                    end
                    G: begin
                        if(head == RIGHT) begin
                            if(pb_out_left) begin
                                display = B;
                                head = UP;
                                cor_pos_index = cor_B;
                            end
                            else if(pb_out_right) begin
                                display = C;
                                head = DOWN;
                                cor_pos_index = cor_C;
                            end
                            else;
                        end
                        else if(head == LEFT) begin
                            if(pb_out_left) begin
                                display = E;
                                head = DOWN;
                                cor_pos_index = cor_E;
                            end
                            else if(pb_out_right) begin
                                display = F;
                                head = UP;
                                cor_pos_index = cor_F;
                            end
                            else;
                        end
                        else;
                    end
                    default: begin
                    end
                endcase
                record = 7'b1111111;
            end
            FALLING: begin
                record[cor_pos_index] = 0;
                case(cor_pos_index)
                    cor_A: begin
                        if(head == RIGHT) begin
                            if(pb_out_right) begin
                                cor_pos_index = cor_B;
                                head = DOWN;
                            end
                            else;
                        end
                        else if(head == LEFT) begin
                            if(pb_out_left) begin
                                cor_pos_index = cor_F;
                                head = DOWN;
                            end
                            else;
                        end
                        else;
                        record[cor_A] = 0;
                    end 
                    cor_B: begin
                        if(head == UP) begin
                            if(pb_out_left) begin
                                cor_pos_index = cor_A;
                                head = LEFT;
                            end 
                            else;
                        end
                        else if(head == DOWN) begin
                            if(pb_out_right) begin
                                cor_pos_index = cor_G;
                                head = LEFT;
                            end
                            else if(pb_out_up) begin
                                cor_pos_index = cor_C;
                                head = DOWN;
                            end
                            else;
                        end
                        else;
                        record[cor_B] = 0;
                    end
                    cor_C: begin
                        if(head == UP) begin
                            if(pb_out_left) begin
                                cor_pos_index = cor_G;
                                head = LEFT;
                            end
                            else if(pb_out_up) begin
                                cor_pos_index = cor_B;
                                head = UP;
                            end
                            else;
                        end
                        else if(head == DOWN) begin
                            if(pb_out_right) begin
                                cor_pos_index = cor_D;
                                head = DOWN;
                            end
                            else;
                        end
                        else;
                        record[cor_C] = 0;
                    end
                    cor_D: begin
                        if(head == RIGHT) begin
                            if(pb_out_left) begin
                                cor_pos_index = cor_C;
                                head = UP;
                            end
                            else;
                        end
                        else if(head == LEFT) begin
                            if(pb_out_right) begin
                                cor_pos_index = cor_E;
                                head = UP;
                            end
                            else;
                        end
                        else;
                        record[cor_D] = 0;
                    end
                    cor_E: begin
                        if(head == UP) begin
                            if(pb_out_right) begin
                                cor_pos_index = cor_G;
                                head = RIGHT;
                            end
                            else if(pb_out_up) begin
                                cor_pos_index = cor_F;
                                head = UP;
                            end
                            else;
                        end
                        else if(head == DOWN) begin
                            if(pb_out_left) begin
                                cor_pos_index = cor_D;
                                head = RIGHT;
                            end
                            else;
                        end
                        else;
                        record[cor_E] = 0;
                    end
                    cor_F: begin
                        if(head == UP) begin
                            if(pb_out_right) begin
                                cor_pos_index = cor_A;
                                head = RIGHT;
                            end
                            else;
                        end
                        else if(head == DOWN) begin
                            if(pb_out_left) begin
                                cor_pos_index = cor_G;
                                head = RIGHT;
                            end
                            else;
                        end
                        else;
                        record[cor_F] = 0;
                    end
                    cor_G: begin
                        if(head == RIGHT) begin
                            if(pb_out_left) begin
                                cor_pos_index = cor_B;
                                head = UP;
                            end
                            else if(pb_out_right) begin
                                cor_pos_index = cor_C;
                                head = DOWN;
                            end
                            else;
                        end
                        else if(head == LEFT) begin
                            if(pb_out_left) begin
                                cor_pos_index = cor_E;
                                head = DOWN;
                            end
                            else if(pb_out_right) begin
                                cor_pos_index = cor_F;
                                head = UP;
                            end
                            else;
                        end
                        else;
                        record[cor_G] = 0;
                    end
                    default: begin
                    end
                endcase
                display = tmp_display;
                if(record == 6'b000000) en_half_second_counter = 1;
                else en_half_second_counter = 0;
            end
            default: begin
            end
        endcase
    end
    

endmodule

// Clock Divider Module
module clock_divider #(parameter n = 25)(clk, clk_div);
    input clk;
    output clk_div;
    reg[n-1:0] num;
    wire[n-1:0] next_num;
    always @(posedge clk) begin
        num <= next_num;
    end
    assign next_num = num + 1;
    assign clk_div = num[n-1];
endmodule

// Debounce Module
module debounce (
    input wire clk,
    input wire pb,
    output wire pb_debounced
);
    reg [3:0] shift_reg;
    always @(posedge clk) begin
        shift_reg[3:1] <= shift_reg[2:0];
        shift_reg[0] <= pb;
    end
    assign pb_debounced = (shift_reg == 4'b1111) ? 1'b1 : 1'b0;
endmodule

// One Pulse Module
module one_pulse (
    input wire clk,
    input wire pb_in,
    output reg pb_out
);
    reg pb_in_delay;
    always @(posedge clk) begin
        if (pb_in == 1'b1 && pb_in_delay == 1'b0) begin
            pb_out <= 1'b1;
        end else begin
            pb_out <= 1'b0;
        end
        
        pb_in_delay <= pb_in;
    end
endmodule

// Flashing
module Flashing(
    input wire [3:0] idx,
    input wire clk,
    input wire [6:0] record,
    output reg [6:0] display
);
    always @(posedge clk) begin
        display = record;
        display[idx] = ~display[idx];
    end
endmodule