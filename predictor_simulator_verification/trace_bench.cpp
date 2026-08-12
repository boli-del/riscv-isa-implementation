#include <iomanip>
#include "microweight_model_predictor.cpp"
#include "tage_predictor.cpp"
#include "synthetic_traces.h"
#include "predictor.h"

double run_microweight(const trace_t &trace){
    regression_classifier p;
    int correct = 0;
    for(auto &branch : trace){
        bool guess = p.predict(branch.first) >= 0.5;
        if(guess == branch.second){
            correct++;
        }
        p.update(branch.first, branch.second);
    }
    return 100.0 * correct / trace.size();
}

double run_tage(const trace_t &trace){
    tage_predictor p;
    int correct = 0;
    for(auto &branch : trace){
        pair<bool, int> guess = p.predict(branch.first);
        if(guess.first == branch.second){
            correct++;
        }
        p.update_usefulness(branch.first, branch.second, guess.first, guess.second);
    }
    return 100.0 * correct / trace.size();
}

double run_last_outcome(const trace_t &trace){
    BranchPredictor p;
    int correct = 0;
    for(auto &branch : trace){
        if(p.predict(branch.first) == branch.second){
            correct++;
        }
        p.update(branch.second);
    }
    return 100.0 * correct / trace.size();
}

int main(){
    pair<const char*, trace_t> traces[] = {
        {"nested_loops", nested_loops()},
        {"correlated", correlated()},
        {"phase_change", phase_change()},
        {"periodic_loops", periodic_loops()},
        {"many_branches", many_branches()},
        {"random_50_50", random_50_50()},
    };
    cout << left << setw(18) << "trace" << right << setw(10) << "branches"
         << setw(14) << "microweight" << setw(14) << "tage" << setw(14) << "last-outcome" << endl;
    for(auto &tr : traces){
        cout << left << setw(18) << tr.first << right << setw(10) << tr.second.size()
             << setw(13) << fixed << setprecision(1) << run_microweight(tr.second) << "%"
             << setw(13) << run_tage(tr.second) << "%"
             << setw(13) << run_last_outcome(tr.second) << "%" << endl;
    }
    return 0;
}
