module ALU(input [31:0] data1, data2,
           input [3:0] aluoperation,
           output reg [31:0] result,
           output reg zero, lt, gt);

  always@(aluoperation, data1, data2) begin
    // 先执行ALU操作
    case (aluoperation)
      4'b0000: result = data1 + data2; // ADD
      4'b0001: result = data1 - data2; // SUB
      4'b0010: result = data1 & data2; // AND
      4'b0011: result = data1 | data2; // OR
      4'b0100: result = data1 ^ data2; // XOR
      4'b0101: begin // SLT
        if (data1[31] && !data2[31]) begin
          result = 32'd1; // data1是负数，data2是正数，data1<data2
        end else if (!data1[31] && data2[31]) begin
          result = 32'd0; // data1是正数，data2是负数，data1>data2
        end else begin
          result = (data1 < data2) ? 32'd1 : 32'd0; // 同号比较
        end
      end
      default: result = data1 + data2; // Default to ADD
    endcase

    // 使用补码逻辑比较大小
    if (data1[31] != data2[31]) begin
      lt = data1[31];
      gt = data2[31];
    end else begin
      lt = (data1 < data2);
      gt = (data1 > data2);
    end

    zero = (result == 32'd0);
  end
endmodule

/*
module ALU(input [31:0] data1,data2,
           input [3:0] aluoperation,
           output reg [31:0] result,
           output reg zero,lt,gt);
  always@(aluoperation,data1,data2)
  begin 
	   case (aluoperation)
      4'b0000 : result = data1 + data2; // ADD
      4'b0001 : result = data1 - data2; // SUB
      4'b0010 : result = data1 & data2; // AND
      4'b0011 : result = data1 | data2; // OR
      4'b0100 : result = data1 ^ data2; // XOR
      4'b0101 : result = {31'b0,lt};//slt
      // if you want to add new Alu instructions  add here
      default : result = data1 + data2; // ADD
    endcase

    if(data1>data2)
      begin
       gt = 1'b1;
       lt = 1'b0; 
      end 
    else if(data1<data2)
      begin
       gt = 1'b0;
       lt = 1'b1;  
      end
    else
      begin
       gt = 1'b0;
       lt = 1'b0;  
      end
    
    if (result==32'd0) zero=1'b1;
    else zero=1'b0;
  end

endmodule
*/