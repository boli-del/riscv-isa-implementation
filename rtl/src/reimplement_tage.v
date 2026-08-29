
module fold (
    input [63:0] global_hist,
    input clk,
    input rst_n,
    input [1:0] mode,
    input [7:0] width,
    output reg [63:0] folded_output
);
    reg [63:0] mask = 64'hffffffffffffffff;
    reg [63:0] base;
    reg [63:0] result = 0;
    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            folded_output <= 0;
        end
        else begin
            case (mode)
                2'b00: begin
                    base = global_hist;
                end
                2'b01: begin
                    base = global_hist & 32'h07ffffff;
                end
                2'b10: begin
                    base = global_hist & 32'h00000fff;
                end
                2'b11: begin
                    base = global_hist & 32'h0000001f;
                end
            endcase
            mask = ~(mask << width);
            while(base != 0) begin
                if(result == 0) begin
                    result = mask & base;
                end
                else begin
                    result = result ^ (mask & base);
                end
                base = base >> width;
            end
            folded_output = result;
        end
    end
endmodule