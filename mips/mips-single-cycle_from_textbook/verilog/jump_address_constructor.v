module jump_address_constructor(
    input [25:0] instruction, 
    input [31:28] PC_plus_4, 
    output reg [31:0] out);
  always @(*)
    out = {PC_plus_4, ({2'b00, instruction}<<2)};
endmodule