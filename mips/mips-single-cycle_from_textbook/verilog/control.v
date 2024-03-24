//`include "mips.h"

// -------------CONTROL-----------------------------------
module control(
    input [5:0] op, funct, 
    //input logic zero, 
    output wire memtoreg, memwrite, memread,
    output wire branch, alusrc,
    output wire regdst, regwrite,
    output wire jump,
    output wire invertzero,  
    output wire [2:0] alucontrol); 

  wire [1:0] aluop;
  wire is_r_type_top, is_i_type_top, is_j_type_top;

  maindec md(op, 
    memtoreg, memwrite, memread,
    branch, alusrc, 
    regdst, regwrite, 
    jump, 
    aluop, 
    invertzero, 
    is_r_type_top, is_i_type_top, is_j_type_top);

  aludec ad(funct, aluop, alucontrol);

endmodule 

module maindec(
    input [5:0] op, 
    output wire memtoreg, memwrite, memread, 
    output wire branch, alusrc, 
    output wire regdst, regwrite, 
    output wire jump, 
    output wire [1:0] aluop,
    output wire invertzero,
    output reg is_r_type_top, is_i_type_top, is_j_type_top
    ); 
  
 reg [10:0] controls; 
 assign {regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop, invertzero, memread} = controls; 
  
 always @(op) begin
  case(op) 
    // RTYPE
    6'b000000: begin
      controls = 11'b11000001000;
      is_r_type_top = 1; 
      is_i_type_top = 0; 
      is_j_type_top = 0;
    end
    // LW 
    6'b100011: begin 
      controls <= 11'b10100100001; 
      is_r_type_top = 0; 
      is_i_type_top = 1; 
      is_j_type_top = 0;
    end
    // SW 
    6'b101011: begin 
      controls <= 11'b00101000000; 
      is_r_type_top = 0; 
      is_i_type_top = 1; 
      is_j_type_top = 0;
    end  
    // ADDI
    6'b001000: begin 
      controls <= 11'b10100000000;
      is_r_type_top = 0; 
      is_i_type_top = 1; 
      is_j_type_top = 0;
    end 
    // ORI - by myself
    6'b001101: begin 
      controls <= 11'b10100001100;
      is_r_type_top = 0; 
      is_i_type_top = 1; 
      is_j_type_top = 0;
    end
    // BEQ
    6'b000100: begin 
      controls <= 11'b00010000100;
      is_r_type_top = 0; 
      is_i_type_top = 1; 
      is_j_type_top = 0;
    end
    // BNE - by my self
    6'b000101: begin 
      controls <= 11'b00010000110;
      is_r_type_top = 0; 
      is_i_type_top = 1; 
      is_j_type_top = 0;
    end
    // J
    6'b000010: begin 
      controls <= 11'b00000010000; 
      is_r_type_top = 0; 
      is_i_type_top = 0; 
      is_j_type_top = 1;
    // JAL - to do
    end 
    default: controls <= 11'bxxxxxxxxxxx; // illegal op 
  endcase 
 end

endmodule 

module aludec(
      input [5:0] funct, 
      input [1:0] aluop, 
      output reg [2:0] alucontrol); 
  always @(aluop) begin
    case(aluop) 
      2'b00: alucontrol <= 3'b010; // add (for lw/sw/addi) 
      2'b01: alucontrol <= 3'b110; // sub (for beq) 
      2'b11: alucontrol <= 3'b001; // or (for ori)
      default:  
        case(funct) // R-type instructions 
          6'b100000: alucontrol <= 3'b010; // add 
          6'b100010: alucontrol <= 3'b110; // sub 
          6'b100100: alucontrol <= 3'b000; // and 
          6'b100101: alucontrol <= 3'b001; // or 
          6'b101010: alucontrol <= 3'b111; // slt 
          default: alucontrol <= 3'bxxx;   // ??? 
        endcase 
    endcase 
  end 
endmodule