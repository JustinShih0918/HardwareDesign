module lab5_2 (
    input wire clk,
    input wire rst,
    input wire start,
    input wire hint,
    inout wire PS2_CLK,
    inout wire PS2_DATA,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue,
    output wire hsync,
    output wire vsync,
    output reg pass
);
    wire [11:0] data;
    wire clk_25MHz;
    wire clk_22;
    wire [16:0] pixel_addr;
    wire [11:0] pixel_original_data [0:7];
    reg [11:0] pixel;
    wire [3:0] img_select;
    wire valid;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480

    wire dp_start;
    wire dp_hint;
    debounce dp_inst(
        .pb_debounced(dp_start),
        .pb(start),
        .clk(clk)
    );

    debounce dp_hint_inst(
        .pb_debounced(dp_hint),
        .pb(hint),
        .clk(clk)
    );

    wire out_start;
    wire out_hint;
    one_pulse op_inst(
        .clk(clk),
        .pb_in(dp_start),
        .pb_out(out_start)
    );

    one_pulse op_hint_inst(
        .clk(clk),
        .pb_in(dp_hint),
        .pb_out(out_hint)
    );


    vga_controller vga_inst(
        .pclk(clk_25MHz),
        .reset(rst),
        .hsync(hsync),
        .vsync(vsync),
        .valid(valid),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt)
    );

    clock_divider clk_wiz_0_inst(
        .clk(clk),
        .clk1(clk_25MHz),
        .clk22(clk_22)
    );

    // memory modules
    blk_mem_gen_1 blk_mem_gen_1_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel_original_data[0])
    );

    blk_mem_gen_2 blk_mem_gen_2_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel_original_data[1])
    );

    blk_mem_gen_3 blk_mem_gen_3_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel_original_data[2])
    );

    blk_mem_gen_4 blk_mem_gen_4_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel_original_data[3])
    );

    blk_mem_gen_5 blk_mem_gen_5_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel_original_data[4])
    );

    blk_mem_gen_6 blk_mem_gen_6_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel_original_data[5])
    );

    blk_mem_gen_7 blk_mem_gen_7_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel_original_data[6])
    );

    blk_mem_gen_8 blk_mem_gen_8_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel_original_data[7])
    );

    reg [11:0] img_pixel_data [0:15];
    reg [15:0] img_flip;
    parameter INIT = 0;
    parameter SHOW = 1;
    parameter GAME = 2;
    parameter FINISH = 3;

    reg [1:0] state, next_state;

    always @(posedge clk, posedge rst) begin
        if(rst) state <= INIT;
        else state <= next_state;
    end

    always @(*) begin
        case (state)
            INIT: begin
                if(out_start) next_state <= SHOW;
                else next_state <= INIT;
            end
            SHOW: begin
                if(out_start) next_state <= GAME;
                else next_state <= SHOW;
            end
            default: next_state <= next_state;
        endcase
    end

    integer i;
    always @(posedge clk) begin
        if(state == INIT) begin
            for(i = 0; i < 16; i = i + 1) img_pixel_data[i] <= 12'h000;
            for(i = 0; i < 16; i = i + 1) begin
                img_flip[i] <= 0;
                if(i == 0 || i == 2 || i == 3) img_flip[i] <= 1;
            end
        end
        else if(state == SHOW) begin
            img_pixel_data[0] <= pixel_original_data[0];
            img_pixel_data[1] <= pixel_original_data[1];
            img_pixel_data[2] <= pixel_original_data[2];
            img_pixel_data[3] <= pixel_original_data[3];
            img_pixel_data[4] <= pixel_original_data[4];
            img_pixel_data[5] <= pixel_original_data[5];
            img_pixel_data[6] <= pixel_original_data[6];
            img_pixel_data[7] <= pixel_original_data[7];
            img_pixel_data[8] <= pixel_original_data[0];
            img_pixel_data[9] <= pixel_original_data[1];
            img_pixel_data[10] <= pixel_original_data[2];
            img_pixel_data[11] <= pixel_original_data[3];
            img_pixel_data[12] <= pixel_original_data[4];
            img_pixel_data[13] <= pixel_original_data[5];
            img_pixel_data[14] <= pixel_original_data[6];
            img_pixel_data[15] <= pixel_original_data[7];
        end
    end


    mem_addr_gen mem_addr_gen_inst(
        .clk(clk_25MHz),
        .rst(rst),
        .start(out_start),
        .hint(out_hint),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .img_flip(img_flip),
        .img_select(img_select),
        .pixel_addr(pixel_addr)
    );

    always @(*) begin
        case (img_select)
            4'b0000 : pixel = img_pixel_data[0];
            4'b0001 : pixel = img_pixel_data[1];
            4'b0010 : pixel = img_pixel_data[2];
            4'b0011 : pixel = img_pixel_data[3];
            4'b0100 : pixel = img_pixel_data[4];
            4'b0101 : pixel = img_pixel_data[5];
            4'b0110 : pixel = img_pixel_data[6];
            4'b0111 : pixel = img_pixel_data[7];
            4'b1000 : pixel = img_pixel_data[0];
            4'b1001 : pixel = img_pixel_data[1];
            4'b1010 : pixel = img_pixel_data[2];
            4'b1011 : pixel = img_pixel_data[3];
            4'b1100 : pixel = img_pixel_data[4];
            4'b1101 : pixel = img_pixel_data[5];
            4'b1110 : pixel = img_pixel_data[6];
            4'b1111 : pixel = img_pixel_data[7];
            default: pixel = 12'h000;
        endcase
    end

    assign {vgaRed, vgaGreen, vgaBlue} = (valid == 1'b1) ? pixel : 12'h000;

endmodule

module mem_addr_gen(
    input clk,
    input rst,
    input start,
    input hint,
    input wire [9:0] h_cnt,
    input wire [9:0] v_cnt,
    input [15:0] img_flip,
    output reg [3:0] img_select,
    output reg [16:0] pixel_addr
);

    wire [9:0] x = h_cnt >> 1;
    wire [9:0] y = v_cnt >> 1;

    wire [1:0] grid_col = x/80;
    wire [1:0] grid_row = y/60;

    always @(*) begin
        img_select = grid_row * 4 + grid_col;
    end

    reg [6:0] img_x;
    reg [6:0] img_y;
    always @(*) begin
        img_x = x % 80;
        if(img_flip[img_select] == 1) img_y = (59 - y + 60) % 60;
        else img_y = y % 60;
        pixel_addr = img_x + img_y * 80;
    end
    
endmodule

module vga_controller (
    input wire pclk, reset,
    output wire hsync, vsync, valid,
    output wire [9:0]h_cnt,
    output wire [9:0]v_cnt
    );

    reg [9:0]pixel_cnt;
    reg [9:0]line_cnt;
    reg hsync_i,vsync_i;

    parameter HD = 640;
    parameter HF = 16;
    parameter HS = 96;
    parameter HB = 48;
    parameter HT = 800; 
    parameter VD = 480;
    parameter VF = 10;
    parameter VS = 2;
    parameter VB = 33;
    parameter VT = 525;
    parameter hsync_default = 1'b1;
    parameter vsync_default = 1'b1;

    always @(posedge pclk)
        if (reset)
            pixel_cnt <= 0;
        else
            if (pixel_cnt < (HT - 1))
                pixel_cnt <= pixel_cnt + 1;
            else
                pixel_cnt <= 0;

    always @(posedge pclk)
        if (reset)
            hsync_i <= hsync_default;
        else
            if ((pixel_cnt >= (HD + HF - 1)) && (pixel_cnt < (HD + HF + HS - 1)))
                hsync_i <= ~hsync_default;
            else
                hsync_i <= hsync_default; 

    always @(posedge pclk)
        if (reset)
            line_cnt <= 0;
        else
            if (pixel_cnt == (HT -1))
                if (line_cnt < (VT - 1))
                    line_cnt <= line_cnt + 1;
                else
                    line_cnt <= 0;

    always @(posedge pclk)
        if (reset)
            vsync_i <= vsync_default; 
        else if ((line_cnt >= (VD + VF - 1)) && (line_cnt < (VD + VF + VS - 1)))
            vsync_i <= ~vsync_default; 
        else
            vsync_i <= vsync_default; 

    assign hsync = hsync_i;
    assign vsync = vsync_i;
    assign valid = ((pixel_cnt < HD) && (line_cnt < VD));

    assign h_cnt = (pixel_cnt < HD) ? pixel_cnt : 10'd0;
    assign v_cnt = (line_cnt < VD) ? line_cnt : 10'd0;
endmodule

module clock_divider(clk1, clk, clk22);
    input clk;
    output clk1;
    output clk22;
    reg [21:0] num;
    wire [21:0] next_num;

    always @(posedge clk) begin
    num <= next_num;
    end

    assign next_num = num + 1'b1;
    assign clk1 = num[1];
    assign clk22 = num[21];
endmodule

module debounce(
    output pb_debounced, 
    input pb ,
    input clk
    );
    
    reg [6:0] shift_reg;
    always @(posedge clk) begin
        shift_reg[6:1] <= shift_reg[5:0];
        shift_reg[0] <= pb;
    end
    
    assign pb_debounced = shift_reg == 7'b111_1111 ? 1'b1 : 1'b0;
endmodule

module one_pulse (
    input wire clk,
    input wire pb_in,
    output reg pb_out
);

	reg pb_in_delay;

	always @(posedge clk) begin
		if (pb_in == 1'b1 && pb_in_delay == 1'b0) begin
			pb_out <= 1'b1;
		end else begin
			pb_out <= 1'b0;
		end
	end
	
	always @(posedge clk) begin
		pb_in_delay <= pb_in;
	end
endmodule