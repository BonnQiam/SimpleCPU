module DFF(clk, i1, i2, i3, o1, o2, o3);
    input clk;
    input i1;
    input i2;
    input i3;
    output o1;
    output o2;
    output o3;
    
    reg o1;
    reg o2;
    reg o3;
    
    always @(posedge clk) begin
        o1 <= i1;
        o2 <= i2;
        o3 <= i3;
    end

endmodule