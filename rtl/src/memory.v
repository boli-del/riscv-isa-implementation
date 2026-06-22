// the below file will also experiment between different implementation of different styles of caches
// each of these cache blocks would be 64 bytes
// each register is 4 bytes
// direct mapped cache: offset = 6-bits (byte addressable data)


// L1 direct-mapped cache
// and then we have 4 bit index
// 32 - 10 = 22 bit tag

module L1_cache(
    input clk,
    input [31:0] luindex,
    input [31:0] stor_index,
    input [31:0] stor_data_in,
    input w_enable,
    output [31:0] stor_data_out,
    output [31:0] data_replacement_idx,
    output [512:0] data_replacement,
    output data_rep_w_enable
);
    //512 bit data storage (64 bytes)
    reg [511:0] data [3:0];
    //each has a 22 bit tag that needs to be accessed
    reg [21:0] tag [3:0];
    //now I need to map a valid bit in:
    reg valid [3:0];
    wire [21:0] tag_extr = luindex[31:10];
    wire [3:0] idx = luindex[9:6];
    wire [5:0] offset = luindex[5:0];
    always @(posedge clk) begin
        if (w_enable) begin
            if(valid[idx]) begin
                if(tag[idx] == tag_extr) begin
                    data[idx] = tag;
                end else begin
                    data_rep_w_enable <= 1;
                end
            end
        end
    end
endmodule


module L2_cache(
    input clk,
    input w_enable,
    input replacement_needed,
    input [512:0] data_in,
    input [31:0] idx,
    output reg [512:0] data_out,
    output data_replacement,
    output [31:0] data_replacement_idx,
    output data_replacement_w_enable,
    output data_out_en
);
    reg [511:0] data [6:0];  //larger cache than l1, 8x more data here
    reg [18:0] index [6:0];
    wire [6:0] idx_l2 = idx [12:6];
    wire [18:0] tag_l2 = idx[31:13];
    always @(posedge clk) begin
        if(replacement_needed) begin
            if(index[idx_l2] == tag_l2) begin
                data_out <= data[idx_l2];
                data_out_en <= 1;
            end
            else begin
                data_replacement_idx <= idx;
                if(w_enable) begin
                    data_replacement_w_enable <= 1;
                end
            end
        end
    end 
endmodule


// base memory is a 4 gb memory storage
module base_memory(
    input clk,
    input [511:0] w_data,
    input [31:0] index,
    input w_enable,
    input mem_hi_up,
    output reg [511:0] data_out,
    output reg [31:0] data_index,
    output reg data_w_up
);
    reg [511:0] base_memory [8:0];
    reg [16:0] tag_base[8:0];
    wire idx[8:0] = index[14:6];
    wire tag[16:0] = index[31:15];
    always @(posedge clk) begin
        if(w_enable) begin
            base_memory[idx] <= w_data;
            data_w_up <= 0;
        end
        if(mem_hi_up) begin
            data_out <= base_memory[idx];
            data_index <= index;
            data_w_up <= 1;
        end
    end
endmodule