import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock
import logging

@cocotb.test()
async def test_sub(dut):
    Clock(dut.clk, 2, unit = 'ns').start()  # starting the clock up
    await Timer(1.2, unit = 'ns') # wait out first rising edge for stability
    fake_op = 0b01000000000100010000000110110011
    inst_loc = dut.IF.instr_mem[0]
    inst_loc.value = fake_op
    dut.pc.value = 0
    dut.rst_n.value = 1
    reg_collec = dut.reg_f.reg_collection
    reg_collec[1].value = 5
    reg_collec[2].value = 8
    #fetch stage
    await RisingEdge(dut.clk)
    await Timer(0.5, unit = 'ns')
    print(dut.inst_code_if.value)
    assert(dut.inst_code_if.value == fake_op)
    #decode stage
    await RisingEdge(dut.clk)
    await Timer(0.5, unit = 'ns')
    print(dut.id_rs1al.value)
    print(dut.id_rs2val.value)
    assert(dut.id_rs1al.value == 8)
    assert(dut.id_rs2val.value == 5)
    await RisingEdge(dut.clk)
    await Timer(0.5, unit = 'ns')
    assert(dut.ex_wb.value == 3)

