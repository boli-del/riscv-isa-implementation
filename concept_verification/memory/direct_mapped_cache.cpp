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
    vector<vector<uint8_t>> first_mem (16, vector<uint8_t> (64), 0);
    vector<uint32_t> tag (16, 0);
    vector<bool> dirty (16, 0);
    vector<bool> valid (16, 0);
    void process(){
       while(true){
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

    vector<vector<uint32_t>> l2_mem(65536, vector<uint8_t>(64, 0));
    vector<uint32_t> l2_tag(65536, 0);
    vector<bool> dirty(65536, 0);
    int idx_w = index_w[6:10];
    int tag_w = index_2[10:];
    
    
    void process(){
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
            if(next_state.read == 3){
                if(l2_tag[idx_w])
            }
        }
    }
}