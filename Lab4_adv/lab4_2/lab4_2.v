module lab4_2 (
      input wire clk,
      input wire rst,
      input wire start,
      inout wire PS2_DATA,
      inout wire PS2_CLK,
      output reg [15:0] LED,
      output wire [3:0] digit,
      output wire [6:0] display
);

      // FSM states
      parameter INIT = 0;
      parameter SET = 1;
      parameter GAME = 2;
      parameter FINAL = 3;
      reg [1:0] state;
      reg [1:0] next_state;

      wire clk_20;
      wire clk_27;
      wire clk_26;
      wire out_rst;
      wire out_start;
      clock_divider #(.n(26)) clk_divider_26(.clk(clk), .clk_div(clk_26));
      clock_divider #(.n(27)) clk_divider_27(.clk(clk), .clk_div(clk_27));
      clock_divider #(.n(20)) clk_divider_20(.clk(clk), .clk_div(clk_20));
      one_pulse rst_pulse(.clk(clk_20), .pb_in(rst), .pb_out(out_rst));
      one_pulse start_pulse(.clk(clk_20), .pb_in(start), .pb_out(out_start));

      // FSM
      always @(posedge clk, posedge out_rst) begin
            if(out_rst) state <= INIT;
            else state <= next_state;
      end

      // state transition
      always @(posedge clk, posedge out_rst) begin
            if(out_rst) next_state <= INIT;
            else begin
                  case (state) 
                        INIT: begin
                              if(out_start) next_state <= SET;
                              else next_state <= INIT;
                        end
                        SET: begin
                              if(out_start) next_state <= GAME;
                              else next_state <= SET;
                        end
                        GAME: begin
                              next_state <= FINAL;
                        end
                        FINAL: begin
                              next_state <= INIT;
                        end
                  endcase
            end
      end

      // Keyboard Controller and 7-segment display controller
      reg [15:0] nums;
      reg [3:0] key_num;
      reg [9:0] last_key;
      wire [511:0] key_down;
      wire [8:0] last_change;
      wire been_ready;
      reg [8:0] prev_change;
      reg delay_prev;
      parameter [8:0] SPACE_CODE = 9'b0_0010_1001;
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

      SevenSegment seven_seg(
        .display(display),
        .digit(digit),
        .nums(nums),
        .rst(out_rst),
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

      // delay for key press
      always @(posedge clk) begin
            delay_prev <= key_down[prev_change];
      end

      // setting mode chnage
      parameter SET_TIME = 0;
      parameter SET_GOAL = 1;
      reg mode_change;
      always @(posedge clk) begin
            if(state == INIT) mode_change <= SET_TIME;
            else begin
                  mode_change <= mode_change;
                  if(been_ready && key_down[SPACE_CODE] == 1'b1 && delay_prev == 1'b0) begin
                        mode_change <= ~mode_change;      
                  end
            end
      end

      // update nums for each state
      reg [7:0] time_nums;
      reg [7:0] goal_nums;
      reg set_start;
      always @(posedge clk) begin
            nums <= nums;
            if(state == INIT) begin
                  nums <= 16'b1111_1111_1111_1111;
                  set_start <= 1'b1;
            end
            else if(state == SET) begin
                  if(set_start) begin
                        time_nums <= {4'b0011, 4'b0000};
                        goal_nums <= {4'b0001, 4'b0000};
                        set_start <= 1'b0;
                  end
                  else begin
                        time_nums <= time_nums;
                        goal_nums <= goal_nums;
                        if(been_ready && key_down[last_change] == 1'b1 && delay_prev == 1'b0) begin
                              if(key_num != 4'b1111) begin
                                    if(mode_change == SET_TIME) time_nums <= {time_nums[3:0], key_num};
                                    else goal_nums <= {goal_nums[3:0], key_num};
                              end     
                        end
                  end
                  nums <= {time_nums, goal_nums};
            end
      end

      // mapping key code to key_num
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
                  default: key_num = 4'b1111;
            endcase
      end

      // LED controller
      always @(posedge clk, posedge out_rst) begin
            if(out_rst) LED <= 16'b0000_0000_0000_0000;
            else LED <= next_led;
      end

      // LFSR for LED
      reg [8:0] LFSR_led;
      always @(posedge clk_27) begin
            if(state != GAME) LFSR_led <= 9'b0_0000_0000;
            else begin
                  LFSR_led[8] <= LFSR_led[0];
                  LFSR_led[7] <= LFSR_led[8];
                  LFSR_led[6] <= LFSR_led[7] ^ LFSR_led[0];
                  LFSR_led[5] <= LFSR_led[6] ^ LFSR_led[0];
                  LFSR_led[4] <= LFSR_led[5];
                  LFSR_led[3] <= LFSR_led[4] ^ LFSR_led[0];
                  LFSR_led[2] <= LFSR_led[3];
                  LFSR_led[1] <= LFSR_led[2];
                  LFSR_led[0] <= LFSR_led[1];
            end
      end

      // Flashing LED
      wire [15:0] flash_led;
      Flashing flash(.clk(clk_26), .led_in(LED), .LED(flash_led));

      reg [15:0] next_led;
      always @(posedge clk) begin
            next_led <= next_led;
            if(state == INIT) next_led <= 16'b0000_0000_0000_0000;
            else if(state == SET) begin
                  if(mode_change == SET_TIME) next_led <= 16'b1111_1111_0000_0000;
                  else next_led <= 16'b0000_0000_1111_1111;
            end
            else if(state == GAME) begin
                  next_led <= {LFSR_led, 7'b000_0000};
            end
            else if(state == FINAL) begin
                  next_led <= flash_led;
            end
      end
endmodule

module Flashing (
      input wire clk,
      input wire [15:0] led_in,
      output wire [15:0] LED
);

      reg [15:0] tmp;
      always @(posedge clk) begin
            tmp <= !LED;
      end
      assign LED = tmp;
endmodule