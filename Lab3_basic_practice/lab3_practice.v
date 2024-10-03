`timescale 1ns / 1ps

module lab3_practice ( 
    input wire clk,
    input wire rst,
    input wire speed,
    output reg [15:0] led
); 
    wire clk_fast;
    wire clk_slow;
    reg rst_led;
    wire [15:0] led_slow;
    wire [15:0] led_fast;
    reg [1:0] state, next_state;
    clock_divider #(.n(27)) fast_clk_divider(.clk(clk), .clk_div(clk_fast));
    clock_divider #(.n(28)) slow_clk_divider(.clk(clk), .clk_div(clk_slow));
    LED slow_led(.clk(clk_slow), .state(state), .next_state(next_state), .led(led_slow));
    LED fast_led(.clk(clk_fast), .state(state), .next_state(next_state), .led(led_fast));

    parameter INITIAL = 0;
    parameter SLOW = 1;
    parameter FAST = 2;

    // FSM
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
                rst_led = 1;
                led = 16'b1111111111111111;
            end 
            SLOW: begin
                if(speed) begin
                    next_state = FAST;
                    rst_led = 1;
                end
                else begin
                    next_state = SLOW;
                    rst_led = 0;
                end
                led = led_slow;
            end
            FAST: begin
                if(!speed) begin
                    next_state = SLOW;
                    rst_led = 1;
                end
                else begin
                    next_state = FAST;
                    rst_led = 0;
                end
                led = led_fast;
            end
            default: begin
                next_state = INITIAL;
                led = 16'b1111111111111111; 
            end
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
    input wire state,
    input wire next_state,
    output reg [15:0] led
);

    reg [3:0] now_idx;
    reg [3:0] pre_idx;
    wire rst;
    assign rst = (state != next_state);
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            pre_idx = 0;
            now_idx = 0;
            led = 16'b0000000000000001;
        end
        else begin
            pre_idx = now_idx;
            if(now_idx == 15) now_idx = 0;
            else now_idx = now_idx + 1;
            
            led[pre_idx] = 0;
            led[now_idx] = 1;
        end
    end

endmodule

