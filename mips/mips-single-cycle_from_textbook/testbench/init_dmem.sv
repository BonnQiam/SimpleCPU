// Memory initialisation

function void init_dmem ();
    for (int i = 0; i < 32'h100000; i=i+1)
    begin
        //T1.D_MEM1.dmem [i] = 32'hefefefef;
        //T1.dmem.mem [i] = 32'hefefefef;
        T1.dmem.mem [i] = 32'b11101111111011111110111111101111;
    end

endfunction
