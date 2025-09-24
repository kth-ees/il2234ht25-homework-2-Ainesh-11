module shift_register #(parameter N=4)
(
  input  logic             clk,
  input  logic             rst_n,
  input  logic             serial_parallel,
  input  logic             load_enable,
  input  logic             serial_in,
  input  logic [N-1:0]     parallel_in,
  output logic [N-1:0]     parallel_out,
  output logic             serial_out
);

  // next value computed by muxes (explicitly)
  logic [N-1:0] next_reg;

  genvar gi;
  generate
    for (gi = 0; gi < N; gi = gi + 1) begin : gen_mux
      // If parallel mode, take parallel_in[i].
      // Else (serial mode):
      //   - leftmost bit (index N-1) takes serial_in
      //   - other bits take the value of the left neighbor (parallel_out[i+1])
      if (gi == N-1) begin
        // MSB: either parallel_in[N-1] or serial_in
        assign next_reg[gi] = serial_parallel ? parallel_in[gi] : serial_in;
      end else begin
        // middle / LSB positions: either parallel_in[i] or previous( i+1 )
        assign next_reg[gi] = serial_parallel ? parallel_in[gi] : parallel_out[gi+1];
      end
    end
  endgenerate

  // Sequential flops (update only when load_enable is asserted)
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      parallel_out <= '0;
    end else if (load_enable) begin
      parallel_out <= next_reg;
    end
    // else keep the current value (holds)
  end

  // serial_out is the rightmost flop (matches diagram)
  assign serial_out = parallel_out[0];

endmodule
