import chisel3._
import chisel3.simulator.EphemeralSimulator._
import org.scalatest.flatspec.AnyFlatSpec

class decodeSpec extends AnyFlatSpec{
    it should "decode r-type correctly" in {
        simulate(new instruction_dec){ dut =>
            dut.io.instr_code.poke("h006281b3".U)
            dut.clock.step(1)
            dut.io.rs1.expect("b00101".U)
            dut.io.rs2.expect("b00110".U)
            dut.io.rd.expect("b00011".U)
            dut.io.funct_sev.expect(0.U)
            dut.io.funct3.expect(0.U)
            dut.io.opcode.expect("b0110011".U)
        }
    }
    it should "decode i-type correctly" in{
        simulate(new instruction_dec){ dut =>
            dut.io.instr_code.poke("h01020193".U)
            dut.clock.step(1)
            dut.io.rs1.expect("b00100".U)
            dut.io.funct3.expect(0.U)
            dut.io.opcode.expect("b0010011".U)
            dut.io.imm.expect(16.U)
            dut.io.bsel.expect(1.U)
            dut.io.rd.expect("b00011".U)
        }
    }
    it should "decode s-type correctly" in{
        simulate(new instruction_dec){ dut =>
            dut.io.instr_code.poke("h418fa3a3".U)
            dut.clock.step(1)
            dut.io.rs1.expect(31.U)
            dut.io.rs2.expect(24.U)
            dut.io.funct3.expect(2.U)
            dut.io.opcode.expect("b0100011".U)
            dut.io.imm.expect(1031.U)
            dut.io.bsel.expect(1.U)
        }
    }
    it should "decode b-type correctly" in {
        simulate(new instruction_dec){ dut =>
            dut.io.instr_code.poke("h41bf8363".U)
            dut.clock.step(1)
            dut.io.rs1.expect(31.U)
            dut.io.rs2.expect(27.U)
            dut.io.funct3.expect(0.U)
            dut.io.opcode.expect("b1100011".U)
            dut.io.imm.expect(1030.U)
            dut.io.bsel.expect(1.U)
        }
    }
    it should "sign extend b-type correctly" in {
        simulate(new instruction_dec){ dut =>
            dut.io.instr_code.poke("hc1bf8363".U)
            dut.clock.step(1)
            dut.io.imm.expect("hfffff406".U)
        }
    }
    it should "decode l-type correctly" in {
        simulate(new instruction_dec){ dut =>
            dut.io.instr_code.poke("h039cad83".U)
            dut.clock.step(1)
            dut.io.rs1.expect(25.U)
            dut.io.rd.expect(27.U)
            dut.io.funct3.expect(2.U)
            dut.io.imm.expect(57.U)
            dut.io.bsel.expect(1.U)
            dut.io.opcode.expect(3.U)
        }
    }
    it should "decode j-type correctly" in {
        simulate(new instruction_dec){ dut =>
            dut.io.instr_code.poke("h40600def".U)
            dut.clock.step(1)
            dut.io.rd.expect(27.U)
            dut.io.imm.expect(1030.U)
        }
    }
}