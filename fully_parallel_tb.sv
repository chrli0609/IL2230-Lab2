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
  logic [7:0] out_not_registered_tb;
  logic [QM + QN + N - 1:0] mac_final_tb;




  assign out_not_registered_tb = dut.out_not_registered;
  assign mac_final_tb = dut.mac_final;

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
    #1; 
    rst_n = 1;
    bias = 0;

    for (int i = 0; i < N; i++) begin
      weights[i] = 1;
      in_data[i] = 0;
    end
    
  end


always @(posedge clk, negedge rst_n) begin
      
      bias = $random;
      for (int i = 0; i < N; i++) begin
       weights[i] = $urandom_range(0,10);
       in_data[i] = $urandom_range(0,10);
      end


      #2;

      mac_sum = 0;
      for (int i = 0; i<N; i++) begin
        mac_sum = mac_sum + in_data[i]*weights[i];
      end
      #1;

      expected_out = mac_sum[QM + QN + N - 1] ? 0 : mac_sum;
      #1;

      assert(expected_out == out_data) $display("TEST PASSED");
      else $error("TEST FAILED\n",
        "in[0]: %d\n", in_data[0],
        "in[1]: %d\n", in_data[1],
        "weights[0]: %d\n", weights[0],
        "weights[1]: %d\n", weights[1],
        "mac_sum: %d\n", mac_sum,
        "expected_out: %d\n", expected_out,
        "out_data: %d\n", out_data
        );

end


endmodule