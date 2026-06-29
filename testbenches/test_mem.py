import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock
import logging
import random

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
    
@cocotb.test()
async def test_l2_cache_no_dirty(dut):
    clk = Clock(dut.clk, 2, unit = "ns")
    clk.start()
    await Timer(1.2, unit = 'ns')
    dut.rst_n.value = 1
    dut.l2_initiated.value = 1
    dut.b_dirty.value = 0
    rand_value = random.getrandbits(512)
    dut.state_in.value = 0b01
    dut.data_in_index.value = 0
    dut.l2_mem[0].value = rand_value
    # data_in_index = 0 -> idx = 0, tag_in = 0; seed the matching tag so the
    # lookup hits and data_out is loaded from l2_mem[0] (rst never runs here,
    # so l2_tag would otherwise be X and the compare would miss)
    dut.l2_tag[0].value = 0
    await RisingEdge(dut.clk)
    await Timer(0.2, unit = 'ns')
    assert(dut.l3_write_from_l2.value == 0)
    assert(dut.l2_finished.value == 1)
    assert(dut.l3_search_dirty.value == 0)
    assert(dut.completed_wb.value == 0)
    assert(dut.next_state.value == 0b01)
    assert(dut.data_out.value == rand_value)

@cocotb.test()
async def run_test_with_stall_l2(dut):
    clk = Clock(dut.clk, 2, unit = "ns")
    clk.start()
    await Timer(1.2, unit = 'ns')
    dut.data_in_index.value = 0
    dut.rst_n.value = 1
    dut.l2_initiated.value = 1
    dut.b_dirty = 0
    dut.state_in.value = 0b01
    dut.data_in_index.value = 0
    dut.l2_tag[0] = 1
    await RisingEdge(dut.clk)
    dut.state_in.value = dut.next_state.value
    dut.l3_completed.value = dut.completed_wb
    await RisingEdge(dut.clk)
    assert (dut.next_state.value == 0)

@cocotb.test()
async def run_test_with_replace_l2(dut):
    clk = Clock(dut.clk, period = 2, unit = 'ns')
    clk.start()
    await Timer(1.2, unit = 'ns')
    dut.rst_n.value = 1
    dut.l2_initiated.value = 1
    dut.b_dirty = 1
    dut.state_in.value = 0b01
    dut.data_w.value = 1
    dut.index_w = 0
    data_in_index = 520
    await(RisingEdge, dut.clk)
    await Timer(0.2, unit = 'ns')
    assert(dut.next_state == 0b11)
