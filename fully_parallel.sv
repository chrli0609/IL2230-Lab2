`include "MAC.sv"
`include "ReLU.sv"


//QM is integer, QN is fraction
module fully_parallel #(parameter N = 2, parameter QM = 12, parameter QN = 20, parameter WM = 6, parameter WN = 10, parameter OB = 8) (
    input logic clk, rst_n,
    input logic signed [QM + QN - 1:0] in [N-1:0],
    input logic signed [WM + WN - 1:0] weights [N-1:0],
    input logic signed [QM + QN - 1:0] bias,
    output logic [QM + QN - 1:0] out
);

logic [QM + QN + WM + WN + N - 1:0] mac_out [N:0];
logic no_overflow, no_underflow;
logic [QM + QN - 1:0] mac_final;
logic [QM + QN - 1:0] out_not_registered;

//Fully parallel loop
genvar i;
generate
    //last iteration handles the bias
    for (i = 0; i <= N; i++) begin
        if (i == N) MAC #(N, QM, QN, WM, WN, OB) mac (bias, {1'b0, 1'b1} << WN, mac_out[i-1], mac_out[i]);
        else if (i == 0) MAC #(N, QM, QN, WM, WN, OB) mac (in[i], weights[i], 0, mac_out[i]);
        else MAC #(N, QM, QN, WM, WN, OB) mac (in[i], weights[i], mac_out[i-1], mac_out[i]);
    end

endgenerate

always_comb begin
    no_overflow = ~|mac_out[N][QM + QN + WM + WN + N - 1 : QM + QN + WN - 1];   
    no_underflow = &mac_out[N][QM + QN + WM + WN + N - 1 : QM + QN + WN - 1];
    if (no_overflow | no_underflow) begin
        mac_final = mac_out[N][QM + QN + WN - 1 : WN];
    end else begin
      if (mac_out[N][QM + QN + WM + WN + N - 1])
        mac_final = -(2**(QM + QN - 1));
      else
        mac_final = 2**(QM + QN - 1) - 1;
    end
end

//Activation function
ReLU #(N, QM, QN) my_func (mac_final, out_not_registered);

//Register the output
always_ff @(posedge clk, negedge rst_n) begin
    
    if (!rst_n) begin
        out <= 0;
    end
    else out <= out_not_registered;
end


endmodule