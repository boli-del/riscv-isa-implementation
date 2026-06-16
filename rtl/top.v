`timescale 1ns/1ps
module top_module(
    input clk,
    input rst_n
);
    wire [31:0] inst_code;
    reg  [31:0] pc; // program counter register (current instruction address)
    wire [31:0] new_pc; // next-PC value computed by the fetch unit (pc + 4) default
    wire [31:0] pc_if, inst_code_if;
    wire [31:0] rs1val, rs2val;
    wire [31:0] id_rs1al, id_rs2val;
    wire [4:0] rd, rs1, rs2;
    wire [4:0] id_rd, ex_rd;
    wire [6:0] funct7;
    wire [2:0] funct3;
    wire [6:0] opcode;
    wire [31:0] wb;
    wire [31:0] ex_wb;
    wire [3:0] mode;
    wire [3:0] id_mode;
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, top_module);
    end
    //pc, this is a pc which updates to the new_pc on all positive edges
    //not directly to +4 due to j and b type instructions.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pc <= 32'b0; //reset on active low rst_n
        else
            pc <= new_pc;
    end

    instruction_fetch IF (
        .pc(pc), .instr_code(inst_code), .new_pc(new_pc)
    );
    instruction_fetch_reg IF_R(
        .clk(clk), .pc(pc), .instr_code(inst_code), .stored_pc(pc_if), .stored_instr_code(inst_code_if)
    );
    instruction_dec ID (
        .instr_code(inst_code_if),  .rs1(rs1),  .rs2(rs2),
        .funct7(funct7), .rd(rd),
        .funct3(funct3), .opcode(opcode), .mode(mode)
    );

    register_file reg_f(
        .clk(clk),  .rst_n(rst_n),  .rs1(rs1),  .rs2(rs2),  .rd(ex_rd),    .rs1val(rs1val),    .rs2val(rs2val),    .wb(ex_wb)
    );

    ID_pipeline_reg reg_d(
        .clk(clk),  .rd(rd),    .mode(mode),    .rs1val(rs1val),    .rs2val(rs2val),    .storage_rd(id_rd),
        .storage_mode(id_mode), .storage_rs1val(id_rs1al),  .storage_rs2val(id_rs2val)
    );

    execute EX (
        .rs1(id_rs1al),   .rs2(id_rs2val),  .mode(id_mode), .out(wb)
    );

    ex_pipeline_reg ex_reg(
        .clk(clk),  .out(wb),   .rd(id_rd), .carried_out(ex_wb),    .carried_rd(ex_rd)
    );
endmodule