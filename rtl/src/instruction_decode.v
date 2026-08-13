//active low reset and instruction decode on every clock cycle
//so far only decode add instruction
//instruction structure and decode element needed, rs1, rs2, rd, and funct 3 and funct 7
//implementing r-type instructions
`timescale 1ns/1ps
module instruction_dec(
    input [31:0] instr_code,
    output [4:0] rs1,
    output [4:0] rs2,
    output [6:0] funct7,
    output [4:0] rd,
    output [2:0] funct3,
    output [6:0] opcode,
    output [3:0] mode,
    output [2:0] immsel,
    output bsel
);
    assign funct7 = instr_code [31:25];
    assign rs2 = instr_code [24:20];
    assign rs1 = instr_code [19:15];
    assign funct3 = instr_code[14:12];
    assign rd = instr_code[11:7];
    assign opcode = instr_code[6:0];
    det_r_alu_op det_op(instr_code[14:12], instr_code[31:25], mode);
endmodule

`timescale 1ns/1ps
module ID_pipeline_reg(
    input clk,
    input [4:0] rd,
    input [3:0] mode,
    input [31:0] rs1val,
    input [31:0] rs2val,
    output reg [4:0] storage_rd,
    output reg [3:0] storage_mode,
    output reg [31:0] storage_rs1val,
    output reg [31:0] storage_rs2val
);
    always @(posedge clk) begin
        storage_rd <= rd;
        storage_mode <= mode;
        storage_rs1val <= rs1val;
        storage_rs2val <= rs2val;
    end
endmodule

`timescale 1ns/1ps
module det_r_alu_op(
    input [2:0] funct3,
    input [6:0] funct7,
    input [6:0] opcode,
    output reg [3:0] alu_op_code
    output reg [2:0] immsel);

    task det_immsel;
        input [6:0] op_code;
        output [2:0] immsel_res;

        begin
            case(opcode)
                7'b0010011: immsel_res = 3'b000;
                7'b0000011: immsel_res = 3'b001;
                7'b0100011: immsel_res = 3'b010;
                7'b1100011: immsel_res = 3'b011;
                7'b1101111: immsel_res = 3'b100;
            endcase
        end
    endtask

    always @(*)begin
        det_immsel selct_imm(opcode, immsel);
        if(funct3 == 0)begin
            if(funct7 == 0) begin
                alu_op_code = 0;
            end
            else begin
                alu_op_code = 1;
            end
        end
        else if(funct3 == 4) begin
            alu_op_code = 2;
        end else if(funct3 == 6) begin
            alu_op_code = 3;
        end
        else if(funct3 == 7) begin
            alu_op_code = 4;
        end
        else if(funct3 == 1) begin
            alu_op_code = 5;
        end
        else if(funct3 == 5) begin
            if(funct7 == 0)
                alu_op_code = 6;
            else
                alu_op_code = 7;
        end
        else if(funct3 == 2) begin
            alu_op_code = 8;
        end
        else if(funct3 == 3) begin
            alu_op_code = 9;
        end
        else begin
            alu_op_code = 0;
        end
    end
endmodule;

`timescale 1ns/1ps
module register_file(
    input clk,
    input rst_n,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] wb,
    output [31:0] rs1val,
    output [31:0] rs2val
);
    reg [31:0] reg_collection [0:31];
    integer i;

    assign rs1val = reg_collection[rs1];
    assign rs2val = reg_collection[rs2];
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for (i = 0; i < 32; i = i + 1)
                reg_collection[i] <= 32'b0;
        end
        else if (rd != 5'd0) begin
            reg_collection[rd] <= wb;
        end
    end
endmodule