module SYSCALL_controller(input [31:0]instruction, input clk, output reg syscall);
  initial
    syscall <= 0;
  // Alert the syscall module if the current instruction is a syscall
  always @(negedge clk) begin
  // A syscall instruction is 00 00 00 0C
    //$display("instruction=%h", instruction);
    syscall = (instruction == {28'h0,`SYSCALL}) ? 1 : 0;
  end
endmodule