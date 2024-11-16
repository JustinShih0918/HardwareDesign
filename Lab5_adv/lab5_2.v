module lab5_2 (
    input wire clk,
    input wire rst,
    input wire start,
    input wire hint,
    inout wire PS2_CLK,
    inout wire PS2_DATA,
    output reg [3:0] vgaRed,
    output reg [3:0] vgaGreen,
    output reg [3:0] vgaBlue,
    output reg hsync,
    output reg vsync,
    output reg pass
);
    wire [11:0] data;
    wire clk_25MHz;
    wire clk_22;
    wire [16:0] pixel_addr;
    wire [11:0] pixel_1, pixel_2, pixel_3, pixel_4, pixel_5, pixel_6, pixel_7, pixel_8;
    wire [11:0] pixel;
    wire [3:0] img_select;
    wire valid;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480

    vga_controller vga_inst(
        .pclk(clk_25MHz),
        .reset(rst),
        .hsync(hsync),
        .vsync(vsync),
        .valid(valid),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt)
    );

    mem_addr_gen mem_addr_gen_inst(
        .clk(clk_22),
        .rst(rst),
        .start(start),
        .hint(hint),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .img_select(img_select),
        .pixel_addr(pixel_addr)
    );

    // memory modules
{
    blk_mem_gen_1 blk_mem_gen_1_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel_1)
    );

    blk_mem_gen_2 blk_mem_gen_2_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel_2)
    );

    blk_mem_gen_3 blk_mem_gen_3_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel_3)
    );

    blk_mem_gen_4 blk_mem_gen_4_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel_4)
    );

    blk_mem_gen_5 blk_mem_gen_5_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel_5)
    );

    blk_mem_gen_6 blk_mem_gen_6_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel_6)
    );

    blk_mem_gen_7 blk_mem_gen_7_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel_7)
    );

    blk_mem_gen_8 blk_mem_gen_8_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel_8)
    );
}
    always @(*) begin
        case (img_select)
            4'b0000 : pixel = pixel_1;
            4'b0001 : pixel = pixel_2;
            4'b0010 : pixel = pixel_3;
            4'b0011 : pixel = pixel_4;
            4'b0100 : pixel = pixel_5;
            4'b0101 : pixel = pixel_6;
            4'b0110 : pixel = pixel_7;
            4'b0111 : pixel = pixel_8;
            4'b1000 : pixel = pixel_1;
            4'b1001 : pixel = pixel_2;
            4'b1010 : pixel = pixel_3;
            4'b1011 : pixel = pixel_4;
            4'b1100 : pixel = pixel_5;
            4'b1101 : pixel = pixel_6;
            4'b1110 : pixel = pixel_7;
            4'b1111 : pixel = pixel_8;
            default: pixel = 12'h000;
        endcase
    end

    assign {vgaRed, vgaGreen, vgaBlue} = (valid) ? pixel : 12'h000;

endmodule

module mem_addr_gen(
    input clk,
    input rst,
    input start,
    input hint,
    input wire [9:0] h_cnt,
    input wire [9:0] v_cnt,
    output reg [3:0] img_select,
    output [16:0] pixel_addr
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
        img_y = y % 60;
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