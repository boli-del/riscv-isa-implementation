#include <iostream>
#include <map>
#include <cstdint>
#include "predictor.h"
#include <utility>
#include <cmath>

using namespace std;

class tage_predictor{
    public:
        BranchPredictor basepredictor;
        map<uint32_t, map<int, int>> confidence;
        map<uint32_t, map<int, int>> usefulness;
        map<uint32_t, int> four_bit;
        map<uint32_t, uint8_t> eight_bit;
        map<uint32_t, uint16_t> sixteen;
        map<uint32_t, uint32_t> thtytwo;
        map<uint32_t, uint64_t> sixfour;
        map<uint32_t, uint32_t> specific_hist;
        pair<bool, int> predict(uint32_t input){
            //hash location, simple version
            int idx0 = table_index(input, 0);
            int idx1 = table_index(input, 1);
            int idx2 = table_index(input, 2);
            int idx3 = table_index(input, 3);
            if(tag(input, 0) == sixfour[idx0]){
                if(is_new(idx0, 0)){
                    return {alt_predict(input, 0), 0};
                }
                if(confidence[idx0][0] > 0){
                    return {true, 0};
                }else{
                    return {false, 0};
                }
            }else if(tag(input, 1) == thtytwo[idx1]){
                if(is_new(idx1, 1)){
                    return {alt_predict(input, 1), 1};
                }
                if(confidence[idx1][1] > 0){
                    return {true, 1};
                }else{
                    return {false, 1};
                }
            }else if(tag(input, 2) == sixteen[idx2]){
                if(is_new(idx2, 2)){
                    return {alt_predict(input, 2), 2};
                }
                if(confidence[idx2][2] > 0){
                    return {true, 2};
                }else{
                    return {false, 2};
                }
            }else if(tag(input, 3) == eight_bit[idx3]){
                if(is_new(idx3, 3)){
                    return {alt_predict(input, 3), 3};
                }
                if(confidence[idx3][3] > 0){
                    return {true, 3};
                }else{
                    return {false, 3};
                }
            }
            return {basepredictor.predict(input), 4};
        }
        void update_usefulness(uint32_t input, bool taken, bool predicted, int segment){
            if(segment != 4){
                int hashed_val = table_index(input, segment);
                if(taken){
                    if(confidence[hashed_val][segment] < 3){
                        confidence[hashed_val][segment] ++;
                    }
                }else{
                    if(confidence[hashed_val][segment] > -4){
                        confidence[hashed_val][segment]--;
                    }
                }
                if(taken != predicted){
                    if(usefulness[hashed_val][segment] > 0){
                        usefulness[hashed_val][segment] = usefulness[hashed_val][segment] - 1;
                    }
                }else{
                    if(usefulness[hashed_val][segment] < 3){
                        usefulness[hashed_val][segment] = usefulness[hashed_val][segment] + 1;
                    }
                }
            }
            if(taken != predicted){
                allocate(input, segment, taken);
            }
            recent_hist = (recent_hist << 1)|taken;
            basepredictor.update(taken);
        }
    private:
        uint64_t recent_hist = 0;
        int hist_len[4] = {64, 27, 12, 5};
        uint64_t fold(int segment, int width){
            uint64_t mask = 0xFFFFFFFFFFFFFFFF;
            int shift = 64 - hist_len[segment];
            mask = mask >> shift;
            uint64_t h = recent_hist & mask;
            uint64_t folded = 0;
            while(h != 0){
                folded = folded ^ (h & ((1ULL << width) - 1));
                h = h >> width;
            }
            return folded;
        }
        int table_index(uint32_t input, int segment){
            return (input ^ (input >> 4) ^ fold(segment, 12)) % 4096;
        }
        int tag(uint32_t input, int segment){
            return (input ^ fold(segment, 8) ^ (fold(segment, 7) << 1)) & 0xFF;
        }
        bool is_new(int hashed_val, int segment){
            return confidence[hashed_val][segment] >= -1 && confidence[hashed_val][segment] <= 1 && usefulness[hashed_val][segment] == 0;
        }
        bool alt_predict(uint32_t input, int provider){
            if(provider < 1 && tag(input, 1) == thtytwo[table_index(input, 1)]){
                return confidence[table_index(input, 1)][1] > 0;
            }else if(provider < 2 && tag(input, 2) == sixteen[table_index(input, 2)]){
                return confidence[table_index(input, 2)][2] > 0;
            }else if(provider < 3 && tag(input, 3) == eight_bit[table_index(input, 3)]){
                return confidence[table_index(input, 3)][3] > 0;
            }
            return basepredictor.predict(input);
        }
        void allocate(uint32_t input, int provider, bool taken){
            for(int s = provider - 1; s >= 0; s--){
                int hashed_val = table_index(input, s);
                if(usefulness[hashed_val][s] == 0){
                    if(s == 0){
                        sixfour[hashed_val] = tag(input, 0);
                    }else if(s == 1){
                        thtytwo[hashed_val] = tag(input, 1);
                    }else if(s == 2){
                        sixteen[hashed_val] = tag(input, 2);
                    }else{
                        eight_bit[hashed_val] = tag(input, 3);
                    }
                    confidence[hashed_val][s] = taken ? 1 : -1;
                    usefulness[hashed_val][s] = 0;
                    return;
                }
            }
            for(int s = provider - 1; s >= 0; s--){
                int hashed_val = table_index(input, s);
                if(usefulness[hashed_val][s] > 0){
                    usefulness[hashed_val][s]--;
                }
            }
        }
};
