module ReLU #(parameter N = 2, parameter QM = 12, parameter QN = 20) (
  input logic [QM + QN - 1:0] in,
  output logic [QM + QN - 1:0] out
);
  always_comb begin
    out = in[QM + QN - 1] ? 0 : in;
  end
endmodule
