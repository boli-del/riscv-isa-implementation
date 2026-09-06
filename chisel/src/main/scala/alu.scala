import chisel3._
import chisel3.util._

class ALU extends Module{
    val io = IO(new Bundle{
        val a = Input(UInt(32.W))
        val b = Input(UInt(32.W))
        val mode = Input(UInt(4.W))
        val Out = Output(UInt(32.W))
    })
    io.Out := 0.U
    switch(io.mode) {
        is(0.U){io.Out := io.a + io.b}
        is(1.U){io.Out := io.a - io.b}
        is(2.U){io.Out := io.a ^ io.b}
        is(3.U){io.Out := io.a | io.b}
        is(4.U){io.Out := io.a & io.b}
        is(5.U){io.Out := (io.a.asUInt << io.b(4,0)).asUInt}
        is(6.U){io.Out := (io.a.asUInt >> io.b(4,0)).asUInt}
        is(7.U){io.Out := (io.a.asSInt >> io.b(4,0)).asUInt}
        is(8.U){io.Out := (io.a.asSInt < io.b.asSInt).asUInt}
        is(9.U){io.Out := (io.a.asUInt < io.b.asUInt).asUInt}
    }
}