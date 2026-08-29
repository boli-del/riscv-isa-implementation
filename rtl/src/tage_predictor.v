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
    reg [3:0] confidence [31:0] [1:0];
    reg [3:0] usefulness [31:0] [1:0];
    reg [3:0] 4_b_hist [31:0];
    reg [7:0] 8_b_hist [31:0];
    reg [15:0] 16_b_hist [31:0];
    reg [31:0] 32_b_hist [31:0];
    reg [63:0] 64_b_hist [31:0];
    reg[63:0] recent_hist;
    wire [31:0] tag;

    task is_new;
        input [31:0] input_location;
        input [1:0] mode;
        output new;
        begin
            if(confidence[input_location][mode] == 0) begin
                new = 1;
            end else begin
                new = 0;
            end
        end
    endtask

    task indexfold;
        input [1:0] mode;
        input [5:0] folded_length;
        output [63:0] folded_tag;
        reg [63:0] folded_output;
        reg [63:0] folded;
        begin
            reg [63:0] mask = 0xffffffffffffffff;
            reg [63:0] second_mask = 0xffffffffffffffff;
            wire [5:0] shifting = 64 - width;
            second_mask = second_mask >> shifting;
            case(mode)
                2'b00 : begin
                    mask <= mask >> 56;
                    folded_output <= recent_hist & mask;
                end
                2'b01 : begin
                    mask <= mask >> 48;
                    folded_output <= recent_hist & mask;
                end
                2'b10 : begin
                    mask <= mask >> 32;
                    folded_output <= recent_hist & mask;
                end
                2'b00 : begin
                    folded_output <= recent_hist;
                end
            endcase
            while(folded_output != 0) begin
                folded = second_mask & folded_output;
                folded_output >> width;
            end
            folded_tag = folded_output;
        end
    endtask
    encode encoding(.branch_location(location), .tag(tag));
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prediction = 0;
        end
        else begin
            
        end
    end

endmodule


module comparator(
    input [8:0] hashed_val
);
endmodule