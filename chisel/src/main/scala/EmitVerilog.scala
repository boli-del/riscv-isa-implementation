// src/main/scala/EmitVerilog.scala
import circt.stage.ChiselStage
import java.io.PrintWriter

object EmitVerilog extends App {
  val verilog = ChiselStage.emitSystemVerilog(new Cache(numWays = 4, numSets = 8, blockSize = 512))
  new PrintWriter("cache_4way_8set_512blk.sv") { write(verilog); close()}
}