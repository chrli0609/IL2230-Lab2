//`include "fully_parallel.sv"  // Include the design file

module fully_serial_tb #(parameter N = 2, QM = 6, QN = 10, WM = 6, WN = 10, OB = 8);

// Testbench signals
logic clk;
logic rst_n;
logic signed [QM + QN - 1:0] in_data [N-1:0];
logic signed [WM + WN - 1:0] weights [N-1:0];
logic [QM + QN - 1:0] bias;
logic [QM + QN - 1:0] out_data;
logic done;

localparam IN_SF = 2.0**-QN;
localparam W_SF = 2.0**-WN;

real mac_sum;
real expected_out;
logic [QM + QN - 1 :0] out_not_registered_tb;
real mac_final_tb;
logic [QM + QN + WM + WN + N - 1:0] feedback_reg_tb;




assign out_not_registered_tb = dut.out_not_registered;
assign feedback_reg_tb = dut.feedback_reg;

// Instantiate the neuron module
fully_serial #(N, QM, QN, WM, WN, OB) dut (
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
  $dumpvars(1, fully_serial_tb);
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
      weights[i] = $urandom_range(0,2 ** WM);
      in_data[i] = $urandom_range(0,2 ** QM);
      weights[i] = $signed(weights[i]) - 2 ** (WM - 1);
      in_data[i] = $signed(in_data[i]) - 2 ** (QM - 1);
      weights[i] = weights[i] << (WN - (WM/2));
      in_data[i] = in_data[i] << (QN - (QM/2));
    end

    @(posedge done)
    mac_sum = 0.0;
    for (int i = 0; i<N; i++) begin
      mac_sum = mac_sum + ($itor(in_data[i]) * IN_SF * $itor(weights[i]) * W_SF);
    end
    
    if (mac_sum <= 0) begin
      expected_out = 0;
    end else begin
      expected_out = mac_sum;
    end

    assert(expected_out == ($itor(out_data) * IN_SF)) $display("TEST PASSED");
    else $error("TEST FAILED\n",
      "in[0]: %d\n", ($itor(in_data[0]) * IN_SF),
      "in[1]: %d\n", ($itor(in_data[1]) * IN_SF),
      "weights[0]: %d\n", ($itor(weights[0]) * W_SF),
      "weights[1]: %d\n", ($itor(weights[1]) * W_SF),
      "mac_sum: %d\n", mac_sum,
      "expected_out: %f\n", expected_out,
      "out_data: %f\n", $itor(out_data) * IN_SF
      );

end


endmodule