module mux32_2 (
    input [31:0] a, b, 
    input high_a, 
    output [31:0] out);
  assign out = high_a ? a : b;
endmodule