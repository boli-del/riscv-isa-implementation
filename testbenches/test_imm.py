import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock

@cocotb.test()
async def test_i_positive(dut){
    clk = dut.Clock(dut.clk, 2, unit = 'ns')
    clk.start()
    await RisingEdge(dut.clk)
    await Timer(1.2, unit = 'ns')
}

@cocotb.test()
async def test_i_add(dut):
    clk = Clock(dut.clk, 2, unit = 'ns')
    clk.start()
    await Timer(1.2, unit = 'ns')
    op_code = 0x00A30293
    dut.rst_n.value = 1
    dut.pc.value = 0
    dut.instr_mem[0].value = op_code
    await RisingEdge(dut.clk)
    await Timer(0.2, unit = 'ns')
    assert(dut.inst_code.value == op_code)
    await RisingEdge(dut.clk)
    await Timer(0.2, unit = 'ns')
    assert(dut.rd.value == 5)
    assert(dut.rs1.value == 6)
    assert(dut.imm == 10)
    assert(dut.bsel == 0)
    await RisingEdge(dut.clk)
    await Timer(0.2, unit = 'ns')
    assert(dut.reg_file[5].value = 10)