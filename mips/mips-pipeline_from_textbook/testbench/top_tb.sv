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
    assign instr_fetch       = T1.instrWire;

    // ISSUE
    // signals tapped from the ISS stage
    assign is_r_type_wb = T1.is_r_type_WB;
    assign is_i_type_wb = T1.is_i_type_WB;
    assign is_j_type_wb = T1.is_j_type_WB;

    assign rs_wb            = T1.instrWireWB[`rs];
    assign rt_wb            = T1.instrWireWB[`rt];
    assign rd_wb            = T1.instrWireWB[`rd];

    // WRITE-BACK
    // signals tapped from the WB stage
    assign rt_val_dest_wb    = T1.RegWriteWB ? T1.WBData : rt_val_wb;
    assign rd_val_dest_wb    = T1.RegWriteWB ? T1.WBData : rd_val_wb;

    assign instr_retired_wb  = (T1.instr_retired & (T1.instrWireWB != 32'b0) & (T1.instrWireMEM != T1.instrWireWB)) | (T1.instrWireWB == 'hc);

    assign pc_fetch          = T1.PC;

    /*
    assign instr_retired_wb  = (pc_wb == 32'b0) ? ( (T1.instrWireWB != T1.instrWireMEM) & (T1.instrWireWB != 32'b0)) : 
        (
            (T1.dataStall & T1.controlStall) ? T1.instr_retired :( (T1.valid_MEM == 0) & T1.instr_retired)
        );
    */
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

    always @ (posedge clk_tb) begin
        $display("NPC_branch_j: %x", T1.NPCValue);
        $display("NPC_increment_4: %x", T1.nextPC);

        $display("pc_fetch: %x", pc_fetch);
        $display("instr_fetch: %x", instr_fetch);
        

        $display("dataStall: %b", T1.dataStall);
        $display("controlStall: %b", T1.controlStall);

        $display("instrWire: %x", T1.instrWire);
        $display("instrWireID: %x", T1.instrWireID);
        $display("instrWireEX: %x", T1.instrWireEX);
        $display("instrWireMEM: %x", T1.instrWireMEM);
        $display("instrWireWB: %x", T1.instrWireWB);

        $display("pc_IF: %x", T1.PC);
        $display("pc_ID: %x", T1.PC_ID);
        $display("pc_EX: %x", T1.PC_EX);
        $display("pc_MEM: %x", T1.PC_MEM);
        $display("pc_WB: %x", T1.PC_WB);
        
        $display("==================================");

        if (instr_retired_wb & (is_r_type_wb || is_i_type_wb || is_j_type_wb))
        begin
            $display("is_r_type_wb: %b", is_r_type_wb);
            $display("is_i_type_wb: %b", is_i_type_wb);
            $display("is_j_type_wb: %b", is_j_type_wb);

            run (1);
            if (is_r_type_wb) 
            begin
                $display("Test r type");

                if (!compare_r (T1.PC_WB, T1.instrWireWB, rd_wb, rs_wb, rt_wb, rd_val_dest_wb, rs_val_wb, rt_val_wb))
                //if (!compare_r (pc_wb, instr_wb, rd_wb, rs_wb, rt_wb, rd_val_dest_wb, rs_val_wb, rt_val_wb))
                    $fatal(1, "TEST FAILED\n");
            end
            else if (is_i_type_wb)
            begin
                $display("Test i type");
                if (!compare_i (T1.PC_WB, T1.instrWireWB, rs_wb, rt_wb, rs_val_wb, rt_val_dest_wb))
                //if (!compare_i (pc_wb, instr_wb, rs_wb, rt_wb, rs_val_wb, rt_val_dest_wb))
                    $fatal(1, "TEST FAILED\n");
            end
            else if (is_j_type_wb)
            begin
                $display("Test j type");
                if (!compare_j (T1.PC_WB, T1.instrWireWB, rt_wb, rt_val_dest_wb))
                //if (!compare_j (pc_wb, instr_wb, rt_wb, rt_val_dest_wb))
                    $fatal(1, "TEST FAILED\n");
            end
            else
                $fatal (1, "Incorrect instruction opcode");
        end
    end

    always @ (posedge clk_tb) begin
        if (instr_retired_wb)
        begin
            if ((T1.instrWireWB == 'hc) && (T1.u11.regfile[2] == 'ha))
            //if (T1.instrWireWB == 'hc)
            begin
                $display("TEST PASSED\n");
                $display("End of simulation reached\n");
                $finish;
            end
        end
    end

endmodule
