module l1_cache(
    input clk,
    input rst_n,
    input [1:0] state_in,
    input w_enable,
    input data_ready,
    input l1_write_from_l2,
    input data_type [1:0],
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
    output [1:0] next_state
);
    reg [511:0] l1_mem [3:0];
    reg [21:0] tag_bit [3:0];
    reg valid[3:0];
    wire [21:0] tag = op_index [31:10];
    wire [3:0] idx = op_index [9:6];
    wire [6:0] offset = op_index[6:0];
    always @(posedge clk) begin
        case (state_in)
            2b00: begin
                if(l2_received) begin
                    start_l2 <= 0;
                end
                if(l1_write_from_l2) begin
                    next_state <= 2b01;
                end
                else if(data_ready) begin
                    next_state <= 2b10;
                end
                else begin
                    next_state <= 2b00;
                end
            end
            2b10: begin
                if(valid[idx] && tag_bit[idx] == tag_bit) begin
                    if(w_enable) begin
                        case (data_type)
                            2b00: l1_mem[offset*4 + 3: offset*4] <= data_in [3;0];
                            2b01: l1_mem[offset*8+7: offset * 8] <= data_in [7:0];
                            2b10: l1_mem[offset*16 + 15: offset * 16] <= data_in [15:0];
                            2b11: l1_mem[offset*32 + 31: offset * 32] <= data_in;
                        endcase
                    end
                    else begin
                        case (data_type)
                            2b00: data_out[3:0] <= l1_mem[offset*4 + 3: offset*4];
                            2b01: data_out[7:0] <= l1_mem[offset*8+7: offset * 8];
                            2b10: data_out[15:0] <= l1_mem[offset*16 + 15: offset * 16];
                            2b11: data_out[31:0] <= l1_mem[offset*32 + 31: offset * 32];
                        endcase
                    end
                    finished_op <= 1;
                    start_l2 <= 0;
                    replacement_needed <= 0;
                    start_read_w <= 1;
                    next_state <= 2b10;
                end
                else begin
                    start_l2 <= 1;
                    replacement_idx <= {tag_bit[idx], idx, 7b0000000};
                    replacement_needed <= 1;
                    read_value <= l1_mem[idx];
                    finished_op <= 0;
                    start_read_w <= 0;
                    next_state <= 2b00;
                end
            end
            2b01: begin
                if
            end
        endcase
    end
endmodule

