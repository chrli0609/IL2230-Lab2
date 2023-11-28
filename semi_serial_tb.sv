//`include "semi_parallel.sv"  // Include the design file

module semi_serial_tb #(parameter N = 2, QM = 16, QN = 16, WM = 6, WN = 10, OB = 8, K = 2);

// Testbench signals
logic clk;
logic rst_n;
logic signed [QM + QN - 1:0] in_data [N-1:0];
logic signed [WM + WN - 1:0] weights [N-1:0];
logic signed [QM + QN - 1:0] bias;
logic [QM + QN - 1:0] out_data;
logic done;

localparam IN_SF = 2.0**-QN;
localparam W_SF = 2.0**-WN;
localparam OUT_MIN = (-(2.0** (QN + QM - 1))) * IN_SF;
localparam OUT_MAX = (2.0** (QN + QM - 1) - 1) * IN_SF;

real mac_sum;
real expected_out;
logic [QM + QN - 1 :0] out_not_registered_tb;
real mac_final_tb;

assign out_not_registered_tb = dut.out_not_registered;


// Instantiate the neuron module
semi_serial #(N, QM, QN, WM, WN, OB, K) dut (
  .clk(clk),
  .rst_n(rst_n),
  .in(in_data),
  .weights(weights),
  .bias(bias),
  .out(out_data),
  .done(done)
);

// Clock generation
initial begin
  clk = 0;
  forever #10 clk = ~clk;
end

initial begin
  $dumpfile("dump.vcd");
  $dumpvars(1, semi_serial_tb);
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


always @(posedge done, negedge rst_n) begin
    #1
    bias = $urandom_range(0,2 ** QM);
    bias = $signed(bias) - 2 ** (QM - 1);
    bias = bias << (QN - (QM/2));
    for (int i = 0; i < N; i++) begin
      weights[i] = $urandom_range(0,2 ** WM);
      in_data[i] = $urandom_range(0,2 ** QM);
      weights[i] = $signed(weights[i]) - 2 ** (WM - 1);
      in_data[i] = $signed(in_data[i]) - 2 ** (QM - 1);
      weights[i] = weights[i] << (WN - (WM/2));
      in_data[i] = in_data[i] << (QN - (QM/2));
    end
end
always @(posedge done) begin 
    mac_sum = 0.0;
    for (int i = 0; i<N; i++) begin
      mac_sum = mac_sum + ($itor(in_data[i]) * IN_SF * $itor(weights[i]) * W_SF);
    end
    mac_sum = mac_sum + ($itor(bias)) * IN_SF;
    
    mac_sum = mac_sum > OUT_MAX ? OUT_MAX : mac_sum;
    mac_sum = mac_sum < OUT_MIN ? OUT_MIN : mac_sum;
    if (mac_sum <= 0) begin
      expected_out = 0;
    end else begin
      expected_out = mac_sum;
    end

    assert(expected_out == ($itor(out_data) * IN_SF)) $display("TEST PASSED");
    else $error("TEST FAILED\n",
      "in[0]: %f\n", ($itor(in_data[0]) * IN_SF),
      "in[1]: %f\n", ($itor(in_data[1]) * IN_SF),
      "weights[0]: %f\n", ($itor(weights[0]) * W_SF),
      "weights[1]: %f\n", ($itor(weights[1]) * W_SF),
      "bias: %f\n", ($itor(bias) * IN_SF),
      "mac_sum: %d\n", mac_sum,
      "expected_out: %f\n", expected_out,
      "out_data: %f\n", $itor(out_data) * IN_SF
      );

end


endmodule