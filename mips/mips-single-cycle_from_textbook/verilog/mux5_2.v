module mux5_2 (
    input [4:0] a, b, 
    input high_a, 
    output [4:0] out);
  assign out = high_a ? a : b;
endmodule