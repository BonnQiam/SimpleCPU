module IDEX(clock,reset,
            iInstr,
            iRegWrite,iALUSrc,iMemRead,iMemWrite,iMemToReg,iBranch,iinvertzero,iJump,
            iALUCtrl,
            iA,iB,
            iwriteRegWire,
            ioutSignEXT,iPC,iNPC1,
            ivalid,
            
            oInstr,
            oRegWrite,oALUSrc,oMemRead,oMemWrite,oMemToReg,oBranch,oinvertzero,oJump,
            oALUCtrl,
            oA,oB,
            owriteRegWire,
            ooutSignEXT,oPC,oNPC1,
            ovalid,
            enable);

input [31:0] iInstr;
input clock, reset, enable;
input iRegWrite,iALUSrc,iMemRead,iMemWrite,iMemToReg,iBranch,iinvertzero,iJump;
input [31:0] iA,iB,ioutSignEXT,iPC,iNPC1;
input [3:0]  iALUCtrl;
input [4:0]  iwriteRegWire;
input ivalid;

output [31:0] oInstr;
output oRegWrite,oALUSrc,oMemRead,oMemWrite,oMemToReg,oBranch,oinvertzero,oJump;
output [31:0] oA,oB,ooutSignEXT,oPC,oNPC1;
output [3:0]  oALUCtrl;
output [4:0]  owriteRegWire;
output ovalid;

reg [31:0] oInstr;
reg oRegWrite,oALUSrc,oMemRead,oMemWrite,oMemToReg,oBranch,oinvertzero,oJump;
reg [31:0] oA,oB,ooutSignEXT,oPC,oNPC1;
reg [3:0]  oALUCtrl;
reg [4:0]  owriteRegWire;
reg ovalid;

always @(posedge clock)
begin
    if(reset)begin
        oInstr      <= 32'b0;
        oRegWrite   <= 1'b0;
        oALUSrc     <= 1'b0;
        oMemRead    <= 1'b0;
        oMemWrite   <= 1'b0;
        oMemToReg   <= 1'b0;
        oBranch     <= 1'b0;
        oinvertzero <= 1'b0;
        oJump       <= 1'b0;

        oA          <= 32'b0;
        oB          <= 32'b0;
        ooutSignEXT <= 32'b0;
        oPC         <= 32'b0;
        oNPC1       <= 32'b0;

        oALUCtrl    <= 4'b0;

        owriteRegWire   <= 5'b0;

        ovalid      <= 1'b0;
    end
    else begin
        
    if(enable)begin
        oInstr      <= iInstr;

        oRegWrite   <= iRegWrite;
        oALUSrc     <= iALUSrc;
        oMemRead    <= iMemRead;
        oMemWrite   <= iMemWrite;
        oMemToReg   <= iMemToReg;
        oBranch     <= iBranch;
        oinvertzero <= iinvertzero;
        oJump       <= iJump;

        oPC         <= iPC;
        oA          <= iA;
        oB          <= iB;
        ooutSignEXT <= ioutSignEXT;
        oNPC1       <= iNPC1;

        oALUCtrl    <= iALUCtrl;

        owriteRegWire   <= iwriteRegWire;

        ovalid     <= ivalid;
    end
    else begin
        oInstr      <= 32'b0;
        oRegWrite   <= 1'b0;
        oALUSrc     <= 1'b0;
        oMemRead    <= 1'b0;
        oMemWrite   <= 1'b0;
        oMemToReg   <= 1'b0;
        oBranch     <= 1'b0;
        oinvertzero <= 1'b0;
        oJump       <= 1'b0;

        oA          <= 32'b0;
        oB          <= 32'b0;
        ooutSignEXT <= 32'b0;
        oPC         <= 32'b0;
        oNPC1       <= 32'b0;

        oALUCtrl    <= 4'b0;

        owriteRegWire   <= 5'b0;

        ovalid      <= 1'b0;
    end

    end

end

endmodule

