#include <systemc.h>
#include <bitset>
#include <cstdint>
#include <vector>

using namespace std;

SC_MODULE(L1_CACHE){
    sc_in<bool> clk;
    sc_in<bool> rst_n;
    sc_in<bool> l2_write_finished;
    sc_in<bool> w_enable;
    sc_in<sc_bv<512>> l2_in_data;
    sc_in<uint32_t> data_in;
    sc_in<uint32_t> location;
    sc_in<int> cache_location, state_in;
    sc_out<int> out_state, next_state;
    sc_out<bool> l2_call, replacement;
    sc_out<uint32_t> l2_fetch_index;
    sc_out <uint32_t> l2_fetch, data_out;
    sc_out <sc_bv<512>> dirty_data;
    vector<sc_bv<512>> first_mem = vector<sc_bv<512>>(16);
    vector<sc_bv<26>> tag = vector<sc_bv<26>>(16);
    vector <bool> dirty = vector <bool> (16, 0);
    vector <bool> valid = vector <bool> (16, 0);
    vector<int> used_locality = vector <int> (16, 0);

    

    int victim_idx = 0;
    void process(){
        while(true){
            wait();
            unsigned int offset = location.read() & 0x3F;
            sc_bv<26> tag_num = location.read() >> 6;

            if(!rst_n.read()){
                out_state.write(1);
                l2_call.write(0);
                replacement.write(0);
                dirty_data.write(0);
                l2_fetch.write(0);
                l2_fetch_index.write(0);
                next_state.write(1);
            }else{
                if(state_in.read() == 1){
                    bool found = false;
                    int idx_counter = 0;
                    for(auto const &n : tag){
                        if(tag_num == n){
                            found = true;
                            break;
                        }
                        else{
                            idx_counter ++;
                        }
                    }
                    if(found){
                        if(valid[idx_counter]){
                            if(w_enable){
                                dirty[idx_counter] = 1;
                                first_mem[idx_counter].range(offset*8 + 31, offset*8) = data_in.read();
                            }else{
                                data_out.write(first_mem[idx_counter].range(offset*8 + 31, offset*8).to_uint());
                            }
                            next_state.write(1);
                            l2_fetch.write(0);
                            l2_call.write(0);
                            replacement.write(0);
                            out_state.write(0);
                            used_locality[idx_counter] = 0;
                            for(int i = 0; i < 16; i ++){
                                if(i != idx_counter){
                                    used_locality[i] = used_locality[i] + 1;
                                }
                            }
                        }else{
                            // tag matched a never-filled way; refill must target this same slot
                            victim_idx = idx_counter;
                            l2_fetch.write(1);
                            l2_call.write(1);
                            replacement.write(0);
                            dirty_data.write(0);
                            l2_fetch_index.write(0);
                            next_state.write(0);
                            out_state.write(0);
                        }
                    }else{
                        l2_fetch.write(1);
                        l2_call.write(1);
                        replacement.write(1);
                        int max_locality = 0, max_idx = 0;
                        for(int i = 0; i < 16; i++){
                            if(used_locality[i] > max_locality){
                                max_locality = used_locality[i];
                                max_idx = i;
                            }
                        }
                        victim_idx = max_idx;
                        l2_fetch_index.write(tag[max_idx].to_uint() << 6);
                        replacement.write(dirty[max_idx]);
                        l2_fetch.write(1);
                        l2_call.write(1);
                        if(dirty[max_idx]){
                            dirty_data.write(first_mem[max_idx]);
                        }else{
                            dirty_data.write(0);
                        }
                        next_state.write(0);
                        out_state.write(0);
                    }
                }
                else if(state_in.read() == 0){
                    if(l2_write_finished.read()){
                        next_state.write(2);
                        out_state.write(2);
                        l2_call.write(0);
                        replacement.write(0);
                        dirty_data.write(0);
                        l2_fetch.write(0);
                    }else{
                        next_state.write(0);
                        out_state.write(0);
                        // hold the request: after an L3 refill, L2 re-enters its lookup
                        // state and must still see l2_initiated to serve this miss
                        l2_call.write(1);
                        replacement.write(0);
                        l2_fetch.write(0);
                    }
                }
                else if(state_in.read() == 2){
                    int idx = victim_idx;
                    tag[idx] = tag_num;
                    first_mem[idx] = l2_in_data.read();
                    used_locality[idx] = 0;
                    for(int i = 0; i < 16; i++){
                        if(i != idx){
                            used_locality[i] ++;
                        }
                    }
                    next_state.write(1);
                    out_state.write(1);
                    valid[idx] = 1;
                    dirty[idx] = 0;
                }
            }
        }
    }
    SC_CTOR(L1_CACHE){
        SC_CTHREAD(process, clk.pos());
    }
};

SC_MODULE(L2_CACHE){
    sc_in<bool> clk, rst_n, l2_initiated, b_dirty, l3_completed;
    sc_in<sc_bv<512>> data_w, l3_in;
    sc_in<uint32_t> index_w, data_in_index;
    sc_in<int> state_in;
    sc_out<bool> completed_wb, l3_write_from_l2, l3_search_dirty, l2_acknowledged, l2_finished, data_out_dirty, dirt_acknowledged;
    sc_out<int> next_state;
    sc_out<sc_bv<512>> data_out, data_out_dirty_line;
    sc_out<uint32_t> dataout_index, data_out_dirty_index;

    vector<sc_bv<512>> l2_mem = vector<sc_bv<512>>(16);
    vector<uint32_t> l2_tag = vector<uint32_t>(16, 0);
    vector<bool> dirty = vector<bool>(16, 0);
    vector<bool> valid = vector<bool>(16, 0);
    vector<int> used_locality = vector<int>(16, 0);
    int victim_idx = 0;

    int find_way(uint32_t tag_num){
        for(int i = 0; i < 16; i++){
            if(valid[i] && l2_tag[i] == tag_num) return i;
        }
        return -1;
    }
    void touch(int idx){
        used_locality[idx] = 0;
        for(int i = 0; i < 16; i++){
            if(i != idx) used_locality[i]++;
        }
    }

    void process(){
        while(true){
            wait();
            uint32_t tag_num = data_in_index.read() >> 6;
            uint32_t tag_w = index_w.read() >> 6;
            if(!rst_n.read()){
                data_out.write(0);
                completed_wb.write(0);
                next_state.write(0);
                l3_write_from_l2.write(0);
                l3_search_dirty.write(0);
                dataout_index.write(0);
                l2_acknowledged.write(0);
                l2_finished.write(0);
                dirt_acknowledged.write(0);
            }else{
                if(state_in.read() == 3){
                    int idx = find_way(tag_w);
                    if(idx >= 0){
                        l2_mem[idx] = data_w.read();
                        dirty[idx] = 1;
                        touch(idx);
                        l2_acknowledged.write(0);
                        l2_finished.write(0);
                        next_state.write(1);
                        dirt_acknowledged.write(1);
                    }else{
                        data_out_dirty.write(1);
                        data_out_dirty_line.write(data_w.read());
                        data_out_dirty_index.write(index_w.read());
                        completed_wb.write(0);
                        l3_write_from_l2.write(0);
                        l2_acknowledged.write(0);
                        l2_finished.write(0);
                        dirt_acknowledged.write(1);
                        next_state.write(1);
                    }
                }
                else if(state_in.read() == 1){
                    if(l2_initiated.read() == 0){
                        next_state.write(1);
                        l2_finished.write(0);
                    }else{
                        if(b_dirty.read()){
                            next_state.write(3);
                        }else{
                            l2_acknowledged.write(1);
                            int idx = find_way(tag_num);
                            if(idx >= 0){
                                touch(idx);
                                l3_write_from_l2.write(0);
                                dataout_index.write(data_in_index.read());
                                data_out.write(l2_mem[idx]);
                                l2_finished.write(1);
                                l3_search_dirty.write(0);
                                completed_wb.write(0);
                                next_state.write(1);
                                dirt_acknowledged.write(0);
                            }else{
                                int max_idx = 0;
                                for(int i = 0; i < 16; i++){
                                    if(!valid[i]){ max_idx = i; break; }
                                    if(used_locality[i] > used_locality[max_idx]) max_idx = i;
                                }
                                victim_idx = max_idx;
                                l3_write_from_l2.write(1);
                                dataout_index.write(data_in_index.read());
                                completed_wb.write(0);
                                l3_search_dirty.write(0);
                                l2_finished.write(0);
                                next_state.write(0);
                                data_out_dirty.write(0);
                            }
                        }
                    }
                }
                else if(state_in.read() == 0){
                    if(l3_completed.read()){
                        next_state.write(2);
                    }else{
                        next_state.write(0);
                    }
                }
                else if(state_in.read() == 2){
                    data_out_dirty.write(dirty[victim_idx]);
                    data_out_dirty_index.write(l2_tag[victim_idx] << 6);
                    data_out_dirty_line.write(l2_mem[victim_idx]);
                    l2_mem[victim_idx] = l3_in.read();
                    l2_tag[victim_idx] = tag_num;
                    valid[victim_idx] = 1;
                    dirty[victim_idx] = 0;
                    touch(victim_idx);
                    next_state.write(1);
                }
            }
        }
    }

    SC_CTOR(L2_CACHE){
        SC_CTHREAD(process, clk.pos());
    }
};


SC_MODULE(BASE_MEM){
    sc_in <bool> clk, rst_n, b_dirty;
    sc_in <sc_bv<512>> data_dirty;
    sc_in <uint32_t> index_dirty, index_w;
    sc_out <sc_bv<512>> data_out;
    sc_out <uint32_t> dataout_index;
    sc_out <bool> l3_completed, l3_finished_writing, l3_acknowledged;
    vector<sc_bv<512>> storage = vector<sc_bv<512>>(32);
    vector<sc_bv<26>> tag = vector<sc_bv<26>>(32);

    int find(sc_bv<26> tag_value){
        for(int i = 0; i < 32; i++){
            if(tag_value == tag[i]){
                return i;
            }
        }
        return -1;
    }

    void process(){
        while(true){
            wait();
            sc_bv<26> tag_mem = index_w.read() >> 6;
            sc_bv<26> tag_dirty = index_dirty.read() >> 6;
            if(rst_n.read() == 0){
                dataout_index.write(0);
                l3_completed.write(0);
                l3_finished_writing.write(0);
                l3_acknowledged.write(0);
            }else{
                l3_acknowledged.write(1);
                if(b_dirty.read()){
                    int index = find(tag_dirty);
                    if(index != -1){
                        storage[index] = data_dirty.read();
                    }
                    l3_finished_writing.write(1);
                    l3_completed.write(0);
                }else{
                    int index = find(tag_mem);
                    if(index != -1){
                        data_out.write(storage[index]);
                        dataout_index.write(index_w.read());
                    }
                    l3_completed.write(1);
                    l3_finished_writing.write(0);
                }
            }
        }
    }

    SC_CTOR(BASE_MEM){
        //quick fill for testing purpose only
        for(int i = 0; i < 32; i++){
            tag[i] = i;
        }
        SC_CTHREAD(process, clk.pos());
    }
};