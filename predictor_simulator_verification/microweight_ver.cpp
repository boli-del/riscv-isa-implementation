#include "microweight_model_predictor.cpp"

int main(){
    regression_classifier predictor;
    vector<pair<uint32_t, bool>> trace;
    for(int i = 0; i < 1000; i++){
        trace.push_back({0x00400000, i % 10 != 9});
        trace.push_back({0x00400804, i % 2 == 0});
        trace.push_back({0x00401008, true});
    }
    int correct = 0;
    for(auto &branch : trace){
        bool guess = predictor.predict(branch.first) >= 0.5;
        if(guess == branch.second){
            correct++;
        }
        predictor.update(branch.first, branch.second);
    }
    cout << "predicted " << correct << " / " << trace.size() << " branches correctly (" << (100.0 * correct / trace.size()) << "%)" << endl;
    cout << "p(taken) after training:" << endl;
    cout << "  0x00400000 (taken 90% of the time): " << predictor.predict(0x00400000) << endl;
    cout << "  0x00400804 (taken 50% of the time): " << predictor.predict(0x00400804) << endl;
    cout << "  0x00401008 (always taken):          " << predictor.predict(0x00401008) << endl;
    return 0;
}
