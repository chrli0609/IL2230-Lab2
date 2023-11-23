module FixedPointFunctions;

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
      lut[i] = $signed($rtoi(32.0 * (1.0 / (1.0 + exp(-((i / 32.0) - 4.0)))))); 
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
