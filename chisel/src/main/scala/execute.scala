import chisel3._
import chisel3.util._

class execute_pipeline extends Module{
    val io = IO(new Bundle{
        val alu_sel = Input(UInt(32.W))
        val a_sel = Input(UInt(1.W))
        val b_sel = Input(UInt(1.W))
        val pc = Input(UInt(32.W))
        val imm = Input(UInt(32.W))
        val rs1_val = Input(UInt(32.W))
        val rs2_val = Input(UInt(32.W))
        val imm_sel = Input(UInt(4.W))
        val produced_val = Output(UInt(32.W))
    })
    val a_val = RegInit(0.U(32.W))
    val b_val = RegInit(0.U(32.W))
    val alu = Module(new ALU);
    when(io.a_sel === 1.U){
        a_val := io.rs1_val
    }otherwise{
        a_val := io.pc
    }
    when(io.b_sel === 1.U){
        b_val := io.rs2_val
    }otherwise{
        b_val := io.imm
    }
    alu.io.a := a_val
    alu.io.b := b_val
    alu.io.mode := io.imm_sel
    io.produced_val := alu.io.Out
}

class ex_pipeline_reg extends Module{
    val io = IO(new Bundle{
        val ex_result = Input(UInt(32.W))
        val rd = Input(UInt(5.W))
        val rd_new = Output(UInt(32.W))
        val ex_result_new = Output(UInt(32.W))
    })
    val ex_result_new = RegNext(io.ex_result)
    val rd_new = RegNext(io.rd)
}