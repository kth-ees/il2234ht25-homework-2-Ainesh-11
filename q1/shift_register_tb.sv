`timescale 1ns/1ps
module shift_register_tb;

  parameter N = 8;

  logic clk;
  logic rst_n;
  logic serial_parallel;
  logic load_enable;
  logic serial_in;
  logic [N-1:0] parallel_in;
  logic [N-1:0] parallel_out;
  logic serial_out;

  shift_register #(N) dut (
    .clk(clk),
    .rst_n(rst_n),
    .serial_parallel(serial_parallel),
    .load_enable(load_enable),
    .serial_in(serial_in),
    .parallel_in(parallel_in),
    .parallel_out(parallel_out),
    .serial_out(serial_out)
  );

  initial clk = 0;
  always #5 clk = ~clk;
  
  logic [N-1:0] pat;
  integer i;

  initial begin
    $display("\n=== tb_shift_register starting ===\n");

    rst_n = 0;
    load_enable = 0;
    serial_parallel = 0;
    serial_in = 0;
    parallel_in = '0;

    #12;
    rst_n = 1;
    @(posedge clk);
//test 1 - 
    pat = 8'hA5; 
    parallel_in = pat;
    serial_parallel = 1;
    load_enable = 1;
    @(posedge clk); 
    load_enable = 0;
    if (parallel_out !== pat) $fatal("Parallel load failed: got %h expected %h", parallel_out, pat);
    $display("PASS: Parallel load -> %h", parallel_out);
//test 2 - 
    parallel_in = ~pat;
    serial_parallel = 1;
    @(posedge clk);
    if (parallel_out !== pat) $fatal("Hold failed: register changed while load_enable==0: got %h expected %h", parallel_out, pat);
    $display("PASS: hold when load_enable==0");
//test 3 - 
    pat = 8'h3C; 
    serial_parallel = 0; 
    load_enable = 1;
    parallel_in = '0;
    for (i = N-1; i >= 0; i = i - 1) begin
      serial_in = pat[i];
      @(posedge clk);
    end
    load_enable = 0;
    @(posedge clk);
    if (parallel_out !== pat) $fatal("Serial load failed: got %h expected %h", parallel_out, pat);
    $display("PASS: Serial load -> %h", parallel_out);

    if (serial_out !== parallel_out[0]) $fatal("serial_out mismatch: serial_out=%b parallel_out[0]=%b", serial_out, parallel_out[0]);
    $display("PASS: serial_out == parallel_out[0] (%b)", serial_out);

    // test 4
    parallel_in = 8'hFF;
    serial_parallel = 1;
    load_enable = 1;
    @(posedge clk);
    load_enable = 0;
    if (parallel_out !== 8'hFF) $fatal("Parallel overwrite failed: got %h expected %h", parallel_out, 8'hFF);
    $display("PASS: Parallel overwrite -> %h", parallel_out);

    $display("\nAll tests PASSED\n");
    #20;
    $finish;
  end

endmodule
