module PCRegWrite(in,out,enable);
input [31:0] in;
input enable;
output reg [31:0] out;

always @(*) begin
    if (enable) begin
        out = in;
    end
end

endmodule
