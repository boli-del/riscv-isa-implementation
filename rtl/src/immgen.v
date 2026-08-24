module immgen(
    input [24:0] instr_need,
    input [2:0] immsel,
    output [31:0] imm
);
    always @(*) begin
        case(immsel)
            3'b000: begin
                imm = instr_need[24:14];
            end
            3'b001: begin
                imm = {instr_need[24:19], instr_need[4:0]}; 
            end
            3'b010: begin
                imm = {instr_need[12], instr_need[0], instr_need[23:19], instr_need[4:1]};
            end
            3'b011: begin
                imm = instr_need[24:5];
            end
            3'b100: begin
                imm = {instr_need[24], instr_need[12:5], instr_need[13], instr_need[23:14]};
            end
        endcase
    end
endmodule;

module 2_b_mux(
    input [31:0] a,
    input [31:0] b,
    input m_sel,
    output [31:0] chosen
);
    always @(*) begin
        if(m_sel) begin
            chosen = a;
        end else begin
            chosen = b;
        end
    end
endmodule;