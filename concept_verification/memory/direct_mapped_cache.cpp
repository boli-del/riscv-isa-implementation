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
            unsigned int index_num = bitset<32>(location)[6:8];
            unsigned int tag_num = bitset<32>(location)[8:];
            unsigned int offset = bitset<32>(location)[0:6];
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
                                int counter = 0;
                                for(uint32_t a = data_in.read(); a > 0; a >>= 8){
                                    first_mem[offset + counter] = a[0:7];
                                    counter ++;
                                }
                                first_mem[index_num] = i;
                                
                            }else{
                                l2_fetch.write(first_mem[offset] + (first_mem[offset+1] << 8) + (first_mem[offset+2] << 16) + (first_mem[offset+3] << 24));
                            }
                            dirty[index_num] = 1;
                            l2_call.write(0);
                            replacement.write(0);
                            dirty_data.write(0);
                            l2_fetch.write(0);
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