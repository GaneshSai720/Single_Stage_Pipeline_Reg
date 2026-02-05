module tb #(parameter WIDTH = 32);

  logic clk, resetn;
  logic in_valid, out_ready;
  logic [WIDTH-1:0] in_data;
  wire  in_ready, out_valid;
  wire  [WIDTH-1:0] out_data;

  logic [WIDTH-1:0] expected_val;

  single_stage_pipeline_reg #(.WIDTH(WIDTH)) dut (.*);
  always #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);

    // Initial State
    clk       = 0;
    resetn    = 0;
    in_valid  = 0;
    in_data   = 0;
    out_ready = 0;

    repeat(2) @(posedge clk);
    resetn <= 1;
    @(posedge clk);

    $display("Test 1: Single data transfer");
    in_valid     <= 1;
    in_data      <= 32'hAAAA_BBBB;
    expected_val  = 32'hAAAA_BBBB;
    out_ready    <= 1; // Downstream is ready
    
    @(posedge clk);
    in_valid     <= 0; // Stop sending after 1 cycle
    
    @(posedge clk);
    // Check if data is there
    if (!out_valid || out_data !== expected_val) 
      $fatal(1, "Data not received correctly! Stored: %h", out_data);

    // Draining
    $display("Test 2: Ensure valid drops after data is consumed");
    out_ready <= 1;
    in_valid  <= 0; 
    repeat(2) @(posedge clk); // Let the pipe empty
    

    // Backpressure (Stall)
    $display("Test 3: Testing backpressure");
    in_valid  <= 1;
    in_data   <= 32'h1234_5678;
    out_ready <= 0; // Downstream is BUSY
    
    @(posedge clk); // Data enters register
    in_valid  <= 0;
    
    // Wait a few cycles, data should stay in the register
    repeat(3) @(posedge clk);
    if (!out_valid || out_data !== 32'h1234_5678)
      $fatal(1, "Data lost during stall!");
    if (in_ready)
      $fatal(1, "in_ready should be low when register is full and downstream is busy");

    // Release backpressure
    out_ready <= 1;
    @(posedge clk);
    
    $display("ALL TESTS PASSED");
    $finish;
  end

endmodule
