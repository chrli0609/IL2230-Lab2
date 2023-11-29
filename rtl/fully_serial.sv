`include "MAC.sv"
`include "ReLU.sv"

module fully_serial #(
    parameter N  = 2,
    parameter QM = 12,
    parameter QN = 20,
    parameter WM = 6,
    parameter WN = 10,
    parameter OB = 8
) (
    input logic clk,
    rst_n,
    input logic signed [QM + QN - 1:0] in[N-1:0],
    input logic signed [WM + WN - 1:0] weights[N-1:0],
    input logic signed [QM + QN - 1:0] bias,
    output logic [QM + QN - 1:0] out,
    output logic done
);

  logic signed [QM + QN + WM + WN + N - 1 : 0] feedback_reg, feedback_next, mac_out;
  logic [$clog2(N):0] i_reg, i_next;
  logic done_next;
  logic [QM + QN - 1:0] out_next;

  enum logic [1:0] {
    MultAcc = 2'b00,
    Bias = 2'b01,
    ActFunc = 2'b10
  }
      curr_state, next_state;

  logic signed [QM + QN - 1:0] mac_in;
  logic signed [WM + WN - 1:0] mac_weight;

  logic no_overflow, no_underflow;
  logic [QM + QN - 1:0] mac_final;
  logic [QM + QN - 1:0] out_not_registered;

  MAC #(N, QM, QN, WM, WN, OB) mac (
      mac_in,
      mac_weight,
      feedback_reg,
      mac_out
  );


  ReLU #(N, QM, QN) my_func (
      mac_final,
      out_not_registered
  );


  //Next state logic
  always_comb begin
    next_state = curr_state;
    i_next = i_reg;
    done_next = 0;

    case (curr_state)
      MultAcc: begin
        if (i_reg == N - 1) begin
          next_state = Bias;
        end else begin
          next_state = MultAcc;
          i_next = i_reg + 1;
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
    no_overflow  = ~|feedback_reg[QM+QN+WM+WN+N-1 : QM+QN+WN-1];
    no_underflow = &feedback_reg[QM+QN+WM+WN+N-1 : QM+QN+WN-1];
    if (no_overflow | no_underflow) begin
      mac_final = feedback_reg[QM+QN+WN-1 : WN];
    end else begin
      if (feedback_reg[QM+QN+WM+WN+N-1]) mac_final = -(2 ** (QM + QN - 1));
      else mac_final = 2 ** (QM + QN - 1) - 1;
    end
  end

  always_comb begin
    out_next = 0;
    mac_in = 0;
    mac_weight = 0;
    feedback_next = feedback_reg;
    case (curr_state)
      MultAcc: begin
        mac_in = in[i_reg];
        mac_weight = weights[i_reg];

        feedback_next = mac_out;
      end
      Bias: begin
        mac_in = bias;
        mac_weight = {0, 1'b1} << WN;

        feedback_next = mac_out;
      end
      ActFunc: begin
        feedback_next = 0;
        out_next = out_not_registered;
      end
      default: begin
        feedback_next = 0;
      end

    endcase
  end


  //State changing
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      curr_state <= MultAcc;
      feedback_reg <= 0;
      i_reg <= 0;
      done <= 0;
      out <= 0;
    end else begin
      curr_state <= next_state;
      feedback_reg <= feedback_next;
      i_reg <= i_next;
      done <= done_next;
      out <= out_next;
    end
  end

endmodule
