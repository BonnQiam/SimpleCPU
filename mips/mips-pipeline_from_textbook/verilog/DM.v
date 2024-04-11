module DMemBank(input memread, input memwrite, input [31:0] address, input [31:0] writedata, 
                output reg [31:0] readdata);

  parameter data_seg_size  = 32'h100000;
  reg [31:0] mem_array [0:data_seg_size];
  //reg [31:0] mem_array [127:0];

  wire[6:0]finalAddress;

  assign finalAddress=address[8:0];
 
  always@(memread, memwrite, address, mem_array[address], writedata)
  begin
    if(memread)begin
      readdata=mem_array[finalAddress];
    end

    if(memwrite)
    begin
      mem_array[finalAddress]= writedata;
    end

  end

endmodule

