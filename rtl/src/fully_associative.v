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
