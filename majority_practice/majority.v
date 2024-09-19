`timescale 1ns/100ps
module majority (
    output wire out,
    input wire a,
    input wire b,
    input wire c
);
    assign out = (a & b) | (a & c) | (b & c);
endmodule