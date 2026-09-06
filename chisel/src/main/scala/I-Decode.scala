import chisel3._
import chisel3.util._

class instruction_dec extends Module{
    val io = IO(new Bundle{
        val instr_code = Input(UInt(32.W))
        val rs1 = Output(UInt(5.W))
        val rs2 = Output(UInt(5.W))
        val funct_sev = Output(UInt(7.W))
        val rd = Output(UInt(5.W))
        val funct3 = Output(UInt(3.W))
        val opcode = Output(UInt(7.W))
        //val mode = Output(UInt(4.W))
        val imm = Output(UInt(32.W))
        val bsel = Output(UInt(1.W))
    })
    val imm_type = Wire(UInt(2.W))
    io.funct_sev := io.instr_code(31, 25)
    io.rs2 := io.instr_code(24, 20)
    io.rs1:= io.instr_code(19, 15)
    io.funct3 := io.instr_code(14, 12)
    io.rd := io.instr_code(11, 7)
    io.opcode := io.instr_code(6, 0)
    io.bsel := 0.U
    imm_type := 0.U
    switch(io.instr_code(6, 0)){
        is("b0010011".U){
            io.bsel := 1.U
            imm_type := 0.U
        }
        is("b0000011".U){
            io.bsel := 1.U
            imm_type := 1.U
        }
        is("b0100011".U){
            io.bsel := 1.U
            imm_type := 2.U
        }
        is("b1100011".U){
            io.bsel := 1.U
            imm_type := 3.U
        }
    }
    io.imm := 0.U
    switch(imm_type){
        is("b00".U){io.imm := io.instr_code(24, 14)}
        is("b01".U){io.imm := Cat(io.instr_code(24, 19), io.instr_code(4, 0))}
        is("b10".U){io.imm := Cat(Fill(21, io.instr_code(12)), io.instr_code(12), io.instr_code(0), io.instr_code(23, 19), io.instr_code(4, 1))}
        is("b11".U){io.imm := io.instr_code(24, 5)}
    }
}

class pipeline_reg extends Module{
    val io = IO(new Bundle{
        val clk = Input(Clock())
        val rd = Input(UInt(5.W))
        val mode = Input(UInt(4.W))
        val rs1val = Input(UInt(32.W))
        val rs2val = Input(UInt(32.W))
        val immval = Input(UInt(32.W))
        val bsel = Input(UInt(1.W))
        val storage_rd = Output(UInt(5.W))
        val storage_mode = Output(UInt(4.W))
        val storage_rs1val = Output(UInt(32.W))
        val storage_rs2val = Output(UInt(32.W))
        val storage_immval = Output(UInt(32.W))
        val storage_bsel = Output(UInt(1.W))
    })
    io.storage_rd := RegNext(io.rd)
    io.storage_mode := RegNext(io.mode)
    io.storage_rs1val := RegNext(io.rs1val)
    io.storage_rs2val := RegNext(io.rs2val)
    io.storage_immval := RegNext(io.immval)
    io.storage_bsel := RegNext(io.bsel)
}