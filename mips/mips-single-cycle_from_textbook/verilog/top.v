module top(input wire clock, input wire reset);
  wire [31:0] pc_adder_mux; /*PC+4*/
  wire [31:0] branch_adder_mux;
  
  wire [31:0] mux_pc;
  wire [31:0] address;

  wire [31:0] instruction;

  /* Control */
  wire memtoreg, memwrite, memread;
  wire branch, alusrc;
  wire regdst, regwrite;
  wire jump;
  wire invertzero;
  wire [2:0] aluop_to_alu;

  /* Register */
  wire [4:0] regdst_mux_output;
  wire [31:0] memtoreg_mux_output;

  wire [31:0] read_data1,read_data2; /*From registers*/

  /* ALU */
  wire [31:0] alusrc_mux_output;
  wire [31:0] alu_result;

  /* Data Memory */
  wire [31:0] read_data;

  /* Branch */
  wire branch_zero_and_output, branch_mux_control;
  wire [31:0] branch_address;

  /* Jump */
  wire [31:0] jump_address;

  /* Syscall */
  wire syscall;

  mux32_2 jump_mux(jump_address, branch_address, 
                  jump, 
                  mux_pc);

  PC p_counter(mux_pc, clock, reset, address);

  adder pc_incrementer(address, 32'h4, pc_adder_mux);

  instruction_memory imem(address, instruction);
  
  SYSCALL_controller syscaller(instruction, clock, syscall);

  control control_test(instruction[`op], instruction[`function],
                  memtoreg, memwrite, memread,
                  branch, alusrc,
                  regdst, regwrite,
                  jump,
                  invertzero,
                  aluop_to_alu);
  
  mux5_2 regdst_mux(instruction[`rd], instruction[`rt], 
                    regdst, 
                    regdst_mux_output);

  registers register_file(instruction[`rs], instruction[`rt],
                          regdst_mux_output, memtoreg_mux_output,
                          regwrite, 
                          syscall, 
                          clock,
                          read_data1, read_data2);

  wire [31:0] ALU_Src_Extend;

  assign ALU_Src_Extend = (instruction[`op] == 6'b001101) ? {16'h0, instruction[15:0]}: {{16{instruction[15]}},instruction[15:0]};

  mux32_2 alusrc_mux(
                    //{16'h0, instruction[15:0]}/*sign-extend from 16 to 32*/, 
                    ALU_Src_Extend,
                    read_data2, 
                    alusrc, alusrc_mux_output);

  ALU alu(aluop_to_alu, read_data1, alusrc_mux_output, alu_result, zero);

  data_memory dmem(alu_result, read_data2, memwrite, memread, 
                  clock, 
                  read_data);

  mux32_2 memtoreg_mux(read_data/*from data memory*/, alu_result, 
                      memtoreg, 
                      memtoreg_mux_output);

  /* Branching logic */
  and1_2 branch_zero_and(branch, zero, branch_zero_and_output);
  // Inverter for detecting when ALU is not zero, used for BNE
  inverter invertzero_inverter(branch_zero_and_output, invertzero, branch_mux_control);
  mux32_2 branch_mux(branch_adder_mux, pc_adder_mux, 
                    branch_mux_control, 
                    branch_address);
  adder branch_adder({{16{instruction[15]}},instruction[15:0]}<<2, /*sign-extend from 16 to 32 then shift left 2*/
                    pc_adder_mux,
                    branch_adder_mux);
  
  
  /* Jumping logic */
  jump_address_constructor jump_constructor(instruction[`target], pc_adder_mux[31:28], jump_address);
endmodule