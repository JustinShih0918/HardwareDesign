module sonic_top(clk, rst, Echo, Trig, stop);
	input clk, rst, Echo;
	output Trig, stop;

	wire[19:0] dis;
	wire[19:0] d;//what is this?
    wire clk1M;
	wire clk_2_17;

    div clk1(clk ,clk1M);
	TrigSignal u1(.clk(clk), .rst(rst), .trig(Trig));
	PosCounter u2(.clk(clk1M), .rst(rst), .echo(Echo), .distance_count(dis));
    
    reg stop, next_stop;
    // [TO-DO] calculate the right distance to trig stop(triggered when the distance is lower than 40 cm)
    // Hint: using "dis"
    ///
    always @(posedge clk)begin
        if(rst)stop <= 1'b0;
        else stop <= next_stop;
    end
    always @(*) begin
        if (dis < 20'd4000) next_stop = 1'b1; // dis 的單位到底是什麼??
        else next_stop = 1'b0;
    end
    ///

endmodule

//Position counter
module PosCounter(clk, rst, echo, distance_count); 
    input clk, rst, echo;
    output[19:0] distance_count;

    parameter S0 = 2'b00; //等待觸發
    parameter S1 = 2'b01; //超聲波傳送中
    parameter S2 = 2'b10; //等待接收
    
    wire start, finish;
    reg[1:0] curr_state, next_state;
    reg echo_reg1, echo_reg2;
    reg[19:0] count, next_count, distance_register, next_distance;
    wire[19:0] distance_count; 

    always@(posedge clk) begin
        if(rst) begin
            echo_reg1 <= 1'b0;
            echo_reg2 <= 1'b0;
            count <= 20'b0;
            distance_register <= 20'b0;
            curr_state <= S0;
        end
        else begin
            echo_reg1 <= echo;   
            echo_reg2 <= echo_reg1; 
            count <= next_count;
            distance_register <= next_distance;//直到S2distance_reg才會更新成next_distance
            curr_state <= next_state;
        end
    end

    always @(*) begin
        case(curr_state)
            S0: begin//wait for trigger
                next_distance = distance_register;//keep 'distance register'
                if (start) begin//triggered->switch to next state
                    next_state = S1;
                    next_count = count;//keep 'count'
                end else begin
                    next_state = curr_state;//keep current state
                    next_count = 20'b0;//reset
                end
            end
            S1: begin//超聲波傳送中
                next_distance = distance_register;//keep 'distance register'
                if (finish) begin
                    next_state = S2;
                    next_count = count;//keep 'count'
                end else begin//counter counts the propagation time
                    next_state = curr_state;//keep 'current state'
                    next_count = (count > 20'd600_000) ? count : count + 1'b1;//counter goes up while under maximum value
                end 
            end
            S2: begin//等待接收
                next_distance = count;//count為此次超聲波往返的總時間，會被存入distance register中
                next_count = 20'b0;
                next_state = S0;
            end
            default: begin
                next_distance = 20'b0;
                next_count = 20'b0;
                next_state = S0;
            end
        endcase
    end

    assign distance_count = distance_register * 20'd100 / 20'd58; //output, why *100/58 ?
    assign start = echo_reg1 & ~echo_reg2;  //start: echo_reg1 = 1 && echo_reg2 = 0
    assign finish = ~echo_reg1 & echo_reg2; //finish: echo_reg1 = 0 && echo_reg2 = 1
    
endmodule

//Echo Trigger
module TrigSignal(clk, rst, trig);
    input clk, rst;
    output trig;

    reg trig, next_trig;
    reg[23:0] count, next_count;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 24'b0;
            trig <= 1'b0;
        end
        else begin
            count <= next_count;
            trig <= next_trig;
        end
    end

    always @(*) begin
        next_trig = trig;
        next_count = count + 1'b1;
        if(count == 24'd999)
            next_trig = 1'b0;
        else if(count == 24'd9999999) begin
            next_trig = 1'b1;
            next_count = 24'd0;
        end
    end
endmodule

//clk divider(microsec)
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
            cnt <= 7'b0;
            out_clk <= 1'b1;
        end
        else begin 
            cnt <= 7'b0;
            out_clk <= 1'b1;
        end
    end
endmodule
