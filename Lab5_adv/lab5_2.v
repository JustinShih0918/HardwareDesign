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
    wire [11:0] pixel_original_data [0:15];
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
    assign pixel_original_data[8] = pixel_original_data[0];
    assign pixel_original_data[9] = pixel_original_data[1];
    assign pixel_original_data[10] = pixel_original_data[2];
    assign pixel_original_data[11] = pixel_original_data[3];
    assign pixel_original_data[12] = pixel_original_data[4];
    assign pixel_original_data[13] = pixel_original_data[5];
    assign pixel_original_data[14] = pixel_original_data[6];
    assign pixel_original_data[15] = pixel_original_data[7];

    parameter [11:0] img_pos [0:15] = {
        12'd0, 12'd1, 12'd2, 12'd3, 12'd4, 12'd5, 12'd6, 12'd7, 12'd0, 12'd1, 12'd2, 12'd3, 12'd4, 12'd5, 12'd6, 12'd7
    };

    reg [15:0] is_good;

    // keyboard
    reg [4:0] key_num;
    wire [511:0] key_down;
    wire [8:0] last_change;
    reg [8:0] prev_change;
    reg delay_prev;
    wire been_ready;
    parameter [8:0] key_code [0:17] = {
        // 1 -> 16
        9'b0_0001_0110,
        // 2 -> 1E
        9'b0_0001_1110,
        // 3 -> 26
        9'b0_0010_0110,
        // 4 -> 25
        9'b0_0010_0101,
        // Q -> 15
        9'b0_0001_0101,
        // W -> 1D
        9'b0_0001_1101,
        // E -> 24
        9'b0_0010_0100,
        // R -> 2D
        9'b0_0010_1101,
        // A -> 1C
        9'b0_0001_1100,
        // S -> 1B
        9'b0_0001_1011,
        // D -> 23
        9'b0_0010_0011,
        // F -> 2B
        9'b0_0010_1011,
        // Z -> 1A
        9'b0_0001_1010,
        // X -> 22
        9'b0_0010_0010,
        // C -> 21
        9'b0_0010_0001,
        // V -> 2A
        9'b0_0010_1010,
        // left shift -> 12
        9'b0_0001_0010,
        // Enter -> 5A
        9'b0_0101_1010
    };
    parameter ENTER = 9'b0_0101_1010;

    always @(*) begin
        case (prev_change_1)
            key_code[0] : key_num = 5'b00000;
            key_code[1] : key_num = 5'b00001;
            key_code[2] : key_num = 5'b00010;
            key_code[3] : key_num = 5'b00011;
            key_code[4] : key_num = 5'b00100;
            key_code[5] : key_num = 5'b00101;
            key_code[6] : key_num = 5'b00110;
            key_code[7] : key_num = 5'b00111;
            key_code[8] : key_num = 5'b01000;
            key_code[9] : key_num = 5'b01001;
            key_code[10] : key_num = 5'b01010;
            key_code[11] : key_num = 5'b01011;
            key_code[12] : key_num = 5'b01100;
            key_code[13] : key_num = 5'b01101;
            key_code[14] : key_num = 5'b01110;
            key_code[15] : key_num = 5'b01111;
            key_code[16] : key_num = 5'b01111; // left shift
            key_code[17] : key_num = 5'b10000; // enter
            default: key_num = 5'b11111;
        endcase
    end

    KeyboardDecoder key_de(
        .key_down(key_down),
        .last_change(last_change),
        .key_valid(been_ready),
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .rst(out_rst),
        .clk(clk)
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

    reg [5:0] win_cnt;
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
            GAME: begin
                if(win_cnt == 8) next_state <= FINISH;
                else next_state <= GAME;
            end
            FINISH: begin
                if(out_start) next_state <= INIT;
                else next_state <= FINISH;
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
                is_good[i] <= 0;
                if(i == 0 || i == 2 || i == 3) img_flip[i] <= 1;
            end
            win_cnt <= 0;
            pass <= 0;
        end
        else if(state == SHOW) begin
            for(i = 0 ; i < 16 ; i = i + 1) img_pixel_data[i] <= pixel_original_data[i];
            win_cnt <= 0;
            for(i = 0; i < 16; i = i + 1) begin
                img_flip[i] <= 0;
                is_good[i] <= 0;
                if(i == 0 || i == 2 || i == 3) img_flip[i] <= 1;
            end
        end
        else if(next_state == GANE && state == SHOW) begin
            for(i = 0 ; i < 16 ; i = i + 1) img_pixel_data[i] <= 12'h000;
        end
        else if(state == GAME) begin
            if(out_hint) begin
                for(i = 0 ; i < 16 ; i = i + 1) img_pixel_data[i] <= pixel_original_data[i];
            end
            else begin
                win_cnt <= win_cnt;
                if(key_down[last_change] && last_change != ENTER) begin
                    if(key_num <= 15 && key_num >= 0) begin
                        img_pixel_data[key_num] <= pixel_original_data[key_num];
                        is_good[key_num] <= 1;
                    end
                end
                else if(key_down[last_change] && last_change == ENTER) begin
                    for(i = 0 ; i < 16 ; i = i + 1) begin
                        if(is_good[i] == 1) img_pixel_data[i] <= img_pixel_data[i];
                        else img_pixel_data[i] <= 12'h000;
                    end
                end
                else begin
                    for(i = 0 ; i < 16 ; i = i + 1) img_pixel_data[i] <= img_pixel_data[i];
                end
            end
        end
        else if(state == FINISH) begin
            pass <= 1;
            for(i = 0 ; i < 16 ; i = i + 1) img_pixel_data[i] <= pixel_original_data[i];
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
            4'b1000 : pixel = img_pixel_data[8];
            4'b1001 : pixel = img_pixel_data[9];
            4'b1010 : pixel = img_pixel_data[10];
            4'b1011 : pixel = img_pixel_data[11];
            4'b1100 : pixel = img_pixel_data[12];
            4'b1101 : pixel = img_pixel_data[13];
            4'b1110 : pixel = img_pixel_data[14];
            4'b1111 : pixel = img_pixel_data[15];
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