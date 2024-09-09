`timescale 1ns/100ps
module practice_1 (
    input wire a,
    input wire b,
    input wire c,
    output wire out
);
    wire xor_ab;
    wire tmp1;
    wire tmp2;

    xor_gate gate(a,b,xor_ab);
    and (tmp1, c, ~xor_ab);
    and (tmp2, c, xor_ab);
    or (out, tmp1, tmp2);

endmodule

module xor_gate (
    input wire a,
    input wire b,
    output wire y
);
    wire tmp1;
    wire tmp2;

    and (tmp1, a, ~b);
    and (tmp2, ~a, b);
    or (y, tmp1, tmp2);

endmodule