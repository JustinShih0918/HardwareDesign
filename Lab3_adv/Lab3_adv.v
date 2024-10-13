module lab3_advanced (
    input wire clk,
    input wire rst,
    input wire right,
    input wire left,
    input wire up,
    input wire down,
    output reg [3:0] DIGIT,
    output wire [6:0] DISPLAY,
    output reg [6:0] display,
    output wire [1:0] pos,
    output reg [1:0] state_out,
    output reg invaild_move
);

    // Clock Divider
    wire clk_27;
    wire clk_26;
    wire clk_20;
    wire clk_22;
    wire clk_19;
    clock_divider #(.n(27)) clk27(.clk(clk), .clk_div(clk_27));
    clock_divider #(.n(26)) clk26(.clk(clk), .clk_div(clk_26));
    clock_divider #(.n(20)) clk20(.clk(clk), .clk_div(clk_20));
    clock_divider #(.n(22)) clk21(.clk(clk), .clk_div(clk_22));
    clock_divider #(.n(19)) clk18(.clk(clk), .clk_div(clk_19));

    // debounce
    wire pb_debounced_right;
    wire pb_debounced_left;
    wire pb_debounced_up;
    wire pb_debounced_down;
    debounce debounce_right(.clk(clk_22), .pb(right), .pb_debounced(pb_debounced_right));
    debounce debounce_left(.clk(clk_22), .pb(left), .pb_debounced(pb_debounced_left));
    debounce debounce_up(.clk(clk_22), .pb(up), .pb_debounced(pb_debounced_up));
    debounce debounce_down(.clk(clk_22), .pb(down), .pb_debounced(pb_debounced_down));

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

    always @(posedge clk_27, posedge rst) begin
        if(rst) one_second_counter <= 16'b0;
        else if(en_one_second_counter) one_second_counter <= one_second_counter + 16'b1;
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
                state_out = 2'b00;
                if(one_second_counter >= 3) next_state = MOVING;
                else next_state = INITIAL;
            end
            MOVING: begin
                state_out = 2'b01;
                if(pb_out_down) next_state = FALLING;
                else next_state = MOVING;
            end
            FALLING: begin
                state_out = 2'b10;
                if(half_second_counter >= 1) next_state = INITIAL;
                else next_state = FALLING;
            end
        endcase
    end

    // FSM behavior
    reg [1:0] head;
    reg [1:0] next_head;
    reg [6:0] next_display;

    assign pos = head;
    assign DISPLAY = display;

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
    reg [6:0] next_record;
    wire [6:0] tmp_display;
    reg [3:0] cor_pos_index;
    reg [3:0] next_pos_index;
    parameter cor_A = 0;
    parameter cor_B = 1;
    parameter cor_C = 2;
    parameter cor_D = 3;
    parameter cor_E = 4;
    parameter cor_F = 5;
    parameter cor_G = 6;
    Flashing flash(.idx(cor_pos_index), .clk(clk_26), .record(record), .display(tmp_display));

    always @(posedge clk_20, posedge rst) begin
        if(rst) begin
            display <= G;
            record <= 7'b1111111;
            head <= LEFT;
            cor_pos_index <= cor_G;
        end
        else begin
            display <= next_display;
            record <= next_record;
            head <= next_head;
            cor_pos_index <= next_pos_index;
        end
    end

    always @(*) begin
        DIGIT = 4'b1110;
        next_display = display;
        next_head = head;
        next_record = record;
        next_pos_index = cor_pos_index;
        if(state == INITIAL) begin
            en_one_second_counter <= 1;
            en_half_second_counter <= 0;
            next_head <= LEFT;
            next_record <= 7'b1111111;
            next_pos_index <= cor_G;
            next_display <= G;
            invaild_move <= 0;
        end
        else if(state == MOVING) begin
            en_one_second_counter = 0;
            if(pb_out_right) begin
                if (display == A && head == RIGHT) begin
                    next_display <= B;
                    next_head <= DOWN;
                    next_pos_index <= cor_B;
                end
                else if(display == B && head == DOWN) begin
                    next_display <= G;
                    next_head <= LEFT;
                    next_pos_index <= cor_G;
                end
                else if(display == C && head == DOWN) begin
                    next_display <= D;
                    next_head <= LEFT;
                    next_pos_index <= cor_D;
                end
                else if(display == D && head == LEFT) begin
                    next_display <= E;
                    next_head <= UP;
                    next_pos_index <= cor_E;
                end
                else if(display == E && head == UP) begin
                    next_display <= G;
                    next_head <= RIGHT;
                    next_pos_index <= cor_G;
                end
                else if(display == F && head == UP) begin
                    next_display <= A;
                    next_head <= RIGHT;
                    next_pos_index <= cor_A;
                end
                else if(display == G && head == RIGHT) begin
                    next_display <= C;
                    next_head <= DOWN;
                    next_pos_index <= cor_C;
                end
                else if(display == G && head == LEFT) begin
                    next_display <= F;
                    next_head <= UP;
                    next_pos_index <= cor_F;
                end
                else invaild_move <= 1;
            end
            else if(pb_out_left) begin
                if(display == A && head == LEFT) begin
                    next_display = F;
                    next_head = DOWN;
                    next_pos_index = cor_F;
                end
                else if(display == B && head == UP) begin
                    next_display = A;
                    next_head = LEFT;
                    next_pos_index = cor_A;
                end
                else if(display == C && head == UP) begin
                    next_display = G;
                    next_head = LEFT;
                    next_pos_index = cor_G;
                end
                else if(display == D && head == RIGHT) begin
                    next_display = C;
                    next_head = UP;
                    next_pos_index = cor_C;
                end
                else if(display == E && head == DOWN) begin
                    next_display = D;
                    next_head = RIGHT;
                    next_pos_index = cor_D;
                end
                else if(display == F && head == DOWN) begin
                    next_display = G;
                    next_head = RIGHT;
                    next_pos_index = cor_G;
                end
                else if(display == G && head == LEFT) begin
                    next_display = E;
                    next_head = DOWN;
                    next_pos_index = cor_E;
                end
                else if(display == G && head == RIGHT) begin
                    next_display = B;
                    next_head = UP;
                    next_pos_index = cor_B;
                end
                else invaild_move <= 1;
            end
            else if(pb_out_up) begin
                if(display == B && head == DOWN) begin
                    next_display = C;
                    next_head = DOWN;
                    next_pos_index = cor_C;
                end
                else if(display == C && head == UP) begin
                    next_display = B;
                    next_head = UP;
                    next_pos_index = cor_B;
                end
                else if(display == E && head == UP) begin
                    next_display = F;
                    next_head = UP;
                    next_pos_index = cor_F;
                end
                else if(display == F && head == DOWN) begin
                    next_display = E;
                    next_head = DOWN;
                    next_pos_index = cor_E;
                end
                else invaild_move <= 1;
            end
        end
        else begin
            next_record[cor_pos_index] = 0;
            next_display = tmp_display;
            if(pb_out_right) begin
                if (cor_pos_index == cor_A && head == RIGHT) begin
                    next_head <= DOWN;
                    next_pos_index <= cor_B;
                end
                else if(cor_pos_index == cor_B && head == DOWN) begin
                    next_head <= LEFT;
                    next_pos_index <= cor_G;
                end
                else if(cor_pos_index == cor_C && head == DOWN) begin
                    next_head <= LEFT;
                    next_pos_index <= cor_D;
                end
                else if(cor_pos_index == cor_D && head == LEFT) begin
                    next_head <= UP;
                    next_pos_index <= cor_E;
                end
                else if(cor_pos_index == cor_E && head == UP) begin
                    next_head <= RIGHT;
                    next_pos_index <= cor_G;
                end
                else if(cor_pos_index == cor_F && head == UP) begin
                    next_head <= RIGHT;
                    next_pos_index <= cor_A;
                end
                else if(cor_pos_index == cor_G && head == RIGHT) begin
                    next_head <= DOWN;
                    next_pos_index <= cor_C;
                end
                else if(cor_pos_index == cor_G && head == LEFT) begin
                    next_head <= UP;
                    next_pos_index <= cor_F;
                end
                else invaild_move <= 1;
            end
            else if(pb_out_left) begin
                if(cor_pos_index == cor_A && head == LEFT) begin
                    next_head = DOWN;
                    next_pos_index = cor_F;
                end
                else if(cor_pos_index == cor_B && head == UP) begin
                    next_head = LEFT;
                    next_pos_index = cor_A;
                end
                else if(cor_pos_index == cor_C && head == UP) begin
                    next_head = LEFT;
                    next_pos_index = cor_G;
                end
                else if(display == cor_D && head == RIGHT) begin
                    next_head = UP;
                    next_pos_index = cor_C;
                end
                else if(cor_pos_index == cor_E && head == DOWN) begin
                    next_head = RIGHT;
                    next_pos_index = cor_D;
                end
                else if(cor_pos_index == cor_F && head == DOWN) begin
                    next_head = RIGHT;
                    next_pos_index = cor_G;
                end
                else if(cor_pos_index == cor_G && head == LEFT) begin
                    next_head = DOWN;
                    next_pos_index = cor_E;
                end
                else if(cor_pos_index == cor_G && head == RIGHT) begin
                    next_head = UP;
                    next_pos_index = cor_B;
                end
                else invaild_move <= 1;
            end
            else if(pb_out_up) begin
                if(cor_pos_index == cor_B && head == DOWN) begin
                    next_head = DOWN;
                    next_pos_index = cor_C;
                end
                else if(cor_pos_index == cor_C && head == UP) begin
                    next_display = B;
                    next_head = UP;
                    next_pos_index = cor_B;
                end
                else if(cor_pos_index == cor_E && head == UP) begin
                    next_head = UP;
                    next_pos_index = cor_F;
                end
                else if(cor_pos_index == cor_F && head == DOWN) begin
                    next_display = E;
                    next_head = DOWN;
                    next_pos_index = cor_E;
                end
                else invaild_move <= 1;
            end
            next_record[next_pos_index] = 0;
        end
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