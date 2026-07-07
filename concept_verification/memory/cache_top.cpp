#include "direct_mapped_cache.cpp"
#include <iostream>
#include <iomanip>
SC_MODULE(TRAFFIC_GEN){
    sc_in<bool> clk;
    sc_out<bool> rst_n, w_enable;
    sc_out<uint32_t> location, data_in;
    sc_in<uint32_t> rdata;
    sc_in<int> l1_state;
    unsigned errors = 0;
    static uint32_t pattern_word(uint32_t a){
        return (a & 0xFF) | (((a+1) & 0xFF) << 8) | (((a+2) & 0xFF) << 16) | (((a+3) & 0xFF) << 24);
    }

    uint32_t access(uint32_t addr, bool we, uint32_t wdata, unsigned &cycles){
        location.write(addr);
        data_in.write(wdata);
        w_enable.write(we);
        cycles = 0;
        wait(); cycles++;
        wait(); cycles++;
        while(l1_state.read() != 1){
            wait(); cycles++;
            if(cycles > 200){
                cout << "DEADLOCK waiting on addr 0x" << hex << addr << dec << endl;
                sc_stop();
                return 0;
            }
        }
        wait(); cycles++;
        return rdata.read();
    }

    void sweep(const char* name, uint32_t base, uint32_t bytes){
        unsigned long total = 0;
        unsigned n = 0, mn = ~0u, mx = 0, c;
        for(uint32_t a = base; a < base + bytes; a += 4){
            uint32_t r = access(a, false, 0, c);
            if(r != pattern_word(a)){
                errors++;
                cout << "  MISMATCH addr 0x" << hex << a << " got 0x" << r
                     << " expected 0x" << pattern_word(a) << dec << endl;
            }
            total += c; n++;
            mn = min(mn, c); mx = max(mx, c);
        }
        cout << left << setw(34) << name << " avg " << fixed << setprecision(2)
             << (double)total / n << " cyc  (min " << mn << ", max " << mx
             << ", n=" << n << ")" << endl;
    }

    void run(){
        rst_n.write(0);
        w_enable.write(0);
        location.write(0);
        data_in.write(0);
        for(int i = 0; i < 3; i++) wait();
        rst_n.write(1);
        for(int i = 0; i < 8; i++) wait();

        unsigned c;

        sweep("512B cold  (L1 miss / L2 hit)",  0, 512);
        sweep("512B warm  (L1 hit)",            0, 512);
        sweep("next 512B  (L1 miss / L2 hit)",  512, 512);
        sweep("upper 1KB  (L1 miss / L2 miss)", 1024, 1024);
        sweep("upper 1KB warm (L1 hit)",        1024, 1024);

        {
            unsigned long total = 0; unsigned n = 0;
            for(int i = 0; i < 32; i++){
                uint32_t a = (i & 1) ? 0x400 : 0x000;
                if(access(a, false, 0, c) != pattern_word(a)) errors++;
                total += c; n++;
            }
            cout << left << setw(34) << "thrash 0x000/0x400 (all miss)" << " avg "
                 << fixed << setprecision(2) << (double)total / n << " cyc  (n=" << n << ")" << endl;
        }

        sweep("refill 512B", 0, 512);
        for(uint32_t a = 0; a < 512; a += 4) access(a, true, ~pattern_word(a), c);
        {
            unsigned bad = 0;
            for(uint32_t a = 0; a < 512; a += 4)
                if(access(a, false, 0, c) != (uint32_t)~pattern_word(a)) bad++;
            cout << left << setw(34) << "write-hit readback" << (bad ? " FAILED, " : " ok, ")
                 << bad << " bad words" << endl;
            errors += bad;
        }

        cout << endl << (errors ? "RESULT: FAIL (" : "RESULT: PASS (") << errors
             << " data errors)" << endl;
        sc_stop();
    }

    SC_CTOR(TRAFFIC_GEN){
        SC_CTHREAD(run, clk.pos());
    }
};

int sc_main(int, char**){
    sc_clock clk("clk", 10, SC_NS);
    sc_signal<bool> rst_n, w_enable;
    sc_signal<uint32_t> addr, wdata, rdata;
    sc_signal<int> l1_state, l2_state;   
    sc_signal<bool> l2_call, replacement, l2_finished;
    sc_signal<vector<uint8_t>> l1_victim_line, l2_data_out;
    sc_signal<bool> l2_evict_dirty, l3_completed;
    sc_signal<uint32_t> l2_mem_addr, l2_evict_addr;
    sc_signal<vector<uint8_t>> mem_data_out, l2_evict_line;
    sc_signal<int> l1_out_state, l1_fetch_index, unused_cache_location;
    sc_signal<bool> l2_completed_wb, l3_write_from_l2, l3_search_dirty, l2_acknowledged, dirt_acknowledged, mem_finished_writing, mem_acknowledged;
    sc_signal<uint32_t> mem_dataout_index;

    L1_CACHE l1("l1");
    l1.clk(clk); l1.rst_n(rst_n);
    l1.location(addr); l1.data_in(wdata); l1.w_enable(w_enable);
    l1.cache_location(unused_cache_location);
    l1.state_in(l1_state); l1.next_state(l1_state);
    l1.out_state(l1_out_state);
    l1.l2_call(l2_call); l1.replacement(replacement);
    l1.dirty_data(l1_victim_line);
    l1.l2_write_finished(l2_finished); l1.l2_in_data(l2_data_out);
    l1.l2_fetch(rdata); l1.l2_fetch_index(l1_fetch_index);

    L2_CACHE l2("l2");
    l2.clk(clk); l2.rst_n(rst_n);
    l2.l2_initiated(l2_call); l2.b_dirty(replacement);
    l2.data_w(l1_victim_line);
    l2.index_w(addr); l2.data_in_index(addr);
    l2.state_in(l2_state); l2.next_state(l2_state);
    l2.data_out(l2_data_out); l2.l2_finished(l2_finished);
    l2.l3_in(mem_data_out); l2.l3_completed(l3_completed);
    l2.dataout_index(l2_mem_addr);
    l2.data_out_dirty(l2_evict_dirty);
    l2.data_out_dirty_line(l2_evict_line);
    l2.data_out_dirty_index(l2_evict_addr);
    l2.completed_wb(l2_completed_wb); l2.l3_write_from_l2(l3_write_from_l2);
    l2.l3_search_dirty(l3_search_dirty); l2.l2_acknowledged(l2_acknowledged);
    l2.dirt_acknowledged(dirt_acknowledged);

    base_mem mem("mem");
    mem.clk(clk); mem.rst_n(rst_n);
    mem.index_w(l2_mem_addr); mem.data_out(mem_data_out);
    mem.b_dirty(l2_evict_dirty); mem.data_dirty(l2_evict_line); mem.index_dirty(l2_evict_addr);
    mem.l3_completed(l3_completed);
    mem.dataout_index(mem_dataout_index);
    mem.l3_finished_writing(mem_finished_writing); mem.l3_acknowledged(mem_acknowledged);

    TRAFFIC_GEN gen("gen");
    gen.clk(clk); gen.rst_n(rst_n); gen.w_enable(w_enable);
    gen.location(addr); gen.data_in(wdata);
    gen.rdata(rdata); gen.l1_state(l1_state);
    for(unsigned line = 0; line < 32; line++)
        for(unsigned b = 0; b < 64; b++)
            mem.storage[line][b] = (uint8_t)(line * 64 + b);
    for(unsigned i = 0; i < 16; i++){
        l2.l2_mem[i] = mem.storage[i];
        l2.valid[i] = 1;
    }

    sc_trace_file* tf = sc_create_vcd_trace_file("cache_top");
    sc_trace(tf, clk, "clk");
    sc_trace(tf, rst_n, "rst_n");
    sc_trace(tf, addr, "addr");
    sc_trace(tf, rdata, "rdata");
    sc_trace(tf, w_enable, "w_enable");
    sc_trace(tf, l1_state, "l1_state");
    sc_trace(tf, l2_state, "l2_state");
    sc_trace(tf, l2_call, "l2_call");
    sc_trace(tf, l2_finished, "l2_finished");
    sc_trace(tf, replacement, "replacement");
    sc_trace(tf, l3_completed, "l3_completed");
    sc_trace(tf, l2_evict_dirty, "l2_evict_dirty");

    sc_start();
    sc_close_vcd_trace_file(tf);
    return 0;
}
