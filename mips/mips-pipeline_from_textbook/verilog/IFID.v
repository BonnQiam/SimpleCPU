module IFID(
    clk,reset,
    iInstr,iNextPC,
    oInstr,oNextPC,
    enable
);

input clk, reset, enable;
input [31:0] iInstr;
input [31:0] iNextPC;

output [31:0] oInstr;
output [31:0] oNextPC;

reg [31:0] oInstr;
reg [31:0] oNextPC;

always @(posedge clk)
begin
    if(reset) begin
        oInstr <= 32'b0;
        oNextPC <= 32'b0;
    end
    else begin
    
    if(enable) begin
        oInstr <= iInstr;
        oNextPC <= iNextPC;
    end

    end
end

endmodule