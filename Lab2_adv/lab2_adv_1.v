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
        $display("code: %b", code);
        h[0] = code[11] ^ code[9] ^ code[7] ^ code[5] ^ code[3] ^ code[1];
        h[1] = code[10] ^ code[9] ^ code[6] ^ code[5] ^ code[2] ^ code[1];
        h[2] = code[8] ^ code[7] ^ code[6] ^ code[5] ^ code[0];
        h[3] = code[4] ^ code[3] ^ code[2] ^ code[1] ^ code[0];
        code_de = code;
        $display("code_de: %b", code_de);
    end

    always @(posedge clk) begin
        if(rst_n == 1'b0) begin //reset
            out = 4'b0;
            raw_data = 8'b0;
            err = 1'b0;
            cor = 1'b0;
        end
        else if(h > 12) begin //multiple errors
            out = 0;
            raw_data = 8'b0;
            err = 1;
            cor = 0;
            $display("Multiple errors, %d", h);
        end
        else if(h <=12 && h >=1) begin //one error
            out = h;
            code_de[12 - h] = ~code[12 - h];
            raw_data = {code_de[9], code_de[7], code_de[6], code_de[5], code_de[3], code_de[2], code_de[1], code_de[0]};
            err = 0;
            cor = 0;
            $display("one error, %d", h);
        end
        else begin //no error
            out = h;
            raw_data = {code_de[9], code_de[7], code_de[6], code_de[5], code_de[3], code_de[2], code_de[1], code_de[0]};
            err = 0;
            cor = 1;
            $display("no error, %d", h);
        end
    end
// Output signals can be reg or wire
// add your design here
   

endmodule
