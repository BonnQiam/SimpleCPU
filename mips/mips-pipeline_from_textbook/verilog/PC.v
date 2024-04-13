module PCRegWrite(
    clk,reset,
    NPC_branch_j,
    NPC_increment_4,
    datastall, controlstall, 
    branch_enable, jump_enable,
    PC);
input [31:0] NPC_branch_j, NPC_increment_4;
input clk, reset;
input datastall, controlstall, branch_enable, jump_enable;
output reg [31:0] PC;

always @(posedge clk) begin
    if (reset) begin
        PC <= 32'b0;
    end
    else begin
    
    if (branch_enable | jump_enable) begin
        PC <= NPC_branch_j;
    end
    else if ( ~(datastall & controlstall) ) begin
        //do nothing PC <= PC;
    end
    else begin
        PC <= NPC_increment_4;
    end   
    
    end
end

endmodule
