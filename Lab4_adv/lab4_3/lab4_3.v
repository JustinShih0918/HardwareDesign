`define silence   32'd50000000
`define c4  32'd262   // C4

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
    

    // Internal Signal
    wire [15:0] audio_in_left, audio_in_right;

    wire [31:0] freqL, freqR;           // Raw frequency
    wire [21:0] freq_outL, freq_outR;    // Processed frequency, adapted to the clock rate of Basys3

    /*------------------ This part does not included in Lab4 ------------------*/
    // wire [11:0] ibeatNum;               // Beat counter

    // Player Control
    // [in]  reset, clock, _play, _slow, _music, and _mode
    // [out] beat number
    // player_control #(.LEN(128)) playerCtrl_00 ( 
    //     .clk(clkDiv22),
    //     .reset(rst),
    //     ._play(1'b1), 
    //     ._mode(1'b0),
    //     .ibeat(ibeatNum)
    // );

    // Music module
    // [in]  beat number and en
    // [out] left & right raw frequency
    // music_example music_00 (
    //     .ibeatNum(ibeatNum),
    //     .en(1'b1),
    //     .toneL(freqL),
    //     .toneR(freqR)
    // );
    /*------------------------------------------------------------------------*/

    // clkDiv22
    wire clkDiv22;
    clock_divider #(.n(22)) clock_22(.clk(clk), .clk_div(clkDiv22));    // for audio
    // freq_outL, freq_outR
    // Note gen makes no sound, if freq_out = 50000000 / `silence = 1
    // assign freq_outL = 50000000 / freqL;
    // assign freq_outR = 50000000 / freqR;

    // Note generation
    // [in]  processed frequency
    // [out] audio wave signal (using square wave here)
    note_gen noteGen_00(
        .clk(clk), 
        .rst(rst), 
        .volume(3'b000),
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

endmodule
