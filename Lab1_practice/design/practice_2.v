`timescale 1ns/100ps

module practice_2(
  input wire G,
  input wire D,
  output wire P,
  output wire Pn
);
  wire nand_1;
  wire nand_2;

  nand(nand_1, D, G);
  nand(nand_2, ~D, G);
  nand(P, nand_1, Pn);
  nand(Pn, nand_2, P);

endmodule
