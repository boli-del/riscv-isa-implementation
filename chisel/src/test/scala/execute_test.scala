import chisel3._
import chisel3.simulator.EphemeralSimulator._
import org.scalatest.flatspec.AnyFlatSpec

class ExSpec extends AnyFlatSpec{
    it should "select values correctly" in {
        simulate(new execute_pipeline){ dut =>
            dut.io.alu_sel.poke(0.U)
            dut.io.a_sel.poke(1.U)
            dut.io.b_sel.poke(0.U)
            dut.io.rs1_val.poke(4.U)
            dut.io.rs2_val.poke(3.U)
            dut.io.imm.poke(32.U)
            dut.clock.step(1)
            dut.io.produced_val.expect(36.U)
        }
    }
}