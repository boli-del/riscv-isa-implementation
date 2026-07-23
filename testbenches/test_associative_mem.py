import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock
import logging
import random 
@cocotb.test()
async def test_l1_cache(dut):
    clk = Clock(dut.clk, 2, unit = 'ns')
    clk.start()
    await Timer(1.2, unit = 'ns')
    rst_n = dut.rst_n
    rst_n.value = 1
    mock_data = dut.data_in
    mock_data.value = 0b00100000000000000000000000000000
    state_in = dut.state_in
    state_in.value = 0b01
    startl2 = dut.l2_call
    index = dut.l2_fetch_index
    replacement = dut.replacement
    next_state= dut.next_state
    await RisingEdge(dut.clk)
    await Timer(0.2, unit = 'ns')
    assert(startl2.value == 1), "expected l2_cache to start fetching but didn't"
    #assert(index.value == 0b00100000000000000000000000000000), "expected index to be filled with index in but didn't invoke index fill"
    assert(next_state.value == 0b00), "expected cache to go on wait by instead got cache to a different state"
