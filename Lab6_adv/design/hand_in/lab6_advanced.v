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

// This module take "mode" input and control two motors accordingly.
// clk should be 100MHz for PWM_gen module to work correctly.
// You can modify / add more inputs and outputs by yourself.
module motor(
    input clk,
    input rst,
    input [1:0] mode,
    input [19:0] dist,
    input recovery,
    output [1:0] pwm,
    output [1:0] l_IN,
    output [1:0] r_IN
);
    parameter LEFT = 2'b00;
    parameter RIGHT = 2'b01;
    parameter STRAIGHT = 2'b10;
    parameter BACK = 2'b11;

    reg [9:0]left_motor, right_motor;
    wire left_pwm, right_pwm;
    reg [1:0] next_r_IN, next_l_IN;

    motor_pwm m0(clk, rst, left_motor, left_pwm);
    motor_pwm m1(clk, rst, right_motor, right_pwm);

    assign pwm = {left_pwm,right_pwm};
    assign l_IN = (dist < 20'd3000) ? 2'b00 : next_l_IN;
    assign r_IN = (dist < 20'd3000) ? 2'b00 : next_r_IN; 

    // TODO: trace the rest of motor.v and control the speed and direction of the two motors
    /// not sure
    always @(*) begin
        case(mode)
            LEFT: begin // left
                left_motor = 10'd450;
                right_motor = 10'd750;
            end
            RIGHT: begin // right
                left_motor = 10'd750;
                right_motor = 10'd450;
            end
            STRAIGHT: begin // mid
                left_motor = 10'd750;
                right_motor = 10'd750;
            end
            BACK: begin
                left_motor = 10'd750;
                right_motor = 10'd750;
            end
            default: begin
                left_motor = left_motor;
                right_motor = right_motor;
            end
        endcase
    end

    // left 10 forward, right 01 forward
    always @(*) begin
        case(mode)
            LEFT: begin // left
                next_l_IN = 2'b01;
                next_r_IN = 2'b01;
            end
            RIGHT: begin // right
                next_l_IN = 2'b10;
                next_r_IN = 2'b10;
            end
            STRAIGHT: begin // mid
                next_l_IN = 2'b10;
                next_r_IN = 2'b01;
            end
            BACK: begin
                next_l_IN = 2'b01;
                next_r_IN = 2'b10;
            end
            default: begin
                next_l_IN = next_l_IN;
                next_r_IN = next_r_IN;
            end
        endcase
    end
    ///

    
endmodule

module motor_pwm (
    input clk,
    input reset,
    input [9:0]duty,
	output pmod_1 //PWM
);
        
    PWM_gen pwm_0 ( 
        .clk(clk), 
        .reset(reset), 
        .freq(32'd25000),
        .duty(duty), 
        .PWM(pmod_1)
    );

endmodule

//generte PWM by input frequency & duty cycle
module PWM_gen (
    input wire clk,
    input wire reset,
	input [31:0] freq,
    input [9:0] duty,
    output reg PWM
);
    wire [31:0] count_max = 100_000_000 / freq;
    wire [31:0] count_duty = count_max * duty / 1024;
    reg [31:0] count;
        
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 0;
            PWM <= 0;
        end else if (count < count_max) begin
            count <= count + 1;
            // TODO: set <PWM> accordingly
            ///
            if(count < count_duty)
                PWM <= 1;
            else
                PWM <= 0;
            ///
        end else begin
            count <= 0;
            PWM <= 0;
        end
    end
endmodule

// sonic_top is the module to interface with sonic sensors
// clk = 100MHz
// <Trig> and <Echo> should connect to the sensor
// <distance> is the output distance in cm
module sonic_top(clk, rst, Echo, Trig, distance);
	input clk, rst, Echo;
	output Trig;
    output [19:0] distance;

	wire[19:0] dis;
    wire clk1M;
	wire clk_2_17;

    assign distance = dis;

    div clk1(clk ,clk1M);
	TrigSignal u1(.clk(clk), .rst(rst), .trig(Trig));
	PosCounter u2(.clk(clk1M), .rst(rst), .echo(Echo), .distance_count(dis));
 
endmodule

module PosCounter(clk, rst, echo, distance_count); 
    input clk, rst, echo;
    output[19:0] distance_count;

    parameter S0 = 2'b00;
    parameter S1 = 2'b01; 
    parameter S2 = 2'b10;
    
    wire start, finish;
    reg[1:0] curr_state, next_state;
    reg echo_reg1, echo_reg2;
    reg[19:0] count, distance_register;
    wire[19:0] distance_count; 

    always@(posedge clk) begin
        if(rst) begin
            echo_reg1 <= 0;
            echo_reg2 <= 0;
            count <= 0;
            distance_register  <= 0;
            curr_state <= S0;
        end
        else begin
            echo_reg1 <= echo;   
            echo_reg2 <= echo_reg1; 
            case(curr_state)
                S0:begin
                    if (start) curr_state <= next_state; //S1
                    else count <= 0;
                end
                S1:begin
                    if (finish) curr_state <= next_state; //S2
                    else count <= count + 1;
                end
                S2:begin
                    distance_register <= count;
                    count <= 0;
                    curr_state <= next_state; //S0
                end
            endcase
        end
    end

    always @(*) begin
        case(curr_state)
            S0:next_state = S1;
            S1:next_state = S2;
            S2:next_state = S0;
            default:next_state = S0;
        endcase
    end

    assign start = echo_reg1 & ~echo_reg2;  
    assign finish = ~echo_reg1 & echo_reg2;

    // TODO: trace the code and calculate the distance, output it to <distance_count>
    assign distance_count = distance_register * 20'd100 / 20'd58; /// not sure

endmodule

// send trigger signal to sensor
module TrigSignal(clk, rst, trig);
    input clk, rst;
    output trig;

    reg trig, next_trig;
    reg[23:0] count, next_count;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 0;
            trig <= 0;
        end
        else begin
            count <= next_count;
            trig <= next_trig;
        end
    end

    // count 10us to set <trig> high and wait for 100ms, then set <trig> back to low
    always @(*) begin
        next_trig = trig;
        next_count = count + 1;
        // TODO: set <next_trig> and <next_count> to let the sensor work properly
        /// not sure
        if(count == 24'd999)
            next_trig = 1'b0;
        else if(count == 24'd9999999) begin
            next_trig = 1'b1;
            next_count = 24'd0;
        end
        ///
    end
endmodule

// clock divider for T = 1us clock
module div(clk ,out_clk);
    input clk;
    output out_clk;
    reg out_clk;
    reg [6:0]cnt;
    
    always @(posedge clk) begin   
        if(cnt < 7'd50) begin
            cnt <= cnt + 1'b1;
            out_clk <= 1'b1;
        end 
        else if(cnt < 7'd100) begin
	        cnt <= cnt + 1'b1;
	        out_clk <= 1'b0;
        end
        else if(cnt == 7'd100) begin
            cnt <= 0;
            out_clk <= 1'b1;
        end
    end
endmodule

module tracker_sensor(clk, reset, left_track, right_track, mid_track, move, recovery);
    input clk;
    input reset;
    input left_track, right_track, mid_track;
    output reg [1:0] move;
    output wire recovery;

    // TODO: Receive three tracks and make your own policy.
    // Hint: You can use output move to change your action.
    parameter LEFT = 2'b00;
    parameter RIGHT = 2'b01;
    parameter STRAIGHT = 2'b10;
    parameter BACK = 2'b11;
    parameter NORMAL = 0;
    parameter RECOVERY = 1;

    reg [1:0] next_move, recover_move;
    reg state, next_state;
    reg need_recovery;
    assign recovery = state;

    always @(posedge clk) begin
        if(reset) state <= NORMAL;
        else state <= next_state;
    end

    always @(posedge clk) begin
        if(reset) move <= STRAIGHT;
        else if(state == NORMAL) move <= next_move;
        else if(state == RECOVERY) move <= recover_move;
    end

    wire [2:0] LMR;
    assign LMR = {left_track, mid_track, right_track};

    // need_recovery will be 1 when LMR is 3'b111 for 1 second
    reg [27:0] cnt;
    always @(posedge clk) begin
        if(LMR == 3'b111 && cnt != 27'b111_1111_1111_1111_1111_1111_1111 && need_recovery == 0) cnt = cnt + 1;
        else if(LMR == 3'b111 && cnt == 27'b111_1111_1111_1111_1111_1111_1111) begin
            need_recovery = 1;
            cnt = cnt;
        end
        else if(LMR != 3'b111) begin
            need_recovery = 0;
            cnt <= 29'd0;
        end
    end

    reg do_recovery;
    always @(posedge clk) begin
        if(need_recovery && LMR == 3'b111) do_recovery <= 1;
        else do_recovery <= 0;
    end

    always @(*) begin
        case (state)
            NORMAL: begin
                if(do_recovery) next_state = RECOVERY;
                else next_state = NORMAL;
            end 
            RECOVERY: begin
                if(!do_recovery) next_state = NORMAL;
                else next_state = RECOVERY;
            end
            default: next_state = state;
        endcase
    end


    always @(*) begin
        next_move = next_move;
        recover_move = recover_move;
        if(state == NORMAL) begin
            case(LMR)
                3'b001: next_move = LEFT;
                3'b011: next_move = LEFT;
                3'b100: next_move = RIGHT;
                3'b101: next_move = STRAIGHT;
                3'b110: next_move = RIGHT;
                default: next_move = move;
            endcase
        end
        else begin
            case (next_move)
                LEFT: recover_move = RIGHT;
                RIGHT: recover_move = LEFT;
                STRAIGHT: recover_move = BACK;
                default: recover_move = BACK;
            endcase
        end
    end

endmodule
