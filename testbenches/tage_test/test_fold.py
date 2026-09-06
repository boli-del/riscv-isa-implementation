import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_folding(dut){
    clk = dut.Clock(dut.clk, 2, unit = 'ns')
    clk.start()
    await RisingEdge(dut.clk)
    await Timer(1.2, unit = 'ns')
    dut.rst_n.value = 1
    dut.global_hist.value = 0xffffffffffffffff
    dut.mode.value = 1
    dut.width.value = 10
    await RisingEdge(dut.clk)
    await Timer(0.2, unit = 'ns')
    assert dut.folded_output.value == 
}