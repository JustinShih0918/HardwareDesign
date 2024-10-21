module lab4_practice (
    input wire clk,
    input wire rst,
    input wire btnL,
    input wire btnR,
    output reg [15:0] LED
);
    wire clk_22;
    wire clk_20;
    clock_divider #(.n(22)) clk_divider_22(.clk(clk), .clk_div(clk_22));
    clock_divider #(.n(20)) clk_divider_20(.clk(clk), .clk_div(clk_22));

    wire debounced_btnL;
    wire debounced_btnR;
    wire debounced_rst;
    debounce d_btnL(.clk(clk_22), .pb(btnL), .pb_debounced(debounced_btnL));
    debounce d_btnR(.clk(clk_22), .pb(btnR), .pb_debounced(debounced_btnR));
    debounce d_rst(.clk(clk_22), .pb(rst), .pb_debounced(debounced_rst));

    wire pb_out_btnL;
    wire pb_out_btnR;
    wire pb_out_rst;
    one_pulse op_btnL(.clk(clk_20), .pb(debounced_btnL), .pb_out(pb_out_btnL));
    one_pulse op_btnR(.clk(clk_20), .pb(debounced_btnR), .pb_out(pb_out_btnR));
    one_pulse op_rst(.clk(clk_20), .pb(debounced_rst), .pb_out(pb_out_rst));

    reg [15:0] next_led;
    reg [3:0] next_idx;
    reg [3:0] cur_idx;
    integer  i;
    always @* begin
        next_led = LED;
        next_idx = cur_idx;
        if(pb_out_btnL && !pb_out_btnR && !debounced_btnR) begin
            if(cur_idx > 0) next_idx = cur_idx - 1;
            else next_idx = cur_idx;
        end
        else if(pb_out_btnR && !pb_out_btnL && !debounced_btnL) begin
            if(cur_idx < 15) next_idx = cur_idx + 1;
            else next_idx = cur_idx;
        end
        else next_idx = cur_idx;

        if(next_idx == 16 || next_idx == -1) next_led = 16'b0000_0000_0000_0000;
        else begin
            for(i = 15; i >= 0 ; i = i - 1) begin
                if(i >= next_idx) next_led[i] = 1;
                else next_led[i] = 0;
            end
        end
    end

    always @(posedge clk_20, posedge pb_out_rst) begin
        if(pb_out_rst) begin
            cur_idx <= 16;
            LEB <= 16'b0000_0000_0000_0000;
        end
        else begin
            cur_idx <= next_idx;
            LED <= next_led;
        end
    end


endmodule