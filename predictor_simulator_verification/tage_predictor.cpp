#include <iostream>
#include <map>
#include <cstdint>
#include "predictor.h"
#include <utility>
#include <cmath>

using namespace std;

class tage_predictor{
    public:
        BranchPredictor tage_predictor::basepredictor();
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
                if(confidence[hashed_val][0] > 0){
                    return {true, 0};
                }else{
                    return {false, 0};
                }
            }else if(recent_hist << 32 == thtytwo[hashed_val]){
                if(confidence[hashed_val][1] > 0){
                    return {true, 1};
                }else{
                    return {false, 1};
                }
            }else if(recent_hist << 48 == sixteen[hashed_val]){
                if(confidence[hashed_val][2] > 0){
                    return {true, 2};
                }else{
                    return {false, 2};
                }
            }else if(recent_hist << 56 == eight_bit[hashed_val]){
                if(confidence[hashed_val][3] > 0){
                    return {true, 3};
                }else{
                    return {false, 3};
                }
            }
        }
        void update_usefulness(uint32_t input, bool taken, bool predicted, int segment){
            int hashed_val = input % 4096;
            recent_hist = (recent_hist << 1)|taken;
            if(taken){
                confidence[hashed_val][segment] ++;
            }else{
                confidence[hashed_val][segment]--;
            }
            if(taken != predicted){
                usefulness[hashed_val][segment] = usefulness[hashed_val][segment] - 1;
            }else{
                usefulness[hashed_val][segment] = usefulness[hashed_val][segment] + 1;
            }
            if(usefulness[hashed_val][segment] <= 0){
                int divisor = pow(2, segment);
                int shift = 64 / divisor;
                usefulness[hashed_val][segment] =  
            }
        }
    private:
        uint64_t recent_hist = 0;
}