import os
from pathlib import Path
from cocotb_tools.runner import get_runner

# hook up of cocotb test bench into test runner, for running cocotb simulation tests
# please follow pre-existing example code already that was already commited to wire up your verilog sources into the project

def test_add_runner():
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sources = [proj_path/"rtl"/"src"/"execute.v", proj_path/"rtl"/"src"/"instruction_decode.v", proj_path/"rtl"/"src"/"instruction_fetch.v", proj_path/"rtl"/"top.v"]
    runner = get_runner(sim)
    runner.build(
        sources = sources,
        hdl_toplevel= "top_module",
        build_args = ["--coverage"] if sim == "verilator" else [],
        waves = True
    )
    runner.test(hdl_toplevel="top_module", test_module = ["test_add", "test_r_type"], waves = True)

if __name__ == "__main__":
    test_add_runner()