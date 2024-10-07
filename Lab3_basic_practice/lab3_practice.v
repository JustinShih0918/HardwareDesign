`timescale 1ns / 1ps

module lab3_practice ( 
    input wire clk,
    input wire rst,
    input wire speed,
    output reg [15:0] led
); 
    wire clk_fast;
    wire clk_slow;
    reg clk_led;
    reg [1:0] state, next_state;
    clock_divider #(.n(27)) fast_clk_divider(.clk(clk), .clk_div(clk_fast));
    clock_divider #(.n(28)) slow_clk_divider(.clk(clk), .clk_div(clk_slow));

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
                clk_led = clk;
                next_state = SLOW;
            end 
            SLOW: begin
                if(speed) begin
                    next_state = FAST;
                end
                else begin
                    next_state = SLOW;
                    clk_led = clk_slow;
                end
            end
            FAST: begin
                if(!speed) begin
                    next_state = SLOW;
                end
                else begin
                    next_state = FAST;
                    clk_led = clk_fast;
                end
            end
            default: begin
                next_state = INITIAL;
                clk_led = clk;
            end
        endcase
    end

    // LED
    always @(posedge clk_led) begin
        if(state == INITIAL) begin
            led = 16'b1111111111111111;
        end
        else begin
            if(led == 16'b1111111111111111 || led == 16'b000000000000001) led = 16'b1000000000000000;
            else led = led >> 1;
        end
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

