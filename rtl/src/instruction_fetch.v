//very custom instruction fetch module
module instruction_fetch(
    input [31:0] pc,
    output [31:0] instr_code,
    output [31:0] new_pc
);
    reg [31:0] instr_mem [0:31];
    assign instr_code = instr_mem[pc];
    //currently only support moving pc to 4 places after
    assign new_pc = pc + 4;
endmodule

module instruction_fetch_reg(
    input clk,
    input [31:0] pc,
    input [31:0] instr_code,
    output reg [31:0] stored_pc,
    output reg [31:0] stored_instr_code
);
    always @(posedge clk) begin
        stored_pc <= pc;
        stored_instr_code <= instr_code;
    end
endmodule