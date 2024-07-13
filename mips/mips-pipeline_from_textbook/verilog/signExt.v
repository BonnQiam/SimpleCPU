module signExt(inData,outData,ALUCtrl,Branch);
input[15:0] inData;
input[3:0]  ALUCtrl;
input Branch;
output[31:0] outData;
reg[31:0] outData;

//always@(inData)
always@(*)
begin
    // addi / stli / beq/ bne using sign-extend
    // andi / ori using zero-extend
    if(ALUCtrl == 4'b0000 | ALUCtrl == 4'b0101 |Branch == 1'b1) begin
        outData[15:0]=inData[15:0];
        outData[31:16]={16{inData[15]}};/*sign-extend from 16 to 32*/
    end
    else if(ALUCtrl == 4'b0010 | ALUCtrl == 4'b0011) begin
        outData = {16'h0, inData[15:0]};
    end
end
endmodule
