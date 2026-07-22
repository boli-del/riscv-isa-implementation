module l1_cache{
    input clk;
    input rst_n;
    input l2_write_finished;
    input w_enable;
    input l2_in_data;
    input [511:0] l2_in_data;
    input [31:0] data_in, location;
    input [1:0] cache_location, state_in;
    input [3:0] victim_idx_in;
    output [1:0] out_state, next_state;
    output l2_call, replacement;
    output [31:0] l2_fetch_index, l2_fetch, data_out;
    output [511:0] dirty_data;
    output [3:0] victim_idx_out;
};
    reg[511:0] first_mem [3:0];
    reg[25:0] tag [3:0];
    reg dirty [3:0];
    reg valid [3:0];
    reg[4:0] used_locality [3:0];

    reg[25:0] tag_num = location >> 6;
    reg[5:0] offset = location & 6b'111111;

    task find_index;
        input [25:0] tag_n,
        input [25:0] tag_in [3:0],
        output [3:0] idx_out,
        output hit
        for(a = 0; a < 5'b10000; a = a+1)begin
            if(tag_n == tag_in[a]) begin
                idx_out <= a;
                hit = 1;
            end
        end
    endtask

    task update_locality;
        input [3:0] most_recent;
        begin
            for(a = 0; a < 5'b10000; a = a+1)begin
                //change from system c implmentation to save limited bits for locality
                if(used_locality[a] < used_locality[most_recent]) begin
                    used_locality[a] = used_locality[a] + 1;
                end
            end
            used_locality[most_recent] = 0;
        end
    endtask

    task find_max_locality;
        output [3:0] index_dirty
        begin
            for(a = 5b'00000; a < 5b'10000; a = a + 1) begin
                if(used_locality[a] == 5b'01111) begin
                    index_dirty = a[3:0];
                end
            end
        end
    endtask
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            out_state <= 1;
            l2_call <= 0;
            replacement <= 0;
            dirty_data <= 0;
            l2_fetch <= 0;
            l2_fetch_index <= 0;
            next_state <= 1;
        end else begin
            case (state_in)
                2'b01: begin
                    reg[3:0] idx;
                    reg hit = 0;
                    find_index(tag_n(tag_num), tag_in(tag), idx_out(idx), hit(hit));
                    if(hit)begin
                        if(valid[idx])begin
                            if(w_enable) begin
                                dirty[idx] = 1;
                                first_mem[idx][offset * 8 + 31 : offset * 8] = data_in;
                            end else begin
                                data_out = first_mem[idx][offset*8+31:offset*8];
                            end
                            next_state = 1;
                            l2_fetch = 0;
                            l2_call = 0;
                            replacement = 0;
                            out_state = 0;
                            used_locality[idx] = 0;
                            update_locality(idx);
                        end
                        else begin
                            l2_fetch = 1;
                            l2_call = 1;
                            replacement = 0;
                            dirty_data = 0;
                            l2_fetch_index = 0;
                            next_state = 0;
                            out_state = 0;
                        end
                    end else begin
                        l2_fetch = 1;
                        l2_call = 1;
                        replacement = 1;
                        reg[3:0] idx_max;
                        find_max_locality(idx_max);
                        l2_fetch_index = tag[idx_max] << 6;
                        replacement = dirty[idx_max];
                        l2_fetch = 1;
                        l2_call = 1;
                        if(dirty[idx_max]) begin
                            dirty_data = first_mem[idx_max];
                        end else begin
                            dirty_data = 0;
                        end
                        next_state = 0;
                        out_state = 0;
                    end
                end
                2'b00: begin
                    if(l2_write_finished) begin
                        next_state = 2;
                        out_state = 2;
                        l2_call = 0;
                        replacement = 0;
                        dirty_data = 0;
                        l2_fetch = 0;
                    end else begin
                        next_state = 0;
                        out_state = 0;
                        l2_call = 1;
                        replacement = 0;
                        l2_fetch = 0;
                    end
                end
                2'b10: begin
                end
            endcase
        end
    end

endmodule;