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
    reg [3:0] next_idx;
    reg [3:0] cur_idx;
    integer i;
    
    always @(posedge clk_20, posedge pb_out_rst) begin
        if(pb_out_rst) state <= RST;
        else state <= next_state;
    end

    always @* begin
        case (state)
            RST: begin
                if(pb_out_rst) next_state <= RST;
                else next_state <= LEFT;
            end
            LEFT: begin
                if(LED[0] == 0) next_state <= LEFT;
                else if(LED[15]) next_state <= RIGHT;
                else next_state <= LR; 
            end
            LR: begin
                if(LED[0] == 0) next_state <= LEFT;
                else if(LED[15])next_state <= RIGHT;
                else next_state <= LR;
            end
            RIGHT: begin
                if(LED[15] == 0) next_state <= RIGHT;
                else if(LED[0]) next_state <= LEFT;
                else next_state <= LR;
            end
            default: 
                next_state <= RST;
        endcase
    end

    always @(posedge clk_20) begin
        LED <= next_led;
        cur_idx <= next_idx;
    end

    always @* begin
        next_led = LED;
        next_idx = cur_idx;
        case (state)
            RST: begin
                next_led = 16'b0000_0000_0000_0000;
                next_idx = 0;
            end
            LEFT: begin
                if(pb_out_btnL) begin
                    next_led = 16'b1000_0000_0000_0000;
                    next_idx = 15;
                end
                else;
            end
            LR: begin
                if(pb_out_btnL) begin
                    next_idx = cur_idx - 1;
                    next_led[next_idx] = 1;
                end
                else if(pb_out_btnR) begin
                    next_idx = cur_idx + 1;
                    next_led[next_idx] = 0;
                end
                else;
            end
            RIGHT: begin
                if(pb_out_btnR) begin
                    next_led = 16'b1111_1111_1111_1111;
                    next_idx = 0;
                end
                else;
            end
            default: begin
                next_led = 16'b0000_0000_0000_0000;
                next_idx = 4'b0000;
            end
        endcase
    end


endmodule