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
        else if(start) en_add <= 1;
        else if(done) en_add <= 0;
    end

    reg [2:0] idx;
    reg [7:0] sum;
    always @(posedge clk) begin
        if(rst) begin
            ans <= 0;
            done <= 0;
            idx <= 0;
            sum <= 0;
        end
        else if(en_add && !done) begin
            if(idx < 6) begin
               sum <= sum + memory[idx];
                idx <= idx + 1; 
            end
            else if(idx == 6) begin
                done <= 1;
                idx <= 0;
                ans <= sum;
            end
        end
    end
    
endmodule