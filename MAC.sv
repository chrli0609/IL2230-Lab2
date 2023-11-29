module MAC #(parameter N = 2, parameter QM = 12, parameter QN = 20, parameter WM = 6, parameter WN = 10)(
    input logic signed [QM + QN - 1:0] in,
    input logic signed [WM + WN - 1:0] weights,
    input logic signed [QM + QN + WM + WN + N - 1 : 0] feedback,
    output logic signed [QM + QN + WM + WN + N - 1:0] out
);
localparam SF = 2.0**-QN;
logic signed [QM + QN + WM + WN - 1 : 0] prod;

always_comb begin
    prod = in * weights;
    // QN + WN , QM + WM is the prod bit width
    // [QM + QN + WN - 1 : WN] to reduce
    out = prod + feedback;
end

endmodule