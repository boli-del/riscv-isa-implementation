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
            int hashed_val = input % 4096;
            if(recent_hist == sixfour[hashed_val]){
                if(is_new(hashed_val, 0)){
                    return {alt_predict(hashed_val, 0, input), 0};
                }
                if(confidence[hashed_val][0] > 0){
                    return {true, 0};
                }else{
                    return {false, 0};
                }
            }else if((recent_hist & 0x7FFFFFF) == thtytwo[hashed_val]){
                if(is_new(hashed_val, 1)){
                    return {alt_predict(hashed_val, 1, input), 1};
                }
                if(confidence[hashed_val][1] > 0){
                    return {true, 1};
                }else{
                    return {false, 1};
                }
            }else if((recent_hist & 0xFFF) == sixteen[hashed_val]){
                if(is_new(hashed_val, 2)){
                    return {alt_predict(hashed_val, 2, input), 2};
                }
                if(confidence[hashed_val][2] > 0){
                    return {true, 2};
                }else{
                    return {false, 2};
                }
            }else if((recent_hist & 0x1F) == eight_bit[hashed_val]){
                if(is_new(hashed_val, 3)){
                    return {alt_predict(hashed_val, 3, input), 3};
                }
                if(confidence[hashed_val][3] > 0){
                    return {true, 3};
                }else{
                    return {false, 3};
                }
            }
            return {basepredictor.predict(input), 4};
        }
        void update_usefulness(uint32_t input, bool taken, bool predicted, int segment){
            int hashed_val = input % 4096;
            recent_hist = (recent_hist << 1)|taken;
            basepredictor.update(taken);
            if(segment == 4){
                if(taken != predicted){
                    allocate(hashed_val, 3, taken);
                }
                return;
            }
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
            if(usefulness[hashed_val][segment] <= 0){
                allocate(hashed_val, segment, taken);
            }
        }
    private:
        uint64_t recent_hist = 0;
        int hist_len[4] = {64, 27, 12, 5};
        bool is_new(int hashed_val, int segment){
            return confidence[hashed_val][segment] >= -1 && confidence[hashed_val][segment] <= 1 && usefulness[hashed_val][segment] == 0;
        }
        bool alt_predict(int hashed_val, int provider, uint32_t input){
            if(provider < 1 && (recent_hist & 0x7FFFFFF) == thtytwo[hashed_val]){
                return confidence[hashed_val][1] > 0;
            }else if(provider < 2 && (recent_hist & 0xFFF) == sixteen[hashed_val]){
                return confidence[hashed_val][2] > 0;
            }else if(provider < 3 && (recent_hist & 0x1F) == eight_bit[hashed_val]){
                return confidence[hashed_val][3] > 0;
            }
            return basepredictor.predict(input);
        }
        void allocate(int hashed_val, int segment, bool taken){
            uint64_t mask = 0xFFFFFFFFFFFFFFFF;
            int shift = 64 - hist_len[segment];
            mask = mask >> shift;
            if(segment == 0){
                sixfour[hashed_val] = recent_hist & mask;
            }else if(segment == 1){
                thtytwo[hashed_val] = recent_hist & mask;
            }else if(segment == 2){
                sixteen[hashed_val] = recent_hist & mask;
            }else{
                eight_bit[hashed_val] = recent_hist & mask;
            }
            confidence[hashed_val][segment] = taken ? 1 : -1;
            usefulness[hashed_val][segment] = 0;
        }
};