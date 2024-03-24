// --------- ALU ------------ //
module ALU (
    input [2:0] aluop, 
    input [31:0] a, b, 
    output reg [31:0] out, output reg zero);
  always @(*) begin
    case (aluop)
      3'b000: out = a & b;
      3'b001: out = a | b;
      3'b010: out = a + b;
      3'b110: out = a - b;
      3'b111: out = a < b;
      default: out = 32'bxxxxxxxx;
    endcase
    zero = (out == 32'h0000);
  end
endmodule