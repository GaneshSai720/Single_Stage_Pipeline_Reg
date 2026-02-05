module tb #(parameter WIDTH = 32);

  reg clk, resetn;
  reg in_valid, out_ready;
  reg [WIDTH-1:0] in_data;
  wire in_ready, out_valid;
  wire [WIDTH-1:0] out_data;

  reg [WIDTH-1:0] exp_data;

  single_stage_pipeline_reg dut (
    .clk(clk), .resetn(resetn),
    .in_ready(in_ready), .in_valid(in_valid), .in_data(in_data),
    .out_ready(out_ready), .out_valid(out_valid), .out_data(out_data)
  );

  always #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb);
    clk = 0;
    resetn = 0;
    in_valid = 0;
    in_data  = 0;
    out_ready = 0;

    #10 resetn = 1;

    out_ready = 1;
    @(posedge clk);
    in_valid = 1; in_data = 32'd43; exp_data = 32'd43;
    @(posedge clk);
    in_valid = 0;

    @(posedge clk);
    if (out_valid && out_data !== exp_data)
      $fatal("Data mismatch");

    out_ready = 0;
    @(posedge clk);
    in_valid = 1; in_data = 32'd99;

    if (in_ready)
      $fatal("in_ready should be low during stall");

    repeat (2) begin
      @(posedge clk);
      if (out_data !== exp_data)
        $fatal("Data changed during backpressure");
    end

    out_ready = 1;
    @(posedge clk);
	#10;
    $display("TEST PASSED");
    $finish;
  end

endmodule
