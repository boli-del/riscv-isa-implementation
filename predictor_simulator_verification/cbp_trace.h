#pragma once
#include <cstdint>
#include <cstdio>
#include <zlib.h>
#include "synthetic_traces.h"

inline trace_t load_cbp_trace(const char* path){
    trace_t t;
    gzFile f = gzopen(path, "rb");
    if(!f){
        printf("could not open %s\n", path);
        return t;
    }
    char magic[8];
    const char expected[9] = "CBPNGAmp";
    bool has_magic = gzread(f, magic, 8) == 8;
    for(int i = 0; i < 8 && has_magic; i++){
        if(magic[i] != expected[i]) has_magic = false;
    }
    if(!has_magic){
        gzseek(f, 0, SEEK_SET);
    }
    while(true){
        uint64_t pc;
        if(gzread(f, &pc, 8) < 8) break;
        uint8_t cls = 8;
        gzread(f, &cls, 1);
        uint8_t has_base_update = 0;
        if(cls == 1 || cls == 2){
            gzseek(f, 9, SEEK_CUR);
            gzread(f, &has_base_update, 1);
            if(cls == 2) gzseek(f, 1, SEEK_CUR);
        }
        uint8_t taken = 0;
        if(cls == 3 || cls == 4 || cls == 5 || cls == 9 || cls == 10 || cls == 11){
            gzread(f, &taken, 1);
            if(taken){
                uint64_t target;
                gzread(f, &target, 8);
            }
        }
        uint8_t num_in = 0;
        gzread(f, &num_in, 1);
        uint8_t in_regs[256];
        int in_count = 0;
        for(int i = 0; i < num_in; i++){
            uint8_t r = 0;
            gzread(f, &r, 1);
            if(r < 32) in_regs[in_count++] = r;
        }
        uint8_t num_out = 0;
        gzread(f, &num_out, 1);
        uint8_t out_regs[256];
        for(int i = 0; i < num_out; i++){
            gzread(f, &out_regs[i], 1);
        }
        uint8_t base_update_reg = 0;
        if(has_base_update){
            if(cls == 2){
                if(num_out != 1){
                    has_base_update = 0;
                }else{
                    base_update_reg = out_regs[0];
                }
            }else{
                if(num_out <= 1){
                    has_base_update = 0;
                }else{
                    int overlap = 0;
                    uint8_t overlap_reg = 0;
                    for(int i = 0; i < num_out; i++){
                        if(out_regs[i] < 32){
                            for(int j = 0; j < in_count; j++){
                                if(in_regs[j] == out_regs[i]){
                                    overlap++;
                                    overlap_reg = out_regs[i];
                                }
                            }
                        }
                    }
                    if(overlap == 1){
                        base_update_reg = overlap_reg;
                    }else{
                        has_base_update = 0;
                    }
                }
            }
        }
        for(int i = 0; i < num_out; i++){
            gzseek(f, 8, SEEK_CUR);
            bool matching_base_upd = has_base_update && base_update_reg == out_regs[i];
            bool integer_register = out_regs[i] < 32 || out_regs[i] == 64 || out_regs[i] == 65;
            if(!matching_base_upd && !integer_register){
                gzseek(f, 8, SEEK_CUR);
            }
        }
        if(cls == 3){
            t.push_back({(uint32_t)pc, taken != 0});
        }
    }
    gzclose(f);
    return t;
}
