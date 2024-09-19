`timescale 1ns/100ps
module test;
    reg [2:0] count;
    wire out;
    reg [2:0] tmp;
    majority m(out, count[0], count[1], count[2]);

    integer  i;
    initial begin
        tmp = 3'b000;
        for(i = 0;i<7;i = i+1) begin
            count = tmp + 1;
            #10
            $display("in = %b, out = %b", count, out);
            tmp = count;
        end
    end
endmodule