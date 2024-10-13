`timescale 1ns / 1ps

module tb_lab3_advanced;

    // Inputs
    reg clk;
    reg rst;
    reg right;
    reg left;
    reg up;
    reg down;

    // Outputs
    wire [3:0] DIGIT;
    wire [6:0] DISPLAY;
    wire [6:0] display;
    wire [1:0] pos;
    wire [1:0] state_out;

    // Instantiate the Unit Under Test (UUT)
    lab3_advanced uut (
        .clk(clk),
        .rst(rst),
        .right(right),
        .left(left),
        .up(up),
        .down(down),
        .DIGIT(DIGIT),
        .DISPLAY(DISPLAY),
        .display(display),
        .pos(pos),
        .state_out(state_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Stimulus process
    initial begin
        // Initialize inputs
        rst = 1;
        right = 0;
        left = 0;
        up = 0;
        down = 0;

        // Wait for global reset
        #10;
        rst = 0;

        // Test Case 1: Check initial state
        #100;  // Allow some time for the FSM to initialize
        $display("Initial state: display = %b, head = %b", display, uut.head);

        // Test Case 2: Simulate multiple right button presses
        repeat(4) begin
            #10; right = 1; // Press right button
            #10; right = 0; // Release right button
            #1000000000; // Wait for the next state change (adjust as necessary)
            $display("After right press: display = %b, head = %b", display, uut.head);
        end

        // Finish simulation
        #10;
        $finish;
    end

endmodule
