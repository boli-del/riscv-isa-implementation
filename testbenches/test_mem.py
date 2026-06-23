import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock
import logging

@cocotb.test()
async def test_l1_cache(dut):
    clk = Clock(dut.clk, 2, unit = "ns")
    clk.start()
    await Timer(1.2, unit = 'ns')
    rst_n = dut.rst_n
    rst_n.value = 1
    mock_data = dut.data_in
    mock_data.value = 0b00100000000000000000000000000000
    state_in = dut.state_in
    state_in.value = 0b10
    startl2 = dut.start_l2
    finished_op = dut.finished_op
    start_read_w = dut.start_read_w
    next_state = dut.next_state
    await RisingEdge(dut.clk)
    await Timer(0.2, unit = 'ns')
    assert (startl2.value == 1), "expected l2_cache to start fetching but didn't"
    assert (finished_op.value == 0), "expected op to not be finished but got finished otherwise"
    assert (start_read_w.value == 0), "expected no l2_cache return finished and start_read_w to be 0, but got 1 otherwise"
    assert(next_state.value == 0b00), "expected the l1_cache to be stuck on stalling state but changed state otherwise"
    

