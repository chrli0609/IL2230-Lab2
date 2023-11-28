module Sigmoid #(parameter N = 2, parameter QM = 6, parameter QN = 10) (
    input logic signed [QM + QN + N - 1:0] in,
    output logic signed [7:0] out
);
  // Define the size of the lookup table
  parameter LUT_BITS = 8;
  parameter LUT_HALF = 2**(LUT_BITS - 1);
  parameter LUT_QN = 5;
  localparam LUT_SF = 2.0**-LUT_QN;

  // Sigmoid lookup table for 8-bit fixed-point numbers 
  logic [7:0] lut[LUT_HALF:-LUT_HALF];

  // Initialize the sigmoid lookup table
  genvar i;
  generate
    for (i = -LUT_HALF; i <= LUT_HALF; i++) begin
      // build lookup table for -4 to 4 with steps of 0.0625 when QN = 4 
      // 1/(1+e^-x)
      assign lut[i] = (1.0/(1.0 + $exp(-$itor(i) * LUT_SF))) / LUT_SF;
    end
  endgenerate
  
  logic signed [LUT_BITS:0] target;
  assign target = in[QN + LUT_BITS : QN - LUT_QN];
  always_comb begin
    if (target > LUT_HALF) begin
      out = lut[LUT_HALF];
    end else if (target > -LUT_HALF) begin
      out = lut[target];
    end else begin
      out = lut[-LUT_HALF];
    end
  end

endmodule