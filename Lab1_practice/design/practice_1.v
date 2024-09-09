`timescale 1ns/100ps
module practice_1 (
    input wire a,
    input wire b,
    input wire c,
    output wire out
);
    wire xor_ab;

    xor_gate gate1(a, b, xor_ab);
    xor_gete gate2(xor_ab, c, out);

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