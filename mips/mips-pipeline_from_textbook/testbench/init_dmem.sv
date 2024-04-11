// Memory initialisation

function void init_dmem ();
    for (int i = 0; i < 32'h40000; i=i+1)
    begin
        T1.u15.mem_array [i] = 32'hefefefef;
    end

endfunction
