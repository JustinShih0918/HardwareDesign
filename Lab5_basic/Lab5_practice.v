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
    integer i;
    always @(posedge clk) begin
        if(rst) begin
            for(i = 0 ;i < 6; i = i + 1) memory[i] <= 8'b0;  
            dout <= 0;
        end
        else if(we) memory[addr] <= din;
        else if(re) dout <= memory[addr];
    end

    always @(posedge clk) begin
        if(rst) begin
            ans <= 0;
            done <= 0;
        end
        else if(start) begin
            for(i = 0; i < 6; i = i + 1) ans <= ans + memory[i];
            done <= 1;
        end
    end
    
endmodule