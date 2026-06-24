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
    tag = extracted_bits[0] ^ extracted_bits[1] ^ extracted_bits[2] ^ extracted_bits[3];        
endmodule

module tag_generator_l2(
    input [31:0] pc,
    input [19:0] l2_hist,
    output [10:0] tag
);
    wire
endmodule