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

    always @(posedge clk) begin
        if(rst) begin
            out_tmp = 16'B0;
        end
        else if(ctrl == 0) begin
            out_tmp = A * B;
        end
        else begin
            if(A < B) begin
                out_tmp = 16'B1;
            end
            else begin
                out_tmp = -1;
            end
        end
    end

    always @(posedge clk) begin
        $display("A=%d, B=%d, ctrl=%d, out=%d", A, B, ctrl, out_tmp);
        out <= out_tmp;
    end

    //Your design here

endmodule

// You can add any module you need.
// Make sure you include all modules you used in this problem.