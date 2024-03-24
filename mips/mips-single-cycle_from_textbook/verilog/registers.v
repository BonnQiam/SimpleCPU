module registers(input [25:21] read_reg1,
                input [20:16] read_reg2,
                input [15:11] write_reg,
                input [31:0] write_data,
                input regwrite,
                input syscall,
                input clk,
                output wire [31:0] read_data1, read_data2);
  //reg [32:0] [32:0] reg_file;
  reg [31:0] reg_file [31:0];

  assign read_data1 = reg_file[read_reg1];
  assign read_data2 = reg_file[read_reg2];

  always @(posedge clk) begin
    if (regwrite) begin
      reg_file[write_reg] = write_data;
      reg_file[`r0] = 0; // Ensure r0 is always 0
    end
  end
  
  always @(posedge syscall) begin
    case (reg_file[`v0])
      1/*print*/: $strobe("%d", reg_file[`a0]);
      10/*exit*/: $finish;
      default: $display("Got an unsupported syscall code:%h", reg_file[`v0]);
    endcase
  end
endmodule