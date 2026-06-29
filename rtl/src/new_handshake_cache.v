`default_nettype none
`timescale 1ns/1ps
module l1_cache(
    input clk,
    input rst_n,
    input [1:0] state_in,
    input w_enable,
    input data_ready,
    input l1_write_from_l2,
    input [1:0] data_type,
    input [31:0] data_in,
    input [31:0] op_index,
    input [511:0] l2_in,
    input l2_received,
    input stall,
    output reg [511:0] read_value,
    output reg [31:0] data_out,
    output reg finished_op,
    output reg start_l2,
    output reg [31:0] replacement_idx,
    output reg replacement_needed,
    output reg start_read_w,
    output reg [1:0] next_state
);
    reg [511:0] l1_mem [3:0];
    reg [23:0] tag_bit [3:0];
    reg valid [3:0];
    reg dirty [3:0];
    integer i;
    wire [23:0] tag = op_index [31:8];
    wire [1:0] idx = op_index [7:6];
    wire [5:0] offset = op_index[5:0];
    always @(posedge clk) begin
        if(!rst_n) begin
            for(i = 0; i < 4; i = i + 1) begin
                valid[i] <= 1'b0;
                dirty[i] <= 1'b0;
            end
            next_state <= 2'b00;
            start_l2 <= 0;
            start_read_w <= 0;
            finished_op <= 0;
            replacement_needed <= 0;
        end
        else begin
        case (state_in)
            2'b00: begin
                if(l2_received) begin
                    start_l2 <= 0;
                end
                if(l1_write_from_l2) begin
                    next_state <= 2'b01;
                    start_read_w <= 0;
                end
                else if(data_ready) begin
                    next_state <= 2'b10;
                    start_read_w <= 1;
                end
                else begin
                    next_state <= 2'b00;
                    start_read_w <= 0;
                end
            end
            2'b10: begin
                if(valid[idx] && tag_bit[idx] == tag) begin
                    if(w_enable) begin
                        case (data_type)
                            2'b00: l1_mem[idx][offset*8+:4] <= data_in [3:0];
                            2'b01: l1_mem[idx][offset*8+:8] <= data_in [7:0];
                            2'b10: l1_mem[idx][offset*8+:16] <= data_in [15:0];
                            2'b11: l1_mem[idx][offset*8+:32] <= data_in;
                        endcase
                        dirty[idx] <= 1'b1;
                    end
                    else begin
                        case (data_type)
                            2'b00: data_out[3:0] <= l1_mem[idx][offset*8 +: 4];
                            2'b01: data_out[7:0] <= l1_mem[idx][offset*8 +: 8];
                            2'b10: data_out[15:0] <= l1_mem[idx][offset*8 +: 16];
                            2'b11: data_out[31:0] <= l1_mem[idx][offset*8 +: 32];
                        endcase
                    end
                    finished_op <= 1;
                    start_l2 <= 0;
                    replacement_needed <= 0;
                    start_read_w <= 1;
                    next_state <= 2'b10;
                end
                else begin
                    start_l2 <= 1;
                    if(valid[idx] && dirty[idx]) begin
                        replacement_idx <= {tag_bit[idx], idx, 6'b000000};
                        replacement_needed <= 1;
                        read_value <= l1_mem[idx];
                    end
                    else begin
                        replacement_needed <= 0;
                    end
                    finished_op <= 0;
                    start_read_w <= 0;
                    next_state <= 2'b00;
                end
            end
            2'b01: begin
                l1_mem[idx] <= l2_in;
                tag_bit[idx] <= tag;
                valid[idx] <= 1'b1;
                dirty[idx] <= 1'b0;
                start_l2 <= 0;
                next_state <= 2'b10;
                start_read_w <= 1;
            end
            2'b11: begin
                next_state <= 2'b11;
            end
        endcase
        end
    end
endmodule

`default_nettype none
`timescale 1ns/1ps
module l2_cache(
    input clk,
    input rst_n,
    input l2_initiated,
    input b_dirty,
    input [511:0] data_w,
    input [31:0] index_w,
    input [31:0] data_in_index,
    input[1:0] state_in,
    input l3_completed,
    input [511:0] l3_in,
    output reg [511:0] data_out,
    output reg completed_wb,
    output reg [1:0] next_state,
    output reg l3_write_from_l2,
    output reg l3_search_dirty,
    output reg [31:0] dataout_index,
    output reg [31:0] data_out_dirty_index,
    output reg [511:0] data_out_dirty_line,
    output reg l2_acknowledged,
    output reg l2_finished,
    output reg data_out_dirty,
    output reg dirt_acknowledged
);
    reg [511:0] l2_mem [15:0];
    reg [21:0] l2_tag [15:0];
    reg dirty [15:0];
    integer i;
    wire [21:0] tag_in = data_in_index[31:10];
    wire [3:0] idx = data_in_index[9:6];
    wire [3:0] idx_w = index_w[9:6];
    wire [21:0] tag_w = index_w [31:10];
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            data_out <= 0;
            completed_wb <= 0;
            next_state <= 0;
            l3_write_from_l2 <= 0;
            l3_search_dirty <= 0;
            dataout_index <= 0;
            l2_acknowledged <= 0;
            l2_finished <= 0;
            data_out_dirty <= 0;
            dirt_acknowledged <= 0;
            for(i = 0; i < 16; i = i + 1) begin
                dirty[i] <= 1'b0;
            end
        end
        else begin
        case(state_in)
            2'b11: begin
                if(l2_tag[idx_w] == tag_w) begin
                    l2_mem[idx_w] <= data_w;
                    dirty[idx_w] <= 1'b1;
                    l2_acknowledged <= 0;
                    l2_finished <= 0;
                    next_state <= 2'b01;
                    dirt_acknowledged <= 1;
                end
                else begin
                    l3_search_dirty <= 1;
                    data_out <= data_w;
                    dataout_index <= index_w;
                    completed_wb <= 0;
                    l3_write_from_l2 <= 1;
                    l2_acknowledged <= 0;
                    l2_finished <= 0;
                    dirt_acknowledged <= 1;
                    next_state <= 2'b00;
                end
            end
            2'b01: begin
                if(~l2_initiated) begin
                    next_state <= 2'b01;
                end
                else begin
                    if(b_dirty) begin
                        next_state <= 2'b11;
                    end
                    else if(l2_initiated) begin
                        l2_acknowledged <= 1;
                        if(l2_tag[idx] == tag_in) begin
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
                            l3_write_from_l2 <= 1;
                            dataout_index <= data_in_index;
                            l3_search_dirty <= 0;
                            completed_wb <= 0;
                            l2_finished <= 0;
                            next_state <= 2'b00;
                            data_out_dirty <= 0;
                        end
                    end
                end
            end
            2'b00: begin
                if(l3_completed) begin
                    next_state <= 2'b10;
                end
                else begin
                    next_state <= 2'b00;
                end
            end
            2'b10: begin
                next_state <= 2'b01;
                data_out_dirty <= dirty[idx];
                data_out_dirty_index <= {l2_tag[idx], idx, 6'b000000};
                data_out_dirty_line <= l2_mem[idx];
                l2_mem[idx] <= l3_in;
                l2_tag[idx] <= tag_in;
                dirty[idx] <= 1'b0;
            end
        endcase
        end
    end
endmodule

`default_nettype none
`timescale 1ns/1ps
module base_mem(
    input clk,
    input rst_n,
    input b_dirty,                  // high => store the dirty victim instead of serving a read
    input [511:0] data_dirty,       // dirty victim line from L2 (data_out_dirty_line)
    input [31:0] index_dirty,       // victim address (data_out_dirty_index)
    input [31:0] index_w,           // read address requested by L2 (dataout_index)
    output reg [511:0] data_out,    // fetched line -> L2.l3_in
    output reg [31:0] dataout_index,
    output reg l3_completed,        // read served -> L2.l3_completed
    output reg l3_finished_writing, // dirty write-back stored
    output reg l3_acknowledged      // request seen this cycle
);
    //maximum storage needed in my base memory here
    reg [511:0] storage [31:0];
    wire [4:0] mem_idx = index_w[10:6];
    wire [4:0] mem_dirty = index_dirty[10:6];
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            data_out <= 0;
            dataout_index <= 0;
            l3_completed <= 0;
            l3_finished_writing <= 0;
            l3_acknowledged <= 0;
        end
        else begin
            l3_acknowledged <= 1;
            if(b_dirty) begin
                storage[mem_dirty] <= data_dirty;
                l3_finished_writing <= 1;
                l3_completed <= 0;
            end
            else begin
                data_out <= storage[mem_idx];
                dataout_index <= index_w;
                l3_completed <= 1;
                l3_finished_writing <= 0;
            end
        end
    end
endmodule

`default_nettype none
`timescale 1ns/1ps
module l2_l3_top(
    input clk,
    input rst_n,
    input l2_initiated,
    input b_dirty,
    input [511:0] data_w,
    input [31:0] index_w,
    input [31:0] data_in_index,
    input [1:0] state_in,
    output [1:0] next_state,
    output [511:0] data_out,
    output l2_finished,
    output l2_acknowledged,
    output l3_completed,
    output l3_write_from_l2
);
    wire [31:0] l2_read_index;
    wire        l2_victim_dirty;
    wire [511:0] l2_victim_line;
    wire [31:0] l2_victim_index;
    wire [511:0] l3_line;

    l2_cache l2 (
        .clk(clk),
        .rst_n(rst_n),
        .l2_initiated(l2_initiated),
        .b_dirty(b_dirty),
        .data_w(data_w),
        .index_w(index_w),
        .data_in_index(data_in_index),
        .state_in(state_in),
        .l3_completed(l3_completed),
        .l3_in(l3_line),
        .data_out(data_out),
        .completed_wb(),
        .next_state(next_state),
        .l3_write_from_l2(l3_write_from_l2),
        .l3_search_dirty(),
        .dataout_index(l2_read_index),
        .data_out_dirty_index(l2_victim_index),
        .data_out_dirty_line(l2_victim_line),
        .l2_acknowledged(l2_acknowledged),
        .l2_finished(l2_finished),
        .data_out_dirty(l2_victim_dirty),
        .dirt_acknowledged()
    );

    base_mem mem (
        .clk(clk),
        .rst_n(rst_n),
        .b_dirty(l2_victim_dirty),
        .data_dirty(l2_victim_line),
        .index_dirty(l2_victim_index),
        .index_w(l2_read_index),
        .data_out(l3_line),
        .dataout_index(),
        .l3_completed(l3_completed),
        .l3_finished_writing(),
        .l3_acknowledged()
    );
endmodule