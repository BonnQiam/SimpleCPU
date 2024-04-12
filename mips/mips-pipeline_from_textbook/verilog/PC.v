module PCRegWrite(in,out,enable,clk,reset);
input [31:0] in;
input enable,clk, reset;
output reg [31:0] out;

always @(posedge clk) begin
    if (reset) begin
        out <= 32'b0;
    end
    else begin

    if (enable) begin
        out <= in;
    end 

    end
end

endmodule
