module lab6_advanced(
    input clk,
    input rst,
    input echo,
    input left_track,
    input right_track,
    input mid_track,
    output trig,
    output IN1, /// sample code: left[0]
    output IN2, /// sample code: left[1]
    output IN3, /// sample code: right[0]
    output IN4, /// sample code: right[1]
    output left_pwm, /// sample code: left motor
    output right_pwm /// sample code: right motor
    // You may modify or add more input/ouput yourself.
);
    wire [1:0] state;
    wire left_pwm, right_pwm;
    wire [19:0] distance;
    // We have connected the motor and sonic_top modules in the template file for you.
    // TODO: control the motors with the information you get from ultrasonic sensor and 3-way track sensor.
    motor A(
        .clk(clk),
        .rst(rst),
        .mode(state),
        .pwm({left_pwm, right_pwm})
        // .l_IN({IN1, IN2}),
        // .r_IN({IN3, IN4})
    );

    sonic_top B(
        .clk(clk), 
        .rst(rst), 
        .Echo(echo), 
        .Trig(trig),
        .distance(distance)
    );

    ///
    assign {IN1, IN2} = (distance < 20'd3000) ? 2'b00 : 2'b01;
    assign {IN3, IN4} = (distance < 20'd3000) ? 2'b00 : 2'b01; 

    tracker_sensor C(
        .clk(clk), 
        .reset(rst), 
        .left_track(left_track), 
        .right_track(right_track),
        .mid_track(mid_track), 
        .state(state)
    );
    ///

endmodule