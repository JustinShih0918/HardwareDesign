module lab4_1 (
    input wire clk,
    input wire rst,
    inout wire PS2_DATA,
    inout wire PS2_CLK,
    output wire [3:0] digit,
    output wire [6:0] display
);
    parameter [8:0] LEFT_SHIFT_CODES  = 9'b0_0001_0010;
    parameter [8:0] RIGHT_SHIFT_CODES = 9'b0_0101_1001;
    parameter [8:0] key_code [0:19] = {
        9'b0_0100_0101,	// 0 => 45
		9'b0_0001_0110,	// 1 => 16
		9'b0_0001_1110,	// 2 => 1E
		9'b0_0010_0110,	// 3 => 26
		9'b0_0010_0101,	// 4 => 25
		9'b0_0010_1110,	// 5 => 2E
		9'b0_0011_0110,	// 6 => 36
		9'b0_0011_1101,	// 7 => 3D
		9'b0_0011_1110,	// 8 => 3E
		9'b0_0100_0110,	// 9 => 46
		
		9'b0_0111_0000, // right_0 => 70
		9'b0_0110_1001, // right_1 => 69
		9'b0_0111_0010, // right_2 => 72
		9'b0_0111_1010, // right_3 => 7A
		9'b0_0110_1011, // right_4 => 6B
		9'b0_0111_0011, // right_5 => 73
		9'b0_0111_0100, // right_6 => 74
		9'b0_0110_1100, // right_7 => 6C
		9'b0_0111_0101, // right_8 => 75
		9'b0_0111_1101  // right_9 => 7D
   };

    reg [15:0] nums;
    reg [3:0] key_num;
    reg [9:0] last_key;

    wire shift_down;
    wire [511:0] key_down;
    wire [8:0] last_change;
    wire been_ready;

    assign shift_down = (key_down[LEFT_SHIFT_CODES] == 1'b1 || key_down[RIGHT_SHIFT_CODES] == 1'b1) ? 1'b1 : 1'b0;

    SevenSegment seven_seg(
        .display(display),
        .digit(digit),
        .nums(nums),
        .rst(rst),
        .clk(clk)
    );

    KeyboardDecoder key_de(
        .key_down(key_down),
        .last_change(last_change),
        .key_valid(been_ready),
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .rst(rst),
        .clk(clk)
    );

    // one pulse for each key press
    reg [8:0] prev_change;

    // use 4'b1111 for rst
    always @(posedge clk, posedge rst) begin
        if(rst) nums <= 16'b1111_1111_1111_1111;
        else begin
            nums <= nums;
            prev_change <= prev_change;
            if(been_ready && key_down[last_change] == 1'b1 && key_down[prev_change] == 1'b0) begin
                if(key_num != 4'b1111) begin
                    if(shift_down == 1'b1) nums <= {nums[11:0], key_num};
                    else nums <= {key_num, nums[15:4]};
                    prev_change <= last_change;
                end
            end
        end
    end

    // mapping to the correct value
    always @(*) begin
        case (last_change)
            key_code[00] : key_num = 4'b0000;
			key_code[01] : key_num = 4'b0001;
			key_code[02] : key_num = 4'b0010;
			key_code[03] : key_num = 4'b0011;
			key_code[04] : key_num = 4'b0100;
			key_code[05] : key_num = 4'b0101;
			key_code[06] : key_num = 4'b0110;
			key_code[07] : key_num = 4'b0111;
			key_code[08] : key_num = 4'b1000;
			key_code[09] : key_num = 4'b1001;
			key_code[10] : key_num = 4'b0000;
			key_code[11] : key_num = 4'b0001;
			key_code[12] : key_num = 4'b0010;
			key_code[13] : key_num = 4'b0011;
			key_code[14] : key_num = 4'b0100;
			key_code[15] : key_num = 4'b0101;
			key_code[16] : key_num = 4'b0110;
			key_code[17] : key_num = 4'b0111;
			key_code[18] : key_num = 4'b1000;
			key_code[19] : key_num = 4'b1001;
			default		  : key_num = 4'b1111;
        endcase
    end

endmodule