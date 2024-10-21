module lab4_practice (
    input wire clk,
    input wire rst,
    input wire btnL,
    input wire btnR,
    output reg [15:0] LED
);

    wire clk_20;
    clock_divider #(.n(20)) cd(.clk(clk), .clk_div(clk_20));

    wire debounced_btnL;
    wire debounced_btnR;
    wire debounced_rst;
    debounce d_btnL(.clk(clk_20), .pb(btnL), .pb_debounced(debounced_btnL));
    debounce d_btnR(.clk(clk_20), .pb(btnR), .pb_debounced(debounced_btnR));
    debounce d_rst(.clk(clk_20), .pb(rst), .pb_debounced(debounced_rst));

    wire pb_out_btnL;
    wire pb_out_btnR;
    wire pb_out_rst;
    one_pulse op_btnL(.clk(clk_20), .pb_in(debounced_btnL), .pb_out(pb_out_btnL));
    one_pulse op_btnR(.clk(clk_20), .pb_in(debounced_btnR), .pb_out(pb_out_btnR));
    one_pulse op_rst(.clk(clk_20), .pb_in(debounced_rst), .pb_out(pb_out_rst));


    parameter RST = 0;
    parameter LEFT = 1;
    parameter LR = 2;
    parameter RIGHT = 3;

    reg [1:0] state;
    reg [1:0] next_state;
    reg [15:0] next_led;
    reg signed [5:0] next_idx;
    reg signed [5:0] cur_idx;
    integer i;
    
    always @(posedge clk_20, posedge pb_out_rst) begin
        if(pb_out_rst) state <= RST;
        else state <= next_state;
    end

    always @* begin
        next_led <= LED;
        next_idx <= cur_idx;
        case (state)
            RST: begin
                next_idx <= 16;
                next_led <= 16'b0;
                next_state <= LEFT;
            end
            LEFT: begin
                if(pb_out_btnL && !debounced_btnR) begin
                    if(cur_idx == 16) begin
                        next_idx <= cur_idx - 1;
                        next_led[next_idx] <= 1;
                        next_state <= LR; 
                    end
                end
                else next_state <= LEFT;
            end
            LR: begin
                if(pb_out_btnL && !debounced_btnR) begin
                    if(cur_idx != 0) begin
                        next_idx <= cur_idx - 1;
                        next_led[next_idx] <= 1;
                        if(next_idx == 0) next_state <= RIGHT;
                        else next_state <= LR;
                    end
                end
                else if(pb_out_btnR && !debounced_btnL) begin
                    if(cur_idx != 16) begin
                        next_idx <= cur_idx + 1;
                        next_led[cur_idx] <= 0;
                        if(next_idx == 16) next_state <= LEFT;
                        else next_state <= LR;
                    end
                end
                else begin
                    next_state <= LR;
                end
            end
            RIGHT: begin
                if(pb_out_btnR && !debounced_btnL) begin
                    if(cur_idx == 0) begin
                        next_idx <= cur_idx + 1;
                        next_led[cur_idx] <= 0;
                        next_state <= LR;
                    end
                end
                else next_state <= RIGHT;
            end
    endcase
    end

    always @(posedge clk_20) begin
        LED <= next_led;
        cur_idx <= next_idx;
    end

endmodule