`timescale 1ns/1ps
module l1_cache(
    input clk,
    input rst_n,
    input l2_write_finished,
    input w_enable,
    input [511:0] l2_in_data,
    input [31:0] data_in, location,
    input [1:0] cache_location, state_in,
    input [3:0] victim_idx_in,
    output reg [1:0] out_state, next_state,
    output reg l2_call, replacement,
    output reg [31:0] l2_fetch_index, l2_fetch, data_out,
    output reg [511:0] dirty_data,
    output reg [3:0] victim_idx_out
);
    reg [511:0] first_mem [0:15];
    reg [25:0] tag [0:15];
    reg dirty [0:15];
    reg valid [0:15];
    reg [4:0] used_locality [0:15];

    wire [25:0] tag_num = location >> 6;
    wire [5:0] offset = location[5:0];

    reg [3:0] idx;
    reg hit;
    reg [3:0] idx_max;
    integer i;

    task find_index;
        input [25:0] tag_n;
        output [3:0] idx_out;
        output hit_out;
        integer a;
        begin
            idx_out = 0;
            hit_out = 0;
            for(a = 0; a < 16; a = a + 1) begin
                if(tag_n == tag[a]) begin
                    idx_out = a[3:0];
                    hit_out = 1;
                end
            end
        end
    endtask

    task update_locality;
        input [3:0] most_recent;
        integer a;
        begin
            for(a = 0; a < 16; a = a + 1) begin
                //change from system c implmentation to save limited bits for locality
                if(used_locality[a] < used_locality[most_recent]) begin
                    used_locality[a] <= used_locality[a] + 1;
                end
            end
            used_locality[most_recent] <= 0;
        end
    endtask

    task find_max_locality;
        output [3:0] index_dirty;
        integer a;
        begin
            index_dirty = 0;
            for(a = 0; a < 16; a = a + 1) begin
                if(used_locality[a] == 5'b01111) begin
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
            for(i = 0; i < 16; i = i + 1) begin
                valid[i] <= 0;
                dirty[i] <= 0;
                used_locality[i] <= i[4:0];
            end
        end else begin
            case (state_in)
                2'b01: begin
                    find_index(tag_num, idx, hit);
                    if(hit)begin
                        if(valid[idx])begin
                            if(w_enable) begin
                                dirty[idx] <= 1;
                                first_mem[idx][offset * 8 +: 32] <= data_in;
                            end else begin
                                data_out <= first_mem[idx][offset * 8 +: 32];
                            end
                            next_state <= 1;
                            l2_fetch <= 0;
                            l2_call <= 0;
                            replacement <= 0;
                            out_state <= 0;
                            update_locality(idx);
                        end
                        else begin
                            victim_idx_out <= idx;
                            l2_fetch <= 1;
                            l2_call <= 1;
                            replacement <= 0;
                            dirty_data <= 0;
                            l2_fetch_index <= 0;
                            next_state <= 0;
                            out_state <= 0;
                        end
                    end else begin
                        find_max_locality(idx_max);
                        l2_fetch <= 1;
                        l2_call <= 1;
                        l2_fetch_index <= tag[idx_max] << 6;
                        replacement <= dirty[idx_max];
                        victim_idx_out <= idx_max;
                        if(dirty[idx_max]) begin
                            dirty_data <= first_mem[idx_max];
                        end else begin
                            dirty_data <= 0;
                        end
                        next_state <= 0;
                        out_state <= 0;
                    end
                end
                2'b00: begin
                    if(l2_write_finished) begin
                        next_state <= 2;
                        out_state <= 2;
                        l2_call <= 0;
                        replacement <= 0;
                        dirty_data <= 0;
                        l2_fetch <= 0;
                    end else begin
                        next_state <= 0;
                        out_state <= 0;
                        l2_call <= 1;
                        replacement <= 0;
                        l2_fetch <= 0;
                    end
                end
                2'b10: begin
                    tag[victim_idx_in] <= tag_num;
                    first_mem[victim_idx_in] <= l2_in_data;
                    update_locality(victim_idx_in);
                    next_state <= 1;
                    out_state <= 1;
                    valid[victim_idx_in] <= 1;
                    dirty[victim_idx_in] <= 0;
                end
            endcase
        end
    end
endmodule

`timescale 1ns/1ps
module l2_cache(
    input clk,
    input rst_n,
    input l2_initiated, b_dirty, l3_completed,
    input [511:0] data_w, l3_in,
    input [31:0] index_w, data_in_index,
    input [1:0] state_in,
    output reg completed_wb, l3_write_from_l2, l3_search_dirty, l2_acknowledged, l2_finished, data_out_dirty, dirt_acknowledged,
    output reg [1:0] next_state,
    output reg [511:0] data_out, data_out_dirty_line,
    output reg [31:0] dataout_index, data_out_dirty_index
);
    parameter LINES = 64;
    parameter IDX_W = 6;

    reg [511:0] l2_mem [0:LINES-1];
    reg [25:0] l2_tag [0:LINES-1];
    reg dirty [0:LINES-1];
    reg valid [0:LINES-1];
    reg [IDX_W-1:0] used_locality [0:LINES-1];

    reg [IDX_W-1:0] victim_idx;
    reg [IDX_W-1:0] idx;
    reg [IDX_W-1:0] max_idx;
    reg found;
    integer i;

    wire [25:0] tag_num = data_in_index[31:6];
    wire [25:0] tag_w = index_w[31:6];

    task find_way;
        input [25:0] tag_find;
        output [IDX_W-1:0] index;
        output hit;
        integer a;
        begin
            index = 0;
            hit = 0;
            for(a = 0; a < LINES; a = a + 1) begin
                if(valid[a] && l2_tag[a] == tag_find) begin
                    index = a[IDX_W-1:0];
                    hit = 1;
                end
            end
        end
    endtask

    task touch;
        input [IDX_W-1:0] index;
        integer a;
        begin
            for(a = 0; a < LINES; a = a + 1) begin
                if(used_locality[a] < used_locality[index]) begin
                    used_locality[a] <= used_locality[a] + 1;
                end
            end
            used_locality[index] <= 0;
        end
    endtask

    task least_local;
        output [IDX_W-1:0] out_index;
        integer a;
        begin
            out_index = 0;
            for(a = 0; a < LINES; a = a + 1) begin
                if(used_locality[a] > used_locality[out_index]) begin
                    out_index = a[IDX_W-1:0];
                end
            end
        end
    endtask

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data_out <= 0;
            completed_wb <= 0;
            next_state <= 2'b01;
            l3_write_from_l2 <= 0;
            l3_search_dirty <= 0;
            dataout_index <= 0;
            l2_acknowledged <= 0;
            l2_finished <= 0;
            data_out_dirty <= 0;
            dirt_acknowledged <= 0;
            victim_idx <= 0;
            for(i = 0; i < LINES; i = i + 1) begin
                valid[i] <= 0;
                dirty[i] <= 0;
                used_locality[i] <= i[IDX_W-1:0];
            end
        end
        else begin
            case(state_in)
                2'b11: begin
                    find_way(tag_w, idx, found);
                    if(found) begin
                        l2_mem[idx] <= data_w;
                        dirty[idx] <= 1;
                        touch(idx);
                        data_out_dirty <= 0;
                        l3_search_dirty <= 0;
                        l3_write_from_l2 <= 0;
                        l2_acknowledged <= 0;
                        l2_finished <= 0;
                        next_state <= 2'b01;
                        dirt_acknowledged <= 1;
                    end
                    else begin
                        data_out_dirty <= 1;
                        data_out_dirty_line <= data_w;
                        data_out_dirty_index <= index_w;
                        l3_search_dirty <= 1;
                        completed_wb <= 0;
                        l3_write_from_l2 <= 0;
                        l2_acknowledged <= 0;
                        l2_finished <= 0;
                        dirt_acknowledged <= 1;
                        next_state <= 2'b01;
                    end
                end
                2'b01: begin
                    if(b_dirty) begin
                        next_state <= 2'b11;
                        l2_finished <= 0;
                    end
                    else if(!l2_initiated) begin
                        next_state <= 2'b01;
                        l2_finished <= 0;
                    end
                    else begin
                        l2_acknowledged <= 1;
                        find_way(tag_num, idx, found);
                        if(found) begin
                            touch(idx);
                            l3_write_from_l2 <= 0;
                            dataout_index <= data_in_index;
                            data_out <= l2_mem[idx];
                            l2_finished <= 1;
                            l3_search_dirty <= 0;
                            completed_wb <= 0;
                            next_state <= 2'b01;
                            dirt_acknowledged <= 0;
                        end
                        else begin
                            least_local(max_idx);
                            victim_idx <= max_idx;
                            l3_write_from_l2 <= 1;
                            dataout_index <= data_in_index;
                            completed_wb <= 0;
                            l3_search_dirty <= 0;
                            l2_finished <= 0;
                            next_state <= 2'b00;
                            data_out_dirty <= 0;
                        end
                    end
                end
                2'b00: begin
                    if(l3_completed) begin
                        next_state <= 2'b10;
                        l3_write_from_l2 <= 0;
                    end
                    else begin
                        next_state <= 2'b00;
                    end
                end
                2'b10: begin
                    data_out_dirty <= dirty[victim_idx];
                    data_out_dirty_index <= {l2_tag[victim_idx], 6'b000000};
                    data_out_dirty_line <= l2_mem[victim_idx];
                    l2_mem[victim_idx] <= l3_in;
                    l2_tag[victim_idx] <= tag_num;
                    valid[victim_idx] <= 1;
                    dirty[victim_idx] <= 0;
                    touch(victim_idx);
                    next_state <= 2'b01;
                end
            endcase
        end
    end
endmodule

module l1_l2_top