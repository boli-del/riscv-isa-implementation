#include <iostream>
#include <vector>
#include "predictor.h"

using namespace std;

int main(){
    BranchPredictor predictor;
    vector<pair<uint32_t, bool>> trace;
    for(int i = 0; i < 1000; i++){
        trace.push_back({0x00400000, i % 10 != 9});
        trace.push_back({0x00400804, i % 2 == 0});
        trace.push_back({0x00401008, true});
    }
    int correct = 0;
    for(auto &branch : trace){
        bool guess = predictor.predict(branch.first);
        if(guess == branch.second){
            correct++;
        }
        predictor.update(branch.second);
    }
    cout << "predicted " << correct << " / " << trace.size() << " branches correctly (" << (100.0 * correct / trace.size()) << "%)" << endl;
    return 0;
}
