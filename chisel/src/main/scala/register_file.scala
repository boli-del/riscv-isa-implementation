import chisel3._
import chisel3.util._

class register_file extends Module{
    val io = IO(new Bundle{
        val rs1val = Input(UInt(5.W))
        val rs2val = Input(UInt(5.W))
        val rd = Input(UInt(5.W))
        val rd_write = Input(UInt(32.W))
        val w_enable = Input(UInt(1.W))
        val rs1_out = Output(UInt(32.W))
        val rs2_out = Output(UInt(32.W))
    })
    val reg_collection = RegInit(Vec(32, UInt(32.W)))
    io.rs1_out := reg_collection(io.rs1val)
    io.rs2_out := reg_collection(io.rs2val)
    when (io.w_enable === 1.U){
        reg_collection(io.rd) := io.rd_write
    }
}