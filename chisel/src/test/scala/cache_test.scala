import chisel3._
import chisel3.simulator.EphemeralSimulator._
import org.scalatest.flatspec.AnyFlatSpec

class CacheSpec extends AnyFlatSpec{
    import reg_refills.State
    import reg_refills.State._
    it should "fetch_stall correctly" in {
        simulate(new Cache(8, 8, 512)){ dut =>
            dut.io.w_enable.poke(0.U)
            dut.io.data_in.poke(0.U)
            dut.io.location.poke(32.U)
            dut.io.stalled_inputloc.poke(0.U)
            dut.io.stalled_input_wenable.poke(0.U)
            dut.io.replacement_incoming.poke(0.U)
            dut.clock.step(1)
            assert(dut.io.state.peekValue().asBigInt == sNot_Hit_Valid.litValue);           dut.io.replacement_incoming.poke(0.U)
            dut.clock.step(1)
            dut.io.replacement_incoming.poke(0.U)
            assert(dut.io.state.peekValue().asBigInt == sNot_Hit_Valid.litValue);
            dut.io.needs_replacement.expect(1.U)
        }
    }
    it should "replace correctly" in {
        simulate(new Cache(8, 8, 512)){ dut =>
            dut.io.w_enable.poke(0)
            dut.io.data_in.poke(0)
            dut.io.location.poke(56.U)
            dut.io.stalled_inputloc.poke(0.U)
            dut.io.stalled_input_wenable.poke(0.U)
            dut.io.replacement_incoming.poke(0.U)
            dut.clock.step(1)
            assert(dut.io.state.peekValue().asBigInt == sNot_Hit_Valid.litValue);
            dut.io.stalled_inputloc.poke(dut.io.stalled_location.peekValue().asBigInt)
            dut.io.stalled_input_wenable.poke(dut.io.stalled_wenable.peekValue().asBigInt)
            dut.clock.step(1)
            dut.io.replacement_incoming.poke(1.U)
            dut.io.stalled_inputloc.poke(dut.io.stalled_location.peekValue().asBigInt)
            dut.io.stalled_input_wenable.poke(dut.io.stalled_wenable.peekValue().asBigInt)
            dut.io.data_in.poke(1234.U)
            dut.io.location.poke(56.U)
            dut.clock.step(1)
            assert(dut.io.state.peekValue().asBigInt == sReplace.litValue);
            dut.io.location.poke(dut.io.stalled_inputloc.peekValue().asBigInt)
            dut.io.w_enable.poke(dut.io.stalled_input_wenable.peekValue().asBigInt)
            dut.clock.step(1)
            assert(dut.io.state.peekValue().asBigInt == sComplete_Stalled.litValue);
            dut.io.location.poke(dut.io.stalled_inputloc.peekValue().asBigInt)
            dut.io.w_enable.poke(dut.io.stalled_input_wenable.peekValue().asBigInt)
            dut.clock.step(1)
            assert(dut.io.state.peekValue().asBigInt == sSearch.litValue);
            dut.io.location.poke(dut.io.stalled_inputloc.peekValue().asBigInt)
            dut.io.w_enable.poke(dut.io.stalled_input_wenable.peekValue().asBigInt)
            dut.clock.step(1)
            assert(dut.io.state.peekValue().asBigInt == sHit_and_return.litValue);
            dut.io.location.poke(dut.io.stalled_inputloc.peekValue().asBigInt)
            dut.io.w_enable.poke(dut.io.stalled_input_wenable.peekValue().asBigInt)
            dut.clock.step(1)
            dut.io.data_out.expect(0.U)
        }
    }
}