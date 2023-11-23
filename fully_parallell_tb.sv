`include "fully_parallel.sv"  // Include the design file

module testbench;

  // Testbench signals
  logic clk;
  logic rst_n;
  logic [31:0] in_data;
  logic [15:0] weights [0:4];
  logic bias;
  logic [7:0] out_data;

  // Instantiate the neuron module
  fully_parallel #(5, 12, 20, 6, 10, 8) dut (
    .clk(clk),
    .rst_n(rst_n),
    .in(in_data),
    .weights(weights),
    .bias(bias),
    .out(out_data)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, testbench);
  end

  // Test procedure
  initial begin
    // Initialize inputs
    rst_n = 0;
    in_data = 32'h12345678;
    weights = {16'h1234, 16'h5678, 16'h9ABC, 16'hDEF0, 16'h9876};
    bias = 1;

    // Release reset
    #10 rst_n = 1;

    // Apply inputs and check outputs
    repeat (10) begin
      #10 in_data = $random;
      weights = $random;
      bias = $random;

      #10 $display("Input: %h, Weights: %h %h %h %h %h, Bias: %h, Output: %h",
                  in_data, weights[0], weights[1], weights[2], weights[3], weights[4],
                  bias, out_data);
    end

    // Finish the simulation
    #10 $stop;
  end

endmodule
