module lab5_practice (
    input wire clk,
    input wire rst,
    input wire [2:0] addr,
    input wire we, 
    input wire [7:0] din,
    input wire re,
    input wire start,
    output reg [7:0] dout,
    output reg done,
    output reg [7:0] ans
);
    // add your design here
    // note that you are free to adjust the IO's data type
    reg [7:0] memory [0:5];
    reg [2:0] idx;
    reg [7:0] sum;
    reg en_add;
    integer i;
    always @(posedge clk) begin
        if(rst) begin
            for(i = 0 ;i < 6; i = i + 1) memory[i] <= 8'b0;  
            dout <= 0;
            ans <= 0;
            sum <= 0;
            idx <= 0;
            done <= 0;
            en_add <= 0;
        end
        else if(we) memory[addr] <= din;
        else if(re) dout <= memory[addr];
        else if(start) en_add <= 1;
        else if(en_add)begin
            if(idx < 6) begin
                sum <= sum + memory[idx];
                idx <= idx + 1;
            end
            else begin
                ans <= sum;
                done <= 1;
                en_add <= 0;
            end
        end
    end
endmodule