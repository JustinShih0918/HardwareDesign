`define silence   32'd50000000
`define c4 32'd262   // C4
`define d4 32'd294   // D4
`define e4 32'd330   // E4
`define f4 32'd350   // F4
`define g4 32'd392   // G4
`define a4 32'd440   // A4
`define b4 32'd494   // B4

module lab4_3(
    input wire clk,
    input wire rst,        // BTNC: active high reset
    input wire volUP,     // BTNU: Vol up
    input wire volDOWN,   // BTND: Vol down
    input wire octaveUP,  // BTNR: Octave up
    input wire octaveDOWN,// BTNL: Octave down
    inout wire PS2_DATA,   // Keyboard I/O
    inout wire PS2_CLK,    // Keyboard I/O
    output reg [4:0] LED,       // LED: [4:0] volume
    output wire audio_mclk, // master clock
    output wire audio_lrck, // left-right clock
    output wire audio_sck,  // serial clock
    output wire audio_sdin, // serial audio data input
    output wire [6:0] DISPLAY,
    output wire [3:0] DIGIT
    );      
    
    // button porcessing
    wire clk_16;
    clock_divider #(.n(16)) clock_10(.clk(clk), .clk_div(clk_16));
    
    wire dp_Volup;
    wire dp_Voldown;
    wire dp_Oup;
    wire dp_Odown;
    wire dp_rst;
    debounce db_u(.pb_debounced(dp_Volup), .pb(volUP), .clk(clk_16));
    debounce db_d(.pb_debounced(dp_Voldown), .pb(volDOWN), .clk(clk_16));
    debounce db_r(.pb_debounced(dp_Oup), .pb(octaveUP), .clk(clk_16));
    debounce db_l(.pb_debounced(dp_Odown), .pb(octaveDOWN), .clk(clk_16));
    debounce db_rst(.pb_debounced(dp_rst), .pb(rst), .clk(clk_16));

    wire out_volUp;
    wire out_volDown;
    wire out_octUp;
    wire out_octDown;
    wire out_rst;
    one_pulse op_vu(.clk(clk), .pb_in(dp_Volup), .pb_out(out_volUp));
    one_pulse op_vd(.clk(clk), .pb_in(dp_Voldown), .pb_out(out_volDown));
    one_pulse op_ou(.clk(clk), .pb_in(dp_Oup), .pb_out(out_octUp));
    one_pulse op_od(.clk(clk), .pb_in(dp_Odown), .pb_out(out_octDown));
    one_pulse op_rst(.clk(clk), .pb_in(dp_rst), .pb_out(out_rst));

    // Internal Signal
    wire [15:0] audio_in_left, audio_in_right;

    reg [31:0] freqL, freqR;           // Raw frequency
    wire [21:0] freq_outL, freq_outR;    // Processed frequency, adapted to the clock rate of Basys3

    // clkDiv22
    wire clkDiv22;
    clock_divider #(.n(22)) clock_22(.clk(clk), .clk_div(clkDiv22));    // for audio
    // freq_outL, freq_outR
    // Note gen makes no sound, if freq_out = 50000000 / `silence = 1
    assign freq_outL = 50000000 / freqL;
    assign freq_outR = 50000000 / freqR;

    // Note generation
    // [in]  processed frequency
    // [out] audio wave signal (using square wave here)
    reg [3:0] vol;
    note_gen noteGen_00(
        .clk(clk), 
        .rst(rst), 
        .volume(vol),
        .note_div_left(freq_outL), 
        .note_div_right(freq_outR), 
        .audio_left(audio_in_left),     // left sound audio
        .audio_right(audio_in_right)    // right sound audio
    );

    // Speaker controller
    speaker_control sc(
        .clk(clk), 
        .rst(rst), 
        .audio_in_left(audio_in_left),      // left channel audio data input
        .audio_in_right(audio_in_right),    // right channel audio data input
        .audio_mclk(audio_mclk),            // master clock
        .audio_lrck(audio_lrck),            // left-right clock
        .audio_sck(audio_sck),              // serial clock
        .audio_sdin(audio_sdin)             // serial audio data input
    );

    // keyboard controller and 7-segment display controller
    reg [15:0] nums;
    reg [3:0] key_num;
    reg [3:0] cur_key_num;
    reg [9:0] last_key;
    wire [511:0] key_down;
    wire [8:0] last_change;
    reg [8:0] prev_change;
    reg delay_prev;
    wire been_ready;
    always @(posedge clk) begin
        delay_prev <= key_down[prev_change];
    end
    parameter [8:0] key_code [0:6] = {
        9'b0_0001_1100, // a -> 1C
        9'b0_0001_1011, // s -> 1B
        9'b0_0010_0011, // d -> 23
        9'b0_0010_1011, // f -> 2B
        9'b0_0011_0100,  // g -> 34
        9'b0_0011_0011,  // h -> 33
        9'b0_0011_1011  // j -> 3B
    };

    SevenSegment seven_seg(
        .display(DISPLAY),
        .digit(DIGIT),
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
        .rst(out_rst),
        .clk(clk)
    );

    reg [3:0] octLevel;
    reg [31:0] next_freq;

    always @(posedge clk, posedge out_rst) begin
        if(out_rst) begin
            nums <= 16'b1111_1111_1111_1111;
            freqL <= `silence;
            freqR <= `silence;
        end
        else begin
            nums <= nums;
            freqL <= freqL;
            freqR <= freqR;
            prev_change <= prev_change;
            if(key_down[last_change] == 1'b1 && delay_prev == 1'b0) begin
                if(key_num != 4'b1111) begin
                    cur_key_num <= key_num;
                    nums <= {8'b1111_1111, key_num, octLevel};
                    freqL <= next_freq;
                    freqR <= next_freq;
                    prev_change <= last_change;
                end
            end
            else if(key_down[prev_change] == 1'b1) begin
                if(cur_key_num != 4'b1111) begin
                    cur_key_num <= cur_key_num;
                    nums <= {8'b1111_1111, cur_key_num, octLevel};
                    freqL <= next_freq;
                    freqR <= next_freq;
                    prev_change <= prev_change;

                    if(octLevel >=4) begin
                        case(cur_key_num)
                            4'b1010 : next_freq <= `c4 * 2 ** (octLevel - 4);
                            4'b1011 : next_freq <= `d4 * 2 ** (octLevel - 4);
                            4'b1100 : next_freq <= `e4 * 2 ** (octLevel - 4);
                            4'b1101 : next_freq <= `f4 * 2 ** (octLevel - 4);
                            4'b1001 : next_freq <= `g4 * 2 ** (octLevel - 4);
                            4'b1110 : next_freq <= `a4 * 2 ** (octLevel - 4);
                            4'b0110 : next_freq <= `b4 * 2 ** (octLevel - 4);
                            default : next_freq <= `silence;
                        endcase 
                    end
                    else if(octLevel == 3) begin
                        case(cur_key_num)
                            4'b1010 : next_freq <= `c4 / 2;
                            4'b1011 : next_freq <= `d4 / 2;
                            4'b1100 : next_freq <= `e4 / 2;
                            4'b1101 : next_freq <= `f4 / 2;
                            4'b1001 : next_freq <= `g4 / 2;
                            4'b1110 : next_freq <= `a4 / 2;
                            4'b0110 : next_freq <= `b4 / 2;
                            default : next_freq <= `silence;
                        endcase
                    end
                end
            end
            else if(key_down[last_change] == 1'b0) begin
                nums <= 16'b1111_1111_1111_1111;
                freqL <= `silence;
                freqR <= `silence;
            end
        end
    end

    always @(posedge clk, posedge out_rst) begin
        if(out_rst) octLevel <= 4;
        else begin
            if(out_octUp && octLevel < 5) octLevel <= octLevel + 1;
            else if(out_octDown && octLevel > 3) octLevel <= octLevel - 1;
            else octLevel <= octLevel;
        end
    end

    // mapping
    always @(*) begin
        case(last_change)
            key_code[00] : key_num <= 4'b1010;
            key_code[01] : key_num <= 4'b1011;
            key_code[02] : key_num <= 4'b1100;
            key_code[03] : key_num <= 4'b1101;
            key_code[04] : key_num <= 4'b1001;
            key_code[05] : key_num <= 4'b1110;
            key_code[06] : key_num <= 4'b0110;
            default : key_num <= 4'b1111;
        endcase
    end

    // led controller
    reg [4:0] next_led;
    always @(posedge clk, posedge out_rst) begin
        if(out_rst) LED <= 5'b00111;
        else LED <= next_led;
    end

    integer i;
    always @(posedge clk, posedge out_rst) begin
        if(out_rst) begin
            vol <= 3;
            next_led <= 5'b00111;
        end
        else begin
            if(out_volUp && vol < 5) vol <= vol + 1;
            else if(out_volDown && vol > 1) vol <= vol - 1;
            else vol <= vol;
            for(i = 0; i<5; i = i + 1) begin
                if(i<vol) next_led[i] <= 1;
                else next_led[i] <= 0;
            end
        end
    end


    

endmodule
