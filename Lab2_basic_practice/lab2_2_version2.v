module lab2_2_1(
    input wire clk,
    input wire rst,
    output reg [15:0] out// You can modify "reg" to "wire" if needed
);
    //Your design here

    reg [15:0] next_state;
    integer i;

    always @* begin
        if (out[0] == 1)
            next_state = out * 2;
        else 
            next_state = out + i;
    end

    always @(posedge clk) begin
        if (rst == 1) begin
            out <= 1;
            i <= 1;
        end
        else begin
            out <= next_state;
            i <= i + 1;
        end
    end

endmodule

// You can add any module you need.
// Make sure you include all modules you used in this problem.