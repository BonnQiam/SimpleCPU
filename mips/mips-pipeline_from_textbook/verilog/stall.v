module stallUnit(
                //clk, 
                reset,
                IRD, is_i_type_ID, is_r_type_ID,
                IREX, is_i_type_EXE, is_r_type_EXE,
                IRMEM, is_i_type_MEM, is_r_type_MEM,
                IRWB, is_i_type_WB, is_r_type_WB,
                stall);
input reset;

input is_i_type_ID, is_r_type_ID;
input is_i_type_EXE, is_r_type_EXE;
input is_i_type_MEM, is_r_type_MEM;
input is_i_type_WB, is_r_type_WB;

input [31:0] IRD,IREX,IRMEM,IRWB;//指令 4 ID / EX / MEM / WB 阶段
output reg stall;
reg stall_ID_EX_r, stall_ID_EX_i,
    stall_ID_MEM_r, stall_ID_MEM_i, 
    stall_ID_WB_r, stall_ID_WB_i;

always @(*) begin
    if(reset) begin
        stall = 1'b1;

        stall_ID_EX_r = 1'b0;
        stall_ID_EX_i = 1'b0;
        stall_ID_MEM_r = 1'b0;
        stall_ID_MEM_i = 1'b0;
        stall_ID_WB_r = 1'b0;
        stall_ID_WB_i = 1'b0;
    end
    else begin
        // when the instruction in the ID stage uses the rs or rt register
        // of the instruction in the EX, MEM, or WB stage
        // stall = 1 meaning no stall, stall = 0 meaning stall

        stall_ID_EX_r = IRD[25:21] == IREX[15:11] | IRD[20:16] == IREX[15:11];
        stall_ID_MEM_r = IRD[25:21] == IRMEM[15:11] | IRD[20:16] == IRMEM[15:11];
        stall_ID_WB_r = IRD[25:21] == IRWB[15:11] | IRD[20:16] == IRWB[15:11];
        stall_ID_EX_i = IRD[25:21] == IREX[20:16] | IRD[20:16] == IREX[20:16];
        stall_ID_MEM_i = IRD[25:21] == IRMEM[20:16] | IRD[20:16] == IRMEM[20:16];
        stall_ID_WB_i = IRD[25:21] == IRWB[20:16] | IRD[20:16] == IRWB[20:16];
            
        stall = ~( stall_ID_EX_r & ((is_i_type_ID | is_r_type_ID) & (is_r_type_EXE)) |
                 stall_ID_EX_i & (is_i_type_ID | is_r_type_ID) & (is_i_type_EXE) |
                stall_ID_MEM_r & (is_i_type_ID | is_r_type_ID) & (is_i_type_MEM) |
                stall_ID_MEM_i & (is_i_type_ID | is_r_type_ID) & (is_i_type_MEM) | 
                stall_ID_WB_r & (is_i_type_ID | is_r_type_ID) & (is_r_type_WB) |
                stall_ID_WB_i & (is_i_type_ID | is_r_type_ID) & (is_i_type_WB)
                );
    end
    
end

endmodule


/*
module stallUnit(
                //clk, 
                reset,
                IRD,
                IREX,
                IRMEM,
                regWB,WWBs,IRWB,
                stall);

//input clk,reset;
input reset;
input WWBs;
input [4:0] regWB;
input [31:0] IRD,IREX,IRMEM,IRWB;//全套的指令

output reg stall;

reg we1,we2,we3;
reg [4:0] rs,rt;
reg [4:0] ws1,ws2,ws3;
reg res,ret;

//always @(posedge clk)begin
always @(*)begin
    if(reset) begin
        stall=1'b1;
        we1  =1'b0;
        we2  =1'b0;
        we3  =1'b0;
        res  =1'b0;
        ret  =1'b0;
    end
    else begin

    //            ID 阶段的指令是否使用 rs、rt 寄存器

    if(IRD != 32'b0)begin
        rs = IRD[25:21];
        rt = IRD[20:16];
        
        case(IRD[31:26])
//        case(opcode)
            //Rtype
            6'b0:begin
            res=1'b1;
            ret=1'b1;
            end
            6'b100011:begin//lw
            res=1'b1;
            ret=1'b0;
            end
            6'b101011:begin//sw
            res=1'b1;
            ret=1'b1;
            end
            6'b000010:begin//jump
            res=1'b0;
            ret=1'b0;
            end
            6'b100:begin//beq
            res=1'b1;
            ret=1'b1;
            end
            6'b101:begin//bne
            res=1'b1;
            ret=1'b1;
            end
            default begin//I Type
            res=1'b1;
            ret=1'b0;
            end
        endcase
    end
    else begin
        res=1'b0;
        ret=1'b0;
    end

   
    //            EX 阶段的指令是否使用 rs 寄存器
    if(IREX != 32'b0)begin
        case(IREX[31:26])//we1,ws1
            //Rtype:opcode 6bit and function 
            6'b0:begin
            we1=1'b1;
            ws1=IREX[15:11];
            end		 
            6'b100011:begin//lw
            we1=1'b1;
            ws1=IREX[20:16];
            end
            6'b101011:begin//sw
            we1=1'b0;
            ws1=5'b0;
            end
            6'b000010:begin//jump
            we1=1'b0;
            ws1=5'b0;
            end
            6'b100:begin//beq
            we1=1'b0;
            ws1=5'b0;
            end
            6'b101:begin//bne
            we1=1'b0;
            ws1=5'b0;
            end
            default begin//IType
            we1=1'b1;
            ws1=IREX[20:16];
            end
        endcase
    end
    else begin
        we1=1'b0;
    end


    //            MEM 阶段指令是否使用 rd 寄存器
    if(IRMEM != 32'b0)begin
        case(IRMEM[31:26])//we2,ws2
            //Rtype:opcode 6bit and function 6bit
            6'b0:begin
            we2=1'b1;
            ws2=IREX[15:11];
            end
            6'b100011:begin//lw
            we2=1'b1;
            ws2=IREX[20:16];
            end
            6'b101011:begin//sw
            we2=1'b0;
            ws2=5'b0;
            end
            6'b000010:begin//jump
            we2=1'b0;
            ws2=5'b0;
            end
            6'b100:begin//beq
            we2=1'b0;
            ws2=5'b0;
            end
            6'b101:begin//bne
            we2=1'b0;
            ws2=5'b0;
            end
            default begin//IType
            we2=1'b1;
            ws2=IREX[20:16];
            end
        endcase
    end
    else begin
        we2=1'b0;
    end

    
    //            WB 阶段的指令是否使用 rd 寄存器
    if(IRWB != 32'b0)begin
        we3=WWBs;
        ws3=regWB;
    end
    else begin
        we3=1'b0;
    end

    stall = ~( (((rs==ws1)&we1) || ((rs==ws2)&we2) || ((rs==ws3)&we3))&res || 
             (((rt==ws1)&we1) || ((rt==ws2)&we2) || ((rt==ws3)&we3))&ret);
    
    // line 1: ID 阶段指令的 rs 寄存器与 EX、MEM、WB 阶段指令的 rd 寄存器重合
    // line 2: ID 阶段指令的 rt 寄存器与 EX、MEM、WB 阶段指令的 rd 寄存器重合
    // stall 为 0 时阻塞，为 1 时无阻塞

    end
end
endmodule
*/