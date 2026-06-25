module tagless_predictor(
    input clk,
    input [1:0] update_value,
    input rst_n,
    input update_enabled,
    input [31:0] pc,
    output reg update_finished,
    output taken
);
    reg [1:0] confidence [31:0];
    taken <= confidence [pc];
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n)begin
            for(i = 0; i < 32; i = i+1) begin
                confidence[i] <= 2'b00;
            end
        end
        else begin
            if(update_enabled) begin
                confidence[pc] <= update_value;
            end
        end
    end
endmodule
    
module tag_generator_l1(
    input [31:0] pc,
    input [7:0] l1_hist,
    output [7:0] tag
);
    wire [7:0] extracted_bits [3:0]
    for(int i = 4; i > = 1; i = i - 1) begin
        wire [5:0] index_first = (i << 3) - 1;
        wire [5:0] index_second = (i-1) << 3; 
        extracted_bits [i-1] <= pc[index_first : index_second];
        extracted_bits [i-1] = extracted_bits [i-1] << (i-1);
    end
    tag = extracted_bits[0] ^ extracted_bits[1] ^ extracted_bits[2] ^ extracted_bits[3] ^ l1_hist;        
endmodule

module tag_generator_l2(
    input [31:0] pc,
    input [19:0] l2_hist,
    output [9:0] tag
);
    wire pc_folded = (pc[9:0] << 2) ^ (pc[19:10] << 1) ^ pc[29:20];
    wire hist_folded = (histoy[9:0] << 1) ^ history [19:10];
    tag = (pc_folded << 1) ^ hist_folded;
endmodule

module tag_generator_l3(
    input [31:0] pc,
    input [63:0] l3_hist,
    output [11:0] tag
);
    wire pc_folded = (pc[11:0] << 1) ^(pc[23:12]);
    wire hist_folded = (l3_hist[11:0] << 4) ^ (l3_hist[23:12] << 3) ^ (l3_hist[35:24] << 2) ^ (l3_hist[47:36] << 1) ^ l3_hist[59:48];
    tag = pc_folded ^ hist_folded;
endmodule

//hts
module l1_table(
    input clk,
    input write_enable_useful,
    input write_enable_ctr,
    input [1:0] ctr_w,
    input [1:0] useful_w,
    input [7:0] tag,
    output [1:0] ctr,
    output [1:0] useful
);
    reg [1:0] l1_ctr [7:0];
    reg [1:0] l1_use [7:0];
    assign ctr = l1_ctr[tag];
    assign useful = l1_use[tag];
    always @(posedge clk) begin
        if(write_enable_ctr) begin
            l1_ctr[tag] = ctr_w;
        end
        if(write_enable_useful) begin
            l1_use[tag] = useful_w;
        end
    end
endmodule

module l2_table(
    input clk,
    input write_enable_useful,
    input write_enable_ctr,
    input [1:0] ctr_w,
    input [1:0] useful_w,
    input [9:0] tag,
    output [1:0] ctr,
    output [1:0] useful
);
    reg [1:0] l1_ctr [9:0];
    reg [1:0] l1_use [9:0];
    assign ctr = l1_ctr[tag];
    assign useful = l1_use[tag];
    always @(posedge clk) begin
        if(write_enable_ctr) begin
            l1_ctr[tag] = ctr_w;
        end
        if(write_enable_useful) begin
            l1_use[tag] = useful_w;
        end
    end
endmodule

module l3_table(
    input clk,
    input write_enable_useful,
    input write_enable_ctr,
    input [1:0] ctr_w,
    input [1:0] useful_w,
    input [7:0] tag,
    output [1:0] ctr,
    output [1:0] useful
);
    reg [1:0] l1_ctr [7:0];
    reg [1:0] l1_use [7:0];
    assign ctr = l1_ctr[tag];
    assign useful = l1_use[tag];
    always @(posedge clk) begin
        if(write_enable_ctr) begin
            l1_ctr[tag] = ctr_w;
        end
        if(write_enable_useful) begin
            l1_use[tag] = useful_w;
        end
    end
endmodule

//let 1 denote provider
//1 means chosen provide, 0 means alt
module comparator(
    input [1:0] ctr1,
    input [1:0] ctr2,
    input [1:0] use1,
    input [1:0] use2,
    output chosen
);
    if(ctr1 <= 1 && use1 == 0) begin
        assign chosen = 0;
    end else begin
        assign chosen = 1;
    end
endmodule