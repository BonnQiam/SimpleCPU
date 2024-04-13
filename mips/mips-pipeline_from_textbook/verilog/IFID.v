module IFID(
    clk,reset,
    iInstr,iNextPC,
    oInstr,oNextPC,
    dataStall,controlStall
);

input clk, reset, dataStall, controlStall;
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
    
        if({dataStall, controlStall} == 2'b11) begin
            oInstr <= iInstr;
            oNextPC <= iNextPC;
        end
        
        else if ({dataStall, controlStall} == 2'b10) begin
            oInstr <= 32'b0;
            oNextPC <= 32'b0;
        end

        else if ({dataStall, controlStall} == 2'b01) begin
            //do nothing
        end
        else if ({dataStall, controlStall} == 2'b00) begin
            //do nothing
        end

    end
end

endmodule