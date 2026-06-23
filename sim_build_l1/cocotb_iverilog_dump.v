module cocotb_iverilog_dump();
initial begin
    string dumpfile_path;    if ($value$plusargs("dumpfile_path=%s", dumpfile_path)) begin
        $dumpfile(dumpfile_path);
    end else begin
        $dumpfile("C:\\Users\\bob.li\\OneDrive - RamSoft Inc\\Documents\\riscv_modules\\sim_build_l1\\l1_cache.fst");
    end
    $dumpvars(0, l1_cache);
end
endmodule
