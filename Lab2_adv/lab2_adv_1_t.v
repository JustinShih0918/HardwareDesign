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


    // TODO 2
    // Connect your lab2_adv_1 module here 
    // Please connect it by port name but not order
    lab2_adv_1 mou1();
    

    // TODO 3
    //write some code here to change the input of the moudle above
    initial begin
        
    end
    //====================================
    

endmodule

