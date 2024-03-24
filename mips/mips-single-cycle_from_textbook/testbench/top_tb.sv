// Top testbench

`define op           31:26  // 6-bit operation code
`define rs           25:21  // 5-bit source register specifier
`define rt           20:16  // 5-bit source/dest register spec or sub opcode
`define rd           15:11  // 5-bit destination register specifier
`define immediate    15:0   // 16-bit immediate, branch or address disp

module top_tb ();
`include "testbench/init_imem.sv"
`include "testbench/init_dmem.sv"
`include "testbench/boot_code.sv"

// following function are decalred in /mips/iss/main.h
import "DPI-C" function void init (string test_name); 
import "DPI-C" function void run (int cycles);
import "DPI-C" function int compare_r (int pc, int instr, int rd, int rs, int rt, int rd_val, int rs_val, int rt_val);
import "DPI-C" function int compare_i (int pc, int instr, int rs, int rt, int rs_val, int rt_val);
import "DPI-C" function int compare_j (int pc, int instr, int rt, int rt_val);

    //wire clk_tb;
    reg  clk_tb, reset_tb;
    string      test_name;

    wire[31:0]  pc;
    wire[31:0]  instr;
    wire[4:0]   rd;
    wire[4:0]   rs;
    wire[4:0]   rt;
    wire[31:0]  rd_val;
    wire[31:0]  rs_val;
    wire[31:0]  rt_val;
    wire[31:0]  rd_val_dest;
    wire[31:0]  rt_val_dest;

    assign pc       = T1.address;
    assign instr    = T1.instruction;
    assign rd       = T1.instruction[`rd];
    assign rs       = T1.instruction[`rs];
    assign rt       = T1.instruction[`rt];
    assign rd_val   = T1.register_file.reg_file[rd];
    assign rs_val   = T1.register_file.reg_file[rs];
    assign rt_val   = T1.register_file.reg_file[rt];


    //assign rt_val_dest  = (T1.reg_wr_top || T1.use_link_reg_top) ? T1.wr_data_rf_top : rt_val;
    //assign rd_val_dest  = T1.reg_wr_top ? T1.wr_data_rf_top : rd_val;

    assign rt_val_dest  = (T1.regwrite) ? T1.memtoreg_mux_output : rt_val;
    assign rd_val_dest  = (T1.regwrite) ? T1.memtoreg_mux_output : rd_val;    

    top T1(clk_tb, reset_tb);

    localparam T = 200;

    always
    begin
        clk_tb = 1'b0;
        # (T/2);
        clk_tb = 1'b1;
        # (T/2);
    end

    initial
    begin
        if (!($value$plusargs("test=%s", test_name)))
          $fatal ("No test name given");
        init_imem (test_name);
        init_dmem ();
        boot_code ();
        init (test_name);
        $display ("CPU initialised\n");
        reset_tb = 1'b1;
        # (T);
        reset_tb = 1'b0;
    end

    always @ (negedge clk_tb)
    if (~reset_tb)
    begin
        //$display("rtype: %b", T1.control_test.is_r_type_top);
        //$display("itype: %b", T1.control_test.is_i_type_top);
        //$display("jtype: %b", T1.control_test.is_j_type_top);
        //$display("Opcode: %b", T1.control_test.op);
        //$display("Funct: %b", T1.control_test.funct);
        //$display("Rs: %h", T1.read_data1);
        //$display("Rt: %h", T1.read_data2);
        //$display("alusrc_mux_output: %h", T1.alusrc_mux_output);
        //$display("Branch: %h", T1.branch);
        //$display("Zero: %h", T1.zero);
        //$display("branch_mux_control: %h", T1.branch_mux_control);
        //$display("branch_adder_mux: %h", T1.branch_adder_mux);
        //$display("pc_adder_mux: %h", T1.pc_adder_mux);
        //$display("Test: %h", T1.branch_address);
        run (1);
        
        if (T1.control_test.is_r_type_top) 
        begin
            if (!compare_r (pc, instr, rd, rs, rt, rd_val_dest, rs_val, rt_val))
                $fatal(1, "TEST FAILED\n");
        end
        else if (T1.control_test.is_i_type_top)
        begin
            if (!compare_i (pc, instr, rs, rt, rs_val, rt_val_dest))
                $fatal(1, "TEST FAILED\n");
        end
        else if (T1.control_test.is_j_type_top)
        begin
            if (!compare_j (pc, instr, rt, rt_val_dest))
                $fatal(1, "TEST FAILED\n");
        end
        else
        begin
            $fatal(1, "TEST FAILED\n");
        end
    end

    always @ (negedge clk_tb)
    begin
        if ((T1.instruction == 'hc) && (T1.register_file.reg_file[2] == 'ha))
        begin
            $display("TEST PASSED\n");
            $display("End of simulation reached\n");
            $finish;
        end
    end

endmodule
