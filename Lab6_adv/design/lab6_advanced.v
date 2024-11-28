module lab6_advanced(
    input clk,
    input rst,
    input echo,
    input left_track,
    input right_track,
    input mid_track,
    input enable,
    // for debugging
    output [1:0] cur_move,
    output [2:0] LMR,
    output [6:0] display,
    output [3:0] digit,
    output recovery,
    //
    output trig,
    output IN1, /// sample code: left[0]
    output IN2, /// sample code: left[1]
    output IN3, /// sample code: right[0]
    output IN4, /// sample code: right[1]
    output left_pwm, /// sample code: left motor
    output right_pwm /// sample code: right motor
    // You may modify or add more input/ouput yourself.
);
    wire [1:0] move;
    wire [19:0] distance;
    assign cur_move = move;
    assign LMR = {left_track, mid_track, right_track};
    wire tmp_in1, tmp_in2, tmp_in3, tmp_in4;
    assign IN1 = (enable) ? 0 : tmp_in1;
    assign IN2 = (enable) ? 0 : tmp_in2;
    assign IN3 = (enable) ? 0 : tmp_in3;
    assign IN4 = (enable) ? 0 : tmp_in4;
    // We have connected the motor and sonic_top modules in the template file for you.
    // TODO: control the motors with the information you get from ultrasonic sensor and 3-way track sensor.
    motor A(
        .clk(clk),
        .rst(rst),
        .mode(move),
        .dist(distance),
        .recovery(recovery),
        .pwm({left_pwm, right_pwm}),
        .l_IN({tmp_in1, tmp_in2}),
        .r_IN({tmp_in3, tmp_in4})
    );

    sonic_top B(
        .clk(clk), 
        .rst(rst), 
        .Echo(echo), 
        .Trig(trig),
        .distance(distance)
    );

    ///

    tracker_sensor C(
        .clk(clk), 
        .reset(rst), 
        .left_track(left_track), 
        .right_track(right_track),
        .mid_track(mid_track), 
        .move(move),
        .recovery(recovery)
    );
    ///

    SevenSegment s(
        .display(display),
        .digit(digit),
        .nums(distance[15:0]),
        .rst(rst),
        .clk(clk)
    );

endmodule