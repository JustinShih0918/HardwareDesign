module lab2_2(
    input wire clk,
    input wire rst,
    output reg [15:0] out// You can modify "reg" to "wire" if needed
);
    reg [15:0] counter;
    wire [15:0] counter_next;
    wire [15:0] out_next;
    assign out_next = (out % 2 != 0) ? out*2 : out+counter ;
    assign counter_next = counter + 1'b1;
    always @(posedge clk) begin
        if (rst) begin
            out = 1'b1;
            counter = 1'b1;
        end else begin
            out = out_next;
            counter = counter_next;
        end
    end
    //Your design here

endmodule