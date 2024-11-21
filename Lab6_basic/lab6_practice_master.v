module lab6_practice_master (
	input wire clk,
	input wire rst,
	input wire [7:0] sw, // switches
	output wire [3:0] data_out,  // data (number) to slave
	output wire [3:0] data_look

);
	parameter [3:0] invalid = 4'b1000;
	parameter [3:0] OFF = 4'b1001;

	reg [3:0] data_out_tmp;
	assign data_out = data_out_tmp;
	assign data_look = data_out_tmp;

	always @(posedge clk) begin
		case(sw) 
			8'b0000_0000: data_out_tmp <= OFF;
			8'b0000_0001: data_out_tmp <= 4'b0000;
			8'b0000_0010: data_out_tmp <= 4'b0001;
			8'b0000_0100: data_out_tmp <= 4'b0010;
			8'b0000_1000: data_out_tmp <= 4'b0011;
			8'b0001_0000: data_out_tmp <= 4'b0100;
			8'b0010_0000: data_out_tmp <= 4'b0101;
			8'b0100_0000: data_out_tmp <= 4'b0110;
			8'b1000_0000: data_out_tmp <= 4'b0111;
			default: data_out_tmp <= invalid;
		endcase
	end
endmodule


// slave design

// if data in == 8 or 9, no light should be turn on
// else led[data_in] = 1

