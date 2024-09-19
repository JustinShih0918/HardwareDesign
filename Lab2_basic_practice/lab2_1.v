`define WIDTH 8

module lab2_1(
    input wire clk,
    input wire rst,
    input wire signed [`WIDTH-1:0] A,
    input wire signed [`WIDTH-1:0] B,
    input wire ctrl,
    output reg signed [`WIDTH*2-1:0] out // You can modify "reg" to "wire" if needed
);
    reg signed [`WIDTH*2-1:0] out_tmp;
    assign out_tmp = (ctrl == 0) ? A * B : (A < B) ? 16'B1 : 16'B0;
    always @(posedge clk) begin
        if(rst) begin
            out_tmp <= 16'B0;
            out <= out_tmp;
        end
        else begin
            out <=out_tmp;
        end
    end

    //Your design here

endmodule

// You can add any module you need.
// Make sure you include all modules you used in this problem.