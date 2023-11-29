`include "MAC.sv"
`include "ReLU.sv"

module semi_serial #(
    parameter N  = 2,
    parameter QM = 12,
    parameter QN = 20,
    parameter WM = 6,
    parameter WN = 10,
    parameter OB = 8,
    parameter K  = 2
) (
    input logic clk,
    rst_n,
    input logic signed [QM + QN - 1:0] in[N-1:0],
    input logic signed [WM + WN - 1:0] weights[N-1:0],
    input logic signed [QM + QN - 1:0] bias,
    output logic [QM + QN - 1:0] out,
    output logic done
);

  logic signed [QM + QN + WM + WN + N - 1 : 0] partial_sum,
      feedback_reg[K-1:0],
      feedback_next[K-1:0],
      mac_out[K-1:0];

  logic [$clog2(N + K):0] i_reg, i_next;
  logic done_next;
  logic [QM + QN - 1:0] out_next;

  enum logic [1:0] {
    MultAcc = 2'b00,
    Bias = 2'b01,
    ActFunc = 2'b10
  }
      curr_state, next_state;

  logic signed [QM + QN - 1:0] mac_in[K-1:0];
  logic signed [WM + WN - 1:0] mac_weight[K-1:0];

  logic no_overflow, no_underflow;
  logic [QM + QN - 1:0] mac_final;
  logic [QM + QN - 1:0] out_not_registered;





  ReLU #(N, QM, QN) my_func (
      mac_final,
      out_not_registered
  );

  genvar k;
  generate
    for (k = 0; k < K; k++) begin
      MAC #(N, QM, QN, WM, WN, OB) mac (
          mac_in[k],
          mac_weight[k],
          feedback_reg[k],
          mac_out[k]
      );
    end
  endgenerate



  //Next state logic
  always_comb begin
    next_state = curr_state;
    i_next = i_reg;
    done_next = 0;

    case (curr_state)
      MultAcc: begin
        if (i_reg >= N - 1) begin
          next_state = Bias;
        end else begin
          if(i_reg + K >= N - 1)
            next_state = Bias;
          else
            next_state = MultAcc;
          i_next = i_reg + K;
        end
      end
      Bias: begin
        next_state = ActFunc;
      end
      ActFunc: begin
        next_state = MultAcc;
        i_next = 0;
        done_next = 1;
      end
      default: begin
        next_state = MultAcc;
        i_next = 0;
      end
    endcase
  end

  always_comb begin
    no_overflow  = ~|partial_sum[QM+QN+WM+WN+N-1 : QM+QN+WN-1];
    no_underflow = &partial_sum[QM+QN+WM+WN+N-1 : QM+QN+WN-1];
    if (no_overflow | no_underflow) begin
      mac_final = partial_sum[QM+QN+WN-1 : WN];
    end else begin
      if (partial_sum[QM+QN+WM+WN+N-1]) mac_final = -(2 ** (QM + QN - 1));
      else mac_final = 2 ** (QM + QN - 1) - 1;
    end
  end

  always_comb begin
    out_next = 0;
    partial_sum = 0;

    for (int k = 0; k < K; k++) begin
      mac_in[k] = 0;
      mac_weight[k] = 0;
      feedback_next[k] = feedback_reg[k];
    end

    case (curr_state)
      MultAcc: begin
        for (int k = 0; k < K; k++) begin
          if (i_reg + k <=  N-1) begin
            feedback_next[k] = mac_out[k];
            mac_in[k] = in[i_reg + k];
            mac_weight[k] = weights[i_reg + k];
           end
        end
      end

      Bias: begin
        mac_in[0] = bias;
        mac_weight[0] = {0, 1'b1} << WN;
        feedback_next[0] = mac_out[0];
      end
      ActFunc: begin
        for (int k = 0; k < K; k++) begin
          feedback_next[k] = 0;
        end
        for (int k = 0; k < K; k++) begin
          partial_sum = partial_sum + feedback_reg[k];
        end
        out_next = out_not_registered;
      end
      default: begin
        for (int k = 0; k < K; k++) begin
          feedback_next[k] = 0;
        end
      end

    endcase
  end


  //State changing
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      curr_state <= MultAcc;
      for (int k = 0; k < K; k++) begin
        feedback_reg[k] <= 0;
      end
      i_reg <= 0;
      done <= 0;
      out <= 0;
    end else begin
      curr_state <= next_state;
      for (int k = 0; k < K; k++) begin
        feedback_reg[k] <= feedback_next[k];
      end
      i_reg <= i_next;
      done <= done_next;
      out <= out_next;
    end
  end

endmodule
