module instruction_memory (input [31:0] address, output [31:0] instruction);
  reg [31:0] mem [2047:0]; // mem is 2048 words of 32 bits each, mem[0] means the first word in memory, mem[1] means the second word in memory, and so on.

  wire[31:0] shifted_read_addr;
  assign shifted_read_addr = (address & 32'hFFFF_FFFC)>>2; 
  // This is equivalent to setting the two least significant bits to zero. This is done to ensure that the address is aligned to a word boundary (4-byte boundary) because each word in memory is 32 bits (4 bytes) long.
  // The resulting value is then right-shifted by 2 bits (>>2) to divide the value by 4. This is done because each word in memory is 4 bytes long, and we want to access the correct word in memory.

  //assign instruction = mem[address[31:2]];
  assign instruction = mem[shifted_read_addr];
endmodule