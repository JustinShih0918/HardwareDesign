module lab6_practice_master (
	input wire clk,
	input wire rst,
	input wire [7:0] sw, // switches
	output wire [3:0] data_out  // data (number) to slave
);
	parameter invalid = 8;
	parameter OFF = 9;

	reg data_out_tmp;
	assign data_out = data_out_tmp;

	always @(posedge clk) begin
		case(sw) 
			8'b0000_0000: data_out_tmp <= OFF;
			8'b0000_0001: data_out_tmp <= 0;
			8'b0000_0010: data_out_tmp <= 1;
			8'b0000_0100: data_out_tmp <= 2;
			8'b0000_1000: data_out_tmp <= 3;
			8'b0001_0000: data_out_tmp <= 4;
			8'b0010_0000: data_out_tmp <= 5;
			8'b0100_0000: data_out_tmp <= 6;
			8'b1000_0000: data_out_tmp <= 7;
			default: data_out_tmp <= invalid;
		endcase
	end
endmodule


// slave design

// if data in == 8 or 9, no light should be turn on
// else led[data_in] = 1

