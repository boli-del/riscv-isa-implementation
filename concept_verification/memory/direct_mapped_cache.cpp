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
    sc_in<bool> l2_write_finished
    sc_in<bool> w_enable
    sc_in<uint32_t> 
    sc_in<vector<int>> location;
    sc_in<int> cache_location, next_state, l2_write_finished;
    sc_out <int> out_state, l2_call, replacement, dirty_data, l2_fetch, l2_fetch_index;
    sc_out <uint32_t> l2_fetch;
    vector<vector<>> first_mem (16, vector<uint8_t> (64), 0);
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
                if(w_enable)
                if(next_state.read() == 1){
                    if(tag[index] == tag_num){
                        
                    }
                }
            }
       }
    }

    SC_Cache(L1_CACHE){
        SC_CTHREAD(process, clk.pos());
    }
}