//module Controlstall(clk,reset,op1,op2,op3,stall);
module Controlstall(reset,op1,op2,op3,stall);
input [5:0]op1,op2,op3;

//input clk,reset;
input reset;

output reg stall;

//always @(posedge clk)begin
always @(reset, op1, op2, op3)begin
    if(reset) begin
        stall=1'b1;//无阻塞
    end
    else begin
        //! 此处使用原来多 if 语句会出错
        if(op1==6'b000100 | op1==6'b000101 | op1==6'b000010)begin// beq or bne or j
            stall=1'b0;//阻塞
        end
        else if(op2==6'b000100 | op2==6'b000101 | op2==6'b000010)begin// beq or bne or j
            stall=1'b0;//阻塞
        end
        else if(op3==6'b000100 | op3==6'b000101 | op3==6'b000010)begin// beq or bne or j
            stall=1'b0;//阻塞
        end
        else begin
            stall=1'b1;// 无阻塞
        end

    end
end
endmodule

module nopSet(
            //clk,
            s1,//数据冒险阻塞信号，0 为阻塞，1 为无阻塞
            s2,//控制冒险阻塞信号，0 为阻塞，1 为无阻塞
            oldF,oldD,
            newF,newD);
//input clk,s1,s2;
input s1,s2;
input [31:0] oldF,oldD;
output reg[31:0] newF,newD;

//always @(posedge clk)begin
always @(*)begin
    if(s1==1'b0 && s2==1'b0)begin//同时存在数据冒险、控制冒险
        //newF=32'b0;
        newD=32'b0;
    end
    else if(s1==1'b0 && s2==1'b1)begin//数据冒险
        newD=32'b0;
    end
    else if(s1==1'b1 && s2==1'b0)begin//控制冒险
        newF=32'b0;
        newD=(oldD == 32'b0) ? 32'b0 : oldD;
    end
    else//无冒险
    begin
        newF=oldF;
        newD=oldD;
    end
end
endmodule
