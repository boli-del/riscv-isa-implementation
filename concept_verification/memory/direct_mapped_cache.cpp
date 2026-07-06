#include <systemc>
#include <vector>
#include <bitset>
#include <stdint>
#include <cassert>

using namespace std;

//verifying the caches under the same size for now
SC_MODULE(L1_CACHE) {
    sc_in<bool> clk;
    sc_in<bool> rst_n;
    sc_in<bool> l2_write_finished;
    sc_in<bool> w_enable;
    sc_in<vector<uint8_t>> l2_in_data;
    sc_in<uint32_t> data_in;
    sc_in<uint32_t> location;
    sc_in<int> cache_location, next_state, l2_write_finished;
    sc_out <int> out_state, l2_call, replacement, l2_fetch, l2_fetch_index;
    sc_out <uint32_t> l2_fetch;
    sc_out <vector<uint8_t>> dirty_data
    vector<vector<uint8_t>> first_mem (16, vector<uint8_t> (64, 0));
    vector<uint32_t> tag (16, 0);
    vector<bool> dirty (16, 0);
    vector<bool> valid (16, 0);
    void process(){
       while(true){
            wait()
            unsigned int index_num = (location.read() >> 6) & 0xF;
            unsigned int tag_num = location.read() >> 10;
            unsigned int offset = location.read() & 0x3F;
            if(rst_n.read()){
                out_state.write(1);
                l2_call.write(0);
                replacement.write(0);
                dirty_data.write(0);
                l2_fetch.write(0);
                l2_fetch_index.write(0);
            }else{
                //valid bit
                if(next_state.read() == 1){
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
                            dirty_data.write(0);
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
                        dirty_data.write(0);
                        l2_fetch.write(1);
                    }
                }
                //state for holding and waiting
                else if(next_state.read() == 2){
                    if(l2_write_finished.read()){
                        next_state.write(1);
                    }else{
                        out_state.write(2);
                        l2_call.write(0);
                    }
                }
            }
       }
    }

    SC_Cache(L1_CACHE){
        SC_CTHREAD(process, clk.pos());
    }
}

SC_MODULE(L2_CACHE){
    sc_in<bool> clk, rst_n, l2_initiated, b_dirty, l3_completed, l3_in;
    sc_in<vector<uint8_t>> data_w;
    sc_in<uint32_t> index_w, data_in_index;
    sc_in<int> state_in;
    sc_out<bool> completed_wb, l3_write_from_l2, l3_search_dirty, l2_acknowledged, l2_finished, data_out_dirty, dirt_acknowledged
    sc_out<int> next_state;
    sc_out<vector<uint8_t>> data_out, data_out_dirty_line;
    sc_out <uint32_t> dataout_index, data_out_dirty_index;

    vector<vector<uint8_t>> l2_mem(16, vector<uint8_t>(64, 0));
    vector<uint32_t> l2_tag(16, 0);
    vector<bool> dirty(16, 0);
    
    
    void process(){
        while(true){
            wait();
            unsigned int idx_w = (index_w >> 6) & 0x0F;
            unsigned int idx = (data_in_index >> 6) & 0x0F;
            unsigned int tag_w = index_w >> 10;
            unsigned int tag = data_in_index >> 10;
            if(rst_n.read() == 0){
                data_out.write(nullptr);
                completed_wb.write(0);
                next_state.write(0);
                l3_write_from_l2.write(0);
                l3_search_dirty.write(0);
                dataout_index.write(0);
                l2_acknowledged.write(0);
                l2_finished.write(0);
                dirt_acknowledged.write(0);
            }else{
                if(state_in.read == 3){
                    if(l2_tag[idx_w] == tag_w){
                        l2_mem[idx_w] = data_w;
                        dirty[idx_w] = 1;
                        l2_acknowledged.write(0);
                        l2_finished.write(0);
                        next_state.write(1);
                        dirt_acknowledged.write(1);
                    }
                    else{
                        l3_search_dirty.write(1);
                        data_out.write(data_w);
                        dataout_index.write(index_w);
                        completed_wb.write(0);
                        l3_write_from_l2.write(0);
                        l2_acknowledged.write(0);
                        l2_finished.write(0);
                        dirt_acknowledged.write(1);
                        next_state.write(0);
                    }
                }
                else if(state_in.read == 1){
                    if(l2_initiated.read() == 0){
                        next_state.write(1);
                    }
                    else{
                        if(b_dirty.read()){
                            next_state.write(3);
                        }
                        else if(l2_initiated.read()){
                            l2_acknowledged.write(1);
                            if(l2_tag[idx] == tag_in){
                                l3_write_from_l2.write(0);
                                dataout_index.write(data_in_index.read());
                                data_out.write(l2_mem[idx]);
                                l2_finished.write(1);
                                l3_search_dirty.write(0);
                                completed_wb.write(0);
                                next_stage.write(1);
                                dirt_acknowledged.write(0);
                            }
                            else{
                                l3_write_from_l2.write(1);
                                dataout_index.write(data_in_index.read());
                                data_out.write(l2_mem[idx])
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
                    data_out_dirty_indexw
                }
            }
        }
    }

    SC_L2CACHE(L2_CACHE){
        SC_CTHREAD(process, clk.pos());
    }
}

SC_MODUlE(base_mem){
    sc_in <bool> clk, rst_n, b_dirty;
    sc_in <vector<uint32_t>> data_dirty;
    sc_in <vector<uint32_t>> index_dirty, index_w;

    vector<vector<uint32_t>> storage ()

    void process(){
        while(true){
            int
        }
    }
}