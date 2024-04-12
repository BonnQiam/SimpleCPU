module MEMWB(clock, reset,
            iInstr,
            iRegWrite,iMemToReg,
            iouputData,iALUResult,
            iwriteRegWire,
            ivalid,

            oInstr,
            oRegWrite,oMemToReg,
            oouputData,oALUResult,
            owriteRegWire,
            ovalid,
            enable);

input clock, reset, enable;
input [31:0] iInstr;
input iRegWrite,iMemToReg;
input [31:0] iouputData,iALUResult;
input [4:0] iwriteRegWire;
input ivalid;

output [31:0] oInstr;
output oRegWrite,oMemToReg;
output [31:0] oouputData,oALUResult;
output [4:0] owriteRegWire;
output ovalid;

reg [31:0] oInstr;
reg oRegWrite,oMemToReg;
reg [31:0] oouputData,oALUResult;
reg [4:0]   owriteRegWire;
reg ovalid;

initial begin
    oInstr=32'b0;
end

always @(posedge clock)
begin
    if(reset)begin
        oInstr      <= 32'b0;
        oRegWrite   <= 1'b0;
        oMemToReg   <= 1'b0;

        oouputData  <= 32'b0;
        oALUResult  <= 32'b0;

        owriteRegWire   <= 5'b0;

        ovalid      <= 1'b0;
    end
    else begin

    if(enable)begin
        oInstr      <= iInstr;

        oRegWrite   <= iRegWrite;
        oMemToReg   <= iMemToReg;

        oouputData  <= iouputData;
        oALUResult  <= iALUResult;

        owriteRegWire <= iwriteRegWire;

        ovalid      <= ivalid;
    end

    end
end
endmodule

