`timescale 1ns / 1ps

module lab3_practice ( 
    input wire clk,
    input wire rst,
    input wire speed,
    output reg [15:0] led
); 
    wire clk_fast;
    wire clk_slow;
    reg [15:0] led_slow;
    reg [15:0] led_fast;
    clock_divider #(.n(27)) fast_clk_divider(.clk(clk), .clk_div(clk_fast));
    clock_divider #(.n(28)) slow_clk_divider(.clk(clk_fast), .clk_div(clk_slow));
    LED slow_led(.clk(clk_slow), .led(led_slow));
    LED fast_led(.clk(clk_fast), .led(led_fast));

    parameter INITIAL = 0;
    parameter SLOW = 1;
    parameter FAST = 2;

    // FSM
    reg [1:0] state, next_state;
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            state = INITIAL;
        end
        else begin
            state = next_state;
        end
    end

    // FSM state transition
    always @* begin
        case (state)
            INITIAL: begin
                next_state = SLOW;
                led = 16'b1111111111111111;
            end 
            SLOW: begin
                if(speed) next_state = FAST;
                else next_state = SLOW;
                led = led_slow;
            end
            FAST: begin
                if(!speed) next_state = SLOW;
                else next_state = FAST;
                led = led_fast;
            end
            default: 
                next_state = INITIAL;
                led = 16'b1111111111111111;
        endcase
    end

endmodule

module clock_divider #(
    parameter n = 27
)(
    input wire  clk,
    output wire clk_div  
);

    reg [n-1:0] num;
    wire [n-1:0] next_num;

    always @(posedge clk) begin
        num <= next_num;
    end

    assign next_num = num + 1;
    assign clk_div = num[n-1];
endmodule

module LED(
    input wire clk,
    output reg [15:0] led;
);

    integer now_idx = 0;
    integer pre_idx = 0;
    integer i;
    always @(posedge clk) begin

        //reset
        for(i = 0; i < 16; i = i + 1) begin
            led[i] = 0;
        end

        led[pre_idx] = 0;
        led[now_idx] = 1;

        pre_idx = now_idx;
        if(now_idx == 15) now_idx = 0;
        else now_idx = now_idx + 1;
    end

endmodule

