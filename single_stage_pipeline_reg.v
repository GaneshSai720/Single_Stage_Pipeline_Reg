module single_stage_pipeline_reg #(
    parameter int WIDTH = 32
)(
    input  logic              clk,
    input  logic              resetn,
    
    // Upstream 
    output logic              in_ready,
    input  logic              in_valid,
    input  logic [WIDTH-1:0]  in_data,
    
    // Downstream
    input  logic              out_ready,
    output logic              out_valid,
    output logic [WIDTH-1:0]  out_data
);
  
  logic               data_valid;
  logic [WIDTH-1:0]   data_reg;
  
  assign in_ready = (!data_valid) | out_ready;
  
  always_ff @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      data_valid <= 1'b0;
      data_reg   <= '0;
    end 
    else begin
      if (in_ready) begin
        data_valid <= in_valid;
        if (in_valid) begin
          data_reg <= in_data;
        end
      end
    end
  end
  
  assign out_valid = data_valid;
  assign out_data  = data_reg;
  
endmodule
