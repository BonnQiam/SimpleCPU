module Top(input clk, input reset);

wire [31:0] PC;

wire [31:0] ctrlSignals;

wire dataStall;
wire controlStall;

/********************************************************
************************* IF / fetch ****************************         
*********************************************************/

wire [31:0] instrWire, nextPC;

IMemBank u0(1'b1, PC,instrWire);/*IF 指令存储器*/

adder32bit u4(32'b100,PC,nextPC);/*IF 加法器*/

/********************************************************
************************* ID ****************************         
*********************************************************/

wire [31:0] instrWireID,nextPCID;// 承接自 IF 阶段的信号

IFID p1(clk,reset,
        instrWire,nextPC,
        instrWireID,nextPCID,
        dataStall,
        controlStall);// IF-ID 流水线寄存器

/* 控制单元的输出 */
wire [2:0]  ALUOp;
wire        RegDest,RegWrite,ALUSrc,MemRead,MemWrite,MemToReg,Branch,Jump;

wire [31:0]     outSignEXT;           //符号扩展输出
wire [3:0]      ALUCtrl;              // ALU控制信号
wire [27:0]     nextPCJump;           // j 指令指定的地址的一部分
wire [31:0]     NPC1;                 // j 指令下的 Next PC (输出)
wire            invertzero;

wire [31:0] readData1,readData2;// 读取寄存器组的信号

/*写回过程*/
wire [4:0]  writeRegWire, writeRegWireWB;// 待写回的寄存器信号以及对应 WB 阶段
wire [31:0] WBData;
wire        RegWriteWB;

/**/
wire valid_ID;// 当前 ID 阶段是否有效
wire is_i_type_ID, is_r_type_ID, is_j_type_ID;

controlUnit u1(
        instrWireID[31:26],instrWireID[5:0],//age enable 0bashe stall darim
        ALUOp,RegDest,RegWrite,ALUSrc,MemRead,MemWrite,MemToReg,Branch,invertzero,Jump,
        is_i_type_ID, is_r_type_ID, is_j_type_ID,
        instrWireID);/*ID*/

assign valid_ID = (is_r_type_ID | is_i_type_ID | is_j_type_ID) & ~reset; 

signExt u2(instrWireID[15:0],outSignEXT,ALUCtrl, Branch);/*ID*/
mux2A u10(RegDest,instrWireID[20:16],instrWireID[15:11],writeRegWire);/*ID*/

RegFile u11(clk, instrWireID[25:21], instrWireID[20:16], 
            writeRegWireWB, WBData, RegWriteWB, 
            readData1, readData2);/*ID and WB*/

ALUcontrol u13(instrWireID[5:0],ALUOp,ALUCtrl);/*ID*/
shiftLeftForJump u7(instrWireID[25:0],nextPCJump);/*ID*/
concatForJump u20(nextPCID[31:28],nextPCJump,NPC1);/*ID*/

/********************************************************
************************* EX ****************************         
*********************************************************/

wire [31:0] instrWireEX;
wire [31:0] instrWireIEXE_hazard;
wire        RegWriteEX,ALUSrcEX,MemReadEX,MemWriteEX,MemToRegEX,BranchEX,JumpEX;//承接自 ID 阶段的控制单元输出信号
wire [31:0] readData1EX,readData2EX,outSignEXTEX;// 承接自 ID 阶段的各项数据通路呼出
wire [4:0]  writeRegWireEX;//承接自 ID 阶段的用于写回寄存器的寄存器地址
wire [3:0]  ALUCtrlEX;//承接自 ID 阶段的 ALU 控制信号
wire [31:0] nextPCEX;//承接自 ID 阶段的 next PC = PC + 4 信号 
wire [31:0] NPC1EX;//承接自 ID 阶段的跳转指令确定的 PC 地址
wire        invertzero_EX;

wire valid_EX;// 当前 EX 阶段是否有效

/* 流水线寄存器 */
IDEX p2(clk, reset,
        instrWireID,
        RegWrite,ALUSrc,MemRead,MemWrite,MemToReg,Branch,invertzero,Jump,
        ALUCtrl,
        readData1,readData2,
        writeRegWire,
        outSignEXT,nextPCID,NPC1,
        valid_ID,

        instrWireEX,
        RegWriteEX,ALUSrcEX,MemReadEX,MemWriteEX,MemToRegEX,BranchEX,invertzero_EX,JumpEX,
        ALUCtrlEX,
        readData1EX,readData2EX,
        writeRegWireEX,
        outSignEXTEX,nextPCEX,NPC1EX,
        valid_EX,
        dataStall);
//        1'b1);

wire [31:0] ALUSrc1;// ALU 输入信号之一

mux2 u12(ALUSrcEX,
        readData2EX,outSignEXTEX,
        ALUSrc1);/*EX*/

/*ALU输出结果*/
wire [31:0] ALUResult;
wire ZeroOut;

wire [31:0] outputSLL;// 移位输出
wire [31:0] nextPCBranch;//分支指令确定 PC 地址

//! lt、gt 信号没有使用 ？
ALU u14(readData1EX,ALUSrc1,
        ALUCtrlEX,ALUResult,ZeroOut, , );/*EX*/

shiftLeft32bitLeft u3(outSignEXTEX,outputSLL);/*EX*/
adder32bit u5(nextPCEX,outputSLL,nextPCBranch);/*EX*/

/********************************************************
************************* MEM ****************************         
*********************************************************/
wire [31:0] instrWireMEM;

wire        RegWriteMEM,MemReadMEM,MemWriteMEM,MemToRegMEM,BranchMEM,invertzero_MEM,JumpMEM;//承接自 EX 阶段的控制单元输出信号
/*承接自 EX 阶段的数据通路信号*/
wire [31:0] readData2MEM,ALUResultMEM,nextPCBranchMEM,NPC1MEM,nextPCMEM;
wire        ZeroOutMEM;
wire [4:0]  writeRegWireMEM;//承接自 EX 阶段的用于写回寄存器的寄存器地址

wire valid_MEM;// 当前 MEM 阶段是否有效

/* 流水线寄存器 */
EXMEM p3(clk, reset,
        instrWireEX,
        RegWriteEX,MemReadEX,MemWriteEX,MemToRegEX,BranchEX,invertzero_EX,JumpEX,
        readData2EX,ALUResult,ZeroOut,
        nextPCBranch,NPC1EX,nextPCEX,writeRegWireEX,
        valid_EX,

        instrWireMEM,
        RegWriteMEM,MemReadMEM,MemWriteMEM,MemToRegMEM,BranchMEM,invertzero_MEM,JumpMEM,
        readData2MEM,ALUResultMEM,ZeroOutMEM,
        nextPCBranchMEM,NPC1MEM,nextPCMEM,writeRegWireMEM,
        valid_MEM,
        1'b1);

wire [31:0]outputData; //读取存储器的输出

wire branch_zero_and_output;//分支指令使能选择信号
wire branchEnable;

wire [31:0]NPC0;//选择默认 PC+4 还是分支信号
wire [31:0]NPCValue;//最终的 NextPC

DMemBank u15(MemReadMEM, MemWriteMEM,ALUResultMEM, readData2MEM, outputData);/*MEM*/

assign branch_zero_and_output= ZeroOutMEM & BranchMEM;/*MEM*/

assign branchEnable = (invertzero_MEM) ? ~branch_zero_and_output : branch_zero_and_output;/*MEM*/

//assign branchEnable = (invertzero_MEM) ? ~branch_zero_and_output : branch_zero_and_output;/*MEM*/

mux2 u6(branchEnable,nextPCMEM,nextPCBranchMEM,NPC0);/*MEM*/
//mux2 u6(branchEnable,nextPC,nextPCBranchMEM,NPC0);/*MEM*/

mux2 u8(JumpMEM,NPC0,NPC1MEM,NPCValue);/*MEM*/

PCRegWrite u9(clk, reset, 
            NPCValue, nextPC, 
            dataStall, controlStall,
            branchEnable, JumpMEM,
            PC);

//PCRegWrite u9(NPCValue,PC,dataStall,clk,reset);/*MEM*/

/********************************************************
************************* WB ****************************         
*********************************************************/
wire [31:0] instrWireWB;
wire [31:0] ALUResultWB,outputDataWB;//承接自 EX 阶段的数据通路信号
wire        MemToRegWB;
//wire        RegWriteWB,MemToRegWB;

wire valid_WB;// 当前 MEM 阶段是否有效
wire instr_retired;

MEMWB p4(clk, reset,
        instrWireMEM,
        RegWriteMEM,MemToRegMEM,
        outputData,ALUResultMEM,
        writeRegWireMEM,
        valid_MEM,
        
        instrWireWB,
        RegWriteWB,MemToRegWB,
        outputDataWB,ALUResultWB,
        writeRegWireWB,
        valid_WB,
        1'b1);

assign instr_retired = valid_WB;

mux2 u16(MemToRegWB,ALUResultWB,outputDataWB,WBData);/*WB, WBData 的声明在 ID 阶段 */ 

/********************************************************
********************** stall ****************************         
*********************************************************/

wire is_i_type_EXE, is_r_type_EXE, is_j_type_EXE;
wire is_i_type_MEM, is_r_type_MEM, is_j_type_MEM;
wire is_i_type_WB, is_r_type_WB, is_j_type_WB;

DFF u17(clk,is_i_type_ID,is_r_type_ID,is_j_type_ID, is_i_type_EXE, is_r_type_EXE, is_j_type_EXE);
DFF u18(clk,is_i_type_EXE,is_r_type_EXE,is_j_type_EXE, is_i_type_MEM, is_r_type_MEM, is_j_type_MEM);
DFF u19(clk,is_i_type_MEM,is_r_type_MEM,is_j_type_MEM, is_i_type_WB, is_r_type_WB, is_j_type_WB);

stallUnit u90(
        //clk, 
        reset,
        instrWireID, is_i_type_ID, is_r_type_ID,
        instrWireEX, is_i_type_EXE, is_r_type_EXE,
        instrWireMEM, is_i_type_MEM, is_r_type_MEM,
        instrWireWB, is_i_type_WB, is_r_type_WB,
        dataStall);

/*
stallUnit u90(clk, 
        instrWireID[25:21],//rs
        instrWireID[20:16],//rt
        instrWireID[31:26],//opcode
        instrWireID,

        instrWireEX,
        instrWireMEM,
        writeRegWireWB,RegWriteWB,
        instrWireWB,
        dataStall);
*/
Controlstall u92(
        //clk,
        reset,
        instrWireID[31:26],
        instrWireEX[31:26],
        instrWireMEM[31:26],/*instrWireWB[31:26],*/
        controlStall);//agar Dstall 0 nop be vorodi midim

/*
nopSet u91(
        //clk,
        dataStall,controlStall,
        instrWire,instrWireID,
        instrWireIF,instrWireEX);
*/
reg [31:0]  PC_ID, PC_EX, PC_MEM, PC_WB;

always @(posedge clk)begin
    if({dataStall, controlStall} == 2'b11) begin
        PC_ID <= PC;
    end
    else if ({dataStall, controlStall} == 2'b10) begin
        PC_ID <= 32'b1;
    end

    if(dataStall) begin
        PC_EX <= PC_ID;
    end
    else begin
        PC_EX <= 32'b1;
    end

    PC_MEM <= PC_EX;
    PC_WB <= PC_MEM;
end

endmodule
