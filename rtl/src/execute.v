module ALU(
    input [31:0] a,
    input [31:0] b,
    input [3:0] mode,
    output reg [31:0] o
);
    always @(*) begin
        case(mode)
            4'b0000: o <= a + b;
            4'b0001: o <= a - b;
            4'b0010: o <= a ^ b;
            4'b0011: o <= a | b;
            4'b0100: o <= a & b;
            4'b0101: o <= a << b;
            4'b0110: o <= a >> b;
            4'b0111: o <= a >>> b;
            4'b1000: slt(a, b, o);
            4'b1001: sltu(a, b, o);
            default: o = a + b;
        endcase
    end
    task slt;
        input [31:0] a;
        input [31:0] b;
        output reg [31:0] c;
        begin
            if(a < b)begin
                c = 1;
            end
            else begin
                c = 0;
            end
        end
    endtask

    task sltu; 
        input [31:0] a;
        input [31:0] b;
        output reg [31:0] c;
        begin : sltu_blk
            reg[31:0] intm_a, intm_b;
            abs(a, intm_a);
            abs(b, intm_b);
            if(intm_a < intm_b) begin
                c = 1;
            end
            else begin
                c = 0;
            end
        end
    endtask

    task abs;
        input [31:0] a;
        output [31:0] out;
        begin
            if(a[31] == 1) begin
                out = (~a) + 1;
            end
            else begin
                out = a;
            end
        end
    endtask
endmodule



module execute(
    input [31:0] rs1,
    input [31:0] rs2,
    input [3:0] mode,
    output [31:0] out
);
    ALU calc(rs1, rs2, mode, out);
endmodule

module ex_pipeline_reg(
    input clk,
    input [31:0] out,
    input [4:0] rd,
    output reg [31:0] carried_out,
    output reg [4:0] carried_rd
);
    always @(posedge clk) begin
        carried_out <= out;
        carried_rd <= rd;
    end
endmodule