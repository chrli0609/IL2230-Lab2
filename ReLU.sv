module ReLU #(parameter N = 2, parameter QM = 12, parameter QN = 20) (
  input logic [QM + QN + N - 1:0] in,
  output logic [7:0] out
);
  always_comb begin
    out = in[QM + QN + N - 1] ? 0 : in;
  end
endmodule
