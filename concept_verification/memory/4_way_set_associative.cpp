#include <systemc>
#include <iostream>
#include <vector>

using namespace std;
using namespace sc_core;
using namespace sc_dt;

SC_MODULE(L1_CACHE){
    sc_in<bool> clk, rst_n, l2_write_finished, w_enable;
    sc_in<sc_bv<512>> l2_in_data;
    sc_in<sc_bv<32>> data_in, location;
    sc_in<int> cache_location, state_in;
    sc_out<int> out_state, next_state;
    sc_out<bool> l2_call, replacement;
    sc_out<sc_bv<32>> l2_fetch_index, l2_fetch, data_out;
    sc_out<sc_bv<512>> dirty_data;
    vector<vector<sc_bv<512>>> first_mem = vector<vector<sc_bv<512>>>(4, vector<sc_bv<512>>(4));
    vector<vector<bool>> valid = vector<vector<bool>>(4, vector<bool>(4, false));
    vector<vector<bool>> dirty = vector<vector<bool>>(4, vector<bool>(4, false));
    vector<vector<uint32_t>> tag = vector<vector<uint32_t>>(4, vector<uint32_t>(4, 0));
    vector<vector<int>> cell_locality = vector<vector<int>>(4, vector<int>(4, 0));
    int victim_idx = 0;

    int row_least_local(int set){
        int highest_loc = -1;
        int index = -1;
        for(int i = 0; i < 4; i++){
            if(cell_locality[set][i] > highest_loc){
                highest_loc = cell_locality[set][i];
                index = i;
            }
        }
        return index;
    }
    int fetch_index(int set, uint32_t tag_num){
        for(int i = 0; i < 4; i++){
            if(tag[set][i] == tag_num){
                return i;
            }
        }
        return -1;
    }
    void update_locality(int recent_index, int set){
        for(int i = 0; i < 4; i++){
            cell_locality[set][i] ++;
        }
        cell_locality[set][recent_index] = 0;
    }
    void process(){
        while(true){
            wait();
            uint32_t addr = location.read().to_uint();
            uint32_t tag_num = addr >> 8;
            int index_num = (addr >> 6) & 0x03;
            int offset = addr & 0x3F;
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
                    int idx_temp = fetch_index(index_num, tag_num);
                    if(idx_temp != -1){
                        if(valid[index_num][idx_temp]){
                            if(w_enable.read()){
                                dirty[index_num][idx_temp] = 1;
                                first_mem[index_num][idx_temp].range(offset * 8 + 31, offset*8) = data_in.read();
                            }else{
                                data_out.write(first_mem[index_num][idx_temp].range(offset*8 + 31, offset*8));
                            }
                            next_state.write(1);
                            l2_fetch.write(0);
                            l2_call.write(0);
                            replacement.write(0);
                            out_state.write(0);
                            update_locality(idx_temp, index_num);
                        }else{
                            victim_idx = idx_temp;
                            l2_fetch.write(1);
                            l2_call.write(1);
                            replacement.write(0);
                            dirty_data.write(0);
                            l2_fetch_index.write(0);
                            next_state.write(0);
                            out_state.write(0);
                        }
                    }else{
                        victim_idx = row_least_local(index_num);
                        l2_fetch.write(1);
                        l2_call.write(1);
                        l2_fetch_index.write((tag[index_num][victim_idx] << 8) | (index_num << 6));
                        replacement.write(dirty[index_num][victim_idx]);
                        dirty_data.write(first_mem[index_num][victim_idx]);
                        next_state.write(0);
                        out_state.write(0);
                    }
                }else if(state_in.read() == 0){
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
                        l2_call.write(1);
                        replacement.write(0);
                        l2_fetch.write(0);
                    }
                }else if(state_in.read() == 2){
                    int idx = victim_idx;
                    tag[index_num][idx] = tag_num;
                    first_mem[index_num][idx] = l2_in_data.read();
                    valid[index_num][idx] = 1;
                    dirty[index_num][idx] = 0;
                    update_locality(idx, index_num);
                    next_state.write(1);
                    out_state.write(1);
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
    sc_in<sc_bv<32>> index_w, data_in_index;
    sc_in<int> state_in;
    sc_out<bool> completed_wb, l3_write_from_l2, l3_search_dirty, l2_acknowledged, l2_finished, data_out_dirty, dirt_acknowledged;
    sc_out<int> next_state;
    sc_out<sc_bv<512>> data_out, data_out_dirty_line;
    sc_out<sc_bv<32>> dataout_index, data_out_dirty_index;

    vector<vector<sc_bv<512>>> l2_mem = vector<vector<sc_bv<512>>>(4, vector<sc_bv<512>>(4));
    vector<vector<uint32_t>> l2_tag = vector<vector<uint32_t>>(4, vector<uint32_t>(4, 0));
    vector<vector<bool>> dirty = vector<vector<bool>>(4, vector<bool>(4, false));
    vector<vector<bool>> valid = vector<vector<bool>>(4, vector<bool>(4, false));
    vector<vector<int>> used_locality = vector<vector<int>>(4, vector<int>(4, 0));
    int victim_idx = 0;

    int row_least_local(int set){
        int highest_loc = -1;
        int index = -1;
        for(int i = 0; i < 4; i++){
            if(!valid[set][i]){
                return i;
            }
            if(used_locality[set][i] > highest_loc){
                highest_loc = used_locality[set][i];
                index = i;
            }
        }
        return index;
    }
    int fetch_index(int set, uint32_t tag_num){
        for(int i = 0; i < 4; i++){
            if(valid[set][i] && l2_tag[set][i] == tag_num){
                return i;
            }
        }
        return -1;
    }
    void update_locality(int recent_index, int set){
        for(int i = 0; i < 4; i++){
            used_locality[set][i] ++;
        }
        used_locality[set][recent_index] = 0;
    }

    void process(){
        while(true){
            wait();
            uint32_t addr_r = data_in_index.read().to_uint();
            uint32_t addr_w = index_w.read().to_uint();
            uint32_t tag_num = addr_r >> 8;
            uint32_t tag_w = addr_w >> 8;
            int idx_num = (addr_r >> 6) & 0x03;
            int idx_w = (addr_w >> 6) & 0x03;
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
                    int idx = fetch_index(idx_w, tag_w);
                    if(idx >= 0){
                        l2_mem[idx_w][idx] = data_w.read();
                        dirty[idx_w][idx] =  1;
                        update_locality(idx, idx_w);
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
                            int idx = fetch_index(idx_num, tag_num);
                            if(idx >= 0){
                                update_locality(idx, idx_num);
                                l3_write_from_l2.write(0);
                                dataout_index.write(data_in_index.read());
                                data_out.write(l2_mem[idx_num][idx]);
                                l2_finished.write(1);
                                l3_search_dirty.write(0);
                                completed_wb.write(0);
                                next_state.write(1);
                                dirt_acknowledged.write(0);
                            }else{
                                victim_idx = row_least_local(idx_num);
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
                    data_out_dirty.write(dirty[idx_num][victim_idx]);
                    data_out_dirty_index.write((l2_tag[idx_num][victim_idx] << 8) | (idx_num << 6));
                    data_out_dirty_line.write(l2_mem[idx_num][victim_idx]);
                    l2_mem[idx_num][victim_idx] = l3_in.read();
                    l2_tag[idx_num][victim_idx] = tag_num;
                    valid[idx_num][victim_idx] = 1;
                    dirty[idx_num][victim_idx] = 0;
                    update_locality(victim_idx, idx_num);
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
    sc_in <sc_bv<32>> index_dirty, index_w;
    sc_out <sc_bv<512>> data_out;
    sc_out <sc_bv<32>> dataout_index;
    sc_out <bool> l3_completed, l3_finished_writing, l3_acknowledged;
    vector<vector<sc_bv<512>>> storage = vector<vector<sc_bv<512>>>(4, vector<sc_bv<512>>(8));
    vector<vector<uint32_t>> tag = vector<vector<uint32_t>>(4, vector<uint32_t>(8, 0));
    vector<vector<bool>> valid = vector<vector<bool>>(4, vector<bool>(8, false));

    int fetch_index(int set, uint32_t tag_num){
        for(int i = 0; i < 8; i++){
            if(valid[set][i] && tag[set][i] == tag_num){
                return i;
            }
        }
        return -1;
    }

    void process(){
        while(true){
            wait();
            uint32_t addr_mem = index_w.read().to_uint();
            uint32_t addr_dirty = index_dirty.read().to_uint();
            uint32_t tag_mem = addr_mem >> 8;
            int idx_mem = (addr_mem >> 6) & 0x03;
            uint32_t tag_dirty = addr_dirty >> 8;
            int idx_dirty = (addr_dirty >> 6) & 0x03;
            if(rst_n.read() == 0){
                dataout_index.write(0);
                l3_completed.write(0);
                l3_finished_writing.write(0);
                l3_acknowledged.write(0);
            }else{
                l3_acknowledged.write(1);
                if(b_dirty.read()){
                    int index = fetch_index(idx_dirty, tag_dirty);
                    if(index != -1){
                        storage[idx_dirty][index] = data_dirty.read();
                    }
                    l3_finished_writing.write(1);
                    l3_completed.write(0);
                }else{
                    int index = fetch_index(idx_mem, tag_mem);
                    if(index != -1){
                        data_out.write(storage[idx_mem][index]);
                        dataout_index.write(index_w.read());
                    }
                    l3_completed.write(1);
                    l3_finished_writing.write(0);
                }
            }
        }
    }

    SC_CTOR(BASE_MEM){
        SC_CTHREAD(process, clk.pos());
    }
};