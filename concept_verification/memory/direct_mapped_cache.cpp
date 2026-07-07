#include <systemc.h>
#include <vector>
#include <bitset>
#include <cstdint>
#include <cassert>

using namespace std;

// sc_signal<T> needs operator<< for its print/dump hooks
namespace std {
    inline ostream& operator<<(ostream& os, const vector<uint8_t>& v){
        for(size_t i = 0; i < v.size(); i++) os << (unsigned)v[i] << ' ';
        return os;
    }
}

// sc_out<T> needs an sc_trace overload for the port type; vector lines aren't
// traceable to VCD, so this is a no-op
namespace sc_core {
    inline void sc_trace(sc_trace_file*, const std::vector<uint8_t>&, const std::string&){}
}

//verifying the caches under the same size for now
SC_MODULE(L1_CACHE) {
    sc_in<bool> clk;
    sc_in<bool> rst_n;
    sc_in<bool> l2_write_finished;
    sc_in<bool> w_enable;
    sc_in<vector<uint8_t>> l2_in_data;
    sc_in<uint32_t> data_in;
    sc_in<uint32_t> location;
    sc_in<int> cache_location, state_in;
    sc_out <int> out_state, l2_fetch_index, next_state;
    sc_out <bool> l2_call, replacement;
    sc_out <uint32_t> l2_fetch;
    sc_out <vector<uint8_t>> dirty_data;
    vector<vector<uint8_t>> first_mem = vector<vector<uint8_t>>(16, vector<uint8_t>(64, 0));
    vector<uint32_t> tag = vector<uint32_t>(16, 0);
    vector<bool> dirty = vector<bool>(16, 0);
    vector<bool> valid = vector<bool>(16, 0);
    void process(){
       while(true){
            wait();
            unsigned int index_num = (location.read() >> 6) & 0xF;
            unsigned int tag_num = location.read() >> 10;
            unsigned int offset = location.read() & 0x3F;
            if(!rst_n.read()){
                out_state.write(1);
                l2_call.write(0);
                replacement.write(0);
                dirty_data.write(vector<uint8_t>(64, 0));
                l2_fetch.write(0);
                l2_fetch_index.write(0);
                next_state.write(1);
            }else{
                //valid bit
                if(state_in.read() == 1){
                    if(valid[index_num]){
                        if(tag_num == tag[index_num]){
                            if(w_enable){
                                uint32_t a = data_in.read();
                                for(int i = 0; i < 4; i++){
                                    first_mem[index_num][offset + i] = (a >> (8 * i)) & 0xFF;
                                }
                                dirty[index_num] = 1;
                                l2_fetch.write(0);
                            }else{
                                l2_fetch.write(first_mem[index_num][offset] + (first_mem[index_num][offset+1] << 8) + (first_mem[index_num][offset+2] << 16) + (first_mem[index_num][offset+3] << 24));
                            }
                            l2_call.write(0);
                            replacement.write(0);
                            dirty_data.write(vector<uint8_t>(64, 0));
                            out_state.write(0);
                        }else{
                            next_state.write(2);
                            l2_call.write(1);
                            replacement.write(dirty[index_num]);
                            dirty_data.write(first_mem[index_num]);
                        }
                    }else{
                        next_state.write(2);
                        l2_call.write(1);
                        replacement.write(0);
                        dirty_data.write(vector<uint8_t>(64, 0));
                        l2_fetch.write(1);
                    }
                }
                //state for holding and waiting
                else if(state_in.read() == 2){
                    if(l2_write_finished.read()){
                        first_mem[index_num] = l2_in_data.read();
                        tag[index_num] = tag_num;
                        valid[index_num] = 1;
                        dirty[index_num] = 0;
                        next_state.write(1);
                    }else{
                        out_state.write(2);
                        l2_call.write(1);
                        replacement.write(0);
                    }
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
    sc_in<vector<uint8_t>> data_w, l3_in;
    sc_in<uint32_t> index_w, data_in_index;
    sc_in<int> state_in;
    sc_out<bool> completed_wb, l3_write_from_l2, l3_search_dirty, l2_acknowledged, l2_finished, data_out_dirty, dirt_acknowledged;
    sc_out<int> next_state;
    sc_out<vector<uint8_t>> data_out, data_out_dirty_line;
    sc_out <uint32_t> dataout_index, data_out_dirty_index;

    vector<vector<uint8_t>> l2_mem = vector<vector<uint8_t>>(16, vector<uint8_t>(64, 0));
    vector<uint32_t> l2_tag = vector<uint32_t>(16, 0);
    vector<bool> dirty = vector<bool>(16, 0);
    vector<bool> valid = vector<bool>(16, 0);
    
    
    void process(){
        while(true){
            wait();
            unsigned int idx_w = (index_w.read() >> 6) & 0x0F;
            unsigned int idx = (data_in_index.read() >> 6) & 0x0F;
            unsigned int tag_w = index_w.read() >> 10;
            unsigned int tag = data_in_index.read() >> 10;
            if(rst_n.read() == 0){
                data_out.write(vector<uint8_t>(64, 0));
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
                    if(valid[idx_w] && l2_tag[idx_w] == tag_w){
                        l2_mem[idx_w] = data_w.read();
                        dirty[idx_w] = 1;
                        l2_acknowledged.write(0);
                        l2_finished.write(0);
                        next_state.write(1);
                        dirt_acknowledged.write(1);
                    }
                    else{
                        l3_search_dirty.write(1);
                        data_out.write(data_w.read());
                        dataout_index.write(index_w.read());
                        completed_wb.write(0);
                        l3_write_from_l2.write(0);
                        l2_acknowledged.write(0);
                        l2_finished.write(0);
                        dirt_acknowledged.write(1);
                        next_state.write(0);
                    }
                }
                else if(state_in.read() == 1){
                    if(l2_initiated.read() == 0){
                        next_state.write(1);
                        l2_finished.write(0);
                    }
                    else{
                        if(b_dirty.read()){
                            next_state.write(3);
                        }
                        else if(l2_initiated.read()){
                            l2_acknowledged.write(1);
                            if(valid[idx] && l2_tag[idx] == tag){
                                l3_write_from_l2.write(0);
                                dataout_index.write(data_in_index.read());
                                data_out.write(l2_mem[idx]);
                                l2_finished.write(1);
                                l3_search_dirty.write(0);
                                completed_wb.write(0);
                                next_state.write(1);
                                dirt_acknowledged.write(0);
                            }
                            else{
                                l3_write_from_l2.write(1);
                                dataout_index.write(data_in_index.read());
                                data_out.write(l2_mem[idx]);
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
                    }
                    else{
                        next_state.write(0);
                    }
                }
                else if(state_in.read() == 2){
                    next_state.write(1);
                    data_out_dirty.write(dirty[idx]);
                    data_out_dirty_index.write((l2_tag[idx] << 10) | (idx << 6));
                    data_out_dirty_line.write(l2_mem[idx]);
                    l2_mem[idx] = l3_in.read();
                    l2_tag[idx] = tag;
                    valid[idx] = 1;
                    dirty[idx] = 0;
                }
            }
        }
    }

    SC_CTOR(L2_CACHE){
        SC_CTHREAD(process, clk.pos());
    }
};

SC_MODULE(base_mem){
    sc_in <bool> clk, rst_n, b_dirty;
    sc_in <vector<uint8_t>> data_dirty;
    sc_in <uint32_t> index_dirty, index_w;
    sc_out <vector<uint8_t>> data_out;
    sc_out <uint32_t> dataout_index;
    sc_out <bool> l3_completed, l3_finished_writing, l3_acknowledged;
    vector<vector<uint8_t>> storage = vector<vector<uint8_t>>(32, vector<uint8_t>(64, 0));
    void process(){
        while(true){
            wait();
            unsigned int mem_idx = (index_w.read() >> 6) & 0x1F;
            unsigned int mem_dirty = (index_dirty.read() >> 6) & 0x1F;
            if(rst_n.read() == 0){
                dataout_index.write(0);
                l3_completed.write(0);
                l3_finished_writing.write(0);
                l3_acknowledged.write(0);
            }else{
                l3_acknowledged.write(1);
                if(b_dirty.read()){
                    storage[mem_dirty] = data_dirty.read();
                    l3_finished_writing.write(1);
                    l3_completed.write(0);
                }else{
                    data_out.write(storage[mem_idx]);
                    dataout_index.write(index_w.read());
                    l3_completed.write(1);
                    l3_finished_writing.write(0);
                }
            }
        }
    }

    SC_CTOR(base_mem){
        SC_CTHREAD(process, clk.pos());
    }
};

