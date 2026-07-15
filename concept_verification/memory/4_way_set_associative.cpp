#include <systemc>
#include <iostream>
#include <vector>

using namespace std;

SC_MODULE(l1_mem){
    sc_in<bool> clk, rst_n, l2_write_finished, w_enable;
    sc_in<sc_bv<512>> l2_in_data;
    sc_in<sc_bv<32>> data_in, location;
    sc_in<int> cache_location, state_in;
    sc_out<int> out_state, next_state;
    sc_out<bool> l2_call, replacement;
    sc_out<sc_bv<32>> l2_fetch_index, l2_fetch, data_out;
    sc_out<sc_bv<512>> dirty_data;
    vector<vector<sc_bv<512>>> first_mem(4, vector<sc_bv<512>>(4, 0))
    vector<vector<bool>> valid (4, vector<bool>(4, 0));
    vector<vector<sc_bv<24>>> tag (4, 0);
    vector<vector<int>> cell_locality(4, vector<int>(4, 0));

    int row_least_local(sc_bv<2> index_num){
        int highest_loc = -1;
        int index = -1;
        int set = index_num.to_uint();
        for(int i = 0; i < 4; i++){
            if(cell_locality[set][i] > highest_loc){
                index = i;
            }
        }
        return index;
    }
    int fetch_index(sc_bv<2> index, sc_bv<24> tag_num){
        int idx = index.to_uint();
        for(int i = 0; i < 4; i++){
            if(tag[idx][i] == tag_num){
                return i;
            }
        }
        return -1;
    }
    void update_locality(int recent_index, sc_bv<2> index){
        int temp = index.to_uint();
        for(int i = 0; i < 4; i++){
            cell_locality[temp][i] ++;
        }
        cell_locality[temp][recent_index] = 0;
    }
    void process(){
        while(true){
            wait();
            sc_bv<24> index_num = location.read() >> 8;
            sc_bv<2> tag_num = (location.read() >> 6) & 0x03;
            sc_bv<6> offset = location.read() & 0x3F;
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
                    int idx_temp = fetch_index(index_num.read(), tag_num.read());
                    if(idx_temp != -1){
                        if(valid[index_num.read().to_uint()][idx_temp]){
                            if(w_enable){
                                dirty[index_num.read().to_uint()][idx_temp] = 1;
                                first_mem[index_num.read().to_uint()][idx_temp].range(offset * 8 + 31, offset*8) = data_in.read();
                            }else{
                                data_out.write(first_mem[index_num.read().to_uint()][idx_temp].range(offset*8 + 31, offset*8));
                            }
                            next_state.write(1);
                            l2_fetch.write(0);
                            l2_call.write(0);
                            replacement.write(0);
                            out_state.write(0);
                            used_locality[idx_counter] = 0;
                            update_locality(idx_temp, index_num.read());
                        }else{
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
                        l2_fetch_index.write(tag[index_num.read().to_uint()][row_least_local(index_num.read())] << 8 | index_num.read());
                        replacement.write(dirty[index_num.read().to_uint()][row_least_local(index_num.read())]);
                        if
                    }
                }
            }
        }
    }
}