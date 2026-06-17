import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock
import logging


#@cocotb.test()
# a test for active low resetting
'''async def test_rst_n(dut):
    logger = logging.getLogger("test_bench")
    logger.info("This test aims to test the reset function within the current stages and whether each pipeline of the current stage would produce an empty output")
    rst_n = dut.rst_n  #get the reset signal from the original top level files
    rst_n.value = 1
    # wait for registers and signal stability
    Clock(dut.clk, 2, unit = 'ns').start()
    await Timer(2, unit = 'ns')
    rst_n.value = 0 #we set the rst_n value to be low for active low reset
    await Timer(2, unit = 'ns')
    inst_code = dut.inst_code
    funct_sev = dut.funct7
    funct_thr = dut.funct3
    rs_two = dut.rs2
    rs_one = dut.rs1
    rd = dut.rd
    opcode = dut.opcode
    wb = dut.wb
    logger.debug("Debugging reset behavior for IF ID and EX")
    assert(inst_code.value == 0), f"inst_code value did not reset upon active low reset, expected inst code value 0 but instead got {inst_code.value}, error persists in instruction fetch"
    assert(funct_sev.value == 0 and funct_thr.value == 0 and rs_two.value == 0 and rs_one.value == 0 and rd.value == 0 and opcode.value == 0), f"instruction decode info was not resetted upon active low reset, expected all code values of 0, check the value for instruction fetch"
'''
@cocotb.test()
async def test_instruction_fetch(dut):
    # this test aims to test the instruction fetch
    logger = logging.getLogger("test_bench") # corectly get the logger
    Clock(dut.clk, period = 2, unit = 'ns').start() # starting clock
    rst_n = dut.rst_n
    rst_n.value = 1
    await Timer(1, unit= 'ns') # wait for stability
    fake_opcode = 0b00000001010100101000100100110011
    # here we assign pc = 0 to indicate starting the code with my program counter at the 0 position
    pc = dut.pc # grep the program counter from our code into a variable
    # we set every value here
    pc.value = 0  # assign start of program counter
    logger.info(f'setting correct value for custom opcode,cc pc set to 0, reg_collection')
    dut.IF.instr_mem[0].value = fake_opcode
    dut.IF.instr_mem[4].value = 0b01000000101101010101001010110011
    await Timer(0.1, unit = 'ns') # waiting for the symbol to stabilize and output
    assert(dut.inst_code.value == fake_opcode), f'failed test_instruction_fetch, expected output for inst_code {fake_opcode} but got {inst_code.value} instead'
    # wait for the next rising edge here
    logger.info('waiting for the next rising edge for the pipeline stages to trigger collectively')
    await RisingEdge(dut.clk)
    logger.info('waiting for stability')
    await Timer(0.1, unit = 'ns') # waiting for the symbol to stabilize and output
    assert(dut.inst_code.value == 0b01000000101101010101001010110011), f'failed test_instruction_fetch, expected output for inst_code {fake_opcode} but got {inst_code.value} instead'
    
@cocotb.test()
async def test_ex(dut):
    Clock(dut.clk, period = 2, unit= 'ns').start() #clock starting
    rst_n = dut.rst_n
    rst_n.value = 1
    pc = dut.pc
    pc.value = 0
    instr_mem = dut.IF.instr_mem
    instr_mem[0].value = 0b00000001000110000000001010110011
    reg_collec = dut.reg_f.reg_collection
    reg_collec[16].value = 1
    reg_collec[17].value = 2
    out = dut.wb
    await Timer(2, unit = 'ns') # wait for clock stability
    await RisingEdge(dut.clk) # wait for rising edge
    await RisingEdge(dut.clk)
    await Timer(0.1, unit = 'ns') # wait for stability
    assert(out.value == 3), f'failed test_ex, expected output for wb is 3 but got {out.value} instead'
    