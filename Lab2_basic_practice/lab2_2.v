module lab2_2(
    input wire clk,
    input wire rst,
    output reg [15:0] out// You can modify "reg" to "wire" if needed
);
    reg [15:0] round;
    always @(posedge clk) begin
        $display("out0=%d, round=%d", out[0], round);
        if(rst) begin
            out <= 16'B1;
            round <= 1;
        end
        else begin
            if(out[0] == 1'B1) begin
                out = out * 2;
                round = round + 1;
            end
            else begin
                out <= out + round;
                round <= round + 1;
            end
        end
    end

endmodule

// You can add any module you need.
// Make sure you include all modules you used in this problem.