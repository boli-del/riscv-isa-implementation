import chisel3._
import chisel3.simulator.EphemeralSimulator._
import org.scalatest.flatspec.AnyFlatSpec
import scala.util._
import synthetic_trace_gen.scala

class cache_custom_trace_eval(int numWays, int numSets, int blockSize, int numTraces_gen) extends AnyFlatSpec{
    it should "cold gen" in {
        simulate(new Cache(numWays, numSets, blockSize)){ dut =>
            Object trace_gen = new Trace_Generator()

            //fully cold generated cache traces
            val traces: Seq[(Long, Boolean)] = trace_gen.generate_trace(numTraces_gen, 32)
            val result: Vec[Int] 
            for i <- traces do{{
                var cycles_taken:Int = 0
                dut.io.w_enable.poke(i._2.asUInt)
                dut.io.location.poke(i._1.asUInt)
                while((dut.io.state.peekValue().asBigInt != sNot_Hit_Valid.litValue) || (dut.io.state.peekValue().asBigInt != sHit_and_return.litValue)){
                    cycles_taken = cycles_taken + 1
                    dut.io.stalled_inputloc.poke(dut.io.stalled_location.peekValue().asBigInt)
                    dut.io.stalled_input_wenable.poke(dut.io.stalled_wenable.peekValue().asBigInt)
                }}
            }
        }
    }
    it should "mild gen" in {
        simulate(new Cache)
    }
}