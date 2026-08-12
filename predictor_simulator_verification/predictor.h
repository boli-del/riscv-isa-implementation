#pragma once
#include <cstdint>

class BranchPredictor{
    public:
        bool predict(uint32_t branch_location);
        void update(bool choice);
    private:
        uint64_t branch_history = 0;
};
