module Sigmoid #(parameter N = 2, parameter QM = 12, parameter QN = 20) (
    input logic [QM + QN + N - 1:0] in,
    output logic [7:0] out
);
  // Define the size of the lookup table
  parameter LUT_BITS = 7;
  parameter LUT_SIZE = 2**LUT_BITS;
  parameter LUT_QN = 4;
  parameter LUT_OFFSET = (2.0**-LUT_QN) * LUT_SIZE / 2;

  // Sigmoid lookup table for 8-bit fixed-point numbers 
  logic signed [7:0] lut[LUT_SIZE];

  // Initialize the sigmoid lookup table
  initial begin
    for (int i = 0; i < LUT_SIZE; i++) begin
      // build lookup table for -4 to 4 with steps of 0.0625 when QN = 4
      lut[i] = $signed($rtoi((2.0**LUT_QN) * (1.0 / (1.0 + $exp(-((i / (2.0**LUT_QN)) - LUT_OFFSET)))))); 
    end
  end
  
  always_comb begin
    if (in[QM + QN + N - 1 : QN - LUT_QN] > LUT_OFFSET) begin
      out = lut[LUT_SIZE];
    end else if (in[QN + LUT_BITS - LUT_QN : QN - LUT_QN] > -LUT_OFFSET) begin
      out = lut[in[QN + LUT_BITS - LUT_QN : QN - LUT_QN]];
    end else begin
      out = lut[0];
    end
  end

endmodule

/*
module Sigmoid;

  // Define the size of the lookup table
  parameter LUT_SIZE = 128;

  // Sigmoid lookup table for 8-bit fixed-point numbers 
  logic signed [7:0] lut[LUT_SIZE];

  logic [7:0] max_value;
  logic [7:0] min_value;
  logic signed [7:0] result;

  // Initialize the sigmoid lookup table
  initial begin
    for (int i = 0; i < LUT_SIZE; i++) begin
      lut[i] = $signed($rtoi(16.0 * (1.0 / (1.0 + $exp(-(i / 16.0)))))); 
    end
  end

  // Sigmoid function using lookup table for 8-bit fixed-point numbers 
  function logic signed [7:0] sigmoid_8bit(input logic [7:0] x);
    max_value = 8'h7F;
    min_value = -8'h80;

    if (x >= 8'h0) begin
      if (x < LUT_SIZE) begin
        result = lut[x];
      end else begin
        result = max_value;
      end
    end else begin
      result = min_value;
    end

    sigmoid_8bit = result;
  endfunction

endmodule
*/