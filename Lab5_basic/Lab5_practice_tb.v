module lab5_practice_tb;

    reg clk;
    reg rst;
    reg [2:0] addr;
    reg we;
    reg [7:0] din;
    reg re;
    reg start;
    wire [7:0] dout;
    wire done;
    wire [7:0] ans;

    // Instantiate the module
    lab5_practice uut (
        .clk(clk),
        .rst(rst),
        .addr(addr),
        .we(we),
        .din(din),
        .re(re),
        .start(start),
        .dout(dout),
        .done(done),
        .ans(ans)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize inputs
        clk = 0;    
        rst = 1;
        addr = 0;
        we = 0;
        din = 0;
        re = 0;
        start = 0;

        // Reset the design
        #10;
        rst = 0;

        // Write some values to memory
        #10;
        we = 1;
        addr = 3'b000;
        din = 8'd10;
        #10;
        addr = 3'b001;
        din = 8'd20;
        #10;
        addr = 3'b010;
        din = 8'd30;
        #10;
        addr = 3'b011;
        din = 8'd40;
        #10;
        addr = 3'b100;
        din = 8'd50;
        #10;
        addr = 3'b101;
        din = 8'd60;
        #10;
        we = 0;

        // Read back the values
        #10;
        re = 1;
        addr = 3'b000;
        #10;
        addr = 3'b001;
        #10;
        addr = 3'b010;
        #10;
        addr = 3'b011;
        #10;
        addr = 3'b100;
        #10;
        addr = 3'b101;
        #10;
        re = 0;

        // Start the summation
        #10;
        start = 1;
        #10;
        start = 0;

        #90;
        // Check the result
        if (ans == 8'd210) begin
            $display("Test Passed: ans = %d", ans);
        end else begin
            $display("Test Failed: ans = %d", ans);
        end

        // Finish the simulation
        #10;
        $finish;
    end

endmodule