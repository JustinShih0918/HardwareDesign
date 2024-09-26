module lab2_adv_2(
    input clk,
    input rst,
    input [4:0] raw_data,
    input [9:0] error_bit_input,
    output reg [9:0] received_data,
    output reg [3:0] error_index,
    output reg multiple_error
);

    reg [9:0] encoded_data;
    reg [9:0] decoded_data;

    // encode the raw data
    wire pn;
    assign pn =  (raw_data[4] + raw_data[3] + raw_data[2] + raw_data[1] + raw_data[0]) % 2;
    always @* begin
        encoded_data[9] = raw_data[4] ^ raw_data[3] ^ raw_data[1] ^ raw_data[0];
        encoded_data[8] = raw_data[4] ^ raw_data[2] ^ raw_data[1];
        encoded_data[7] = raw_data[4];
        encoded_data[6] = raw_data[3] ^ raw_data[2] ^ raw_data[1];
        encoded_data[5] = raw_data[3];
        encoded_data[4] = raw_data[2];
        encoded_data[3] = raw_data[1];
        encoded_data[2] = raw_data[0] ^ pn;
        encoded_data[1] = raw_data[0];
        encoded_data[0] = pn;
    end

    // add error bits
    integer i;
    always @* begin
        for(i = 0; i < 10; i = i + 1) begin
            if(error_bit_input[i] == 1) begin
                decoded_data[i] = !encoded_data[i];
            end
            else begin
                decoded_data[i] = encoded_data[i];
            end
        end
    end

    // decode the received data
    reg [3:0] h;
    reg hn;
    always @* begin
        h[0] = decoded_data[9] ^ decoded_data[7] ^ decoded_data[5] ^ decoded_data[3] ^ decoded_data[1];
        h[1] = decoded_data[8] ^ decoded_data[7] ^ decoded_data[4] ^ decoded_data[3];
        h[2] = decoded_data[6] ^ decoded_data[5] ^ decoded_data[4] ^ decoded_data[3];
        h[3] = decoded_data[2] ^ decoded_data[1];
        hn = decoded_data[9] ^ decoded_data[8] ^ decoded_data[7] ^ decoded_data[6] ^ decoded_data[5] ^ decoded_data[4] ^ decoded_data[3] ^ decoded_data[2] ^ decoded_data[1] ^ decoded_data[0];
    end

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            received_data = 10'b0;
            error_index = 4'b0;
            multiple_error = 1'b0;
        end
        else if(h == 0 && hn == 0) begin
            error_index = 4'b0;
            multiple_error = 0;
            received_data = decoded_data;
        end
        else if(h == 0 && hn != 0) begin
            error_index = 10;
            multiple_error = 0;
            received_data = decoded_data;
        end
        else if(h != 0 && hn != 0) begin
            error_index = h;
            multiple_error = 0;
            received_data = decoded_data;
        end
        else begin
            error_index = 0;
            multiple_error = 1;
            received_data = decoded_data;
        end
    end
endmodule
