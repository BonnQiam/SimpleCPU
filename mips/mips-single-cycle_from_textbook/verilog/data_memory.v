// -------- Memory ---------- //
module data_memory(input [31:0] address, write_data, input memwrite, memread, clk, output wire [31:0] read_data);
  //reg [31:0] mem[0:255];
  parameter data_seg_begin = 32'h1000,
            data_seg_size  = 32'h100000;
  reg [31:0] mem [0:data_seg_size];
  
  always @(posedge clk) begin
    if (memwrite) begin
      mem[address] = write_data;
    end else;
  end

  assign read_data = mem[address];
endmodule