//`include "fully_parallel.sv"  // Include the design file

module fully_parallel_tb #(parameter N = 2, QM = 12, QN = 20, WM = 6, WN = 10, OB = 8);

  // Testbench signals
  logic clk;
  logic rst_n;
  logic [31:0] in_data [N-1:0];
  logic [15:0] weights [N-1:0];
  logic bias;
  logic [7:0] out_data;


  logic [QM + QN + N - 1:0] mac_sum;
  logic [7:0] expected_out;

  // Instantiate the neuron module
  fully_parallel #(N, QM, QN, WM, WN, OB) dut (
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
    forever #10 clk = ~clk;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, fully_parallel_tb);
  end

  // Test procedure
  initial begin
    // Initialize inputs
    rst_n = 0;
    bias = 0;

    for (int i = 0; i < N; i++) begin
      weights[i] = 1;
      in_data[i] = 0;
    end
    
  end


always @(posedge clk, negedge rst_n) begin
      
      bias = $random;
      for (int i = 0; i < N; i++) begin
       weights[i] = $random;
       in_data[i] = $random;
      end


      #5;

      mac_sum = 0;
      for (int i = 0; i<N; i++) begin
        mac_sum = mac_sum + in_data[i]*weights[i];
      end

      expected_out = mac_sum[QM + QN + N - 1] ? 0 : mac_sum;
      

      assert(expected_out == out_data) $display("TEST PASSED");
      else $error("TEST FAILED");

end


endmodule