// the below file will also experiment between different implementation of different styles of caches
// each of these cache blocks would be 64 bytes
// each register is 4 bytes
// direct mapped cache: offset = 6-bits (byte addressable data)


// L1 direct-mapped cache
// and then we have 4 bit index
// 32 - 10 = 22 bit tag

module L1_cache(
    input [31:0] luindex,
    input [31:0] stor_index,
    input [31:0] stor_data_in,
    input w_enable,
    output [31:0] stor_data_out
);
    //512 bit data storage (64 bytes)
    reg [511:0] data [15:0];
    //each has a 22 bit tag that needs to be accessed
    reg [21:0] tag [15:0];
    //now I need to map a valid bit in:
    reg [15:0] valid [15:0];
    wire [21:0] tag_extr = luindex[31:10];
    wire [3:0] idx = luindex[9:6];
    wire [5:0] offset = luindex[5:0];

    //implementation of least recently used policy
    reg [3:0] LRU [15:0];
    always @(*) begin
        if (w_enable) begin
            if(tag[idx] == tag_extr) begin
                data[idx] = tag;
                for(i = 0; i < 16; i = i +1) begin
                    LRU [i] = LRU [i] + 1;
                end
                LRU [idx] = 0;
            end else begin
                det_most_used 
                L2_cache()
            end
        end
    end
endmodule

module L2_cache(
    input clk,
    input [31:0] w_data,
    input [31:0] index,
    input w_enable,
    input mem_hi_up,
    output [511:0] mem_hi_up_result
);
    reg []
endmodule


// base memory is a 4 gb memory storage
module base_memory(
    input clk,
    input [31:0] w_data,
    input [31:0] index,
    input w_enable,
    input mem_hi_up,
    output [31:0] data_read,
    output [31:0] data_index,
    output [511:0] mem_hi
);
    reg [7:0] mem [31:0];
    always @(posedge clk) begin
        if(mem_hi_up) begin
            for(i = index; i < index + 64; i = i + 1) begin
                mem_hi[((i-index)*8) : (((i - index)*8) + 7)];
            end
        end
        if(w_enable) begin
            mem[index] <= w_data[7:0];
            mem[index + 1] <= w_data[15:8];
            mem[index + 2] <= w_data[23:16];
            mem[index + 3] <= w_data[31:24];
        end
        else begin
            data_read <= {mem[index+3], mem[index+2], mem[index+1], mem[index]};
        end
    end
endmodule