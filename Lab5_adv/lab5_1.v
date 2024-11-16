module lab5_1 (
    input wire clk,
    input wire rst,
    input wire en,
    input wire dir,
    input wire vmir,
    input wire hmir,
    input wire enlarge,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue,
    output hsync,
    output vsync
);

    wire [11:0] data;
    wire clk_25MHz;
    wire clk_22;
    wire [16:0] pixel_addr;
    wire [11:0] pixel;
    wire valid;
    wire [9:0] h_cnt; //640
    wire [9:0] v_cnt;  //480
    
    assign {vgaRed, vgaGreen, vgaBlue} = (valid==1'b1) ? pixel:12'h0;

    clock_divider clk_wiz_0_inst(
      .clk(clk),
      .clk1(clk_25MHz),
      .clk22(clk_22)
    );

    mem_addr_gen mem_addr_gen_inst(
        .clk(clk_22),
        .rst(rst),
        .en(en),
        .dir(dir),
        .vmir(vmir),
        .hmir(hmir),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .pixel_addr(pixel_addr)
    );

    blk_mem_gen_0 blk_mem_gen_0_inst(
        .clka(clk_25MHz),
        .wea(0),
        .addra(pixel_addr),
        .dina(data[11:0]),
        .douta(pixel)
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

endmodule

module mem_addr_gen(
    input clk,
    input rst,
    input en,
    input dir,
    input vmir,
    input hmir,
    input enlarge,
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    output [16:0] pixel_addr
);
    
    reg [9:0] run_x;
    reg [9:0] run_y; 
    reg [9:0] turn_y;
    reg [9:0] turn_x;
    parameter IMG_W = 320;
    parameter IMG_H = 240;

    wire [9:0] center_x = IMG_W/2;
    wire [9:0] center_y = IMG_H/2;

    reg [3:0] zoom;

    wire [9:0] xpos = center_x + ((h_cnt - 320) >> zoom);
    wire [9:0] ypos = center_y + ((v_cnt - 240) >> zoom);


    // enlarge
    always @ (posedge clk or posedge rst) begin
        if(rst) begin
            zoom <= 1;
        end                                                                                                                
        else if(enlarge) begin
            zoom <= 2;
        end
        else zoom <= 1;
    end

    // mirror
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            turn_x <= 0;
            turn_y <= 0;
        end
        else begin
            if(vmir && hmir) begin
                turn_x <= 640;
                turn_y <= 480;
            end
            else if(vmir) begin
                turn_y <= 480;
                turn_x <= 0;
            end
            else if(hmir) begin
                turn_x <= 640;
                turn_y <= 0;
            end
        end
    end

    // direction
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            run_x <= 0;
            run_y <= 0;
        end
        else if(en) begin
            if(dir) begin
                run_x <= run_x + 1;
                run_y <= run_y - 1;
                if(run_x == 319) run_x <= 0;
                else if(run_y == 0) run_y <= 239;
            end
            else begin
                run_x <= run_x - 1;
                run_y <= run_y + 1;
                if(run_x == 0) run_x <= 319;
                else if(run_y == 239) run_y <= 0;
            end
        end
        else begin
            run_x <= 0;
            run_y <= 0;
        end
    end
    

    assign pixel_addr = (vmir || hmir) ? ((((turn_x - (xpos + run_x)) % IMG_W)) + IMG_W * ((turn_y - (ypos + run_y)) % IMG_H)) % 76800 : ((((xpos + run_x) % IMG_W)) + IMG_W * ((ypos + run_y) % IMG_H)) % 76800;  //640*480 --> 320*240 
    
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