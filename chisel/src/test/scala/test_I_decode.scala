import chisel3._
import chisel3.simulator.EphemeralSimulator._
import org.scalatest.flatspec.AnyFlatSpec

class decodeSpec extends AnyFlatSpec{
    it should "decode r-type correctly" in {
        simulate(new instruction_dec){ dut =>
            dut.io.instr_code.poke("h006281b2".U)
            dut.clock.step(1)
            dut.io.rs1.expect("b00101".U)
            dut.io.rs2.expect("b00110".U)
            dut.io.rd.expect("b00011".U)
            dut.io.funct_sev.expect(0.U)
            dut.io.funct3.expect(0.U)
            dut.io.opcode.expect("b0110011".U)
        }
    }
}