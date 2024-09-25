`timescale 1ns/100ps
module lab2_adv_1_t ();

    parameter DELAY = 5;
    reg clk = 0;
    reg  rst_n = 0;
    reg [11:0] code = 12'b100110110110;
    wire [3:0] out;
    wire [7:0] raw_data;
    wire err;
    wire cor;

    initial begin
        while (1) begin
            clk = ~clk;
            #DELAY;
        end
    end

    initial begin
        #120 $finish;
    end

    //====================================
    // TODO 1
    //you should test these 8 cases:
    //hint: use array
    //000000011001
    //101110100111
    //110010111111
    //101111101010
    //110100100001
    //101100110011
    //010010011101
    //111111011011
    reg [11:0] test_case [7:0];
    initial begin
        test_case[0] = 12'b000000011001;
        test_case[1] = 12'b101110100111;
        test_case[2] = 12'b110010111111;
        test_case[3] = 12'b101111101010;
        test_case[4] = 12'b110100100001;
        test_case[5] = 12'b101100110011;
        test_case[6] = 12'b010010011101;
        test_case[7] = 12'b111111011011;
    end
    

    // TODO 2
    // Connect your lab2_adv_1 module here 
    // Please connect it by port name but not order
    lab2_adv_1 mou1(.clk(clk), .rst_n(rst_n), .code(code), .out(out), .raw_data(raw_data), .err(err), .cor(cor));
    

    // TODO 3
    //write some code here to change the input of the moudle above
    integer i;
    initial begin
        $DELAY(35);
        for(i = 0; i < 8; i = i + 1) begin
            code = test_case[i];
            #10;
        end
    end
    //====================================
    

endmodule

