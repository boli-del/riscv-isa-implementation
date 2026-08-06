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

@cocotb.test()
async def test_l1_read(dut):
    clk = Clock(dut.clk, 2, unit = 'ns')
    clk.start()
    await Timer(1.2, unit = 'ns')
    rst_n = dut.rst_n
    rst_n.value = 1
    mock_data = dut.location
    mock_data.value = 0b00100000000000000000000000000000
    state_in = dut.state_in
    dut.valid[0].value = 1
    state_in.value = 0b01
    dut.w_enable.value = 0;
    dut.first_mem[0].value = 0xA000000F_A000000E_A000000D_A000000C_A000000B_A000000A_A0000009_A0000008_A0000007_A0000006_A0000005_A0000004_A0000003_A0000002_A0000001_A0000000
    dut.tag[0].value = 0b00100000000000000000000000
    await RisingEdge(dut.clk)
    await Timer(0.2, unit = 'ns')
    assert(dut.data_out.value == 0xA0000000), "wrong expected value for data read"

@cocotb.test()
async def test_l1_write(dut):
    clk = Clock(dut.clk, 2, unit = 'ns')
    clk.start()
    await Timer(1.2, unit = 'ns')
    dut.rst_n.value = 1
    dut.location.value = 0b00100000000000000000000000000000
    state_in = dut.state_in
    dut.valid[0].value = 1
    state_in.value = 0b01
    dut.used_locality[0].value = 2
    dut.w_enable.value = 1
    dut.first_mem[0].value = 0xA000000F_A000000E_A000000D_A000000C_A000000B_A000000A_A0000009_A0000008_A0000007_A0000006_A0000005_A0000004_A0000003_A0000002_A0000001_A0000000
    dut.tag[0].value = 0b00100000000000000000000000
    dut.data_in.value = 0xFEDCBA98
    dut.dirty[0].value = 0
    await RisingEdge(dut.clk)
    await Timer(0.2, unit = 'ns')
    assert(dut.dirty[0].value == 1), "dirty bit did not get set despite getting changed"
    assert(dut.used_locality[0].value == 0), "locality did not reset despite getting written to"
    assert(dut.first_mem[0].value == 0xA000000F_A000000E_A000000D_A000000C_A000000B_A000000A_A0000009_A0000008_A0000007_A0000006_A0000005_A0000004_A0000003_A0000002_A0000001_FEDCBA98)

@cocotb.test()
async def test_l2_read(dut):
    clk = Clock(dut.clk, 2, unit = 'ns')
    clk.start()
    await Timer(1.2, unit = 'ns')
    dut.rst_n.value = 1
    dut.l2_mem[0].value = 1
    dut.l2_tag[0].value = 1 << 24
    dut.dirty[0].value = 0
    dut.valid[0].value = 1
    dut.used_locality[0].value = 16
    dut.l2_initiated.value = 1
    dut.state_in.value = 0b01
    dut.b_dirty.value = 0
    dut.data_in_index.value = 0b01<<30
    await RisingEdge(dut.clk)
    # first rising edge, we should expect first round of outputs
    await Timer(0.2, unit = 'ns')
    assert dut.l2_acknowledged == 1, "l2 task was ran without acknowledgement"
    assert dut.l3_write_from_l2.value == 0, "write_enable is not acknowledged"
    assert dut.dataout_index.value == 0b01 << 30, "inconsistent data in with inconsistent data out"
    assert dut.completed_wb == 0, "inconsistent writeback value"
    assert dut.next_state == 0b01, "output state did not reset"
    assert dut.dirt_acknowledged == 0, "dirt is acknowledged despite no dirty bit set"
    assert dut.used_locality[0].value == 0, "information pulled but locality not reset"

@cocotb.test()
async def test_l2_write(dut):
    clk = Clock(dut.clk, 2, unit = 'ns')
    clk.start()
    await Timer(1.2, unit = 'ns')
    dut.rst_n.value = 1
    dut.l2_mem[0].value = 1
    dut.l2_tag[0].value = 1 << 24
    dut.dirty[0].value = 0
    dut.valid[0].value = 1
    dut.l2_initiated.value = 1
    dut.used_locality[0].value = 16
    dut.state_in.value = 0b01
    dut.b_dirty.value = 0
    dut.index_w.value = 0b01<<30
    dut.data_w.value = 0xA000000F_A000000E_A000000D_A000000C_A000000B_A000000A_A0000009_A0000008_A0000007_A0000006_A0000005_A0000004_A0000003_A0000002_A0000001_FEDCBA98
    await RisingEdge(dut.clk)
    await Timer(0.2, unit = 'ns')
    assert dut.next_state.value == 0b11, "not in writing state despite w_enable is on"
    assert dut.l2_finished.value == 0, "process finished despite write back not happened"
    dut.rst_n.value = 1
    dut.l2_mem[0].value = 1
    dut.l2_tag[0].value = 1 << 24
    dut.dirty[0].value = 0
    dut.valid[0].value = 1
    dut.l2_initiated.value = 1
    dut.used_locality[0].value = 16
    dut.state_in.value = 0b11
    dut.b_dirty.value = 0
    dut.index_w.value = 0b01<<30
    dut.data_w.vlaue = 0xA000000F_A000000E_A000000D_A000000C_A000000B_A000000A_A0000009_A0000008_A0000007_A0000006_A0000005_A0000004_A0000003_A0000002_A0000001_FEDCBA98
    await RisingEdge(dut.clk)
    await Timer(0.2, unit = 'ns')
    assert dut.l2_mem[0].value == 0xA000000F_A000000E_A000000D_A000000C_A000000B_A000000A_A0000009_A0000008_A0000007_A0000006_A0000005_A0000004_A0000003_A0000002_A0000001_FEDCBA98, "memory value did not update"
    assert dut.dirty[0].value == 1, "dirty value did not update even though data was written"
    assert dut.l2_acknowledged.value == 0, "acknowledgement not reset even when the request was processed"
    assert dut.next_state.value == 0b01, ""
    assert dut.dirt_acknowledged.value == 1
    assert dut.
