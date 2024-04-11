module EXMEM(
        clock,reset,
        iInstr,
        iRegWrite,iMemRead,iMemWrite,iMemToReg,iBranch,iJump,
        iB,iResult,iZero,
        inextPCBranch,iNPC1,iPC,iwriteRegWire,

        oInstr,
        oRegWrite,oMemRead,oMemWrite,oMemToReg,oBranch,oJump,
        oB,oResult,oZero,
        onextPCBranch,oNPC1,oPC,owriteRegWire,
        enable);

input clock,reset,enable;
input iZero;
input [31:0] iInstr;
input iRegWrite,iMemRead,iMemWrite,iMemToReg,iBranch,iJump;
input [4:0] iwriteRegWire;
input [31:0] iB,iResult, inextPCBranch,iNPC1,iPC;

output [31:0] oInstr;
output oRegWrite,oMemRead,oMemWrite,oMemToReg,oBranch,oJump;
output [4:0] owriteRegWire;
output oZero;
output [31:0] oB,oResult,onextPCBranch,oNPC1,oPC;

reg [31:0] oInstr;
reg oRegWrite,oMemRead,oMemWrite,oMemToReg,oBranch,oJump;
reg [4:0] owriteRegWire;
reg [31:0] oB,oResult,oZero,onextPCBranch,oNPC1,oPC;

always @(posedge clock)
begin
    if(reset)begin
        oInstr      <= 32'b0;
        oRegWrite   <= 1'b0;
        oMemRead    <= 1'b0;
        oMemWrite   <= 1'b0;
        oMemToReg   <= 1'b0;
        oBranch     <= 1'b0;
        oJump       <= 1'b0;

        oB          <= 32'b0;
        oResult     <= 32'b0;
        oZero       <= 1'b0;
        onextPCBranch   <= 32'b0;
        oNPC1           <= 32'b0;
        oPC             <= 32'b0;
        owriteRegWire   <= 5'b0;
    end
    else begin
        
    if(enable)begin
        oInstr      <=iInstr;
        
        oRegWrite   <=iRegWrite;
        oMemRead    <=iMemRead;
        oMemWrite   <=iMemWrite;
        oMemToReg   <=iMemToReg;
        oBranch     <=iBranch;
        oJump       <=iJump;

        
        oB          <=iB;
        oResult     <=iResult;
        oZero       <=iZero;

        onextPCBranch   <= inextPCBranch;
        oNPC1           <= iNPC1;
        oPC             <= iPC;
        owriteRegWire   <= iwriteRegWire;
        
    end

    end
end
endmodule


