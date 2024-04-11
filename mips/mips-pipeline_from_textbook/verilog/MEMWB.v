module MEMWB(clock,
            iInstr,
            iRegWrite,iMemToReg,
            iouputData,iALUResult,
            iwriteRegWire,

            oInstr,
            oRegWrite,oMemToReg,
            oouputData,oALUResult,
            owriteRegWire,
            enable);

input clock, enable;
input [31:0] iInstr;
input iRegWrite,iMemToReg;
input [31:0] iouputData,iALUResult;
input [4:0] iwriteRegWire;

output [31:0] oInstr;
output oRegWrite,oMemToReg;
output [31:0] oouputData,oALUResult;
output [4:0] owriteRegWire;

reg [31:0] oInstr;
reg oRegWrite,oMemToReg;
reg [31:0] oouputData,oALUResult;
reg [4:0]   owriteRegWire;

initial begin
    oInstr=32'b0;
end

always @(posedge clock)
begin
    if(enable)begin
        oInstr      <= iInstr;

        oRegWrite   <= iRegWrite;
        oMemToReg   <= iMemToReg;

        oouputData  <= iouputData;
        oALUResult  <= iALUResult;

        owriteRegWire <= iwriteRegWire;
    end
end
endmodule

