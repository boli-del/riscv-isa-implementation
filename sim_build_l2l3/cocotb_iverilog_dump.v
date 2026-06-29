module cocotb_iverilog_dump();
initial begin
    string dumpfile_path;    if ($value$plusargs("dumpfile_path=%s", dumpfile_path)) begin
        $dumpfile(dumpfile_path);
    end else begin
        $dumpfile("C:\\Users\\bob.li\\OneDrive - RamSoft Inc\\Documents\\riscv_modules\\sim_build_l2l3\\l2_l3_top.fst");
    end
    $dumpvars(0, l2_l3_top);
end
endmodule
