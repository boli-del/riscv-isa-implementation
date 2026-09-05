import chisel3._
import chisel3.simulator.EphemeralSimulator._
import org.scalatest.flatspec.AnyFlatSpec

class ALUSpec extends AnyFlatSpec{
    it should "add correctly" in {
        simulate(new ALU){ dut =>
            dut.io.a.poke(3.U)
            dut.io.b.poke(4.U)
            dut.io.mode.poke(0.U)
            dut.clock.step(1)
            dut.io.Out.expect(7.U)
        }
    }
    it should "subtract correctly" in {
        simulate(new ALU){ dut =>
            dut.io.a.poke(4.U)
            dut.io.b.poke(3.U)
            dut.io.mode.poke(1.U)
            dut.clock.step(1)
            dut.io.Out.expect(1.U)    
        }
    }
    it should "xor correctly" in {
        simulate(new ALU){ dut =>
            dut.io.a.poke(1.U)
            dut.io.b.poke(0.U)
            dut.io.mode.poke(2.U)
            dut.clock.step(1)
            dut.io.Out.expect(1.U)
        }
    }
}