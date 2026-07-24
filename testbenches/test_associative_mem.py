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