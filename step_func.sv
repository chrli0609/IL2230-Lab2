module step_func #(parameter N = 2, parameter QM = 12, parameter QN = 20) (
    input logic signed [QM + QN - 1:0] in,
    output logic signed [QM + QN - 1:0] out
);

always_comb begin
    if (in[QM+QN-1]) out = {(QM+QN){1'b1}};
    
    else out = {1'b0, 1'b1} << QN;
end
        

endmodule