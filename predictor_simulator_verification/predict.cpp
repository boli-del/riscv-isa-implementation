#include "predictor.h"

bool BranchPredictor::predict(uint32_t branch_location){
    return branch_history & 1;
}

void BranchPredictor::update(bool choice){
    branch_history = (branch_history << 1) | choice;
}
