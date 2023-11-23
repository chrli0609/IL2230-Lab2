//QM is integer, QN is fraction
module fully_parallel #(parameter N, parameter QM = 12, parameter QN = 20, parameter WM = 6, parameter WN = 10, parameter OB = 8) (
    input logic clk, rst_n,
    input logic [31:0] in,
    input logic  [15:0] weights,
    input logic bias,
    output logic [7:0] out
);

logic [QM + QN + WM + WN + N - 1:0] mac_out [N-1:0];
logic no_overflow, no_underflow;
logic [QM + QN + N - 1:0] mac_final;
logic [7:0] out_not_registered;

//Fully parallel loop
genvar i;
generate
    //last iteration handles the bias
    for (i = 0; i <= N; i++) begin
        if (i == N) MAC mac (bias, 1, 0, mac_out[i]);
        else if (i == 0) MAC mac (in[i], weights[i], 0, mac_out[i]);
        else MAC mac (in[i], weights[i], mac_out[i-1], mac_out[i]);
    end

endgenerate

always_comb begin
    no_overflow = ~|mac_out[N-1][QM + QN + WM + WN + N - 1 : QM + QN + WM + WN];   
    no_underflow = &mac_out[N-1][QM + QN + WM + WN + N - 1 : QM + QN + WM + WN];
    if (no_overflow | no_underflow) begin
        mac_final = mac_out[N-1][QM + QN + WN - 1 : WN];
    end else begin
        mac_final = $signed(mac_out[N-1][QM + QN + WM + WN + N - 1]);
    end
end

//Activation function
sigmoid my_func (mac_final, out_not_registered);

//Register the output
always_ff @(posedge clk, negedge rst_n) begin
    out <= out_not_registered;
end


endmodule