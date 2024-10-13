module tb_debounce_one_pulse;

    // Clock and reset
    reg clk;
    reg reset;
    
    // Inputs (button press simulation)
    reg right, left, up, down;
    
    // Debounced outputs
    wire pb_debounced_right;
    wire pb_debounced_left;
    wire pb_debounced_up;
    wire pb_debounced_down;
    
    // One pulse outputs
    wire pb_out_right;
    wire pb_out_left;
    wire pb_out_up;
    wire pb_out_down;

    // Instantiate debounce modules
    debounce debounce_right(.clk(clk), .pb(right), .pb_debounced(pb_debounced_right));
    debounce debounce_left(.clk(clk), .pb(left), .pb_debounced(pb_debounced_left));
    debounce debounce_up(.clk(clk), .pb(up), .pb_debounced(pb_debounced_up));
    debounce debounce_down(.clk(clk), .pb(down), .pb_debounced(pb_debounced_down));

    // Instantiate one pulse modules
    one_pulse one_pulse_right(.clk(clk), .pb_in(pb_debounced_right), .pb_out(pb_out_right));
    one_pulse one_pulse_left(.clk(clk), .pb_in(pb_debounced_left), .pb_out(pb_out_left));
    one_pulse one_pulse_up(.clk(clk), .pb_in(pb_debounced_up), .pb_out(pb_out_up));
    one_pulse one_pulse_down(.clk(clk), .pb_in(pb_debounced_down), .pb_out(pb_out_down));

    // Clock generation (10ns period => 100MHz)
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // Initialize inputs
        clk = 0;
        right = 0;
        left = 0;
        up = 0;
        down = 0;
        
        // Test debounce and one-pulse for "down" button press
        #10;
        down = 1;   // Press the down button
        #50;
        down = 0;   // Release the down button
        #50;

        // Test debounce and one-pulse for "up" button press
        #10;
        up = 1;     // Press the up button
        #50;
        up = 0;     // Release the up button
        #50;

        // Test debounce and one-pulse for "right" button press
        #10;
        right = 1;  // Press the right button
        #50;
        right = 0;  // Release the right button
        #50;

        // Test debounce and one-pulse for "left" button press
        #10;
        left = 1;   // Press the left button
        #50;
        left = 0;   // Release the left button
        #50;

        // Finish the simulation
        #100;
        $stop;
    end

    // Monitor signals to check the outputs
    initial begin
        $monitor("Time: %0d | right=%b left=%b up=%b down=%b | pb_out_right=%b pb_out_left=%b pb_out_up=%b pb_out_down=%b",
                 $time, right, left, up, down, pb_out_right, pb_out_left, pb_out_up, pb_out_down);
    end

endmodule
