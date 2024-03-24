module instruction_memory (input [31:0] address, output [31:0] instruction);
  //reg [31:0] mem [32'h0100000: 32'h0101000];
  //reg [31:0] mem [1023:0];
  reg [31:0] mem [2047:0];

  wire[31:0] shifted_read_addr;
  assign shifted_read_addr = (address & 32'hFFFF_FFFC)>>2;

  //assign instruction = mem[address[31:2]];
  assign instruction = mem[shifted_read_addr];
endmodule