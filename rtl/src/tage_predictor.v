module base_predictor(
    input [63:0] branch_hist,
    output prediction
);
    assign prediction = branch_hist[0];
endmodule

module update(
    input taken,
    input [63:0] branch_hist,
    output [63:0] hist_update
);
    assign hist_update <= (branch_hist[62:0], taken);
endmodule

module encode(
    input [31:0] branch_location,
    output [31:0] tag
);
    assign tag = branch_location ^ 32hffffffff;
endmodule

module tage_main(
    input clk,
    input rst_n,
    input location[31:0],
    output prediction
);
    reg [3:0] confidence [31:0] [3:0];
    reg [3:0] usefulness [31:0] [3:0];
    reg [3:0] 4_b_hist [31:0];
    reg [7:0] 8_b_hist [31:0];
    reg [15:0] 16_b_hist [31:0];
    reg [31:0] 32_b_hist [31:0];
    reg [64:0] 64_b_hist [31:0];

    wire [31:0] tag;
    encode encoding(.branch_location(location), .tag(tag));
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prediction = 0;
        end
        else begin
            
        end
    end

endmodule