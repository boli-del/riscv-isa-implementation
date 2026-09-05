import chisel3._
import chisel3.util._

class instruction_dec extends Module{
    val io = IO(new Bundle{
        val instr_code = Input(UInt(32.W))
        val rs1 = Input(UInt(5.W))
        val rs2 = Input(UInt(5.W))
        val funct_sev = Input(UInt(7.W))
        val rd = Output(UInt(5.W))
        val funct3 = Output(UInt(3.W))
        val opcode = Output(UInt(7.W))
        val mode = Output(UInt(4.W))
        val imm = Output(UInt(32.W))
        val bsel = Output(Bool)
    })
    io.funct_sev := io.instr_code(31:25)
    io.rs2 := io.instr_code(24:20)
    io.rs1:= io.instr_code(19:15)
    io.funct3 := io.instr_code(14:12)
    io.rd := io.instr_code(11:7)
    io.opcode := io.instr_code(6:0)
    switch(io.instr_code(6:0)){
        is("b0010011".U){
            io.bsel := 1.U
            io.mode := 0.U
        }
        is("b0000011".U){
            io.bsel := 1.U
            io.mode := 1.U
        }
        is("b0100011".U){
            io.bsel := 1.U
            io.mode := 2.U
        }
        is("b1100011".U){
            io.bsel = 1.U
            io.mode = 3.U
        }
    }
}

class pipeline_reg extends Module{
    
}