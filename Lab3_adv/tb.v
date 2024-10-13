module tb_one_pulse;

    reg clk;
    reg reset;
    reg pb_in;
    wire pb_out;

    // Instantiate the one_pulse module
    one_pulse UUT (
        .clk(clk),
        .reset(reset),
        .pb_in(pb_in),
        .pb_out(pb_out)
    );

    // Clock generator
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100 MHz clock (10ns period)
    end

    // Test sequence
    initial begin
        reset = 1;
        pb_in = 0;
        #20 reset = 0;
        
        // Apply a rising edge on pb_in
        #30 pb_in = 1;
        #10 pb_in = 0;  // Keep it high for one cycle, then go low again

        // Wait and observe the pulse output
        #50 $stop;
    end

endmodule
