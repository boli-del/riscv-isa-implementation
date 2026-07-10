#include <systemc>
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
    sc_out<int> out_state, l2_call, replacement, l2_fetch_index, next_state;
    sc_out <uint32_t> l2_fetch, data_out;
    sc_out <sc_bv<512>> dirty_data;
    vector<sc_bv<512>> = vector<sc_bv<512>> first_mem(16);
    vector<sc_bv<26>> tag(16);
    vector <bool> dirty = vector <bool> (16, 0);
    vector <bool> valid = vector <bool> (16, 0);
    vector<int> used_locality = vector <int> (16, 0);
    // Victim way chosen on a state-1 miss, latched so the state-2 refill writes the same
    // slot instead of re-deriving it from locality counters that may have shifted.
    int victim_idx = 0;
    void process(){
        while(true){
            wait();
            sc_bv<6> offset = location.read() & 0x3F;
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
                                first_mem[idx_counter].range(((offset)*8) + 31, offset*8) = data_in;
                            }else{
                                data_out.write(first_mem[idx_counter].range(((offset)*8) + 31, offset*8));
                            }
                            next_state.write(0);
                            l2_fetch.write(0);
                            l2_call.write(0);
                            replacement.write(0);
                            out_state.write(0);
                            used_locality[idx] = 0;
                            for(int i = 0; i < 16; i ++){
                                if(i != idx){
                                    used_locality[i] = used_locality[i] + 1;
                                }
                            }
                        }else{
                            l2_fetch.write(1);
                            l2_call.write(1);
                            replacement.write(0);
                            dirty_data.write(0);
                            l2_fetch_index.write(data_in);
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
                                //max of the locality determination
                                max_locality = used_locality[i];
                                //maximum of the index of the locality determination
                                max_idx = i;
                            }
                        }
                        victim_idx = max_idx;
                        l2_fetch_index.write(tag[max_idx] << 6);
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
                        l2_call.write(0);
                        replacement.write(0);
                        dirty_data.write(0);
                        l2_fetch.write(0);
                    }
                }
                else if(state_in.read() == 2){
                    int idx = victim_idx;
                    tag[idx] = tag_num;
                    first_mem[idx] = l2_in_data;
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
}