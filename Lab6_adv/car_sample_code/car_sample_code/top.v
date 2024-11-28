module Top(
    input clk,
    input rst,
    input echo,// output by HC-SR04 Echo Pin,  indicates the soundwave travel time  in microsecond
    input left_signal,
    input right_signal,
    input mid_signal,
    output trig,
    output left_motor,//PWM speed for left motor (EN)
    output reg [1:0] left,//2 bit output for left motor's direction (IN)
    output right_motor,//PWM speed for right motor (EN)
    output reg [1:0] right//2 bit output for right motor's direction (IN)
);

    wire [1:0] pwm;///
    wire [1:0] state;///
    wire Rst, rst_pb, stop, dclk;
    debounce d0(rst_pb, rst, clk);
    clk_div dd0(clk, rst, 32'd100000, dclk);
    onepulse d1(rst_pb, clk, dclk, Rst);
    
    motor A(
        .clk(clk),
        .rst(Rst),
        .mode(state),
        .pwm(pwm)
    );
    
    sonic_top B(
        .clk(clk), 
        .rst(Rst), 
        .Echo(echo), 
        .Trig(trig),
        .stop(stop)
    );
    
    tracker_sensor C(
        .clk(clk), 
        .reset(Rst), 
        .left_signal(left_signal), 
        .right_signal(right_signal),
        .mid_signal(mid_signal), 
        .state(state)
       );

    ///
    assign left_motor = pwm[1];
    assign right_motor = pwm[0];
    
    always @(*) begin
        // [TO-DO] Use left and right to set your pwm
        if(stop) begin
            left = 2'b00;
            right = 2'b00;
        end
        else begin
            left = 2'b01;
            right = 2'b01;
        end
    end
    ///
    
endmodule

module debounce (pb_debounced, pb, clk);//for reset
    output pb_debounced; 
    input pb;
    input clk;
    reg [4:0] DFF;
    
    always @(posedge clk) begin
        DFF[4:1] <= DFF[3:0];
        DFF[0] <= pb; 
    end
    assign pb_debounced = (&(DFF)); 
endmodule

module clk_div(clk, rst, freq, dclk);
    input clk, rst;
    input [31:0] freq;
    output reg dclk;
    reg [31:0] cnt;
    always@(posedge clk) begin
        if(rst) begin
            cnt <= 1'b0;
            dclk <= 1'b0;
        end else begin
            if(cnt == freq) begin
                cnt <= 0;
                dclk <= 1'b1;
            end else begin
                cnt <= cnt+1'b1;
                dclk <= 1'b0;
            end
        end
    end
endmodule

module onepulse (PB_debounced, clk, dclk, PB_one_pulse);//for reset
    input PB_debounced;
    input clk, dclk;
    output reg PB_one_pulse;
    reg PB_debounced_delay;

    always @(posedge clk) begin
        if(dclk)begin
            PB_one_pulse <= PB_debounced & (!PB_debounced_delay);
            PB_debounced_delay <= PB_debounced;
        end
        else begin
        end
    end 
endmodule

