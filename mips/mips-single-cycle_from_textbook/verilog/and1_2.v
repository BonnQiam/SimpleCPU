module and1_2(input a, b, output reg out);
  always @(*) begin
    out = a & b;
  end
endmodule