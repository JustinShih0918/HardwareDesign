// This module take "mode" input and control two motors accordingly.
// clk should be 100MHz for PWM_gen module to work correctly.
// You can modify / add more inputs and outputs by yourself.
module motor(
    input clk,
    input rst,
    input [1:0] mode,
    input [19:0] dist,
    output [1:0] pwm,
    output [1:0] l_IN,
    output [1:0] r_IN
);
    parameter LEFT = 2'b00;
    parameter RIGHT = 2'b01;
    parameter STRAIGHT = 2'b10;

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
                left_motor = 10'd256;
                right_motor = 10'd768;
            end
            RIGHT: begin // right
                left_motor = 10'd768;
                right_motor = 10'd256;
            end
            STRAIGHT: begin // mid
                left_motor = 10'd768;
                right_motor = 10'd768;
            end
            default: begin
                left_motor = left_motor;
                right_motor = right_motor;
            end
        endcase
    end

    always @(*) begin
        case(mode)
            LEFT: begin // left
                next_l_IN = 2'b01;
                next_r_IN = 2'b10;
            end
            RIGHT: begin // right
                next_l_IN = 2'b10;
                next_r_IN = 2'b01;
            end
            STRAIGHT: begin // mid
                next_l_IN = 2'b10;
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

