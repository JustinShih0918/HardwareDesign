`timescale 1ns/100ps
module lab2_adv_1 (
    input clk,
    input rst_n, 
    input wire [11:0] code, 
    output reg [3:0] out,
    output reg [7:0] raw_data,
    output reg err,
    output reg cor
);
    reg [3:0] h;
    reg [11:0] code_de;
    always @* begin
        h[0] = code[0] ^ code[2] ^ code[4] ^ code[6] ^ code[8] ^ code[10];
        h[1] = code[1] ^ code[2] ^ code[5] ^ code[6] ^ code[9] ^ code[10];
        h[2] = code[3] ^ code[4] ^ code[5] ^ code[6] ^ code[11];
        h[3] = code[7] ^ code[8] ^ code[9] ^ code[10] ^ code[11];
        code_de = code;
    end

    always @(posedge clk, negedge rst_n) begin
        if(rst_n == 1'b0) begin //reset
            out = 4'b0;
            raw_data = 8'b0;
            err = 1'b0;
            cor = 1'b0;
        end
        else if(h > 12) begin //multiple errors
            out = 0;
            raw_data = 0;
            err = 1;
            cor = 0;
        end
        else if(h == 0) begin //no error
            out = 0;
            raw_data = {code_de[2], code_de[4], code_de[5], code_de[6], code_de[8], code_de[9], code_de[10], code_de[11]};
            err = 0;
            cor = 1;
        end
        else begin //one error
            out = h;
            code_de[h-1] = ~code[h-1];
            raw_data = {code_de[2], code_de[4], code_de[5], code_de[6], code_de[8], code_de[9], code_de[10], code_de[11]};
            err = 0;
            cor = 0;
        end
    end
// Output signals can be reg or wire
// add your design here
   

endmodule
