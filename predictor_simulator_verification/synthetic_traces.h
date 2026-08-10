#pragma once
#include <vector>
#include <utility>
#include <cstdint>

using namespace std;

//just generate synthethic test suites for comparison testing

typedef vector<pair<uint32_t, bool>> trace_t;

inline uint32_t xorshift(uint32_t &s){
    s ^= s << 13;
    s ^= s >> 17;
    s ^= s << 5;
    return s;
}

inline trace_t nested_loops(){
    trace_t t;
    for(int o = 0; o < 200; o++){
        for(int i = 0; i < 8; i++){
            t.push_back({0x1000, i < 7});
            t.push_back({0x1004, (i + o) % 3 != 0});
        }
        t.push_back({0x1008, o < 199});
    }
    return t;
}

inline trace_t correlated(){
    trace_t t;
    uint32_t s = 12345;
    for(int i = 0; i < 3000; i++){
        bool x = xorshift(s) & 1;
        t.push_back({0x2000, x});
        t.push_back({0x2004, (xorshift(s) % 10) < 7});
        t.push_back({0x2008, !x});
    }
    return t;
}

inline trace_t phase_change(){
    trace_t t;
    uint32_t s = 999;
    for(int i = 0; i < 6000; i++){
        int bias = i < 3000 ? 9 : 1;
        t.push_back({0x3000, (int)(xorshift(s) % 10) < bias});
    }
    return t;
}

inline trace_t periodic_loops(){
    trace_t t;
    for(int i = 0; i < 3000; i++){
        t.push_back({0x4000, i % 5 != 4});
        t.push_back({0x4004, i % 31 != 30});
    }
    return t;
}

inline trace_t many_branches(){
    trace_t t;
    uint32_t s = 777;
    int bias[256];
    for(int b = 0; b < 256; b++){
        bias[b] = xorshift(s) % 11;
    }
    for(int i = 0; i < 30; i++){
        for(int b = 0; b < 256; b++){
            t.push_back({0x10000 + 4u*b, (int)(xorshift(s) % 10) < bias[b]});
        }
    }
    return t;
}

inline trace_t random_50_50(){
    trace_t t;
    uint32_t s = 42;
    for(int i = 0; i < 3000; i++){
        t.push_back({0x5000, xorshift(s) & 1});
    }
    return t;
}
