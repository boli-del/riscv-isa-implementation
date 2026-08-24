import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock

@cocotb.test()
async def test_i_positive(dut){
    clk = dut.Clock(dut.clk, 2, unit = 'ns')
    clk.start()
    await RisingEdge(dut.clk)
    dut.await Timer(1.2, unit = 'ns')
}