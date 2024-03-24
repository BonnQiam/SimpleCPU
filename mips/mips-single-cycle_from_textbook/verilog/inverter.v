// Inverter outputs the inverse of the input if control is 1.
module inverter(input in, control, output reg out);
  always @(*) begin
    out = (control) ? ~in : in;
  end
endmodule