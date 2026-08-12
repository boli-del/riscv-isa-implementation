module branch_hist(
    input clk,
    input latest_taken,
    input write_enable,
    output [7:0] l1_hist_o,
    output [19:0] l2_hist_o,
    output [63:0] l3_hist_o
);
    reg [7:0] l1_hist;
    reg [19:0] l2_hist;
    reg [63:0] l3_hist;
    assign l1_hist_o = l1_hist;
    assign l2_hist_o = l2_hist;
    assign l3_hist_o = l3_hist;
    always @(posedge clk) begin
        if(write_enable) begin
            l1_hist <= (l1_hist << 1)|latest_taken;
            l2_hist <= (l2_hist << 1)|latest_taken;
            l3_hist <= (l3_hist << 1)|latest_taken;
        end
    end
endmodule