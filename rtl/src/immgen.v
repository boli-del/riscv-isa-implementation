module immgen(
    input [31:0] instr_code,
    input [1:0] mode,
    output [31:0] imm_gened
);
    always @(*) begin
        case (mode)
            // i-type instructions
            2b00: begin
                if(instr_code[31] == 1) begin
                    reg[11:0] imm = (~instr_code[31:20]) + 1;
                    imm_gened = {20b11111111111111111111, imm};
                end
                else begin
                    imm_gened = {20b00000000000000000000, imm};
                end
            end
        endcase
    end
endmodule