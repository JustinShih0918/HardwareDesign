module lab3_advanced (
    input wire clk,
    input wire rst,
    input wire right,
    input wire left,
    input wire up,
    input wire down,
    output reg [3:0] DIGIT,
    output reg [6:0] DISPLAY,
    output wire r,
    output wire l,
    output wire u,
    output wire d,
    output wire RB,
    output wire LB,
    output wire UB,
    output wire DB
);

    // Clock Divider
    wire clk_27;
    wire clk_26;
    clock_divider #(.n(27)) clk27(.clk(clk), .clk_div(clk_27));
    clock_divider #(.n(26)) clk26(.clk(clk), .clk_div(clk_26));

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
    one_pulse one_pulse_right(.clk(clk), .pb_in(pb_debounced_right), .pb_out(pb_out_right));
    one_pulse one_pulse_left(.clk(clk), .pb_in(pb_debounced_left), .pb_out(pb_out_left));
    one_pulse one_pulse_up(.clk(clk), .pb_in(pb_debounced_up), .pb_out(pb_out_up));
    one_pulse one_pulse_down(.clk(clk), .pb_in(pb_debounced_down), .pb_out(pb_out_down));
    assign RB = pb_out_right;
    assign LB = pb_out_left;
    assign UB = pb_out_up;
    assign DB = pb_out_down;

    assign r = pb_debounced_right;
    assign l = pb_debounced_left;
    assign u = pb_debounced_up;
    assign d = pb_debounced_down;

    // FSM
    reg [1:0] state, next_state;
    parameter INITIAL = 0;
    parameter MOVING = 1;
    parameter FALLING = 2;

    always @(posedge clk, posedge rst) begin
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
                if(one_second_counter >= 3) next_state = MOVING;
                else next_state = INITIAL;
            end
            MOVING: begin
                if(pb_out_down) next_state = FALLING;
                else next_state = MOVING;
            end
            FALLING: begin
                if(half_second_counter >= 1) next_state = INITIAL;
                else next_state = FALLING;
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
    end
    always @(posedge clk) begin
        pb_in_delay <= pb_in;
    end
endmodule

