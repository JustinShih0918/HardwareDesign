module lab2_2(
    input wire clk,
    input wire rst,
    output reg [15:0] out// You can modify "reg" to "wire" if needed
);
    wire out_next = (out % 2 != 0) ? out * 2 : out + 1; 
    always @(posedge clk) begin
        if(rst) begin
            out <= 16'B1;
        end
        else begin
            out <= out_next;
        end
    end

endmodule

// You can add any module you need.
// Make sure you include all modules you used in this problem.