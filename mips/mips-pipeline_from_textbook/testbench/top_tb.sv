// Top testbench

`define rs           25:21  // 5-bit source register specifier
`define rt           20:16  // 5-bit source/dest register spec or sub opcode
`define rd           15:11  // 5-bit destination register specifier

module top_tb ();
`include "testbench/init_imem.sv"
`include "testbench/init_dmem.sv"
`include "testbench/boot_code.sv"
import "DPI-C" function void init (string test_name);
import "DPI-C" function void run (int cycles);
import "DPI-C" function int compare_r (int pc, int instr, int rd, int rs, int rt, int rd_val, int rs_val, int rt_val);
import "DPI-C" function int compare_i (int pc, int instr, int rs, int rt, int rs_val, int rt_val);
import "DPI-C" function int compare_j (int pc, int instr, int rt, int rt_val);

    logic   clk_tb, reset_tb;
    string  test_name;

    // Fetch stage signals
    logic[31:0]   pc_fetch;
    logic[31:0]   instr_fetch;
    // Issue stage signals
    logic[31:0]   pc_iss;
    logic[31:0]   instr_iss;
    logic         is_r_type_iss;
    logic         is_i_type_iss;
    logic         is_j_type_iss;
    logic[4:0]    rd_iss;
    logic[4:0]    rs_iss;
    logic[4:0]    rt_iss;
    // Execute stage signals
    logic[31:0]   pc_ex;
    logic[31:0]   instr_ex;
    logic         is_r_type_ex;
    logic         is_i_type_ex;
    logic         is_j_type_ex;
    logic[4:0]    rd_ex;
    logic[4:0]    rs_ex;
    logic[4:0]    rt_ex;
    logic[31:0]   rd_val_ex;
    logic[31:0]   rs_val_ex;
    logic[31:0]   rt_val_ex;
    // Memory stage signals
    logic[31:0]   pc_mem;
    logic[31:0]   instr_mem;
    logic         is_r_type_mem;
    logic         is_i_type_mem;
    logic         is_j_type_mem;
    logic[4:0]    rd_mem;
    logic[4:0]    rs_mem;
    logic[4:0]    rt_mem;
    logic[31:0]   rd_val_mem;
    logic[31:0]   rs_val_mem;
    logic[31:0]   rt_val_mem;
    // Write-back stage signals
    logic[31:0]   pc_wb;
    logic[31:0]   instr_wb;
    logic         is_r_type_wb;
    logic         is_i_type_wb;
    logic         is_j_type_wb;
    logic[4:0]    rd_wb;
    logic[4:0]    rs_wb;
    logic[4:0]    rt_wb;
    logic[31:0]   rd_val_wb;
    logic[31:0]   rs_val_wb;
    logic[31:0]   rt_val_wb;
    logic[31:0]   rd_val_dest_wb;
    logic[31:0]   rt_val_dest_wb;
    logic         instr_retired_wb;  

    // FETCH
    // // signals tapped from the FETCH stage
    assign pc_fetch          = T1.PC;
    assign instr_fetch       = T1.instrWire;

    // ISSUE
    // signals tapped from the ISS stage
    assign is_r_type_iss     = T1.u1.is_r_type;
    assign is_i_type_iss     = T1.u1.is_i_type;
    assign is_j_type_iss     = T1.u1.is_j_type;

    assign rs_iss            = T1.instrWireID[`rs];
    assign rt_iss            = T1.instrWireID[`rt];
    assign rd_iss            = T1.instrWireID[`rd];

    // WRITE-BACK
    // signals tapped from the WB stage
    assign rt_val_dest_wb    = T1.RegWriteWB ? T1.writeRegWireWB : rt_val_wb;
    assign rd_val_dest_wb    = T1.RegWriteWB ? T1.writeRegWireWB : rd_val_wb;
    
    //assign instr_retired_wb  = T1.controlStall & T1.dataStall;
    assign instr_retired_wb = (pc_wb == 32'b0) ?
        ((instr_wb != instr_mem) ? 1 : 0) :
            (
                (T1.dataStall & T1. controlStall) ? 
                    1 : (
                        (instr_wb != instr_mem) ? 1 : 0
                    )
            );

    assign rd_val_wb         = T1.u11.regfile[rd_wb];
    assign rs_val_wb         = T1.u11.regfile[rs_wb];
    assign rt_val_wb         = T1.u11.regfile[rt_wb];

    Top T1 (
        .clk (clk_tb),
        .reset (reset_tb)
    );

    //localparam T = 40;
    localparam T = 6;
    
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
        repeat (5) @(posedge clk_tb);
        reset_tb = 1'b0;
        
        
        $display("---------------Begin Test-----------------");
    end

    always
    begin
        clk_tb = 1'b0;
        # (T/2);
        clk_tb = 1'b1;
        # (T/2);
    end

    // ISSUE
    always @ (posedge clk_tb)
    begin
        pc_iss      <=  pc_fetch;
        instr_iss   <=  instr_fetch;
    end

    // EXECUTE
    always @ (posedge clk_tb)
    begin
        //$display ("RD is %x\tRS is %x\tRT is %x\n", rd_iss, rs_iss, rt_iss);
        pc_ex           <=  pc_iss;
        instr_ex        <=  instr_iss;
        is_r_type_ex    <=  is_r_type_iss;
        is_i_type_ex    <=  is_i_type_iss;
        is_j_type_ex    <=  is_j_type_iss;
        rs_ex           <=  rs_iss;
        rt_ex           <=  rt_iss;
        rd_ex           <=  rd_iss;
    end

    // MEMORY
    always @ (posedge clk_tb)
    begin
        pc_mem          <=  pc_ex;
        instr_mem       <=  instr_ex;
        is_r_type_mem   <=  is_r_type_ex;
        is_i_type_mem   <=  is_i_type_ex;
        is_j_type_mem   <=  is_j_type_ex;
        rs_mem          <=  rs_ex;
        rt_mem          <=  rt_ex;
        rd_mem          <=  rd_ex;
    end

    // WRITE-BACK
    always @ (posedge clk_tb)
    begin
        pc_wb           <=  pc_mem;
        instr_wb        <=  instr_mem;
        is_r_type_wb    <=  is_r_type_mem;
        is_i_type_wb    <=  is_i_type_mem;
        is_j_type_wb    <=  is_j_type_mem;
        rs_wb           <=  rs_mem;
        rt_wb           <=  rt_mem;
        rd_wb           <=  rd_mem;
    end

    integer i;

    always @ (posedge clk_tb) begin

        $display("NPCValue: %x", T1.NPCValue);
        $display("pc_fetch: %x", pc_fetch);
        $display("instr_fetch: %x", instr_fetch);
        $display("Real instrWireWB: %x", T1.instrWireWB);

        $display("dataStall: %b", T1.dataStall);
        $display("controlStall: %b", T1.controlStall);
        $display("==================================");


        if (instr_retired_wb)
        begin
            $display("dataStall: %b", T1.dataStall);
            $display("controlStall: %b", T1.controlStall);

            $display("pc_fetch: %x", pc_fetch);
            $display("instr_fetch: %x", instr_fetch);

            $display("pc_iss: %x", pc_iss);
            $display("instr_iss: %x", instr_iss);
            $display("is_r_type_iss: %x", is_r_type_iss);
            $display("is_i_type_iss: %x", is_i_type_iss);
            $display("is_j_type_iss: %x", is_j_type_iss);

            $display("pc_ex: %x", pc_ex);
            $display("instr_ex: %x", instr_ex);
            $display("is_r_type_ex: %x", is_r_type_ex);
            $display("is_i_type_ex: %x", is_i_type_ex);
            $display("is_j_type_ex: %x", is_j_type_ex);

            $display("pc_mem: %x", pc_mem);
            $display("instr_mem: %x", instr_mem);
            $display("is_r_type_mem: %x", is_r_type_mem);
            $display("is_i_type_mem: %x", is_i_type_mem);
            $display("is_j_type_mem: %x", is_j_type_mem);

            $display("pc_wb: %x", pc_wb);
            $display("instr_wb: %x", instr_wb);
            $display("is_r_type_iss_wb: %x", is_r_type_wb);
            $display("is_i_type_iss_wb: %x", is_i_type_wb);
            $display("is_j_type_iss_wb: %x", is_j_type_wb);

            run (1);
            if (is_r_type_wb) 
            begin
                $display("Test r type");
                if (!compare_r (pc_wb, instr_wb, rd_wb, rs_wb, rt_wb, rd_val_dest_wb, rs_val_wb, rt_val_wb))
                    $fatal(1, "TEST FAILED\n");
            end
            else if (is_i_type_wb)
            begin
                $display("Test i type");
                if (!compare_i (pc_wb, instr_wb, rs_wb, rt_wb, rs_val_wb, rt_val_dest_wb))
                    $fatal(1, "TEST FAILED\n");
            end
            else if (is_j_type_wb)
            begin
                $display("Test j type");
                if (!compare_j (pc_wb, instr_wb, rt_wb, rt_val_dest_wb))
                    $fatal(1, "TEST FAILED\n");
            end
            else
                $fatal (1, "Incorrect instruction opcode");
        end
    end

    always @ (posedge clk_tb) begin
        if (instr_retired_wb)
        begin
            if ((instr_wb == 'hc) && (T1.u11.regfile[2] == 'ha))
            begin
                $display("TEST PASSED\n");
                $display("End of simulation reached\n");
                $finish;
            end
        end
    end

endmodule
