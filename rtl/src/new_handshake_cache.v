module l1_cache(
    input clk,
    input rst_n,
    input w_enable,
    input data_ready,
    input l1_write_from_l2,
    input data_type [1:0],
    input [31:0] data_in,
    input [31:0] op_index,
    output [511:0] read_value,
    output [31:0] data_out,
    output finished_op,
    output start_l2,
    output [31:0] replacement_idx,
    output replacement_needed
);
    reg [511:0] l1_mem [3:0];
    reg [21:0] tag_bit [3:0];
    reg valid[3:0];
    wire tag = op_index [31:10];
    wire idx = op_index [9:6];
    wire offset = op_index[6:0];
    always (@posedge clk) begin
        if(data_ready) begin
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
            end
            else begin
                start_l2 <= 1;
                replacement_idx <= {tag_bit[idx], idx, 7b0000000};
                replacement_needed <= 1;
                read_value <= l1_mem[idx];
                finished_op <= 0;
            end
        end
    end
endmodule


