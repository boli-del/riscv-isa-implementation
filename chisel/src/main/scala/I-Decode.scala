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
    io.funct_sev := io.instr_code(31, 25)
    io.rs2 := io.instr_code(24, 20)
    io.rs1:= io.instr_code(19, 15)
    io.funct3 := io.instr_code(14, 12)
    io.rd := io.instr_code(11, 7)
    io.opcode := io.instr_code(6, 0)
    io.bsel := 0.U
    switch(io.instr_code(6, 0)){
        is("b0010011".U){ io.bsel := 1.U }
        is("b0000011".U){ io.bsel := 1.U }
        is("b0100011".U){ io.bsel := 1.U }
        is("b1100011".U){ io.bsel := 1.U }
        is("b1101111".U){ io.bsel := 1.U }
    }
    io.imm := MuxLookup(io.instr_code(6, 0), 0.U)(Seq(
        "b0010011".U -> io.instr_code(31, 20),
        "b0000011".U -> io.instr_code(31, 20),
        "b0100011".U -> Cat(io.instr_code(31, 25), io.instr_code(11, 7)),
        "b1100011".U -> Cat(Fill(19, io.instr_code(31)), io.instr_code(31), io.instr_code(7), io.instr_code(30, 25), io.instr_code(11, 8), 0.U),
        "b1101111".U -> Cat(Fill(11, io.instr_code(31)), io.instr_code(31), io.instr_code(19, 12), io.instr_code(20), io.instr_code(30, 21), 0.U),
    ))
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

class Instruction_dec_Top extends Module{
    val io = IO(new Bundle{
        val instr_code = Input(UInt(32.W))
        val w_back = Input(UInt(32.W))
        val rd = Input(UInt(32.W))
        val W_enable = Input(UInt(1.W))
        val rs1_val = Output(UInt(32.W))
        val rs2_val = Output(UInt(32.W))
        val b_sel = Output(UInt(1.W))
        val immval = Output(UInt(32.W))
    })
    val dec = Module(new instruction_dec);
    dec.io.instr_code := io.instr_code
    io.immval := dec.io.imm
    io.b_sel := dec.io.bsel
    val reg_f = Module(new register_file);
    reg_f.io.rs1val := dec.io.rs1
    reg_f.io.rs2val := dec.io.rs2
    reg_f.io.w_enable := io.W_enable
    reg_f.io.rd := io.rd
    reg_f.io.rd_write := io.w_back
    io.rs1_val := reg_f.io.rs1_out
    io.rs2_val := reg_f.io.rs2_out
}