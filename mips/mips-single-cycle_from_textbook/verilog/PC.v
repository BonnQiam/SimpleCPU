module PC (
    input [31:0] new_pc, 
    input clk, 
    input reset, 
    output reg [31:0] PC);
  always @(posedge clk or posedge reset) begin
    if(reset)
      PC <= 31'b0;
    else
      PC <= new_pc;  
  end
endmodule