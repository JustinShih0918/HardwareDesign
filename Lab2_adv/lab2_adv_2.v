module lab2_adv_2(
    input clk,
    input rst,
    input [4:0] raw_data,
    input [9:0] error_bit_input,
    output wire [9:0] received_data,
    output reg [3:0] error_index,
    output reg multiple_error
);
    // encode the raw data
    integer i;
    always @* begin
        received_data[0] = raw_data[0] ^ raw_data[1] ^ raw_data[3] ^ raw_data[4];
        received_data[1] = raw_data[0] ^ raw_data[2] ^ raw_data[3];
        received_data[2] = raw_data[0];
        received_data[3] = raw_data[1] ^ raw_data[2] ^ raw_data[3];
        received_data[4] = raw_data[1];
        received_data[5] = raw_data[2];
        received_data[6] = raw_data[3];
        received_data[7] = raw_data[4];
        received_data[8] = raw_data[4];
        received_data[9] = (raw_data[0] + raw_data[1] + raw_data[2] + raw_data[3] + raw_data[4] + raw_data[5] + raw_data[6] + raw_data[7] + raw_data[8] + raw_data[9] + raw_data[10] + raw_data[11]) % 2;
        for(i = 0;i < 10; i = i + 1) begin
            if(error_bit_input[i]) received_data[i] = ~received_data[i];
        end
    end

    // decode the received data
    reg [3:0] h;
    always @* begin
        h[0] = received_data[0] ^ received_data[2] ^ received_data[4] ^ received_data[6] ^received_data[8];
        h[1] = received_data[1] ^ received_data[2] ^ received_data[5] ^ received_data[6];
        h[2] = received_data[3] ^ received_data[4] ^ received_data[5] ^ received_data[6];
        h[3] = received_data[7] ^ received_data[8];
        multiple_error = received_data[0] ^ received_data[1] ^ received_data[2] ^ received_data[3] ^ received_data[4] ^ received_data[5] ^ received_data[6] ^ received_data[7] ^ received_data[8] ^ received_data[9];
    end

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            received_data <= 10'b0;
            error_index <= 4'b0;
            multiple_error <= 1'b0;
        end
        else if(h == 0 && multiple_error == 0) begin
            error_index <= 4'b0;
        end
        else if(h > 10 && multiple_error == 1) begin
            error_index <= 4'b0;
        end
        else begin
            error_index <= h;
        end
    end
// Output signals can be reg or wire
// add your design here

endmodule
